#!/bin/bash
#SBATCH --job-name=spec
#SBATCH --output=o.%x.%j
#SBATCH --time=3:00:00
#SBATCH --partition=k2-hipri
#SBATCH --ntasks=96
#SBATCH --mem-per-cpu=4000M
#SBATCH --nodes=1                       

module load nextflow
nextflow run main.nf
