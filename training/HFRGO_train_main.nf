#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

// Import modules
include { GENERATE_PSSM; GENERATE_SS; GENERATE_INTERPRO; TRAIN_HFRGO } from './modules/hfrgo'

workflow hfrgo_training {
    take:
        fasta
    
    main:
        // Feature generation
        pssm_ch = GENERATE_PSSM(fasta)
        ss_ch = GENERATE_SS(fasta)
        interpro_ch = GENERATE_INTERPRO(fasta)
        
        // Training
        model_ch = TRAIN_HFRGO(
            pssm_ch.collect(),
            ss_ch.collect(),
            interpro_ch.collect()
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
    
    // Run HFRGO training workflow
    hfrgo_training(ch_fasta)
}