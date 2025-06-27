#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

// Import modules
include { GENERATE_PPI_FEATURES; TRAIN_PPIGO } from './modules/ppigo'

workflow ppigo_training {
    take:
        fasta
    
    main:
        // Feature generation
        ppi_ch = GENERATE_PPI_FEATURES(fasta)
        
        // Training
        model_ch = TRAIN_PPIGO(
            ppi_ch.collect()
        )
    
    emit:
        model = model_ch
}

workflow {
    // Input validation
    if (!params.input_fasta) {
        error "Please provide input FASTA file with --input_fasta"
    }
    
    // Channel for input fasta
    ch_fasta = channel.fromPath(params.input_fasta)
    
    // Run PPIGO training workflow
    ppigo_training(ch_fasta)
}