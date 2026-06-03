// merge_sne.nf

process MERGE_SNE {
	
	label 'SN_nf_combine_sne'
	container = null
	//errorStrategy 'retry'
	
	input:
	val SPEC_BIN               // First input: path to Spectronaut binary
	val LICENSE                // Second input: license key
	val sne_files
	val PROP_DIA
	val REPORT
	val COND_SETUP

	// output:
	// path "${params.JOB_NAME}"   // Output directory for each rawfile

	// publishDir "${params.dia_output}", mode: 'copy'
	// cp -r ${params.dia_output}/*/*.sne ${params.dia_output}
	script:
	"""
	
	dotnet ${SPEC_BIN} -activate ${LICENSE}

	dotnet ${SPEC_BIN} manageSNE --merge -setTemp ${params.tmp_dir} -d ${params.dia_output} -o ${params.dia_output} -n ${params.JOB_NAME} ${params.PROP_SEARCH ?: ''}\
	${COND_SETUP ? "-con ${COND_SETUP}" : ""} ${REPORT ? "-rs ${REPORT}" : ""} ${PROP_DIA ? "-s ${PROP_DIA}" : ""}

	"""
}
