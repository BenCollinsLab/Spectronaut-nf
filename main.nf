#!/usr/bin/env nextflow

include { PULSAR_1_LIB } from './modules/SN_pulsarStages.nf'
include { PULSAR_1_LIB_BATCH } from './modules/SN_pulsarStages.nf'
include { GENERATE_QSP } from './modules/SN_pulsarStages.nf'
include { PULSAR_3_LIB } from './modules/SN_pulsarStages.nf'
include { PULSAR_3_LIB_BATCH } from './modules/SN_pulsarStages.nf'

include { COMBINE_PSAR	} from './modules/combine_psar.nf'
include { WORKFLOW_DIA	} from './modules/SN_dia.nf'
include { WORKFLOW_DIA_BATCH } from './modules/SN_dia.nf'
include { COMBINE_SNE_REPORT	} from './modules/combine_sne.nf'
include { COMBINE_SNE	} from './modules/combine_sne.nf'
include { MERGE_SNE	} from './modules/merge_sne.nf'
include { SAMPLING_RAWFILES  } from './modules/rawfile_sampling.nf'

// --- Normalize file-based params ---
def resolveFilePath(val) {
        if (!val) return null
        def f = file(val)
	return f.exists() ? f.toAbsolutePath().toString() : file("${launchDir}/${val}").toAbsolutePath().toString()
}

workflow {

	// ============================================================
	// Spectronaut execution mode
	// ============================================================
	
	def usingContainer = workflow.profile.contains('container')
	
	if (usingContainer && !params.image_path) {
	    exit 1, "ERROR: '-profile container' requires 'image_path' to be set."
	}
	
	if (!usingContainer && !params.spec_bin) {
	    exit 1, "ERROR: running without '-profile container' requires 'spec_bin' to be set."
	}

	// ============================================================
	// Spectronaut executable
	// ============================================================

	def spec_bin

	if (usingContainer) {

		// This path exists INSIDE the SIF
		spec_bin = params.spec_bin ?: '/usr/lib/spectronaut/SpectronautCMD.dll'

	} else {

		// This path exists on the HOST
		spec_bin = resolveFilePath(params.spec_bin)
	}

	println "Spectronaut executable: ${spec_bin}"

	// Create the log directory
	def logDir = new File(params.log_dir)
	if (!logDir.exists() && !logDir.mkdirs()) {
		error "Could not create log directory: ${params.log_dir}"
	}

	//check if intermediates directory exists
	def intermediates = new File("${params.intermediates_output}")
	if (!intermediates.exists()) {
			intermediates.mkdirs()
			}

	//checking if output dir exists
	def out_dir = new File("${params.lib_output}")
	if (!out_dir.exists()) {
			out_dir.mkdirs()
		}

        //checking if DIA output dir exists
        def dia_out = new File("${params.dia_output}")
        if (!dia_out.exists()) {
                        dia_out.mkdirs()
                }

	//checking if temporary dir exists
	def tmp_dir = new File("${params.tmp_dir}")
	if (!tmp_dir.exists()) {
			tmp_dir.mkdirs()
		}

	// Required
	def license = params.license?.toString()?.trim()

	if (!license) {
		error "License must be provided in params.yaml"
	}

	// If the supplied value points to an existing file, read the first line
	if (new File(license).exists()) {

		def licenseFile = new File(license)

		if (!licenseFile.isFile()) {
			error "License path exists but is not a file: ${license}"
		}

		license = licenseFile.readLines()[0]?.trim()

		if (!license) {
			error "License file is empty: ${licenseFile}"
		}

		println "License loaded from file: ${licenseFile}"

	} else {

		// Otherwise treat the supplied value as the license key itself
		println "License provided directly as a value"
	}

	def FASTA   = resolveFilePath(params.FASTA)
	RANDOM_SLEEP = Channel.value(file("${baseDir}/scripts/random_sleep.sh"))

	// Optional (normalize only if user defined something other than null)
	def EXT_PSAR    = (params.EXT_PSAR && !params.EXT_PSAR.contains("null")) ? resolveFilePath(params.EXT_PSAR) : ""
	def PROP_DIA    = (params.PROP_DIA && !params.PROP_DIA.contains("null")) ? resolveFilePath(params.PROP_DIA) : ""
	def COND_SETUP  = (params.COND_SETUP && !params.COND_SETUP.contains("null")) ? resolveFilePath(params.COND_SETUP) : ""
	def REPORT = (params.REPORT && !params.REPORT.contains("null")) ? resolveFilePath(params.REPORT) : ""

	log.info "Pipeline Name: ${workflow.manifest.name}"
	log.info "Author: ${workflow.manifest.author}"
	log.info "Description: ${workflow.manifest.description}"
	log.info "HomePage: ${workflow.manifest.homePage}"
	log.info "Main Script: ${workflow.manifest.mainScript}"
	log.info "Nextflow Version Required: ${workflow.manifest.nextflowVersion}"
	log.info "Pipeline Version: ${workflow.manifest.version}"
	
	if (params.sample_size) {
		log.info "INFO: Executing random sampling"
		sampled_tsv = SAMPLING_RAWFILES(
			params.rawfile_dir,
			params.sample_size,
			0,
			file("${baseDir}/scripts/sampling_rawfiles.py")
		)
		
		// When the TSV file is emitted, read and process it
		rawfiles_for_lib = sampled_tsv
				.map { it.toString() }
				.map { tsv_path ->
					println "[DEBUG] TSV path received: $tsv_path"
					return file(tsv_path).text
						.readLines()
						.collect { it.trim() }
						.findAll { it }
				}
				.flatten()
				.ifEmpty { error "TSV file exists but has no usable paths." }
		
		// Print the loaded paths
		rawfiles_for_lib.subscribe { println "Rawfile: $it" }
		
		// Count and print how many rawfiles were loaded
		rawfiles_for_lib.count().subscribe { println "Loaded $it raw files for processing" }
		
	} else {
		// Load .d and other rawfiles from the directory
		rawfiles_for_lib = Channel.fromPath("${params.rawfile_dir}/*.{d,raw,RAW,wiff,mzML}", type: 'any', checkIfExists: true, glob: true)
					.ifEmpty { error "No Bruker/raw/wiff/mzML files found in ${params.rawfile_dir}" }
					.map { it.toAbsolutePath().toString() }
	
		rawfiles_for_lib.count().subscribe { println "Found $it raw files in ${params.rawfile_dir}" }
	}

	// Static parameter channels
	Spectronaut = Channel.value(spec_bin)
	SN_license = Channel.value(license)
	
	// Process each raw file in parallel
	
	def batchSize = params.batch_size ? params.batch_size.toInteger() : 1
	
	println "Batch size: ${batchSize}"

	if (batchSize > 1) {
		rawfiles_for_lib
		.buffer(size: batchSize, remainder: true) // Group into batches of user-defined size
		.ifEmpty { error "No batches were produced. Check the rawfile count." }
		.set { rawfile_batches }
		log.info "Processing raw files in batches of ${params.batch_size} for PulsarStep1"
		rawfile_batches.subscribe { println "Processing batch: $it" }
		pulsarStep1_output = PULSAR_1_LIB_BATCH(Spectronaut, SN_license, FASTA, rawfile_batches, PROP_DIA ?: "", "pulsarStep1")
		rawf_mapped_psar = pulsarStep1_output.map{ rawfile, psar -> psar }

	} else {
		rawfiles_for_lib
		.set { rawfile_mapped }
		log.info "Processing raw files individually (batch size = 1) for PulsarStep1"
		rawfile_mapped.subscribe { println "Processing Mapped rawfile: $it" }
		pulsarStep1_output = PULSAR_1_LIB(Spectronaut, SN_license, FASTA, rawfile_mapped, PROP_DIA ?: "", "pulsarStep1")
		rawf_mapped_psar = pulsarStep1_output.map{ rawfile, psar -> psar }
	}

	rawfile_dir = Channel.value(params.rawfile_dir)
	sample_size = Channel.value(params.sample_size)
	
	qsp_file = GENERATE_QSP(Spectronaut, SN_license, FASTA, rawf_mapped_psar.collect(), PROP_DIA ?: "", "pulsarStep2")

	qsp_file.view { "QSP OUTPUT: $it" }

	pulsar3_input = pulsarStep1_output.combine(qsp_file).map { item -> tuple(item[0], item[1], item[2])}

	pulsar3_input.view { "PULSAR STEP3 INPUT: $it" }

	println "FASTA: ${FASTA}"

	pulsarStep3_output = PULSAR_3_LIB_BATCH(Spectronaut, SN_license, FASTA, PROP_DIA ?: "", "pulsarStep3", pulsar3_input)

	kit_file = COMBINE_PSAR(Spectronaut, SN_license, FASTA, pulsarStep3_output.collect(), EXT_PSAR ?: "", PROP_DIA ?: "")

	kit_file.view { "KIT OUTPUT: $it" }

	kit_file_value = kit_file.first()
	
	rawfiles_for_dia = Channel.fromPath("${params.rawfile_dir}/*.{d,raw,RAW,wiff,mzML}", type: 'any', checkIfExists: true, glob: true)
		.ifEmpty { error "Cannot find any Bruker rawfile on ${params.rawfile_dir}"}
	rawfiles_for_dia.set { rawfiles_for_dia_mapped }
	
	// Check if excludePattern is defined and filter rawfiles accordingly
	if (params.excludePattern) {
		log.info "Exclude pattern defined: '${params.excludePattern}'"
		filtered_rawfiles = rawfiles_for_dia.filter { !it.contains(params.excludePattern) }
		.ifEmpty 
		{ println "No rawfiles matched the exclude pattern. Using all rawfiles."
		return rawfiles_for_dia
		}
		// filtered_rawfiles.subscribe { println "Filtered rawfile: $it" }
	} else {
		log.info "Exclude pattern not defined. Considering all rawfiles."
		filtered_rawfiles = rawfiles_for_dia
	}
	
	
	if (batchSize > 1) {
		batchSize_dia = batchSize * 2
		rawfile_batches_dia = rawfiles_for_dia
			.filter { rawfile -> !params.excludePattern || !rawfile.toString().contains(params.excludePattern) }
			.buffer(size: batchSize_dia, remainder: true)

		rawfile_batches_dia.view { batch -> "DIA BATCH (${batch.size()} files): ${batch}"}
                
		log.info "Processing raw files in batches of ${batchSize_dia}"
                
                dia_output = WORKFLOW_DIA_BATCH(Spectronaut, SN_license, FASTA, kit_file_value, rawfile_batches_dia, EXT_PSAR ?: "", PROP_DIA ?: "", RANDOM_SLEEP)

        } else {
                log.info "Processing raw files individually (batch size = 1)"
                filtered_rawfiles.subscribe { println "Processing Mapped rawfile: $it for DIA search" }
                dia_output = WORKFLOW_DIA(Spectronaut, SN_license, FASTA, kit_file_value, filtered_rawfiles, EXT_PSAR ?: "", PROP_DIA ?: "", RANDOM_SLEEP)
        }
	
	
	dia_output.view { "DIA Output: $it" }
	
	merged_input = dia_output.collect()

	def rawDir = new File(params.rawfile_dir).getAbsoluteFile()
	def validExtensions = ['.raw', '.RAW', '.wiff', '.mzML']
	def fileCount = rawDir.listFiles()?.count { f ->
		(f.isFile() && validExtensions.any { f.name.endsWith(it) }) ||
		(f.isDirectory() && f.name.endsWith('.d'))
	} ?: 0
	
	println "Number of raw files: $fileCount"

	if (fileCount > params.max_files_for_ManageSNE && REPORT) {
		log.info "INFO: SNE files will be subjected to CombineSNE with Report schema input as there are more than ${params.max_files_for_ManageSNE} raw files"
		COMBINE_SNE_REPORT(Spectronaut, SN_license, FASTA, merged_input, PROP_DIA, REPORT)
	} else if (fileCount > params.max_files_for_ManageSNE) {
		log.info "INFO: SNE files will be subjected to CombineSNE as there are more than ${params.max_files_for_ManageSNE} raw files"
		COMBINE_SNE(Spectronaut, SN_license, FASTA, merged_input, PROP_DIA)
	
        } else {
		log.info "INFO: Executing ManageSNE to merge all SNEs to a single SNE file"
		MERGE_SNE(Spectronaut, SN_license, merged_input, PROP_DIA ?: "", REPORT ?: "", COND_SETUP ?: "")
	}
}

