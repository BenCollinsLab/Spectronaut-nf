# Spectronaut-nf
A [nextflow](https://www.nextflow.io/) pipeline to carry [Spectronaut](https://biognosys.com/software/spectronaut/) DIA analysis with its parallel execution attribute. Here, individual LC-MS/MS derived proteomic rawfiles are queued for [Spectronaut](https://biognosys.com/software/spectronaut/) search separately with the help of [nextflow](https://www.nextflow.io/docs/latest/reference/config.html#executor) parallel execution attribute and the results are combined in the end to form an experiment wide output. This increases the [Spectronaut](https://biognosys.com/software/spectronaut/) DIA analysis search speed owing to the use of multiple High-Performance Computing (HPC) nodes with the help of batch schedulers (ex: SLURM).

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

Define or modify all DIA search-related inputs in `params.yaml`:

* **JOB_NAME** - Unique identifier/name for your Spectronaut search job
* **spec_bin** - Absolute path to the Spectronaut command-line executable (SpectronautCMD.dll)
* **license** - Absolute path to your Spectronaut license file
* **rawfile_dir** - Directory path containing all input LC-MS/MS raw data files
* **FASTA** - Protein sequence database file in bgsfasta format for peptide identification
* **EXT_PSAR** - External Spectronaut result file (.psar) to use as input for DIA search

#### Optional Parameters

* **sample_size** - Number of raw files to randomly sample for library generation (if not specified, all files are used)
* **batch_size** - Number of raw files to group together for each library generation process (i.e., task). Default: 1 (individual files processed separately via Pulsar)
* **excludePattern** - Exclude raw files by name pattern (e.g., "pooled" will skip files containing "pooled")
* **COND_SETUP** - TSV file specifying experimental condition/sample grouping metadata
* **REPORT** - Spectronaut report template (.rs file) to customize output report columns and format
* **PROP_DIA** - Optional custom Spectronaut search parameters file (.prop) for advanced search configuration
* **max_files_for_ManageSNE** - Maximum number of SNE result files threshold for manage SNE process execution. If the total number of raw files exceeds this cutoff, the pipeline will execute combineSNE process instead. Default: 150 (adjust based on available HPC/Cloud resources for large-scale SNE file merging)

### Process-specific Resource Allocation

The pipeline consists of six main processes;

1. Library generation - Pulsar Stage 1
2. Generate QSP
3. Library generation - Pulsar Stage 3
4. Combine PSAR
5. DIA search
6. Combine/merge SNE

Each process is executed by different modules in Spectronaut-nf i.e., _SN_nf_pulsar_ (Process 1-3) , _SN_nf_combine_psar_ (Process 4), _SN_nf_dia_ (Process 5) and _SN_nf_combine_sne_ (Process 6), each with configurable HPC resource requirements. Adjust the CPU, memory, and time limits based on your HPC cluster capabilities and data size.

### Batch scheduler and its parameters 
Set the batch scheduler used in your HPC platform inside `process`. 
```
executor = 'slurm'
```
This will be followed by setting up process-specific partition requirements such as CPUs, RAM and Duration available in the respective HPC partition.

| Parameter | Description |
|-----------|-------------|
| `*_queue` | HPC queue/partition used for each task. |
| `*_cpus` | Number of CPU cores allocated per jtaskob. |
| `*_memory` | Memory allocated per task. |
| `*_time` | Maximum wall-clock time for task execution. |

#### Parallel Execution Control
- **executor_queueSize** - Maximum number of search tasks to execute in parallel on the HPC queue

## How to deploy the nextflow workflow directly to the HPC?
```
nextflow -bg run /path/to/main.nf -params-file /path/to/params.yaml >> nextflow_cmd.log
```
If the nextflow pipeline crashes/breaks in between, you can resume the searches with the help of `-resume` command.

## Output
| Output Folder | Description |
|---------------|-------------|
| intermediates | Task-specific outputs from Library generation stages (Pulsar Stage 1, Generate QSP and Pulsar Stage 3) are saved here. |
| out_lib | Final output of library generation, i.e., experiment-wide library (.psar and .kit) by combining all task-specific .psar files. |
| out_dia | |
| logs | |
| work | |
| tmp | |

## Future direction
Implementation of process-specific dynamic resource request/allocation by Nextflow based on the batch size and also based on the size of individual raw files. This will improve efficiency by requesting the appropriate CPUs and memory needed for a single or batch of raw files. Finally, by leveraging Nextflow, the workflow can be extended to operate seamlessly across 19 different execution platforms, offering broad adaptability to diverse computing environments with minor adjustments to the workflow.
