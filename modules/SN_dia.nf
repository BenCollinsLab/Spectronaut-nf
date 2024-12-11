// SN_dia.nf

//checking if libraries dir exists
def dia_dir = new File("${params.dia_output}")
if (!dia_dir.exists()) {
        dia_dir.mkdirs()
        }

process WORKFLOW_DIA {
	
	label 'SN19_nf_dia_search'
	
	module 'dotnet/6.0.16'
	
	input:
	val SPEC_BIN               // First input: path to Spectronaut binary
	val LICENSE                // Second input: license key
	path psar_lib
	path rawfile               // Third input: One rawfile from the raw_d folder
	
	output:
	path "${params.JOB}.kit", emit: kit_file    // Output directory for each rawfile
	
	// publishDir "${params.dia_output}", mode: 'copy'
	
    	script:
	"""
	
	sleep \$((RANDOM:0:60))

	dotnet ${SPEC_BIN} diaanalysis -setTemp ${params.tmp_dir} -r ${params.baseDir}/raw_d/${rawfile} -o ${params.dia_output}	-a ${params.LIB_IN}\
	-n ${rawfile.getBaseName()} -fasta ${params.FASTA} ${params.EXT_PSAR ?: ''} ${params.PROP_SEARCH ?: ''} ${params.PROP_LIB ?: ''}
	"""
}
