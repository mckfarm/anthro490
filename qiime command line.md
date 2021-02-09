## QIIME commands in Quest interactive session  
\ - backslash allows you to type a new line without running the commands  

```
srun --account=e31333 --time=2:00:00 --partition=short --mem=4G --pty bash -l
```  

always load in singularity module  
key line needed to start every command since qiime2 runs in a singularity container

```
singularity exec -B /projects/e31333 -B /projects/e31333/mckenna /projects/e31333/qiime2-core2020-6.simg \
```

**First html doc**  

importing paired end reads
```
singularity exec -B /projects/e31333 -B /projects/e31333/mckenna /projects/e31333/qiime2-core2020-6.simg \
qiime tools import --input-path /projects/e31333/mckenna/manifest.csv \
--output-path /projects/e31333/mckenna/baboon_paired.qza --type SampleData[PairedEndSequencesWithQuality] \
--input-format PairedEndFastqManifestPhred33
```

visualization output
```
singularity exec -B /projects/e31333 -B /projects/e31333/mckenna /projects/e31333/qiime2-core2020-6.simg \
qiime demux summarize --i-data /projects/e31333/mckenna/baboon_paired.qza \
--o-visualization /projects/e31333/mckenna/baboon_paired.qzv
```

dada2 bash script (dada2.sh)
- remove # comments when pasting to bash script
- this command creates three files: dada2 quality filtering table (stats), data table of read info that can be coupled to metadata (table), and a list of amplicon sequence variants that will be used for blast (rep_seqs)
```
singularity exec -B /projects/e31333 -B /projects/e31333/mckenna /projects/e31333/qiime2-core2020-6.simg \
qiime dada2 denoise-paired --i-demultiplexed-seqs /projects/e31333/mckenna/baboon_paired.qza \ #call dada2 on qza file
--p-trim-left-f 20 --p-trim-left-r 21 --p-trunc-len-f 260 --p-trunc-len-r 240 \ # trim forward and reverse reads
--o-representative-sequences /projects/e31333/mckenna/rep_seqs_dada2.qza \ # outputs
--o-table /projects/e31333/mckenna/table_dada2.qza --o-denoising-stats /projects/e31333/mckenna/stats_dada2.qza
```

dada2 visualization
```
singularity exec -B /projects/e31333 -B /projects/e31333/mckenna /projects/e31333/qiime2-core2020-6.simg \
qiime metadata tabulate --m-input-file /projects/e31333/mckenna/stats_dada2.qza \
--o-visualization /projects/e31333/mckenna/stats_dada2.qzv
```

mapping file - couples metadata to sequences
```
singularity exec -B /projects/e31333 -B /projects/e31333/mckenna /projects/e31333/qiime2-core2020-6.simg \
qiime feature-table summarize --i-table /projects/e31333/mckenna/table_dada2.qza \
--o-visualization /projects/e31333/mckenna/table_dada2.qzv \
--m-sample-metadata-file /projects/e31333/16S_data/baboon_metadata.txt
```

list ASV sequences - this will allow us to use blast on sequences
```
singularity exec -B /projects/e31333 -B /projects/e31333/mckenna /projects/e31333/qiime2-core2020-6.simg \
qiime feature-table tabulate-seqs --i-data /projects/e31333/mckenna/rep_seqs_dada2.qza \
--o-visualization /projects/e31333/mckenna/rep-seqs_dada2.qzv
```

phylogenetic tree bash script (tree.sh)
- creates phylogenetic alignment using MAFFT and creates a tree using fasttree
```
singularity exec -B /projects/e31333 -B /projects/e31333/mckenna /projects/e31333/qiime2-core2020-6.simg \
qiime phylogeny align-to-tree-mafft-fasttree --i-sequences /projects/e31333/mckenna/rep_seqs_dada2.qza \
--o-alignment /projects/e31333/mckenna/aligned_rep_seqs_dada2.qza \
--o-masked-alignment /projects/e31333/mckenna/masked_aligned_rep_seqs_dada2.qza \
--o-tree /projects/e31333/mckenna/unrooted_tree.qza --o-rooted-tree /projects/e31333/mckenna/rooted_tree.qza
```

**Switch to qiime2-core2020-2.simg, container was originally mislabeled**

taxonomic assignment bash script (taxa.sh)
```
singularity exec -B /projects/e31333 -B /projects/e31333/mckenna /projects/e31333/qiime2-core2020-2.simg \
qiime feature-classifier classify-sklearn --i-classifier /projects/e31333/silva-138-99-nb-classifier-20-2.qza \
--i-reads /projects/e31333/mckenna/rep_seqs_dada2.qza --o-classification /projects/e31333/mckenna/taxonomy.qza
```

list of ASVs and taxonomy
```
singularity exec -B /projects/e31333 -B /projects/e31333/mckenna /projects/e31333/qiime2-core2020-2.simg qiime \
metadata tabulate --m-input-file /projects/e31333/mckenna/taxonomy.qza \
--o-visualization /projects/e31333/mckenna/taxonomy.qzv
```

filter out chloroplasts and mitochondria
```
singularity exec -B /projects/e31333 -B /projects/e31333/mckenna /projects/e31333/qiime2-core2020-2.simg \
qiime taxa filter-table --i-table /projects/e31333/mckenna/table_dada2.qza \
--i-taxonomy /projects/e31333/mckenna/taxonomy.qza --p-exclude mitochondria,chloroplast \
--o-filtered-table /projects/e31333/mckenna/table_dada2_nomito_nochloro.qza
```

show results again via mapping file without chloroplast and mitrochondria
```
singularity exec -B /projects/e31333 -B /projects/e31333/mckenna /projects/e31333/qiime2-core2020-2.simg \
qiime feature-table summarize --i-table /projects/e31333/mckenna/table_dada2_nomito_nochloro.qza \
--o-visualization /projects/e31333/mckenna/table_dada2_nomito_nochloro.qzv \
--m-sample-metadata-file /projects/e31333/16S_data/baboon_metadata.txt
```


**Next html doc**

alpha rarefaction curves - determining how well the sequencing went, measure of how diversity changes with sequencing depth
```
singularity exec -B /projects/e31333 -B /projects/e31333/mckenna /projects/e31333/qiime2-core2020-2.simg \
qiime diversity alpha-rarefaction --i-table /projects/e31333/mckenna/table_dada2.qza \
--i-phylogeny /projects/e31333/mckenna/rooted_tree.qza \
--o-visualization /projects/e31333/mckenna/alpha_rarefaction.qzv --p-max-depth 15000
```

alpha and beta diversity - normalizing through rarefying then calculating diversity indices
```
singularity exec -B /projects/e31333 -B /projects/e31333/mckenna /projects/e31333/qiime2-core2020-2.simg \
qiime diversity core-metrics-phylogenetic --i-phylogeny /projects/e31333/mckenna/rooted_tree.qza \
--i-table /projects/e31333/mckenna/table_dada2_nomito_nochloro.qza --p-sampling-depth 1500 \
--m-metadata-file /projects/e31333/16S_data/baboon_metadata.txt --output-dir /projects/e31333/mckenna/core-metrics-results-1500
```

extracting alpha and beta diversity matrices for downstream analysis
unweighted unifrac distance matrix
```
singularity exec -B /projects/e31333 -B /projects/e31333/mckenna /projects/e31333/qiime2-core2020-2.simg \
qiime tools extract --input-path /projects/e31333/mckenna/core-metrics-results-1500/unweighted_unifrac_distance_matrix.qza \
--output-path /projects/e31333/mckenna/core-metrics-results-1500/
```

weighted unifrac distance matrix
```
singularity exec -B /projects/e31333 -B /projects/e31333/mckenna /projects/e31333/qiime2-core2020-2.simg \
qiime tools extract \
--input-path /projects/e31333/mckenna/core-metrics-results-1500/weighted_unifrac_distance_matrix.qza \
--output-path /projects/e31333/mckenna/core-metrics-results-1500/
```

emperor PCoA plots
```
singularity exec -B /projects/e31333 -B /projects/e31333/mckenna /projects/e31333/qiime2-core2020-2.simg \
qiime emperor plot --i-pcoa /projects/e31333/mckenna/core-metrics-results-1500/weighted_unifrac_pcoa_results.qza \
--m-metadata-file /projects/e31333/16S_data/baboon_metadata.txt \
--o-visualization /projects/e31333/mckenna/emperor_weighted_unifrac_pcoa_results.qzv
```

relative abundance tables
- makes table of relative abundances of taxa at the genus level (p-level=6)
```
singularity exec -B /projects/e31333 -B /projects/e31333/mckenna /projects/e31333/qiime2-core2020-2.simg \
qiime taxa collapse --i-table /projects/e31333/mckenna/core-metrics-results-1500/rarefied_table.qza \
--i-taxonomy /projects/e31333/mckenna/taxonomy.qza --p-level 6 \
--o-collapsed-table /projects/e31333/mckenna/table_dada2_nomito_nochloro_even1500_genus.qza
```
- saves table to biom format, which can be converted to other formats
```
singularity exec -B /projects/e31333 -B /projects/e31333/mckenna /projects/e31333/qiime2-core2020-2.simg \
qiime tools extract --input-path /projects/e31333/mckenna/table_dada2_nomito_nochloro_even1500_genus.qza \
--output-path /projects/e31333/mckenna/
```

filtering - can filter by metadata
```
singularity exec -B /projects/e31333 -B /projects/e31333/mckenna /projects/e31333/qiime2-core2020-2.simg \
qiime feature-table filter-samples --i-table /projects/e31333/mckenna/table_dada2_nomito_nochloro.qza \
--m-metadata-file /projects/e31333/16S_data/baboon_metadata.txt --p-where "diet='garbage'" \
--o-filtered-table /projects/e31333/mckenna/table_dada2_nomito_nochloro_garbage.qza
```

statistics - core microbiome
- can set a cut off for abundance to be considered in the core
```
singularity exec -B /projects/e31333 -B /projects/e31333/mckenna /projects/e31333/qiime2-core2020-2.simg \
qiime feature-table core-features --i-table /projects/e31333/mckenna/table_dada2_nomito_nochloro.qza \
--p-min-fraction 0.7 --p-steps 4 --output-dir /projects/e31333/mckenna/core
```

ANCOM
- set up pseudotable
```
singularity exec -B /projects/e31333 -B /projects/e31333/mckenna /projects/e31333/qiime2-core2020-2.simg \
qiime composition add-pseudocount --i-table /projects/e31333/mckenna/table_dada2_nomito_nochloro.qza \
--o-composition-table /projects/e31333/mckenna/table_dada2_nomito_nochloro_comp.qza
```
- run ancom
```
singularity exec -B /projects/e31333 -B /projects/e31333/mckenna /projects/e31333/qiime2-core2020-2.simg \
qiime composition ancom --i-table /projects/e31333/mckenna/table_dada2_nomito_nochloro_comp.qza \
--m-metadata-file /projects/e31333/16S_data/baboon_metadata.txt --m-metadata-column diet \
--o-visualization /projects/e31333/mckenna/ancom-diet.qzv
```

Supervised learning algorithm - bash?
```
singularity exec -B /projects/e31333 -B /projects/e31333/mckenna /projects/e31333/qiime2-core2020-2.simg \
qiime sample-classifier classify-samples --i-table /projects/e31333/mckenna/table_dada2_nomito_nochloro_comp.qza \
--m-metadata-file /projects/e31333/16S_data/baboon_metadata.txt --m-metadata-column diet \
--p-optimize-feature-selection --p-parameter-tuning --p-estimator RandomForestClassifier \
--p-n-estimators 20 --output-dir  /projects/e31333/mckenna/supervised_learning
