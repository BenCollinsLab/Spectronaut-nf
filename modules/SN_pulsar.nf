// SN_pulsar.nf

//checking if libraries dir exists
def libs_dir = new File("${params.psar_lib}")
if (!libs_dir.exists()) {
        libs_dir.mkdirs()
        }

process WORKFLOW_LIB {

    label 'SN_nf_pulsar'
    container = null  // always run Spectronaut outside container

    // module 'dotnet/6.0.16'

    input:
    val SPEC_BIN               // First input: path to Spectronaut binary
    val LICENSE                // Second input: license key
    val FASTA
    path rawfile               // Third input: One rawfile from the raw_d folder
    val EXT_PSAR
    val PROP_DIA

    output:
    path "${rawfile.getBaseName()}.psar", emit: psar_lib // Emit the .psar file created for each rawfile

    // Use publishDir to save the output to the out_lib directory
    publishDir "${params.psar_lib}", mode: 'copy'

    // Define output and error logs using task variables
    // error = "logs/${task.process}.${task.id}.err"
    // output = "logs/${task.process}.${task.id}.out"

    script:
    """
        echo "Processing rawfile: ${rawfile}"
	
	dotnet ${SPEC_BIN} -activate ${LICENSE}

        dotnet ${SPEC_BIN} lg -se Pulsar\
        -setTemp ${params.tmp_dir}\
       	-r ${params.rawfile_dir}/${rawfile}\
        -o ${params.lib_output}\
        -a ${rawfile.getBaseName()}\
        -n ${rawfile.getBaseName()}\
        -fasta ${FASTA}\
	${EXT_PSAR ? " -sa ${EXT_PSAR}" : ""}\
	${params.PROP_SEARCH ? " -es ${params.PROP_SEARCH}" : ""}\
	${PROP_DIA ? "-rs ${PROP_DIA}" : ""}
	
    """
}

process WORKFLOW_LIB_BATCH {

    label 'SN_nf_pulsar'
    container = null  // always run Spectronaut outside container

    // module 'dotnet/6.0.16'

    input:
    val SPEC_BIN               // First input: path to Spectronaut binary
    val LICENSE                // Second input: license key
    val FASTA
    path rawfiles               // Third input: One rawfile from the raw_d folder
    val EXT_PSAR
    val PROP_DIA

    output:
    path "${task.index}.psar", emit: psar_lib // Emit the .psar file created for each rawfile

    // Use publishDir to save the output to the out_lib directory
    publishDir "${params.psar_lib}", mode: 'copy'

    // Define output and error logs using task variables
    // error = "logs/${task.process}.${task.id}.err"
    // output = "logs/${task.process}.${task.id}.out"
    // -n ${rawfiles.collect { it.getBaseName()}.join('_')}

    script:
    """
        echo "Processing rawfile: ${rawfiles}"
	
	dotnet ${SPEC_BIN} -activate ${LICENSE}	

        dotnet ${SPEC_BIN} lg -se Pulsar\
        -setTemp ${params.tmp_dir}\
        ${rawfiles.collect { "-r ${params.rawfile_dir}/${it}" }.join(' ')}\
        -o ${params.lib_output}\
        -a ${task.index}\
	-n ${task.index}\
        -fasta ${FASTA}\
	${EXT_PSAR ? " -sa ${EXT_PSAR}" : ""}\
	${params.PROP_SEARCH ? " -es ${params.PROP_SEARCH}" : ""}\
        ${PROP_DIA ? "-rs ${PROP_DIA}" : ""}

        echo "Nextflow Task ID: ${task.index}"
    """

}
