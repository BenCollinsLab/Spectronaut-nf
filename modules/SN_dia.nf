// SN_dia.nf

//checking if libraries dir exists
def dia_dir = new File("${params.dia_output}")
if (!dia_dir.exists()) {
        dia_dir.mkdirs()
        }

process WORKFLOW_DIA{

    jobName = 'SN19_nf_dia_search'
    errorStrategy 'retry'

    module 'dotnet/6.0.16'

    input:
    val SPEC_BIN               // First input: path to Spectronaut binary
    val LICENSE                // Second input: license key
    path rawfile               // Third input: One rawfile from the raw_d folder

    output:
    path out, emit: output     // Output directory for each rawfile

    script:
    """
        dotnet ${SPEC_BIN} -activate ${LICENSE}

        dotnet ${SPEC_BIN} diaanalysis\
        -setTemp ${params.tmp_dir}\
        -r ${params.baseDir}/raw_d/${rawfile}\
        -o ${params.dia_output}\
	-a ${params.LIB_IN}\
        -n ${rawfile.getBaseName()}\
        -fasta ${params.FASTA}\
        ${params.EXT_PSAR ?: ''}\
        ${params.PROP_SEARCH ?: ''}\
        ${params.PROP_LIB ?: ''}

        dotnet ${SPEC_BIN} -deactivate
    """
}
