process DOWNLOAD_SEQUENCES {
    tag "Download gene sequences"
    
    input:
    path uniprot_ids
    
    output:
    path "sequences/*", emit: sequences
    
    script:
    """
    mkdir -p sequences
    python ${baseDir}/../testing/download_gene_sequence.py \
        --input ${uniprot_ids} \
        --outdir sequences/
    """
}

process EXTRACT_NCTRANS {
    tag "Extract NCTrans features"
    label 'gpu'
    
    input:
    path sequences
    
    output:
    path "nctrans_features/*", emit: features
    
    script:
    """
    mkdir -p nctrans_features
    python ${baseDir}/../testing/nctrans_extract.py \
        --input ${sequences} \
        --outdir nctrans_features/
    """
}

process TRAIN_DLMGO {
    tag "DLMGO training"
    label 'gpu'
    
    input:
    path features
    
    output:
    path "dlmgo_model/*", emit: model
    
    script:
    """
    mkdir -p dlmgo_model
    python ${baseDir}/../training/Triplet_Network_With_Global_Loss.py \
        --features ${features} \
        --outdir dlmgo_model/
    """
}