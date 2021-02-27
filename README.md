# Project: S2EBPR 16s analysis - Anthro 490 final project
# Purpose: Documenting commands and scripts used for QIIME analysis
# Output: QIIME data files
# Date: 2/9/21

Helpful commands:  
```
srun --account=e31333 --time=2:00:00 --partition=short --mem=4G --pty bash -l
module load singularity
```  
\ - backslash allows you to type a new line without running the commands  

Programs and computing:  
- QIIME2
- Python/Anaconda
- Performed on Quest Computing Cluster

Workflow:  
1) manifest_parse.py
- Creates manifest file for QIIME2 analysis based on filenames
- Executed with python

2) import paired end reads  
```
singularity exec -B /projects/b1052/Wells_b1042/McKenna/s2ebpr_16s /projects/b1052/shared/qiime2-core2020.11.simg \
qiime tools import --input-path /projects/b1052/Wells_b1042/McKenna/s2ebpr_16s/scripts/manifest_r1.csv \
--input-format PairedEndFastqManifestPhred33 \
--output-path /projects/b1052/Wells_b1042/McKenna/s2ebpr_16s/round1_paired.qza \
--type SampleData[PairedEndSequencesWithQuality]

singularity exec -B /projects/b1052/Wells_b1042/McKenna/s2ebpr_16s /projects/b1052/shared/qiime2-core2020.11.simg \
qiime tools import --input-path /projects/b1052/Wells_b1042/McKenna/s2ebpr_16s/scripts/manifest_r2.csv \
--input-format PairedEndFastqManifestPhred33 \
--output-path /projects/b1052/Wells_b1042/McKenna/s2ebpr_16s/round2_paired.qza \
--type SampleData[PairedEndSequencesWithQuality]

singularity exec -B /projects/b1052/Wells_b1042/McKenna/s2ebpr_16s /projects/b1052/shared/qiime2-core2020.11.simg \
qiime tools import --input-path /projects/b1052/Wells_b1042/McKenna/s2ebpr_16s/scripts/manifest_r3.csv \
--input-format PairedEndFastqManifestPhred33 \
--output-path /projects/b1052/Wells_b1042/McKenna/s2ebpr_16s/round3_paired.qza \
--type SampleData[PairedEndSequencesWithQuality]
```

3) visualize read quality
```
singularity exec -B /projects/b1052/Wells_b1042/McKenna/s2ebpr_16s /projects/b1052/shared/qiime2-core2020.11.simg \
qiime demux summarize --i-data /projects/b1052/Wells_b1042/McKenna/s2ebpr_16s/round1_paired.qza \
--o-visualization /projects/b1052/Wells_b1042/McKenna/s2ebpr_16s/visuals/round1_paired.qzv

singularity exec -B /projects/b1052/Wells_b1042/McKenna/s2ebpr_16s /projects/b1052/shared/qiime2-core2020.11.simg \
qiime demux summarize --i-data /projects/b1052/Wells_b1042/McKenna/s2ebpr_16s/round2_paired.qza \
--o-visualization /projects/b1052/Wells_b1042/McKenna/s2ebpr_16s/visuals/round2_paired.qzv

singularity exec -B /projects/b1052/Wells_b1042/McKenna/s2ebpr_16s /projects/b1052/shared/qiime2-core2020.11.simg \
qiime demux summarize --i-data /projects/b1052/Wells_b1042/McKenna/s2ebpr_16s/round3_paired.qza \
--o-visualization /projects/b1052/Wells_b1042/McKenna/s2ebpr_16s/visuals/round3_paired.qzv
```

4) dada2.sh
- denoise and trim
- this command creates three files: dada2 quality filtering table (stats), data table of read info that can be coupled to metadata (table), and a list of amplicon sequence variants that will be used for blast (rep_seqs)
- also includes merging

5) mapping
- couples metadata to sequences
```
singularity exec -B /projects/b1052/Wells_b1042/McKenna/s2ebpr_16s /projects/b1052/shared/qiime2-core2020.11.simg \
qiime feature-table summarize \
--i-table /projects/b1052/Wells_b1042/McKenna/s2ebpr_16s/table_merged.qza \
--o-visualization /projects/b1052/Wells_b1042/McKenna/s2ebpr_16s/table_merged.qzv \
--m-sample-metadata-file /projects/b1052/Wells_b1042/McKenna/s2ebpr_16s/metadata.txt
```

6) list ASVs
```
singularity exec -B /projects/b1052/Wells_b1042/McKenna/s2ebpr_16s /projects/b1052/shared/qiime2-core2020.11.simg \
qiime feature-table tabulate-seqs \
--i-data /projects/b1052/Wells_b1042/McKenna/s2ebpr_16s/rep_seqs_merged.qza \
--o-visualization /projects/b1052/Wells_b1042/McKenna/s2ebpr_16s/rep_seqs_merged.qzv
```

7) phylogenetic tree with mafft
```
singularity exec -B /projects/b1052/Wells_b1042/McKenna/s2ebpr_16s /projects/b1052/shared/qiime2-core2020.11.simg \
qiime phylogeny align-to-tree-mafft-fasttree \
--i-sequences /projects/b1052/Wells_b1042/McKenna/s2ebpr_16s/rep_seqs_merged.qza \
--o-alignment /projects/b1052/Wells_b1042/McKenna/s2ebpr_16s/aligned_rep_seqs_merged.qza \
--o-masked-alignment /projects/b1052/Wells_b1042/McKenna/s2ebpr_16s/masked_aligned_rep_seqs_merged.qza \
--o-tree /projects/b1052/Wells_b1042/McKenna/s2ebpr_16s/unrooted_tree.qza \
--o-rooted-tree /projects/b1052/Wells_b1042/McKenna/s2ebpr_16s/rooted_tree.qza
```

7) make Midas classifier from Midas downloads
- https://midasfieldguide.org/guide/downloads
```
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
```

8) taxa.sh and taxa_silva.sh
- assigns taxa from Midas and Silva classifiers
- produces output qzv file for viewing
- comparison of Midas and Silva taxonomy!!

9) alpha rarefaction curves
- measure of how diversity changes with sequencing depth
- switched to new qiime filepath!
```
singularity exec -B /projects/b1052/Wells_b1042/McKenna/s2ebpr_16s -B /projects/b1052/shared/qiime /projects/b1052/shared/qiime/qiime2-core2020.11.simg \
qiime diversity alpha-rarefaction \
--i-table /projects/b1052/Wells_b1042/McKenna/s2ebpr_16s/table_merged.qza \
--i-phylogeny /projects/b1052/Wells_b1042/McKenna/s2ebpr_16s/rooted_tree.qza \
--o-visualization /projects/b1052/Wells_b1042/McKenna/s2ebpr_16s/alpha_rarefaction.qzv \
--p-max-depth 15000
```

10) alpha and beta diversity and metric extraction
- picking a depth of 8000 based on rough estimate of plateau in faith_pd rarefaction curve
```
singularity exec -B /projects/b1052/Wells_b1042/McKenna/s2ebpr_16s -B /projects/b1052/shared/qiime /projects/b1052/shared/qiime/qiime2-core2020.11.simg \
qiime diversity core-metrics-phylogenetic \
--i-phylogeny /projects/b1052/Wells_b1042/McKenna/s2ebpr_16s/rooted_tree.qza \
--i-table /projects/b1052/Wells_b1042/McKenna/s2ebpr_16s/table_merged.qza \
--p-sampling-depth 8000 \
--m-metadata-file /projects/b1052/Wells_b1042/McKenna/s2ebpr_16s/metadata.txt \
--output-dir /projects/b1052/Wells_b1042/McKenna/s2ebpr_16s/core-metrics-results-8000

# unweighted unifrac distance_matrix.tsv - moved file from created subdirectory and renamed
singularity exec -B /projects/b1052/Wells_b1042/McKenna/s2ebpr_16s -B /projects/b1052/shared/qiime /projects/b1052/shared/qiime/qiime2-core2020.11.simg \
qiime tools extract \
--input-path /projects/b1052/Wells_b1042/McKenna/s2ebpr_16s/core-metrics-results-8000/unweighted_unifrac_distance_matrix.qza \
--output-path /projects/b1052/Wells_b1042/McKenna/s2ebpr_16s/core-metrics-results-8000/

# weighted unifrac distance matrix - moved file from created subdirectory and renamed
singularity exec -B /projects/b1052/Wells_b1042/McKenna/s2ebpr_16s -B /projects/b1052/shared/qiime /projects/b1052/shared/qiime/qiime2-core2020.11.simg \
qiime tools extract \
--input-path /projects/b1052/Wells_b1042/McKenna/s2ebpr_16s/core-metrics-results-8000/weighted_unifrac_distance_matrix.qza \
--output-path /projects/b1052/Wells_b1042/McKenna/s2ebpr_16s/core-metrics-results-8000/
```

11) emperor pcoa plot
```
singularity exec -B /projects/b1052/Wells_b1042/McKenna/s2ebpr_16s -B /projects/b1052/shared/qiime /projects/b1052/shared/qiime/qiime2-core2020.11.simg \
qiime emperor plot --i-pcoa /projects/b1052/Wells_b1042/McKenna/s2ebpr_16s/core-metrics-results-8000/weighted_unifrac_pcoa_results.qza \
--m-metadata-file /projects/b1052/Wells_b1042/McKenna/s2ebpr_16s/metadata.txt \
--o-visualization /projects/b1052/Wells_b1042/McKenna/s2ebpr_16s/visuals/emperor_weighted_unifrac_pcoa_results.qzv
```

12) relative abundance
- makes table of relative abundances of taxa at the genus level (p-level=6)
```
singularity exec -B /projects/b1052/Wells_b1042/McKenna/s2ebpr_16s -B /projects/b1052/shared/qiime /projects/b1052/shared/qiime/qiime2-core2020.11.simg \
qiime taxa collapse \
--i-table /projects/b1052/Wells_b1042/McKenna/s2ebpr_16s/core-metrics-results-8000/rarefied_table.qza \
--i-taxonomy /projects/b1052/Wells_b1042/McKenna/s2ebpr_16s/taxonomy.qza --p-level 6 \
--o-collapsed-table /projects/b1052/Wells_b1042/McKenna/s2ebpr_16s/table_8000_genus.qza
```
- saves table to biom format, which can be converted to other formats
```
singularity exec -B /projects/b1052/Wells_b1042/McKenna/s2ebpr_16s -B /projects/b1052/shared/qiime /projects/b1052/shared/qiime/qiime2-core2020.11.simg \
qiime tools extract --input-path /projects/b1052/Wells_b1042/McKenna/s2ebpr_16s/table_8000_genus.qza \
--output-path /projects/b1052/Wells_b1042/McKenna/s2ebpr_16s/
```

same commands but for the silva classifer results  
- makes table of relative abundances of taxa at the genus level (p-level=6)
```
singularity exec -B /projects/b1052/Wells_b1042/McKenna/s2ebpr_16s -B /projects/b1052/shared/qiime /projects/b1052/shared/qiime/qiime2-core2020.11.simg \
qiime taxa collapse \
--i-table /projects/b1052/Wells_b1042/McKenna/s2ebpr_16s/core-metrics-results-8000/rarefied_table.qza \
--i-taxonomy /projects/b1052/Wells_b1042/McKenna/s2ebpr_16s/taxonomy_silva.qza --p-level 6 \
--o-collapsed-table /projects/b1052/Wells_b1042/McKenna/s2ebpr_16s/table_8000_genus_silva.qza
```
- saves table to biom format, which can be converted to other formats
```
singularity exec -B /projects/b1052/Wells_b1042/McKenna/s2ebpr_16s -B /projects/b1052/shared/qiime /projects/b1052/shared/qiime/qiime2-core2020.11.simg \
qiime tools extract --input-path /projects/b1052/Wells_b1042/McKenna/s2ebpr_16s/table_8000_genus_silva.qza \
--output-path /projects/b1052/Wells_b1042/McKenna/s2ebpr_16s/
```
