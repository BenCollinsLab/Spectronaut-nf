// SN_pulsar.nf

//checking if libraries dir exists
def libs_dir = new File("${params.psar_lib}")
if (!libs_dir.exists()) {
        libs_dir.mkdirs()
        }

process WORKFLOW_LIB {

    jobName = 'SN19_nf_lib'
    errorStrategy 'retry'

    module 'dotnet/6.0.16'

    input:
    val SPEC_BIN               // First input: path to Spectronaut binary
    val LICENSE                // Second input: license key
    path rawfile               // Third input: One rawfile from the raw_d folder

    output:
    path out, emit: output     // Output directory for each rawfile

    // Define output and error logs using task variables
    // error = "logs/${task.process}.${task.id}.err"
    // output = "logs/${task.process}.${task.id}.out"

    script:
    """
        echo "Processing rawfile: ${rawfile}"

        dotnet ${SPEC_BIN} -activate ${LICENSE}
        dotnet ${SPEC_BIN} lg -se Pulsar\
        -setTemp ${params.tmp_dir}\
        -r ${params.baseDir}/raw_d/${rawfile}\
        -o ${params.output_dir}\
        -a ${params.psar_lib}/${rawfile.getBaseName()}\
        -n ${rawfile.getBaseName()}\
        -fasta ${params.FASTA}\
        ${params.EXT_PSAR ?: ''}\
        ${params.PROP_SEARCH ?: ''}\
        ${params.PROP_LIB ?: ''}

        dotnet ${SPEC_BIN} -deactivate
    """
}
