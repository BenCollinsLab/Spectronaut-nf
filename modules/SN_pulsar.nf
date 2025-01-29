// SN_pulsar.nf

//checking if libraries dir exists
def libs_dir = new File("${params.psar_lib}")
if (!libs_dir.exists()) {
        libs_dir.mkdirs()
        }

process WORKFLOW_LIB {

    label 'SN19_nf_lib'

    // module 'dotnet/6.0.16'

    input:
    val SPEC_BIN               // First input: path to Spectronaut binary
    val LICENSE                // Second input: license key
    path rawfiles               // Third input: One rawfile from the raw_d folder

    output:
    path "${rawfile.getBaseName()}.psar", emit: psar_lib // Emit the .psar file created for each rawfile

    // Use publishDir to save the output to the out_lib directory
    publishDir "${params.psar_lib}", mode: 'copy'

    // Define output and error logs using task variables
    // error = "logs/${task.process}.${task.id}.err"
    // output = "logs/${task.process}.${task.id}.out"

    script:
    """
        echo "Processing rawfile: ${rawfiles}"

        dotnet ${SPEC_BIN} lg -se Pulsar\
        -setTemp ${params.tmp_dir}\
       	-r ${params.baseDir}/raw_d/${rawfile}\
        -o ${params.lib_output}\
        -a ${rawfile.getBaseName()}\
        -n ${rawfile.getBaseName()}\
        -fasta ${params.FASTA}\
        ${params.EXT_PSAR ?: ''}\
        ${params.PROP_SEARCH ?: ''}\
        ${params.PROP_LIB ?: ''}
	
    """
}

process WORKFLOW_LIB_BATCH {

    label 'SN19_nf_lib'

    // module 'dotnet/6.0.16'

    input:
    val SPEC_BIN               // First input: path to Spectronaut binary
    val LICENSE                // Second input: license key
    path rawfiles               // Third input: One rawfile from the raw_d folder

    output:
    path "${task.index}.psar", emit: psar_lib // Emit the .psar file created for each rawfile

    // Use publishDir to save the output to the out_lib directory
    publishDir "${params.psar_lib}", mode: 'copy'

    // Define output and error logs using task variables
    // error = "logs/${task.process}.${task.id}.err"
    // output = "logs/${task.process}.${task.id}.out"

    script:
    """
        echo "Processing rawfile: ${rawfiles}"

        dotnet ${SPEC_BIN} lg -se Pulsar\
        -setTemp ${params.tmp_dir}\
        ${rawfiles.collect { "-r ${params.baseDir}/raw_d/${it}" }.join(' ')}\
        -o ${params.lib_output}\
        -a ${task.index}\
        -n ${rawfiles.collect { it.getBaseName()}.join('_')}\
        -fasta ${params.FASTA}\
        ${params.EXT_PSAR ?: ''}\
        ${params.PROP_SEARCH ?: ''}\
        ${params.PROP_LIB ?: ''}

        echo "Nextflow Task ID: ${task.index}"
    """
}
