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
    // Create_dir() // Create out and tmp directories

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

    COMBINE_PSAR(spec_bin_channel, license_channel, params.psar_lib)
}

