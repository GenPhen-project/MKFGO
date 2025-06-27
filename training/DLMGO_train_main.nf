#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

// Import modules
include { DOWNLOAD_SEQUENCES; EXTRACT_NCTRANS; TRAIN_DLMGO } from './modules/dlmgo'

workflow dlmgo_training {
    take:
        uniprot_ids
    
    main:
        // Download sequences
        sequences_ch = DOWNLOAD_SEQUENCES(uniprot_ids)
        
        // Extract features
        features_ch = EXTRACT_NCTRANS(sequences_ch)
        
        // Training
        model_ch = TRAIN_DLMGO(
            features_ch.collect()
        )
    
    emit:
        model = model_ch
}

workflow {
    // Input validation
    if (!params.uniprot_ids) {
        error "Please provide UniProt IDs file with --uniprot_ids"
    }
    
    // Channel for input IDs
    ch_ids = channel.fromPath(params.uniprot_ids)
    
    // Run DLMGO training workflow
    dlmgo_training(ch_ids)
}