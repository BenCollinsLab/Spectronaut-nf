// SN_dia.nf

//checking if libraries dir exists
def dia_dir = new File("${params.dia_output}")
if (!dia_dir.exists()) {
        dia_dir.mkdirs()
        }

process WORKFLOW_DIA {
	
	label 'SN19_nf_dia_search'
	
	// module 'dotnet/6.0.16'
	
	input:
	val SPEC_BIN               // First input: path to Spectronaut binary
	val LICENSE                // Second input: license key
	path psar_lib
	path rawfile               // Third input: One rawfile from the raw_d folder
	
	output:
	path "${params.JOB}.kit", emit: kit_file    // Output directory for each rawfile
	
	// publishDir "${params.dia_output}", mode: 'copy'
	
	// sleep $(($RANDOM % 100))

    	script:
	"""
	bash ${baseDir}/scripts/random_sleep.sh
	
	dotnet ${SPEC_BIN} -activate ${LICENSE}	

	dotnet ${SPEC_BIN} diaanalysis -setTemp ${params.tmp_dir} -r ${params.rawfile_dir}/${rawfile}\
	-o ${params.dia_output}\
	-a ${params.LIB_IN}\
	-n ${rawfile.getBaseName()}\
	-fasta ${params.FASTA}\
	${params.EXT_PSAR ? "-sa ${params.EXT_PSAR}" : ""}\
	${params.PROP_DIA ? "-s ${params.PROP_DIA}" : ""}
	
	"""
}

process WORKFLOW_DIA_BATCH {
	label 'SN19_nf_dia_search'
	
	// module 'dotnet/6.0.16'
	input:
	val SPEC_BIN               // First input: path to Spectronaut binary
	val LICENSE                // Second input: license key
	path psar_lib
	path rawfiles              // Third input: One rawfile from the raw_d folder
	
	output:
	path "${params.JOB}.kit", emit: kit_file
	
	// Define output and error logs using task variables
	// error = "logs/${task.process}.${task.id}.err"
	// output = "logs/${task.process}.${task.id}.out"
	// -n ${rawfiles.collect { it.getBaseName()}.join('_')}
	script:
	"""
	echo "Processing rawfiles: ${rawfiles}"
	
	bash ${baseDir}/scripts/random_sleep.sh
	
	dotnet ${SPEC_BIN} -activate ${LICENSE}
	
	dotnet ${SPEC_BIN} diaanalysis -setTemp ${params.tmp_dir}\
	${rawfiles.collect { "-r ${params.rawfile_dir}/${it}" }.join(' ')}\
	-o ${params.dia_output}\
	-a ${params.LIB_IN}\
	-n ${task.index}\
	-fasta ${params.FASTA}\
	${params.EXT_PSAR ? "-sa ${params.EXT_PSAR}" : ""}\
	${params.PROP_DIA ? "-s ${params.PROP_DIA}" : ""}
	
	echo "Nextflow Task ID: ${task.index}"

	"""
}
