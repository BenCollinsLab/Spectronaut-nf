#!/usr/bin/env nextflow

include { COMBINE_PSAR	} from './modules/combine_psar.nf'
include { WORKFLOW_LIB	} from './modules/SN_pulsar.nf'
include { WORKFLOW_DIA	} from './modules/SN_dia.nf'
include { COMBINE_SNE	} from './modules/combine_sne.nf'

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

    // Load .d rawfiles from the directory
    rawfiles = Channel.fromPath("${params.rawfile_dir}/*.d", type: 'dir', checkIfExists: true)
               .ifEmpty { error "Cannot find any Bruker rawfile on ${params.rawfile_dir}"}.map { it.toString() }

    // Static parameter channels
    spec_bin_channel = Channel.value(params.spec_bin)
    license_channel = Channel.value(params.license)

    // Process each raw file in parallel, with a maximum of 6 concurrent processes
    rawfiles.take(6).set { rawfile_mapped }  // Set mapped raw files
    
    rawfiles.subscribe { println "Mapped rawfile: $it"}

    // WORKFLOW_LIB(spec_bin_channel, license_channel, rawfile_mapped)

    // COMBINE_PSAR(spec_bin_channel, license_channel, params.psar_lib)

    // WORKFLOW_DIA(spec_bin_channel, license_channel, rawfile_mapped)

    // snefiles = Channel.fromPath("${params.dia_output}/*.sne", type: 'file', checkIfExists: true)
    //           .ifEmpty { error "Cannot find any Spectronaut SNE files on ${params.dia_output}"}.map { it.toString() }

    // snefiles.subscribe { println "Found SNE file: $it"}

    // snefiles.collect().set { snefile_mapped }  // Set mapped SNE files

    // COMBINE_SNE(spec_bin_channel, license_channel, params.dia_output)

    // Step 1: WORKFLOW_LIB
    WORKFLOW_LIB(spec_bin_channel, license_channel, rawfile_mapped)
        .set { lib_output }

    // Step 2: COMBINE_PSAR
    lib_output
        .flatMap { COMBINE_PSAR(spec_bin_channel, license_channel, params.psar_lib) }
        .set { psar_output }

    // Step 3: WORKFLOW_DIA
    psar_output
        .flatMap { WORKFLOW_DIA(spec_bin_channel, license_channel, rawfile_mapped) }
        .set { dia_output }

    // Step 4: Handle SNE files after WORKFLOW_DIA
    dia_output
        .flatMap { Channel.fromPath("${params.dia_output}/*.sne", type: 'file', checkIfExists: true) }
        .ifEmpty { error "Cannot find any Spectronaut SNE files on ${params.dia_output}" }
        .map { it.toString() }
        .set { snefile_mapped }

    snefile_mapped
        .subscribe { println "Found SNE file: $it" }

    // Step 5: COMBINE_SNE
    snefile_mapped
        .flatMap { COMBINE_SNE(spec_bin_channel, license_channel, params.dia_output) }

}

