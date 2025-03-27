// combine_psar.nf

process COMBINE_PSAR{

    label 'SN19_nf_combine_lib'

    // module 'dotnet/6.0.16'

    input:
    val SPEC_BIN               // First input: path to Spectronaut binary
    val LICENSE                // Second input: license key
    path lib_output            //

    output:
    path "${params.JOB}.kit", emit: psar_lib
    
    publishDir "${params.psar_lib}", mode: 'copy'

    script:
    """
	dotnet ${SPEC_BIN} -activate ${LICENSE}

	dotnet ${SPEC_BIN} lg -se Pulsar\
        -setTemp ${params.tmp_dir}\
	-sad ${params.psar_lib}\
	-k ${params.JOB}\
        -o ${params.lib_output}\
        -n ${params.JOB}\
        -fasta ${params.FASTA}\
        ${params.EXT_PSAR ?: ''}\
        ${params.PROP_SEARCH ?: ''}\
        ${params.PROP_DIA ? "-rs ${params.PROP_DIA}" : ""}
    """

}
