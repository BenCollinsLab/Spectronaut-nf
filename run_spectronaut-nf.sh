module load nextflow

nextflow -bg run /users/3054755/job_scripts/Spectronaut-nf/main.nf -c $1 -with-timeline -with-trace >> nextflow_$HOSTNAME.log
