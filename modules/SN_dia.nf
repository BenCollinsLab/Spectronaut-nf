// SN_dia.nf

process WORKFLOW_DIA {
	
	label 'SN_nf_dia_search'
	
	input:
	val SPEC_BIN               // First input: path to Spectronaut binary
	val LICENSE                // Second input: license key
	val FASTA
	path psar_lib
	path rawfile               // Third input: One rawfile from the raw_d folder
	val EXT_PSAR
	val PROP_DIA
	path random_sleep

	output:
	path "**/*.sne", emit: sne_file

    	script:
	"""
	bash "${random_sleep}"
	
	dotnet ${SPEC_BIN} activate ${LICENSE}	

	dotnet ${SPEC_BIN} diaanalysis -setTemp ${params.tmp_dir} -r ${params.rawfile_dir}/${rawfile}\
	-o . \
	-a ${params.LIB_IN}\
	-n ${rawfile.getBaseName()}\
	-fasta ${FASTA}\
	${EXT_PSAR ? "-sa ${EXT_PSAR}" : ""}\
	${PROP_DIA ? "-s ${PROP_DIA}" : ""}
	
	"""
}

process WORKFLOW_DIA_BATCH {
	
	label 'SN_nf_dia_search'
	
	input:
	val SPEC_BIN               // First input: path to Spectronaut binary
	val LICENSE                // Second input: license key
	val FASTA
	path psar_lib
	path rawfiles              // Third input: One rawfile from the raw_d folder
	val EXT_PSAR
	val PROP_DIA
	path random_sleep

	output:
	path "**/*.sne", emit: sne_file

	script:
	"""
	echo "Processing rawfiles: ${rawfiles}"
	
	bash "${random_sleep}"
	
	dotnet ${SPEC_BIN} activate ${LICENSE}
	
	dotnet ${SPEC_BIN} diaanalysis -setTemp ${params.tmp_dir}\
	${rawfiles.collect { "-r ${params.rawfile_dir}/${it}" }.join(' ')}\
	-o . \
	-a ${params.LIB_IN}\
	-n ${task.index}\
	-fasta ${FASTA}\
	${EXT_PSAR ? "-sa ${EXT_PSAR}" : ""}\
	${PROP_DIA ? "-s ${PROP_DIA}" : ""}
	
	echo "Nextflow Task ID: ${task.index}"

	"""
}
