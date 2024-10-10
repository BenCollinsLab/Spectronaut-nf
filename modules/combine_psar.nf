// combine_psar.nf

// dotnet /users/3054755/bin/spectronaut/Spectronaut_19.1.240806.62635/binaries/Spectronaut/bin/SpectronautCMD.dll lg -se Pulsar -setTemp /mnt/scratch2/users/3058937/nextflow_setup/tmp -sad /mnt/scratch2/users/3058937/nextflow_setup/out/libs/ -fasta /mnt/scratch2/users/3058937/nextflow_setup/uniprot_sprot_2022-01-07_YEAST_HUMA_contam.bgsfasta -n /mnt/scratch2/users/3058937/nextflow_setup/241008_HY_MMC_HT_Nextflow -k /mnt/scratch2/users/3058937/nextflow_setup/241008_HY_MMC_HT_Nextflow.kit

process COMBINE_PSAR{

    label 'SN19_nf_combine_lib'
    errorStrategy 'retry'

    module 'dotnet/6.0.16'

    input:
    val SPEC_BIN               // First input: path to Spectronaut binary
    val LICENSE                // Second input: license key
    path psar_lib               // Third input: One rawfile from the raw_d folder

    output:
    path out, emit: output     // Output directory for each rawfile

    script:
    """
        dotnet ${SPEC_BIN} -activate ${LICENSE}
        
	dotnet ${SPEC_BIN} lg -se Pulsar\
        -setTemp ${params.tmp_dir}\
	-sad ${params.psar_lib}\
	-k ${params.psar_lib}/${params.JOB}\
        -o ${params.lib_output}\
        -n ${params.JOB}\
        -fasta ${params.FASTA}\
        ${params.EXT_PSAR ?: ''}\
        ${params.PROP_SEARCH ?: ''}\
        ${params.PROP_LIB ?: ''}

        dotnet ${SPEC_BIN} -deactivate
    """

}
