process TRAIN_NAIGO {
    tag "NAIGO training"
    
    input:
    path fasta
    
    output:
    path "naigo_model/*", emit: model
    
    script:
    """
    mkdir -p naigo_model
    python ${baseDir}/../testing/naive_method.py \
        --input ${fasta} \
        --outdir naigo_model/ \
        --training_mode true
    """
}