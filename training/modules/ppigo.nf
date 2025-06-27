process GENERATE_PPI_FEATURES {
    tag "PPI feature extraction"
    
    input:
    path fasta
    
    output:
    path "ppi_features/*", emit: ppi_features
    
    script:
    """
    mkdir -p ppi_features
    python ${baseDir}/../testing/generate_ppi_features.py \
        --input ${fasta} \
        --outdir ppi_features/
    """
}

process TRAIN_PPIGO {
    tag "PPIGO training"
    label 'gpu'
    
    input:
    path ppi_features
    
    output:
    path "ppigo_model/*", emit: model
    
    script:
    """
    mkdir -p ppigo_model
    python ${baseDir}/../training/PPIGO_train.py \
        --features ${ppi_features} \
        --outdir ppigo_model/
    """
}