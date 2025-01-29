#!/usr/bin/env nextflow

include { COMBINE_PSAR	} from './modules/combine_psar.nf'
include { WORKFLOW_LIB	} from './modules/SN_pulsar.nf'
include { WORKFLOW_LIB_BATCH } from './modules/SN_pulsar.nf'
include { WORKFLOW_DIA	} from './modules/SN_dia.nf'
include { COMBINE_SNE	} from './modules/combine_sne.nf'
include { COMBINE_SNE_REPORT_COND } from './modules/combine_sne.nf'
include { COMBINE_SNE_REPORT } from './modules/combine_sne.nf'
include { COMBINE_SNE_COND } from './modules/combine_sne.nf'
include { SAMPLING_RAWFILES  } from './modules/rawfile_sampling.nf'

//checking if logs dir exists
def logs_dir = new File("${params.log_dir}")
if (!logs_dir.exists()) {
        logs_dir.mkdirs()
        }

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
		SAMPLING_RAWFILES(params.rawfile_dir, params.sample_size, 0)
		
		// Ensure that the Rawfiles_for_library.tsv file exists before trying to read it
		def tsvFile = new File("${params.rawfile_dir}/Rawfiles_for_library.tsv")
		if (!tsvFile.exists()) {
			error "Rawfiles_for_library.tsv not found at ${params.rawfile_dir}"
		}

		// Load sampled rawfiles from Rawfiles_for_library.tsv
		rawfiles_for_lib = Channel
			.fromPath("${params.rawfile_dir}/Rawfiles_for_library.tsv", checkIfExists: true)
			.splitCsv(header: false, sep: '\n')  // Split the file by lines
			.map { it[0] }  // Extract the file path (the first column)
			.ifEmpty { error "Cannot find any rawfile paths in Rawfiles_for_library.tsv" }
		
		rawfiles_for_lib?.println { "Rawfile: $it" }
		
		// Validate the channel
		if (!rawfiles_for_lib) {
			error "Cannot find any Bruker rawfile in ${params.rawfile_dir}"
		}
		
		rawfiles_for_lib?.count()?.subscribe { println "Loaded $it raw files for processing" }
		
	} else {
		// Load .d rawfiles from the directory
		rawfiles_for_lib = Channel.fromPath("${params.rawfile_dir}/*.d", type: 'dir', checkIfExists: true)
               		.ifEmpty { error "Cannot find any Bruker rawfile on ${params.rawfile_dir}"}.map { it.toString() }
		
		// rawfile_count = Channel.of("${params.rawfile_dir}/*.d", type: 'dir', checkIfExists: true).count()
		
		// rawfile_count.subscribe { println "Found $it raw files in ${params.rawfile_dir}" }
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
	
	rawfiles_for_dia = Channel.fromPath("${params.rawfile_dir}/*.d", type: 'dir', checkIfExists: true)
		.ifEmpty { error "Cannot find any Bruker rawfile on ${params.rawfile_dir}"}.map { it.toString() }
	rawfiles_for_dia.set { rawfiles_for_dia_mapped }

	// Check if excludePattern is defined and filter rawfiles accordingly
	if (params.excludePattern) {
		log.info "Exclude pattern defined: '${params.excludePattern}'"
		filtered_rawfiles = rawfiles_for_dia.filter { !it.contains(params.excludePattern) }.ifEmpty {
			println "No rawfiles matched the exclude pattern. Using all rawfiles."
			rawfiles
		filtered_rawfiles.subscribe { println "Filtered rawfile: $it" }

		}
	} else {
		log.info "Exclude pattern not defined. Considering all rawfiles."
		filtered_rawfiles = rawfiles_for_dia
	}
	
	
	dia_output = WORKFLOW_DIA(Spectronaut, SN_license, kit_file.collect(), filtered_rawfiles)

	if (params.REPORT && params.COND_SETUP) {
		log.info "Executing Combining SNEs with Condition and Report schema inputs"
		single_sne = COMBINE_SNE_REPORT_COND(Spectronaut, dia_output.collect())	
	} else if (params.REPORT) {
		log.info "Executing Combining SNEs with Report schema input"
		single_sne = COMBINE_SNE_REPORT(Spectronaut, dia_output.collect())
	} else if (params.COND_SETUP) {
		log.info "Executing Combining SNEs with Conditions input"
		single_sne = COMBINE_SNE_COND(Spectronaut, dia_output.collect())
	} else {
		log.info "Executing Combining SNEs without any Conditions or Report schema inputs"
		single_sne = COMBINE_SNE(Spectronaut, dia_output.collect())
	}
}

