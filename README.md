# Spectronaut-nf
A [nextflow](https://www.nextflow.io/) pipeline to carry [Spectronaut](https://biognosys.com/software/spectronaut/) DIA analysis with its parallel execution attribute. Here, individual LC-MS/MS derived proteomic rawfiles are queued for [Spectronaut](https://biognosys.com/software/spectronaut/) search separately with the help of [nextflow](https://www.nextflow.io/docs/latest/reference/config.html#executor) parallel execution attribute and the results are combined in the end to form a experiment wide output. This increases the [Spectronaut](https://biognosys.com/software/spectronaut/) DIA analysis search speed owing to the use of multiple High Performance Computing (HPC) nodes with the help of batch schedulers (ex: SLURM).

### Spectronaut-nf workflow
![spectronaut_nextflow_workflow](https://github.com/user-attachments/assets/2a7344b3-1cfb-4d34-923a-147aa5b54e46)

## Download Spectronaut-nf
```
git clone https://github.com/BenCollinsLab/Spectronaut-nf
```

## Spectronaut-nf input parameters
Users can set most of the input parameters required to run the Spectronaut-nf pipeline in `params.yaml` file. This file can be edited using `vim` or `nano` editor in linux/HPC platform. In case of[...]

### DIA search inputs
![spectronaut-nf_nextflow config](https://github.com/user-attachments/assets/eaf80480-e46d-41aa-ab2c-091eed20efe7)

#### Required Parameters

Define or modify all DIA search related inputs in `params.yaml`:

* **JOB_NAME** - Unique identifier/name for your Spectronaut search job
* **spec_bin** - Absolute path to the Spectronaut command-line executable (SpectronautCMD.dll)
* **license** - Absolute path to your Spectronaut license file
* **rawfile_dir** - Directory path containing all input LC-MS/MS raw data files
* **FASTA** - Protein sequence database file in bgsfasta format for peptide identification
* **EXT_PSAR** - External Spectronaut result file (.psar) to use as input for DIA search

#### Optional Parameters

* **sample_size** - Number of raw files to randomly sample for library generation (if not specified, all files are used)
* **batch_size** - Number of raw files to group together for each library generation process. Default: 1 (individual files processed separately via Pulsar)
* **excludePattern** - Exclude raw files by name pattern (e.g., "pooled" will skip files containing "pooled")
* **COND_SETUP** - TSV file specifying experimental condition/sample grouping metadata
* **REPORT** - Spectronaut report template (.rs file) to customize output report columns and format
* **PROP_DIA** - Optional custom Spectronaut search parameters file (.prop) for advanced search configuration
* **max_files_for_ManageSNE** - Maximum number of SNE result files threshold for ManageSNE process execution. If total number of raw files exceeds this cutoff, the pipeline will execute CombineSNE process instead. Default: 150 (adjust based on available HPC/Cloud resources for large-scale SNE file merging)

### Process-specific Resource Allocation

The pipeline consists of four main processes, each with configurable HPC resource requirements. Adjust the CPU, memory, and time limits based on your HPC cluster capabilities and data size.

#### Pulsar Library Generation (`SN_nf_pulsar_*`)
- **SN_nf_pulsar_queue** - HPC queue name(s) for submitting Pulsar jobs
- **SN_nf_pulsar_cpus** - Number of CPU cores per Pulsar job
- **SN_nf_pulsar_memory** - RAM memory allocation per Pulsar job
- **SN_nf_pulsar_time** - Maximum wall-clock time for Pulsar job execution

#### PSAR Combination (`SN_nf_combine_psar_*`)
- **SN_nf_combine_psar_queue** - HPC queue name(s) for combining multiple PSAR library files
- **SN_nf_combine_psar_cpus** - Number of CPU cores per PSAR combination job
- **SN_nf_combine_psar_memory** - RAM memory allocation per PSAR combination job
- **SN_nf_combine_psar_time** - Maximum wall-clock time for PSAR combination job execution

#### DIA Search (`SN_nf_dia_search_*`)
- **SN_nf_dia_search_queue** - HPC queue name(s) for DIA search jobs
- **SN_nf_dia_search_cpus** - Number of CPU cores per DIA search job
- **SN_nf_dia_search_memory** - RAM memory allocation per DIA search job
- **SN_nf_dia_search_time** - Maximum wall-clock time for DIA search job execution

#### SNE Combination/Merging (`SN_nf_combine_sne_*`)
- **SN_nf_combine_sne_queue** - HPC queue name(s) for merging/combining SNE result files
- **SN_nf_combine_sne_cpus** - Number of CPU cores per SNE combination job
- **SN_nf_combine_sne_memory** - RAM memory allocation per SNE combination job
- **SN_nf_combine_sne_time** - Maximum wall-clock time for SNE combination job execution

#### Parallel Execution Control
- **executor_queueSize** - Maximum number of search jobs to execute in parallel on the HPC queue

### Batch scheduler and its parameters 
Set the batch scheduler used in your HPC platform inside `process`. 
```
executor = 'slurm'
```
This will be followed by setting up process-specific partition requirements such as CPUs, RAM and Duration available in the respective HPC partition.

## How to deploy the nextflow workflow directly to the HPC?
```
nextflow -bg run /path/to/main.nf -params-file /path/to/params.yaml >> nextflow_cmd.log
```
If the nextflow pipeline crashes/brakes inbetween, you can resume the searches with the help of `-resume` command.
