// combine_sne.nf

// dotnet /users/3054755/bin/spectronaut/Spectronaut_19.1.240806.62635/binaries/Spectronaut/bin/SpectronautCMD.dll manageSNE -f out_dia/20241009_121736_20230704_yeast_hela_matched_matrix_B_R3_50ng_Slot2-40_1_5652/20241009_121734_20230704_yeast_hela_matched_matrix_B_R3_50ng_Slot2-40_1_5652.sne -f out_dia/20241009_122216_20230704_yeast_hela_matched_matrix_C_R2_50ng_Slot2-39_1_5648/20241009_122214_20230704_yeast_hela_matched_matrix_C_R2_50ng_Slot2-39_1_5648.sne -o out_dia/ -n test --merge

process COMBINE_SNE{

    jobName = 'SN19_nf_combine_sne'
    errorStrategy 'retry'

    module 'dotnet/6.0.16'

    input:
    val SPEC_BIN               // First input: path to Spectronaut binary
    val LICENSE                // Second input: license key
    path dia_output                   // Third input: SNE files from all the result directories

    output:
    path out, emit: output     // Output directory for each rawfile

    script:
    """
       dotnet ${SPEC_BIN} -activate ${LICENSE}
        
       dotnet ${SPEC_BIN} manageSNE --merge\
       -setTemp ${params.tmp_dir}\
       -d ${params.dia_output}\
       -o ${params.dia_output}\
       -n ${params.JOB}\
       ${params.PROP_SEARCH ?: ''}

       dotnet ${SPEC_BIN} -deactivate
    """

}
