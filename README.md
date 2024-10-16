# Spectronaut-nf

## Download Spectronaut-nf
```
git clone https://github.com/BenCollinsLab/Spectronaut-nf
```

## Input requirements
1. Make sure that all the raw files are available in raw_d folder inside the Project directory
2. Keep the proteome database (bgsfasta format) required for the search in the Project directory
3. If your search requires additional parameters or any changes in the default parameters, create one using the Spectronaut GUI and export it in the .prop format. The exported .prop file needs to be stored in the Project directory

### Edit the `nextflow.config`
Edit the `nextflow.config` file as per the requirements using `vim` editor in linux systems or any text editor tools such as [Notepad++](https://notepad-plus-plus.org/) or [sublime](https://www.sublimetext.com/3) etc. 

## How to deploy the nextflow workflow directly to the HPC using SLURM?
```
nextflow run main.nf -c nextflow.config -with-dag -resume -with-report -with-trace
```
### Spectronaut-nf workflow
![image](https://github.com/user-attachments/assets/cb48fb58-d4b7-4c3a-b8ee-02437acaa712)
