// merge_sne.nf

process MERGE_SNE {
	
	label 'SN_nf_combine_sne'
	
	input:
	val SPEC_BIN               // First input: path to Spectronaut binary
	val LICENSE                // Second input: license key
	path sne_files
	val PROP_DIA
	val REPORT
	val COND_SETUP

	script:
	"""
        set -euxo pipefail

        echo "Nextflow working directory: \$PWD"
        echo "Input SNE files: ${sne_files}"

        mkdir -p sne_staging

        echo "Checking input SNE files:"
        ls -lh ${sne_files}

        echo "Copying SNE files to DIA output directory..."

        cp -v ${sne_files} sne_staging/
	
	dotnet ${SPEC_BIN} activate ${LICENSE}

	dotnet ${SPEC_BIN} manageSNE --merge -setTemp ${params.tmp_dir} \
	-d sne_staging \
	-o ${params.dia_output} \
	-n ${params.JOB_NAME} \
	${params.PROP_SEARCH ?: ''}\
	${COND_SETUP ? "-con ${COND_SETUP}" : ""}\
	${REPORT ? "-rs ${REPORT}" : ""}\
	${PROP_DIA ? "-s ${PROP_DIA}" : ""}

	"""
}
