# Spectronaut-nf
A [nextflow](https://www.nextflow.io/) pipeline to carry [Spectronaut](https://biognosys.com/software/spectronaut/) DIA analysis with its parallel execution attribute. Here, individual LC-MS/MS derived proteomic rawfiles are queued for [Spectronaut](https://biognosys.com/software/spectronaut/) search separately with the help of [nextflow](https://www.nextflow.io/docs/latest/reference/config.html#executor) parallel execution attribute and the results are combined in the end to form an experiment wide output. This increases the [Spectronaut](https://biognosys.com/software/spectronaut/) DIA analysis search speed owing to the use of multiple High-Performance Computing (HPC) nodes with the help of batch schedulers (ex: SLURM).

## Key Features
- 🚀 Parallel execution of Spectronaut searches across multiple HPC nodes
- 📈 Scalable processing of hundreds to thousands of DIA raw files
- ⚡ Reduced analysis time compared with standard Spectronaut execution
- 🔄 Fully resumable workflow using Nextflow caching
- 🖥️ Compatible with HPC schedulers such as SLURM
- 🧩 Configurable computational resources for each workflow stage
- 📊 Generates experiment-wide spectral libraries and DIA reports

### Spectronaut-nf workflow
![spectronaut_nextflow_workflow](https://github.com/user-attachments/assets/2a7344b3-1cfb-4d34-923a-147aa5b54e46)

The pipeline consists of six main processes:

1. Library generation - Pulsar Stage 1
2. Generate QSP
3. Library generation - Pulsar Stage 3
4. Combine PSAR
5. DIA search
6. Combine/merge SNE

## Installation
### clone Spectronaut-nf repository
```
git clone https://github.com/BenCollinsLab/Spectronaut-nf
cd Spectronaut-nf
```
## Prerequisite
The following software packages must be installed and accessible in your environment before running `Spectronaut-nf`.

| Software | Minimum Version | Purpose |
|-----------|----------------|----------|
| [.NET](https://aka.ms/dotnet/download) | 8.0.18 | Required to execute the Spectronaut command-line application (`SpectronautCMD.dll`). |
| [Nextflow](https://www.nextflow.io/) | 25.10.3 | Workflow manager used to orchestrate and execute the pipeline processes. |
| [SLURM](https://slurm.schedmd.com/) | 24.04.3 | Optional but recommended HPC workload manager used to distribute and execute jobs in parallel across compute nodes. |

### Verify Installation

```bash
$ dotnet --info

Host:
  Version:      8.0.18
  Architecture: x64
  Commit:       ef853a7105
  RID:          rocky.8-x64
.
.
.
```

```
$ nextflow info
  Version: 25.10.3 build 10983
  Created: 22-01-2026 15:34 UTC (15:34 BST)
  System: Linux 4.18.0-553.64.1.el8_10.x86_64
  Runtime: Groovy 4.0.28 on Java HotSpot(TM) 64-Bit Server VM 22.0.2+9-70
  Encoding: UTF-8 (UTF-8)
```

```
$ sinfo --version
slurm 25.05.2
```

> **Note:** `Spectronaut-nf` has been developed and tested using the software versions listed above. Earlier or later versions may work but have not been extensively validated.

> **Cluster Environment:** On most HPC systems, these dependencies can be loaded through environment modules, for example:
>
> ```bash
> module load dotnet/8.0.18
> module load nextflow/25.10.3
> module load slurm/25.05.2
> ```
>
> Please consult your local HPC administrator if different module names or versions are used on your system.

## Spectronaut-nf input variables
Users can set most of the input parameters required to run the Spectronaut-nf pipeline in `params.yaml` file. This file can be edited using `vim` or `nano` editor in linux/HPC platform.

### DIA search inputs
![spectronaut-nf_nextflow config](https://github.com/user-attachments/assets/eaf80480-e46d-41aa-ab2c-091eed20efe7)

#### Required Parameters

Define or modify all DIA search-related inputs in `params.yaml`:

| Parameter | Description |
|--------------|--------------------------------------------------------|
| `JOB_NAME` | Unique identifier/name for your Spectronaut search job |
| `spec_bin` | Absolute path to the Spectronaut command-line executable (SpectronautCMD.dll) |
| `license` | Absolute path to your Spectronaut license file |
| `rawfile_dir` | Directory path containing all input LC-MS/MS raw data files |
| `FASTA` | Protein sequence database file in bgsfasta format for peptide identification |
| `EXT_PSAR` | External Spectronaut result file (.psar) to use as input for DIA search |

#### Optional Parameters
| Parameter | Description |
|--------------|---------------------------------------------------------------------------------------------------------|
| `sample_size` | Number of raw files to randomly sample for library generation (if not specified, all files are used) |
| `batch_size` | Number of raw files to group together for each library generation process (i.e., task). Default: 1 (individual files processed separately via Pulsar) |
| `excludePattern` | Exclude raw files by name pattern (e.g., "pooled" will skip files containing "pooled") |
| `COND_SETUP` | TSV file specifying experimental condition/sample grouping metadata |
| `REPORT` | Spectronaut report template (.rs file) to customize output report columns and format |
| `PROP_DIA` | Optional custom Spectronaut search parameters file (.prop) for advanced search configuration |
| `max_files_for_ManageSNE` | Maximum number of SNE result files threshold for manage SNE process execution. If the total number of raw files exceeds this cutoff, the pipeline will execute combineSNE process instead. Default: 150 (adjust based on available HPC/Cloud resources for large-scale SNE file merging) |

### HPC Configuration
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

> Note: Each process is executed by different modules in Spectronaut-nf i.e., _SN_nf_pulsar_ (Process 1-3) , _SN_nf_combine_psar_ (Process 4), _SN_nf_dia_ (Process 5) and _SN_nf_combine_sne_ (Process 6), each with configurable HPC resource requirements. Adjust the CPU, memory, and time limits based on your HPC cluster capabilities and data size.

#### Parallel Execution Control
- **executor_queueSize** - Maximum number of search tasks to execute in parallel on the HPC queue

## Running Spectronaut-nf
```
nextflow -bg run /path/to/main.nf \
         -params-file /path/to/params.yaml >> nextflow_cmd.log
```

## Resume Failed Runs
```
nextflow -bg run /path/to/main.nf \
         -params-file /path/to/params.yaml \
         -resume >> nextflow_cmd.log
```
Nextflow automatically reuses previously completed tasks and continues from the last successful checkpoint.

## Output
| Output Folder | Description |
|---------------|-------------|
| `intermediates/` | Task-specific outputs generated during the library creation stages (Pulsar Stage 1, Generate QSP, and Pulsar Stage 3). |
| `out_lib/` | Final library generation outputs, including the experiment-wide spectral library files (`.psar` and `.kit`) obtained by combining all task-specific `.psar` files. |
| `out_dia/` | Outputs from all DIA search tasks, including the final experiment-wide DIA search results. Users can use the final Spectronaut reports or SNE file for further downstream analysis. |
| `logs/` | Nextflow execution reports, timelines, traces, and other log files generated during the pipeline run. |
| `work/` | Nextflow working directory containing task-specific execution folders identified by unique hash keys. |
| `tmp/` | Temporary files and intermediate data generated during pipeline execution. These files can be safely removed after successful completion of the pipeline. |

### Example Directory Structure
```
results/
├── intermediates/
├── out_lib/
├── out_dia/
├── logs/
├── tmp/
└── work/
```

## License
GLP-3.0

## Citation
xxxxxxxxxxxxx
