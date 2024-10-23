// combine_sne.nf

process COMBINE_SNE{
	
	label 'SN19_nf_combine_sne'
	//errorStrategy 'retry'
	
	module 'dotnet/6.0.16'
	
	input:
	val SPEC_BIN               // First input: path to Spectronaut binary
	val LICENSE                // Second input: license key
	val "sne_files"

	// output:
	// path "${params.JOB}.sne", emit: merged_sne     // Output directory for each rawfile

	// publishDir "${params.dia_output}", mode: 'copy'

	script:
	"""
	cp -r ${params.dia_output}/*/*.sne ${params.dia_output}
	
	dotnet ${SPEC_BIN} manageSNE --merge -setTemp ${params.tmp_dir} -d ${params.dia_output} -o ${params.dia_output} -n ${params.JOB} ${params.PROP_SEARCH ?: ''}

	"""
	
}
