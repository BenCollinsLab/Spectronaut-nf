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
A detailed description on how to install the linux compatible SpectronautCMD.dll or the containerized image (*.sif) file is available in [Deploying Spectronaut on an HPC system](https://github.com/BenCollinsLab/Spectronaut-nf/edit/main/README.md#deploying-spectronaut-on-an-hpc-system).

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
| `spec_bin` | Absolute path to the Spectronaut command-line executable (SpectronautCMD.dll). If you use `spec_bin`, comment `image_path`. |
| `image_path` | Absolute path to the containerized Spectronaut image file (spectronaut.sif). If you use `image_path`, comment `spec_bin`. |
| `license` | Absolute path to your Spectronaut license file |
| `rawfile_dir` | Directory path containing all input LC-MS/MS raw data files (Default path is ./raw_d/) |
| `FASTA` | Protein sequence database file in bgsfasta format for peptide identification |

#### Optional Parameters
| Parameter | Description |
|--------------|---------------------------------------------------------------------------------------------------------|
| `sample_size` | Number of raw files to randomly sample for library generation (if not specified, all files are used) |
| `batch_size` | Number of raw files to group together for each library generation process (i.e., task). Default: 1 (individual files processed separately via Pulsar) |
| `excludePattern` | Exclude raw files by name pattern (e.g., "pooled" will skip files containing "pooled") |
| `COND_SETUP` | TSV file specifying experimental condition/sample grouping metadata |
| `REPORT` | Spectronaut report template (.rs file) to customize output report columns and format |
| `PROP_DIA` | Optional custom Spectronaut search parameters file (.prop) for advanced search configuration |
| `EXT_PSAR` | External Spectronaut result file (.psar) to use as input for DIA search |
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
         -profile container \
         -params-file /path/to/params.yaml >> nextflow_cmd.log
```
> Note: If users want to run Spectronaut in its native format (i.e., SpectronautCMD.dll) without containerizing it, either set ```-profile host``` or dont use it at all.

## Resume Failed Runs
```
nextflow -bg run /path/to/main.nf \
         -profile container \
         -params-file /path/to/params.yaml \
         -resume >> nextflow_cmd.log
```
When users `-resume` in their command, Nextflow automatically resumes the search from previously completed tasks (Cached).

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

## Testing and Continuous Integration

Spectronaut-nf uses GitHub Actions to validate the Nextflow code.

### Local validation

Run:

    nextflow lint .

This checks the Nextflow code for syntax and style issues.

### Workflow testing

Linting does not guarantee that the pipeline executes successfully.
Changes affecting workflow behaviour should also be tested with an
appropriate dataset and execution profile.

Users can test Spectronaut-nf on their HPC system using the provided FASTA database and publicly available diaPASEF raw files from the PRIDE Archive. Since mass spectrometry raw files are large, they are not included directly in this repository.

#### Test Dataset

- FASTA database: Use the FASTA file provided in this repository.
- diaPASEF raw files: Download the raw files from the PRIDE Archive using the accession PXD078858.
- Spectronaut: Ensure that Spectronaut is installed and activated with a valid licence.
- HPC environment: Ensure that Nextflow and the required dependencies are available and that the pipeline is configured for your cluster's executor and resource limits.

### Continuous Integration

The GitHub Actions workflow is defined in:

`.github/workflows/ci.yml`

It runs automated validation when the configured repository events occur.

## Deploying Spectronaut on an HPC System

`Spectronaut-nf` requires an authorised installation of Spectronaut and a valid licence. Since Spectronaut is proprietary software, its installer and licence are not distributed with this repository.

Users can deploy Spectronaut on an HPC system using either a native installation or an Apptainer/Singularity container, depending on their cluster configuration and local policies.

### Option 1: Native Spectronaut Installation

If Spectronaut is installed directly on the HPC system, configure `spec_bin` in `params.yaml` to point to the installed `SpectronautCMD.dll`.

**Important:** Do not copy only `SpectronautCMD.dll` from another machine. The command-line application may depend on additional files and libraries in the Spectronaut installation directory. The complete installation and its dependencies must remain accessible.

1. Obtain the Spectronaut Linux installer from an authorised Biognosys source.
2. Install Spectronaut according to the vendor's instructions. If administrator privileges are required, contact your HPC administrator.
3. Where supported, install Spectronaut in a persistent software directory accessible to the compute nodes. For example:

   ```text
   /shared/apps/spectronaut/<version>/
   ```

   The actual directory structure depends on the installation method. Identify the location of `SpectronautCMD.dll` within the complete installation.
4. Ensure that the required .NET runtime is available in the job environment and that the installation and licence are accessible from the compute nodes.
5. Configure `params.yaml` with the appropriate paths:

   ```yaml
   spec_bin: "/shared/apps/spectronaut/<version>/SpectronautCMD.dll"
   license: "/shared/licenses/spectronaut/<licence-file>"
   ```

   Replace these example paths with the actual locations on your HPC system.

Run the pipeline using the host execution profile, for example:

```bash
nextflow run main.nf \
    -profile host \
    -params-file params.yaml
```

Use the profile and parameter names defined in your local Nextflow configuration.

### Option 2: Apptainer/Singularity Container

For HPC systems supporting Apptainer/Singularity, users can prepare a container image containing Spectronaut and its required runtime dependencies.

This approach packages the software environment into a single `.sif` image that can be stored in a shared directory and executed on compatible compute nodes.

Follow the instructions in the [Spectronaut Container Setup Guide](Container/container_README_updated.md) to:

1. Obtain the Spectronaut installer from an authorised source.
2. Build a Docker image containing Spectronaut and its required dependencies.
3. Convert the Docker image into an Apptainer/Singularity image.
4. Test the image and verify that the Spectronaut command-line application starts correctly.

After creating the image, copy it to a persistent location accessible to the compute nodes. For example:

```text
/shared/containers/spectronaut/<version>/spectronaut.sif
```

Configure `params.yaml` to use the container:

```yaml
image_path: "/shared/containers/spectronaut/<version>/spectronaut.sif"
license: "/shared/licenses/spectronaut/<licence-file>"
```

Then execute the pipeline using the container profile:

```bash
nextflow run main.nf \
    -profile container \
    -params-file params.yaml
```

Ensure that the container profile is configured correctly for your HPC environment and that the licence and input/output directories are accessible from within the container.

### HPC Storage and Permissions

Regardless of the deployment method, consider the following requirements:

* **Persistent storage:** Store the Spectronaut installation or `.sif` image in a persistent software or project directory rather than temporary storage that may be automatically cleaned.
* **Compute-node accessibility:** Ensure that the software installation or container image, licence, input data, and output directories are accessible from the compute nodes executing the pipeline.
* **File permissions:** Configure appropriate read and execute permissions for the software installation or container image. Follow your institution's policies for licence-file permissions.
* **Licensing:** Obtain and activate Spectronaut according to the applicable licensing terms. Do not include licence files in the public repository or bake them into the container image.
* **Security and distribution:** Do not commit proprietary installers, licence files, or generated container images to this public GitHub repository.
* **Testing:** Test the installation or container before launching a large-scale analysis. Confirm that the runtime is available and that Spectronaut can execute a search using a valid licence.

**Note:** A message indicating that no valid licence was found may confirm that the command-line application starts, but it does not establish that the software is activated or ready for a search. Verify licensing separately before running the full pipeline.


## Documentation and Community

- **Changelog:** [CHANGELOG.md](CHANGELOG.md)
- **Report a bug or request a feature:** [GitHub Issues](https://github.com/BenCollinsLab/Spectronaut-nf/issues)
- **Contributing guidelines:** [CONTRIBUTING.md](CONTRIBUTING.md)
- **Testing and CI:** See the Testing and Continuous Integration section above.
- **Releases:** [GitHub Releases](https://github.com/BenCollinsLab/Spectronaut-nf/releases)

## Citation
Spectronaut-nf: A Nextflow Pipeline for Parallel Processing of DIA Data with Spectronaut [bioRxiv, 2026](https://www.biorxiv.org/content/10.64898/2026.07.29.741433v1)
