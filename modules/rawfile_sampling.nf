// rawfile_sampling.nf

sample_rfile = "${baseDir}/scripts/sampling_rawfiles.py"

process SAMPLING_RAWFILES {
	label 'random_sampling'
	
	module 'python3'
	
	input:
	val (rawfile_path) // First input: path to rawfile directory
	val (size)         // Second input: sample_size
	val (seed)         // Third input: random seed
	
	output:
	path "Rawfiles_for_library.tsv", emit: rawfiles_list
	
	publishDir "${params.rawfile_dir}", mode: 'copy'
	
	script:
	"""
	python ${sample_rfile} -rawfile_path ${rawfile_path} -sample_size ${size} -seed ${seed}
	"""
}
