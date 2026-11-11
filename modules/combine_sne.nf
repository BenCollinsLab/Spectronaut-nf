//combine_sne.nf

process COMBINE_SNE {

        label 'SN_nf_combine_sne'
	
        input:
        val SPEC_BIN               // First input: path to Spectronaut binary
        val LICENSE                // Second input: license key
	val FASTA
	path sne_files
	val PROP_DIA
        
        script:
        """
        set -euxo pipefail

        echo "Nextflow working directory: \$PWD"
        echo "Input SNE files: ${sne_files}"

        mkdir -p ${params.dia_output}

        echo "Checking input SNE files:"
        ls -lh ${sne_files}

        echo "Copying SNE files to DIA output directory..."

        cp -v ${sne_files} ${params.dia_output}/

        echo "Checking copied SNE files:"
        ls -lh ${params.dia_output}/*.sne

        dotnet ${SPEC_BIN} activate ${LICENSE}

        dotnet ${SPEC_BIN} combine -setTemp ${params.tmp_dir} \
	-d ${params.dia_output} \
	-o ${params.dia_output} \
	-n ${params.JOB_NAME} \
	-fasta ${FASTA} \
	 ${PROP_DIA ? "-s ${PROP_DIA}" : ""}

        """
}

process COMBINE_SNE_REPORT {

        label 'SN_nf_combine_sne'
	
        input:
        val SPEC_BIN               // First input: path to Spectronaut binary
        val LICENSE                // Second input: license key
	val FASTA
        path sne_files
	val REPORT
	val PROP_DIA

        script:
        """
	set -euxo pipefail

        echo "Nextflow working directory: \$PWD"
        echo "Input SNE files: ${sne_files}"

        mkdir -p ${params.dia_output}

        echo "Checking input SNE files:"
        ls -lh ${sne_files}

        echo "Copying SNE files to DIA output directory..."

        cp -v ${sne_files} ${params.dia_output}/

        echo "Checking copied SNE files:"
        ls -lh ${params.dia_output}/*.sne
	
        dotnet ${SPEC_BIN} activate ${LICENSE}

        dotnet ${SPEC_BIN} combine -setTemp ${params.tmp_dir} \
	-d ${params.dia_output} \
	-o ${params.dia_output} \
	-n ${params.JOB_NAME} \
	-fasta ${FASTA}\
	${PROP_DIA ? "-s ${PROP_DIA}" : ""} \
	-rs ${REPORT}

        """
}
