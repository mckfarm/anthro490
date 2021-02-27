

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
