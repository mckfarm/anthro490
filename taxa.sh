#!/bin/bash
#SBATCH --job-name="taxa"
#SBATCH -A e31333
#SBATCH -p normal
#SBATCH -t 24:00:00
#SBATCH -N 1
#SBATCH --mem=32G
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=mckennafarmer2023@u.northwestern.edu
#SBATCH --output=outlog_taxa.txt
#SBATCH --error=errorlog_taxa.txt

module purge all
module load singularity

# taxonomic classification
singularity exec -B /projects/b1052/Wells_b1042/McKenna/s2ebpr_16s -B /projects/b1052/shared /projects/b1052/shared/qiime2-core2020.11.simg \
qiime feature-classifier classify-sklearn \
--i-classifier /projects/b1052/shared/midas3.7_classifier.qza \
--i-reads /projects/b1052/Wells_b1042/McKenna/s2ebpr_16s/rep_seqs_merged.qza \
--o-classification /projects/b1052/Wells_b1042/McKenna/s2ebpr_16s/taxonomy.qza

singularity exec -B /projects/b1052/Wells_b1042/McKenna/s2ebpr_16s -B /projects/b1052/shared /projects/b1052/shared/qiime2-core2020.11.simg \
qiime metadata tabulate --m-input-file /projects/b1052/Wells_b1042/McKenna/s2ebpr_16s/taxonomy.qza \
--o-visualization /projects/b1052/Wells_b1042/McKenna/s2ebpr_16s/taxonomy.qzv
