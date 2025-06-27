process EXTRACT_PROTTRANS {
    tag "ProtTrans feature extraction"
    label 'gpu'
    
    input:
    path fasta
    
    output:
    path "prottrans_features/*", emit: prottrans_features
    
    script:
    """
    mkdir -p prottrans_features
    python ${baseDir}/../testing/prottrans_extract.py \
        --input ${fasta} \
        --outdir prottrans_features/
    """
}

process TRAIN_PLMGO {
    tag "PLMGO training"
    label 'gpu'
    
    input:
    path prottrans_features
    
    output:
    path "plmgo_model/*", emit: model
    
    script:
    """
    mkdir -p plmgo_model
    python ${baseDir}/../training/PLMGO_train.py