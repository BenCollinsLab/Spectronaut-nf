// copy_psar.nf

process COPY_PSAR{

    input:
    path tmp_lib
    path psar_lib

    output:

    script:
    """
    mv $tmp_lib/*.psar ${params.psar_lib}
    """

}
