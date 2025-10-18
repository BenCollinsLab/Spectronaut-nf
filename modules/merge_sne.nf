// merge_sne.nf

process MERGE_SNE {
	
	label 'SN_nf_combine_sne'
	//errorStrategy 'retry'
	
	// module 'dotnet/6.0.16'
	
	input:
	val SPEC_BIN               // First input: path to Spectronaut binary
	val LICENSE                // Second input: license key
	val sne_files
	val PROP_DIA

	// output:
	// path "${params.JOB_NAME}"   // Output directory for each rawfile

	// publishDir "${params.dia_output}", mode: 'copy'
	// cp -r ${params.dia_output}/*/*.sne ${params.dia_output}
	script:
	"""
	
	dotnet ${SPEC_BIN} -activate ${LICENSE}

	dotnet ${SPEC_BIN} manageSNE --merge -setTemp ${params.tmp_dir} -d ${params.dia_output} -o ${params.dia_output} -n ${params.JOB_NAME} ${params.PROP_SEARCH ?: ''}\
	 ${PROP_DIA ? "-s ${PROP_DIA}" : ""}

	"""
}

process MERGE_SNE_REPORT_COND {

        label 'SN_nf_combine_sne'

        // module 'dotnet/6.0.16'

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

        dotnet ${SPEC_BIN} manageSNE --merge -setTemp ${params.tmp_dir} -d ${params.dia_output} -o ${params.dia_output} -n ${params.JOB_NAME} -rs ${REPORT} -con ${COND_SETUP}\
		${params.PROP_SEARCH ?: ''} ${PROP_DIA ? "-s ${PROP_DIA}" : ""}

        """
}

process MERGE_SNE_REPORT {
	
        label 'SN_nf_combine_sne'
	container = null  // always run Spectronaut outside container
	
        //errorStrategy 'retry'
	
        // module 'dotnet/6.0.16'
	
        input:
        val SPEC_BIN               // First input: path to Spectronaut binary
        val LICENSE                // Second input: license key
        val sne_files
	val PROP_DIA
	val REPORT
	
        // output:
        // path "${params.JOB_NAME}"   // Output directory for each rawfile

        // publishDir "${params.dia_output}", mode: 'copy'
        // cp -r ${params.dia_output}/*/*.sne ${params.dia_output}
        script:
        """
	dotnet ${SPEC_BIN} -activate ${LICENSE}
	
        dotnet ${SPEC_BIN} manageSNE --merge -setTemp ${params.tmp_dir} -d ${params.dia_output} -o ${params.dia_output} -n ${params.JOB_NAME} -rs ${REPORT}\
	 ${params.PROP_SEARCH ?: ''} ${PROP_DIA ? "-s ${PROP_DIA}" : ""}
	
        """
}

process MERGE_SNE_COND {
	
        label 'SN_nf_combine_sne'
	container = null  // always run Spectronaut outside container
	
        //errorStrategy 'retry'
	
        // module 'dotnet/6.0.16'
	
        input:
        val SPEC_BIN               // First input: path to Spectronaut binary
        val LICENSE                // Second input: license key
        val sne_files
	val PROP_DIA
	val COND_SETUP

        // output:
        // path "${params.JOB_NAME}"   // Output directory for each rawfile
	
        // publishDir "${params.dia_output}", mode: 'copy'
        // cp -r ${params.dia_output}/*/*.sne ${params.dia_output}
	
        script:
        """
	
	dotnet ${SPEC_BIN} -activate ${LICENSE}
	
        dotnet ${SPEC_BIN} manageSNE --merge -setTemp ${params.tmp_dir} -d ${params.dia_output} -o ${params.dia_output} -n ${params.JOB_NAME} -con ${COND_SETUP}\
	 ${params.PROP_SEARCH ?: ''} ${PROP_DIA ? "-s ${PROP_DIA}" : ""}
	
        """
}
