#!/bin/bash
#SBATCH --job-name="midas"
#SBATCH -A e31333
#SBATCH -p normal
#SBATCH -t 10:00:00
#SBATCH -N 1
#SBATCH --mem=16G
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=mckennafarmer2023@u.northwestern.edu
#SBATCH --output=outlog_midas.txt
#SBATCH --error=errorlog_midas.txt

module purge all
module load singularity

make midas classifier from downloaded fa and txt files, midas 3.7
singularity exec -B /projects/b1052/Wells_b1042/McKenna/s2ebpr_16s -B /projects/b1052/shared /projects/b1052/shared/qiime2-core2020.11.simg \
qiime tools import \
--type 'FeatureData[Sequence]' \
--input-path /projects/b1052/shared/midas_3.7.fa \
--output-path /projects/b1052/shared/midas_asv.qza

singularity exec -B /projects/b1052/Wells_b1042/McKenna/s2ebpr_16s -B /projects/b1052/shared /projects/b1052/shared/qiime2-core2020.11.simg \
qiime tools import \
--type 'FeatureData[Taxonomy]' \
--input-format HeaderlessTSVTaxonomyFormat \
--input-path /projects/b1052/shared/midas_3.7.txt \
--output-path /projects/b1052/shared/midas_taxonomy.qza

singularity exec -B /projects/b1052/Wells_b1042/McKenna/s2ebpr_16s -B /projects/b1052/shared /projects/b1052/shared/qiime2-core2020.11.simg \
qiime feature-classifier fit-classifier-naive-bayes \
--i-reference-reads /projects/b1052/shared/midas_asv.qza \
--i-reference-taxonomy /projects/b1052/shared/midas_taxonomy.qza \
--o-classifier /projects/b1052/shared/midas3.7_classifier.qza
