#! /bin/bash

# This lines are normally introduced in all bash files and can be also intrduced as set -euo pipefail. By parts this is what this 3 lines make in our script:
# set -e: If any command returns a non zero value - an error - the script will stop running
# set -u: If we wanted to work with a variable that has not already been described it will cause an error and will tell us where the error has been encountered
# set -o pipefail: There are cases where some pipelines can fail but will not stop running, this line prevents the bash script to have this behaiviour and will stop running when this kind of failures happen.  
set -e
set -u
set -o pipefail

# Create the directory system where the data will be stored.
mkdir -p ./fastq_downloads
mkdir -p ./fastq_downloads/sra_files
mkdir -p ./fastq_downloads/fastq_files

# SAMPLE_NAMES is an array inputed from terminal that will contain the names of the samples that we will download.
SAMPLE_NAMES=("$@")

# Storage of the different output folders where data will be stored, this will help us to make our script more readable during its construcion, here, paths have been stored in their absolute form because when have been stored in a realative manner it has given us some problems. Absolute paths to the programs are also stored in this step.
PREFETCH_OUT=/home/ignasi/Desktop/fastq_downloader/fastq_downloads/sra_files
FASTQ_DUMP_OUT=/home/ignasi/Desktop/fastq_downloader/fastq_downloads/fastq_files
PREFETCH=/home/ignasi/sratoolkit.3.0.0-ubuntu64/bin/prefetch
FASTQ_DUMP=/home/ignasi/sratoolkit.3.0.0-ubuntu64/bin/fastq-dump 

# Print a header
figlet -c "SRA to .fastq"

# Check if the programs respond, in case the program doesn't, a message will appear in the terminal. There are 3 main reasons why it may not work:
# 1. The path to the program is not specified correctly
# 2. SRA-tools has not been instaled correctly
# 3. SRA-tools has not been configured correctly
if ! `command -v $PREFETCH >/dev/null 2>/dev/null`  
then
    echo "Prefetch doesn't respond"
    exit 1
fi

if ! `command -v $FASTQ_DUMP >/dev/null 2>/dev/null`  
then
    echo "Fastq-dump doesn't respond"
    exit 1
fi

# This message will appear allways as a description of what the script does
echo -e "This script works as a fasta file downloader, it combines prefetch and
fastq-dump in order to minimize the time it takes to download these fastq
files. Some parameters have been already been configured but can be changed 
changing this file. \n" 


# If no input has been entered to the system, an error message will appear in the terminal
if [[ "$#" -lt 1 ]]
then 
echo -e "A list of SRA accessions must be introduced! \n"
fi

# If a list of samples has been entered to the system, this same list will apear in the terminal
if [[ "$#" -gt 0 ]]
then
echo -e "The following samples will be downloaded:"
fi

for i in ${SAMPLE_NAMES[@]}
do
echo $i
done
echo -e "\n"

# Download .sra files
for i in ${SAMPLE_NAMES[@]}
do
/home/ignasi/sratoolkit.3.0.0-ubuntu64/bin/prefetch $i -O $PREFETCH_OUT
done

echo -e "\n"

if [[ "$#" -gt 0 ]]
then
echo ".sra files downloaded"
fi


# Extract .fastq files from .sra files. The --split-files, --skip-technical and --origfmt options are activated.
cd $PREFETCH_OUT

if [[ "$#" -gt 0 ]]
then
echo "Converting .sra files into .fastq files"
fi

if [[ "$#" -gt 0 ]]
then
for folder in SRR*
do
if cd "./$folder"
then
for sra_file in *.sra
do
$FASTQ_DUMP $sra_file --gzip --defline-qual '+' --split-files --skip-technical --outdir $FASTQ_DUMP_OUT 
cd ..
done
fi
done
fi

echo -e "\n"

if [[ "$#" -gt 0 ]]
then
echo ".fastq files extracted"
fi
