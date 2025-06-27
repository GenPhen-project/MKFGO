#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

// Import modules
include { TRAIN_NAIGO } from './modules/naigo'

workflow naigo_training {
    take:
        fasta
    
    main:
        // Training
        model_ch = TRAIN_NAIGO(fasta)
    
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
    
    // Run NAIGO training workflow
    naigo_training(ch_fasta)
}