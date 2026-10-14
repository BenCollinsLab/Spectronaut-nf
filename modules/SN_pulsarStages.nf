// SN_pulsarStages.nf

process PULSAR_1_LIB {

    label 'SN_nf_pulsar'
	// Use publishDir to save the output to the out_lib directory
	publishDir "${params.intermediate_psar}", mode: 'copy'

    input:
    val SPEC_BIN               // First input: path to Spectronaut binary
    val LICENSE                // Second input: license key
    path FASTA
    val rawfile               // Third input: One rawfile from the raw_d folder
    val PROP_DIA
    val pulsarStep

    output:
    tuple val(rawfile), path("${rawfile.getBaseName()}.psar"), emit: psar_with_raw

    // path "${rawfile.getBaseName()}.psar", emit: intermediate_psar // Emit the .psar file created for each rawfile

    // Define output and error logs using task variables
    // error = "logs/${task.process}.${task.id}.err"
    // output = "logs/${task.process}.${task.id}.out"

    script:
    """
        echo "Processing rawfile: ${rawfile}"

		dotnet ${SPEC_BIN} activate ${LICENSE}

        dotnet ${SPEC_BIN} lg -se Pulsar\
        -setTemp ${params.tmp_dir}\
       	-r ${rawfile}\
        -o ${params.intermediates_output}\
        -a ${rawfile.getBaseName()}\
        -n ${rawfile.getBaseName()}\
        -fasta "${FASTA}"\
		${params.PROP_SEARCH ? " -es ${params.PROP_SEARCH}" : ""}\
		${PROP_DIA ? "-rs ${PROP_DIA}" : ""}\
		--pulsarStage ${pulsarStep}
    """
}

process PULSAR_1_LIB_BATCH {

    label 'SN_nf_pulsar'
    // Use publishDir to save the intermediate output to the intermediates directory
    publishDir "${params.intermediate_psar}", mode: 'copy', pattern: '*.psar'

    input:
    val SPEC_BIN               // First input: path to Spectronaut binary
    val LICENSE                // Second input: license key
    path FASTA
    path rawfiles               // Third input: One rawfile from the raw_d folder
    val PROP_DIA
    val pulsarStep

    output:
    tuple path(rawfiles), path("${task.index}.psar"), emit: psar_with_raw

    // path "${task.index}.psar", emit: intermediate_psar // Emit the intermediate .psar file created for each rawfile

    script:
    """
		echo "Processing rawfile: ${rawfiles}"
		echo "Spectronaut: ${SPEC_BIN}"
		echo "FASTA: ${FASTA}"

		dotnet "${SPEC_BIN}" activate "${LICENSE}"

        dotnet ${SPEC_BIN} lg -se Pulsar\
        -setTemp ${params.tmp_dir}\
        ${rawfiles.collect { "-r ${it}" }.join(' ')}\
        -o ${params.intermediates_output}\
        -a ${task.index}\
		-n ${task.index}\
        -fasta "${FASTA}"\
		${params.PROP_SEARCH ? " -es ${params.PROP_SEARCH}" : ""}\
        ${PROP_DIA ? "-rs ${PROP_DIA}" : ""}\
		--pulsarStage ${pulsarStep}

        echo "Nextflow Task ID: ${task.index}"
    """
}

process GENERATE_QSP{

    label 'SN_nf_combine_psar'
	publishDir "${params.intermediates_output}", mode: 'copy', pattern: '*.qsp'

    input:
    val SPEC_BIN               // First input: path to Spectronaut binary
    val LICENSE                // Second input: license key
    val FASTA
    path intermediates_output
    val PROP_DIA
    val pulsarStep

    output:
    path "${params.JOB_NAME}.qsp", emit: qsp_file

    script:
    """
        dotnet ${SPEC_BIN} activate ${LICENSE}

        dotnet ${SPEC_BIN} lg -se Pulsar\
        -setTemp ${params.tmp_dir}\
        -sad ${params.intermediate_psar}\
        -k ${params.JOB_NAME}\
        -o .\
		--noOutputSubfolder\
        -n ${params.JOB_NAME}\
        -fasta ${FASTA}\
        ${PROP_DIA ? "-rs ${PROP_DIA}" : ""}\
        --pulsarStage ${pulsarStep}
    """

}

process PULSAR_3_LIB {

    label 'SN_nf_pulsar'
    // Use publishDir to save the output to the out_lib directory
    publishDir "${params.intermediate_psar}", mode: 'copy'

    input:
    val SPEC_BIN               // First input: path to Spectronaut binary
    val LICENSE                // Second input: license key
    path FASTA
    val PROP_DIA
    val pulsarStep
    tuple path(rawfile), path(psar_file), path(qsp_file)

    output:
    tuple path(rawfile), path("${rawfile.getBaseName()}.psar"), emit: psar_with_raw

    // path "${rawfile.getBaseName()}.psar", emit: intermediate_psar // Emit the .psar file created for each rawfile

    // Define output and error logs using task variables
    // error = "logs/${task.process}.${task.id}.err"
    // output = "logs/${task.process}.${task.id}.out"

    script:
    """
        echo "Processing rawfile: ${rawfile}"

        dotnet ${SPEC_BIN} activate ${LICENSE}

        dotnet ${SPEC_BIN} lg -se Pulsar\
        -setTemp ${params.tmp_dir}\
        -r ${params.rawfile_dir}/${rawfile}\
		-sa ${params.psar_file}\
        -o ${params.intermediates_output}\
        -a ${params.psar_file}\
        -n ${rawfile.getBaseName()}\
        -fasta ${FASTA}\
        ${params.PROP_SEARCH ? " -es ${params.PROP_SEARCH}" : ""}\
        ${PROP_DIA ? "-rs ${PROP_DIA}" : ""}\
		--optimizedModels ${params.intermediates_output}/${qsp_file}\
        --pulsarStage ${pulsarStep}
    """
}

process PULSAR_3_LIB_BATCH {

    label 'SN_nf_pulsar'
    publishDir "${params.intermediate_psar}", mode: 'copy'

    input:
    val SPEC_BIN
    val LICENSE
    path FASTA
    val PROP_DIA
    val pulsarStep

    // path rawfiles
    tuple path(rawfiles), path(psar_file), path(qsp_file)

    output:
    path "${task.index}.psar", emit: intermediate_psar

    script:
    """
        echo "Spectronaut: ${SPEC_BIN}"
        echo "License: ${LICENSE}"
        echo "FASTA: ${FASTA}"
	echo "Rawfiles: ${rawfiles}"
        echo "PSAR: ${psar_file}"
	echo "QSP: ${qsp_file}"

        dotnet "${SPEC_BIN}" activate ${LICENSE}

        dotnet "${SPEC_BIN}" lg -se Pulsar\
        -setTemp "${params.tmp_dir}"\
        ${rawfiles.collect { "-r \"${params.rawfile_dir}/${it}\"" }.join(' ')}\
        -sa "${psar_file}"\
        -o "${params.intermediates_output}"\
        -a ${task.index}\
        -n ${task.index}\
        -fasta "${FASTA}"\
        ${params.PROP_SEARCH ? " -es ${params.PROP_SEARCH}" : ""}\
        ${PROP_DIA ? "-rs ${PROP_DIA}" : ""}\
        --optimizedModels "${qsp_file}"\
        --pulsarStage ${pulsarStep}

        echo "Nextflow Task ID: ${task.index}"

    """

}
