# Spectronaut-nf
A nextflow pipeline to carry Spectronaut DIA analysis with its parallel execution attribute. Here, individual LC-MS/MS derived proteomic rawfiles are queued for Spectronaut search separately with the help of nextflow parallel execution attribute and the results are combined in the end to form a experiment wide output. This increases the Spectronaut DIA analysis search speed owing to the use of multiple High Performance Computing (HPC) nodes with the help of batch schedulers (ex: SLURM).

## Download Spectronaut-nf
```
git clone https://github.com/BenCollinsLab/Spectronaut-nf
```

## Input requirements
1. Make sure that all the raw files are available in raw_d folder inside the Project directory
2. Keep the proteome database (bgsfasta format) required for the search in the Project directory
3. If your search requires additional parameters or any changes in the default parameters, create one using the Spectronaut GUI and export it in the .prop format. The exported .prop file needs to be stored in the Project directory and the path to it should be included in the nextflow.config file

### Edit the `nextflow.config`
Edit the `nextflow.config` file as per the requirements using `vim` editor in linux systems or any text editor tools such as [Notepad++](https://notepad-plus-plus.org/) or [sublime](https://www.sublimetext.com/3) etc. 

#### Batch scheduler and its parameters 
Set the batch scheduler used in your HPC platform inside `process`. 
```
executor = 'slurm'
```
This will be followed by setting up process-specific partition requirements such as CPUs, RAM and Duration available in the respective HPC partition.

#### DIA search inputs
1. Job name
2. Raw file directory/path
3. Fasta file/format
4. Additional search parameters in .PROP file
5. Condition Setup file
6. Custom report templates

#### Additional parameters
1. Random raw file sampling for library generation
2. Set batch of raw files for each library generation process
3. Exclude raw file/s based on common name pattern for DIA search

## How to deploy the nextflow workflow directly to the HPC?
```
nextflow -bg run main.nf -c nextflow.config -with-timeline -with-trace >> nextflow_cmd.log
```
If the nextflow pipeline crashes/brakes inbetween, you can resume the searches with the help of `-resume` command.

### Spectronaut-nf workflow
![image](https://github.com/user-attachments/assets/cb48fb58-d4b7-4c3a-b8ee-02437acaa712)
