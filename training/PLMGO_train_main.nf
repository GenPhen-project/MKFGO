#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

// Import modules
include { EXTRACT_PROTTRANS; TRAIN_PLMGO } from './modules/plmgo'

workflow plmgo_training {
    take:
        fasta
    
    main:
        // Feature generation
        prottrans_ch = EXTRACT_PROTTRANS(fasta)
        
        // Training
        model_ch = TRAIN_PLMGO(
            prottrans_ch.collect()
        )
    
    emit:
        model = model_ch
}