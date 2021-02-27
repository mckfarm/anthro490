#!/bin/bash
#SBATCH --job-name="dada2"
#SBATCH -A e31333
#SBATCH -p normal
#SBATCH -t 24:00:00
#SBATCH -N 1
#SBATCH --mem=16G
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=mckennafarmer2023@u.northwestern.edu
#SBATCH --output=outlog_dada2.txt
#SBATCH --error=errorlog_dada2.txt

module purge all
module load singularity

# load singularity and execute command
singularity exec -B /projects/b1052/Wells_b1042/McKenna/s2ebpr_16s -B /projects/b1052/shared /projects/b1052/shared/qiime2-core2020.11.simg \
qiime dada2 denoise-paired --i-demultiplexed-seqs /projects/b1052/Wells_b1042/McKenna/s2ebpr_16s/round1_paired.qza \
--p-trim-left-f 20 --p-trim-left-r 20 --p-trunc-len-f 240 --p-trunc-len-r 220 \
--o-representative-sequences /projects/b1052/Wells_b1042/McKenna/s2ebpr_16s/rep_seqs_dada2_r1.qza \
--o-table /projects/b1052/Wells_b1042/McKenna/s2ebpr_16s/table_dada2_r1.qza \
--o-denoising-stats /projects/b1052/Wells_b1042/McKenna/s2ebpr_16s/stats_dada2_r1.qza

singularity exec -B /projects/b1052/Wells_b1042/McKenna/s2ebpr_16s -B /projects/b1052/shared /projects/b1052/shared/qiime2-core2020.11.simg \
qiime dada2 denoise-paired --i-demultiplexed-seqs /projects/b1052/Wells_b1042/McKenna/s2ebpr_16s/round2_paired.qza \
--p-trim-left-f 20 --p-trim-left-r 20 --p-trunc-len-f 290 --p-trunc-len-r 280 \
--o-representative-sequences /projects/b1052/Wells_b1042/McKenna/s2ebpr_16s/rep_seqs_dada2_r2.qza \
--o-table /projects/b1052/Wells_b1042/McKenna/s2ebpr_16s/table_dada2_r2.qza \
--o-denoising-stats /projects/b1052/Wells_b1042/McKenna/s2ebpr_16s/stats_dada2_r2.qza

singularity exec -B /projects/b1052/Wells_b1042/McKenna/s2ebpr_16s -B /projects/b1052/shared /projects/b1052/shared/qiime2-core2020.11.simg \
qiime dada2 denoise-paired --i-demultiplexed-seqs /projects/b1052/Wells_b1042/McKenna/s2ebpr_16s/round3_paired.qza \
--p-trim-left-f 20 --p-trim-left-r 20 --p-trunc-len-f 220 --p-trunc-len-r 220 \
--o-representative-sequences /projects/b1052/Wells_b1042/McKenna/s2ebpr_16s/rep_seqs_dada2_r3.qza \
--o-table /projects/b1052/Wells_b1042/McKenna/s2ebpr_16s/table_dada2_r3.qza \
--o-denoising-stats /projects/b1052/Wells_b1042/McKenna/s2ebpr_16s/stats_dada2_r3.qza

# stats visuals
singularity exec -B /projects/b1052/Wells_b1042/McKenna/s2ebpr_16s /projects/b1052/shared/qiime2-core2020.11.simg \
qiime metadata tabulate --m-input-file /projects/b1052/Wells_b1042/McKenna/s2ebpr_16s/stats_dada2_r1.qza \
--o-visualization /projects/b1052/Wells_b1042/McKenna/s2ebpr_16s/stats_dada2_r1.qzv

singularity exec -B /projects/b1052/Wells_b1042/McKenna/s2ebpr_16s /projects/b1052/shared/qiime2-core2020.11.simg \
qiime metadata tabulate --m-input-file /projects/b1052/Wells_b1042/McKenna/s2ebpr_16s/stats_dada2_r2.qza \
--o-visualization /projects/b1052/Wells_b1042/McKenna/s2ebpr_16s/stats_dada2_r2.qzv

singularity exec -B /projects/b1052/Wells_b1042/McKenna/s2ebpr_16s /projects/b1052/shared/qiime2-core2020.11.simg \
qiime metadata tabulate --m-input-file /projects/b1052/Wells_b1042/McKenna/s2ebpr_16s/stats_dada2_r3.qza \
--o-visualization /projects/b1052/Wells_b1042/McKenna/s2ebpr_16s/stats_dada2_r3.qzv

# merge separate rounds into one file
singularity exec -B /projects/b1052/Wells_b1042/McKenna/s2ebpr_16s /projects/b1052/shared/qiime2-core2020.11.simg \
qiime feature-table merge \
--i-tables table_dada2_r1.qza \
--i-tables table_dada2_r2.qza \
--i-tables table_dada2_r3.qza \
--o-merged-table table_merged.qza

singularity exec -B /projects/b1052/Wells_b1042/McKenna/s2ebpr_16s /projects/b1052/shared/qiime2-core2020.11.simg \
qiime feature-table merge-seqs \
--i-data rep_seqs_dada2_r1.qza \
--i-data rep_seqs_dada2_r2.qza \
--i-data rep_seqs_dada2_r3.qza \
--o-merged-data rep_seqs_merged.qza
