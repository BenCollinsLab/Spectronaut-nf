#!/usr/bin/env nextflow

include { COMBINE_PSAR	} from './modules/combine_psar.nf'
include { WORKFLOW_LIB	} from './modules/SN_pulsar.nf'
include { WORKFLOW_LIB_BATCH } from './modules/SN_pulsar.nf'
include { WORKFLOW_DIA	} from './modules/SN_dia.nf'
include { WORKFLOW_DIA_BATCH } from './modules/SN_dia.nf'
include { COMBINE_SNE_REPORT	} from './modules/combine_sne.nf'
include { COMBINE_SNE	} from './modules/combine_sne.nf'
include { MERGE_SNE	} from './modules/merge_sne.nf'
include { MERGE_SNE_REPORT_COND } from './modules/merge_sne.nf'
include { MERGE_SNE_REPORT } from './modules/merge_sne.nf'
include { MERGE_SNE_COND } from './modules/merge_sne.nf'
include { SAMPLING_RAWFILES  } from './modules/rawfile_sampling.nf'

//checking if logs dir exists
//def logs_dir = new File("${params.log_dir}")
//if (!logs_dir.exists()) {
//        logs_dir.mkdirs()
//        }

//checking if output dir exists
def out_dir = new File("${params.lib_output}")
if (!out_dir.exists()) {
        out_dir.mkdirs()
	}

//checking if temporary dir exists
def tmp_dir = new File("${params.tmp_dir}")
if (!tmp_dir.exists()) {
        tmp_dir.mkdirs()
	}

workflow {

	log.info "Pipeline Name: ${workflow.manifest.name}"
	log.info "Author: ${workflow.manifest.author}"
	log.info "Description: ${workflow.manifest.description}"
	log.info "HomePage: ${workflow.manifest.homePage}"
	log.info "Main Script: ${workflow.manifest.mainScript}"
	log.info "Nextflow Version Required: ${workflow.manifest.nextflowVersion}"
	log.info "Pipeline Version: ${workflow.manifest.version}"
	
	if (params.sample_size) {
		log.info "INFO: Executing random sampling"
		sampled_tsv = SAMPLING_RAWFILES(params.rawfile_dir, params.sample_size, 0)
		
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
					.ifEmpty { error "Cannot find any Bruker rawfile in ${params.rawfile_dir}" }
					.map { it.toString() }
	
		rawfiles_for_lib.count().subscribe { println "Found $it raw files in ${params.rawfile_dir}" }
	}

	// Static parameter channels
	Spectronaut = Channel.value(params.spec_bin)
	SN_license = Channel.value(params.license)
	
	// Process each raw file in parallel
	
	def batchSize = params.batch_size ? params.batch_size.toInteger() : 1
	
	println "Batch size: ${batchSize}"

	if (batchSize > 1) {
		rawfiles_for_lib
		.buffer(size: batchSize, remainder: true) // Group into batches of user-defined size
		.ifEmpty { error "No batches were produced. Check the rawfile count." }
		.set { rawfile_batches }
		log.info "Processing raw files in batches of ${params.batch_size}"
		rawfile_batches.subscribe { println "Processing batch: $it" }
		lib_output = WORKFLOW_LIB_BATCH(Spectronaut, SN_license, rawfile_batches)

	} else {
		rawfiles_for_lib
		.map { [it] }  // Process one file at a time (wrap in list)
		.set { rawfile_mapped }
		log.info "Processing raw files individually (batch size = 1)"
		rawfile_mapped.subscribe { println "Processing Mapped rawfile: $it" }
		lib_output = WORKFLOW_LIB(Spectronaut, SN_license, rawfile_mapped)
	}

	rawfile_dir = Channel.value(params.rawfile_dir)
	sample_size = Channel.value(params.sample_size)
	
	// lib_output = WORKFLOW_LIB(Spectronaut, SN_license, rawfile_batches)
	kit_file = COMBINE_PSAR(Spectronaut, SN_license, lib_output.collect())
	
	rawfiles_for_dia = Channel.fromPath("${params.rawfile_dir}/*.{d,raw,RAW,wiff,mzML}", type: 'any', checkIfExists: true, glob: true)
		.ifEmpty { error "Cannot find any Bruker rawfile on ${params.rawfile_dir}"}.map { it.toString() }
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
                filtered_rawfiles
                .buffer(size: batchSize_dia, remainder: true) // Group into batches of user-defined size
                .ifEmpty { error "No batches were produced. Check the rawfile count." }
                .set { rawfile_batches_dia }
                log.info "Processing raw files in batches of ${batchSize_dia}"
                rawfile_batches_dia.subscribe { println "Processing a batch of $it for DIA search" }
                dia_output = WORKFLOW_DIA_BATCH(Spectronaut, SN_license, kit_file.collect(), rawfile_batches_dia)

        } else {
                log.info "Processing raw files individually (batch size = 1)"
                filtered_rawfiles.subscribe { println "Processing Mapped rawfile: $it for DIA search" }
                dia_output = WORKFLOW_DIA(Spectronaut, SN_license, kit_file.collect(), filtered_rawfiles)
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

	if (fileCount > 150 && params.REPORT) {
		log.info "INFO: SNE files will be subjected to COMBINE SNE with Report schema input as there are more than ${fileCount} raw files"
		COMBINE_SNE_REPORT(Spectronaut, SN_license, merged_input)
	} else if (fileCount > 150) {
		log.info "INFO: SNE files will be subjected to COMBINE SNE as there are more than ${params.rawfile_count} raw files"
		COMBINE_SNE(Spectronaut, SN_license, merged_input)
	
        } else if (params.REPORT && params.COND_SETUP) {
		log.info "INFO: Executing merge SNEs with Condition and Report schema inputs"
		MERGE_SNE_REPORT_COND(Spectronaut, SN_license, merged_input)
	} else if (params.REPORT) {
		log.info "INFO: Executing merge SNEs with Report schema input"
		MERGE_SNE_REPORT(Spectronaut, SN_license, merged_input)
	} else if (params.COND_SETUP) {
		log.info "INFO: Executing merge SNEs with Conditions input"
		MERGE_SNE_COND(Spectronaut, SN_license, merged_input)
	} else {
		log.info "INFO: Executing merge SNEs without any Conditions or Report schema inputs"
		MERGE_SNE(Spectronaut, SN_license, merged_input)
	}
}

