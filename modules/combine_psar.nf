// combine_psar.nf

process COMBINE_PSAR{

    label 'SN_nf_combine_psar'
    container = null  // always run Spectronaut outside container

    input:
    val SPEC_BIN               // First input: path to Spectronaut binary
    val LICENSE                // Second input: license key
    val FASTA
    path lib_output            //
    val EXT_PSAR
    val PROP_DIA

    output:
    path "${params.JOB_NAME}.kit", emit: psar_lib
    
    publishDir "${params.psar_lib}", mode: 'copy'

    script:
    """
	dotnet ${SPEC_BIN} -activate ${LICENSE}

	dotnet ${SPEC_BIN} lg -se Pulsar\
        -setTemp ${params.tmp_dir}\
	-sad ${params.intermediate_psar}\
	-k ${params.JOB_NAME}\
        -o ${params.lib_output}\
        -n ${params.JOB_NAME}\
        -fasta ${FASTA}\
        ${EXT_PSAR ? " -sa ${EXT_PSAR}" : ""}\
        ${params.PROP_SEARCH ? " -es ${params.PROP_SEARCH}" : ""}\
        ${PROP_DIA ? "-rs ${PROP_DIA}" : ""}
    """

}
