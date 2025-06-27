process GENERATE_PSSM {
    tag "PSSM generation"
    
    input:
    path fasta
    
    output:
    path "pssm_features/*", emit: pssm_features
    
    script:
    """
    mkdir -p pssm_features
    python ${baseDir}/../testing/generate_pssm_feature.py \
        --input ${fasta} \
        --outdir pssm_features/
    """
}

process GENERATE_SS {
    tag "Secondary structure prediction"
    
    input:
    path fasta
    
    output:
    path "ss_features/*", emit: ss_features
    
    script:
    """
    mkdir -p ss_features
    python ${baseDir}/../testing/generate_ss_feature.py \
        --input ${fasta} \
        --outdir ss_features/
    """
}

process GENERATE_INTERPRO {
    tag "InterPro feature extraction"
    
    input:
    path fasta
    
    output:
    path "interpro_features/*", emit: interpro_features
    
    script:
    """
    mkdir -p interpro_features
    python ${baseDir}/../testing/generate_interpro_feature.py \
        --input ${fasta} \
        --outdir interpro_features/
    """
}

process TRAIN_HFRGO {
    tag "HFRGO training"
    label 'gpu'
    
    input:
    path pssm_features
    path ss_features
    path interpro_features
    
    output:
    path "hfrgo_model/*", emit: model
    
    script:
    """
    mkdir -p hfrgo_model
    python ${baseDir}/../training/LSTM_Combine_PSSM_SS_InterPro_Attention_Triplet.py \
        --pssm ${pssm_features} \
        --ss ${ss_features} \
        --interpro ${interpro_features} \
        --outdir hfrgo_model/
    """
}