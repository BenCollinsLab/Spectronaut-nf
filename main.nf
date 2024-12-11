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
	
	// rawfile_count = Channel.of("${params.rawfile_dir}/*.d", type: 'dir', checkIfExists: true).count()
	
	// rawfile_count.subscribe { println "Found $it raw files in ${params.rawfile_dir}" }
	
	// Static parameter channels
	Spectronaut = Channel.value(params.spec_bin)
	SN_license = Channel.value(params.license)
	
	// Process each raw file in parallel, with a maximum of 6 concurrent processes
	rawfiles.set { rawfile_mapped }  // Set mapped raw files
	
	rawfiles.subscribe { println "Mapped rawfile: $it"}
	
	lib_output = WORKFLOW_LIB(Spectronaut, SN_license, rawfile_mapped)
	kit_file = COMBINE_PSAR(Spectronaut, SN_license, lib_output.collect())
	dia_output = WORKFLOW_DIA(Spectronaut, SN_license, kit_file.collect(), rawfile_mapped)
	single_sne = COMBINE_SNE(Spectronaut, dia_output.collect())

}

