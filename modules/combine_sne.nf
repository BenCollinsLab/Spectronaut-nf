//combine_sne.nf

process COMBINE_SNE {

        label 'SN_nf_combine_sne'
	container = null  // always run Spectronaut outside container

        input:
        val SPEC_BIN               // First input: path to Spectronaut binary
        val LICENSE                // Second input: license key
	val FASTA
	val sne_files
	val PROP_DIA

        // output:
        // path "${params.JOB_NAME}"   // Output directory for each rawfile
        
        script:
        """
	cp -rf ${params.dia_output}/*/*.sne ${params.dia_output}

        dotnet ${SPEC_BIN} -activate ${LICENSE}

        dotnet ${SPEC_BIN} combine -setTemp ${params.tmp_dir} -d ${params.dia_output} -o ${params.dia_output} -n ${params.JOB_NAME} -fasta ${FASTA}\
	 ${PROP_DIA ? "-s ${PROP_DIA}" : ""}

        """
}

process COMBINE_SNE_REPORT {

        label 'SN_nf_combine_sne'
	container = null  // always run Spectronaut outside container

        input:
        val SPEC_BIN               // First input: path to Spectronaut binary
        val LICENSE                // Second input: license key
	val FASTA
        val sne_files
	val REPORT
	val PROP_DIA

        // output:
        // path "${params.JOB_NAME}"   // Output directory for each rawfile

        script:
        """
	cp -rf ${params.dia_output}/*/*.sne ${params.dia_output}
	
        dotnet ${SPEC_BIN} -activate ${LICENSE}

        dotnet ${SPEC_BIN} combine -setTemp ${params.tmp_dir} -d ${params.dia_output} -o ${params.dia_output} -n ${params.JOB_NAME} -fasta ${FASTA}\
	 ${PROP_DIA ? "-s ${PROP_DIA}" : ""} -rs ${REPORT}

        """

}
