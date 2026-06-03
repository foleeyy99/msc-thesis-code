#!/bin/bash

# Local BLASTP comparison of the PITG_01069 protein sequence
# against the predicted protein FASTA from the Matson et al. (2022)
# chromosome-scale Phytophthora infestans assembly.

blastp \
  -query PITG_01069.txt \
  -subject protein.faa \
  -evalue 1e-10 \
  -max_target_seqs 20 \
  -outfmt "6 qseqid sseqid pident length qlen slen qcovs evalue bitscore stitle" \
  -out PITG01069_vs_Matson.tsv
