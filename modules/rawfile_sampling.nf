// rawfile_sampling.nf

process SAMPLING_RAWFILES {

	label 'random_sampling'

	publishDir "${params.rawfile_dir}", mode: 'copy'

	module 'python3'

	input:
	val rawfile_path // First input: path to rawfile directory
	val size         // Second input: sample_size
	val seed         // Third input: random seed
	path sample_rfile

	output:
	path "Rawfiles_for_library.tsv", emit: rawfiles_list

	script:
	"""
	python ${sample_rfile} -rawfile_path ${rawfile_path} -sample_size ${size} -seed ${seed}
	"""
}
