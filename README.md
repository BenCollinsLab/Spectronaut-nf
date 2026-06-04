# Spectronaut-nf
A [nextflow](https://www.nextflow.io/) pipeline to carry [Spectronaut](https://biognosys.com/software/spectronaut/) DIA analysis with its parallel execution attribute. Here, individual LC-MS/MS derived proteomic rawfiles are queued for [Spectronaut](https://biognosys.com/software/spectronaut/) search separately with the help of [nextflow](https://www.nextflow.io/docs/latest/reference/config.html#executor) parallel execution attribute and the results are combined in the end to form a experiment wide output. This increases the [Spectronaut](https://biognosys.com/software/spectronaut/) DIA analysis search speed owing to the use of multiple High Performance Computing (HPC) nodes with the help of batch schedulers (ex: SLURM).

### Spectronaut-nf workflow
![spectronaut_nextflow_workflow](https://github.com/user-attachments/assets/2a7344b3-1cfb-4d34-923a-147aa5b54e46)

## Download Spectronaut-nf
```
git clone https://github.com/BenCollinsLab/Spectronaut-nf
```

## Spectronaut-nf input parameters
Users can set most of the input parameters required to run the Spectronaut-nf pipeline in `params.yaml` file. This file can be edited using `vim` or `nano` editor in linux/HPC platform. In case of Windows systems, any text editor tools such as [Notepad++](https://notepad-plus-plus.org/) or [sublime](https://www.sublimetext.com/3) can be used.

### Batch scheduler and its parameters 
Set the batch scheduler used in your HPC platform inside `process`. 
```
executor = 'slurm'
```
This will be followed by setting up process-specific partition requirements such as CPUs, RAM and Duration available in the respective HPC partition.

### DIA search inputs
![spectronaut-nf_nextflow config](https://github.com/user-attachments/assets/eaf80480-e46d-41aa-ab2c-091eed20efe7)

Define or modify all DIA search related inputs in `params.yaml`
* **Job name**
* **Raw file directory/path:** Make sure that all the raw files are available in raw_d folder inside the Project directory
* **Fasta file/format:** Keep the proteome database (bgsfasta format) required for the search in the Project directory
* **Additional search parameters in .PROP file:** If your search requires additional parameters or any changes in the default parameters, define the parameters under Settings tab of the Spectronaut GUI and export it in the .prop format. The exported .prop file needs to be stored in the Project directory and the path to it should be included in the nextflow.config file
* **Condition Setup file**
* **Custom report templates**

### Additional optional parameters
* **Random raw file sampling for library generation**
* **Set batch of raw files for each library generation process**

* **Exclude raw file/s based on common name pattern for DIA search**

## How to deploy the nextflow workflow directly to the HPC?
```
nextflow -bg run /path/to/main.nf -params-file /path/to/params.yaml >> nextflow_cmd.log
```
If the nextflow pipeline crashes/brakes inbetween, you can resume the searches with the help of `-resume` command.
