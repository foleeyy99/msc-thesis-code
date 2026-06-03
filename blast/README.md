# PITG_01069 cross-reference against the Matson et al. (2022) proteome

This folder contains the command and output used to cross reference the PITG_01069 protein sequence against the predicted protein FASTA from the Phytophthora infestans assembly reported by Matson et al. (2022).
The purpose of this analysis was to determine whether the older PITG_01069 annotation has corresponding protein models in the updated Matson et al. proteome, and whether any obvious additional full-length IP3R-like homologues were apparent.

### Note: These workflows were designed and executed on MacOS Version 15.7.4.

## Input files

* PITG_01069.txt: PITG_01069 protein sequence in FASTA format.
* protein.faa: predicted protein FASTA from the Matson et al. (2022) P. infestans assembly, downloaded from NCBI.

The full protein.faa file is not included in this repository. It is publicly available from NCBI under Bioproject PRJNA868814.

## Software setup

The search was performed using BLASTP from the NCBI BLAST+ command line suite.

1. Install BLAST using Conda
conda create -n blast_env -c conda-forge -c bioconda blast -y
conda activate blast_env

2. To check that BLAST is available:
blastp -version

## BLASTP Command 

The search was performed in query vs subject mode. This directly compares the PITG_01069 protein FASTA file against the Matson et al. predicted protein FASTA file. 

blastp \ 
-query PITG_01069.txt \ 
-subject protein.faa \ 
-evalue 1e-10 \ 
-max_target_seqs 20 \ 
-outfmt "6 qseqid sseqid pident length qlen slen qcovs evalue bitscore stitle" \ 
-out PITG01069_vs_Matson.tsv

## Output file

The output file is:

PITG01069_vs_Matson.tsv

The BLASTP output is in tab-separated format with the following columns:

query sequence ID
subject sequence ID
percentage identity
alignment length
query length
subject length
query coverage
E-value
bit score
subject title

## Summary of output

The BLASTP comparison identified two highly similar PITG_01069-related protein models in the Matson et al. predicted proteome:

KAI9996190.1 — hypothetical protein PInf_013573
KAI9979760.1 — hypothetical protein PInf_027913

Both showed high sequence identity to the PITG_01069 query and corresponded to large protein models of similar length. Additional lower scoring hits were much shorter neighbouring predicted proteins and were not consistent with obvious additional full-length IP3R-like homologues in this comparison.
