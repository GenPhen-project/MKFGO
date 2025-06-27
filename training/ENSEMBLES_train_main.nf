#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

// Import modules
include { CREATE_SAMPLE_FILE; TRAIN_ENSEMBLE } from './modules/ensembles'

workflow ensembles_training {
    take:
        hfrgo_predictions
        plmgo_predictions
        ppigo_predictions
        naigo_predictions
        dlmgo_predictions
    
    main:
        // Create unified sample file
        sample_data_ch = CREATE_SAMPLE_FILE(
            hfrgo_predictions,
            plmgo_predictions,
            ppigo_predictions,
            naigo_predictions,
            dlmgo_predictions
        )
        
        // Train ensemble model
        model_ch = TRAIN_ENSEMBLE(sample_data_ch)
    
    emit:
        model = model_ch
}

workflow {
    // Input validation
    if (!params.predictions_dir) {
        error "Please provide predictions directory with --predictions_dir"
    }
    
    // Input channels for predictions from each model
    ch_hfrgo = channel.fromPath("${params.predictions_dir}/hfrgo/*")
    ch_plmgo = channel.fromPath("${params.predictions_dir}/plmgo/*")
    ch_ppigo = channel.fromPath("${params.predictions_dir}/ppigo/*")
    ch_naigo = channel.fromPath("${params.predictions_dir}/naigo/*")
    ch_dlmgo = channel.fromPath("${params.predictions_dir}/dlmgo/*")
    
    // Run ensembles training workflow
    ensembles_training(
        ch_hfrgo,
        ch_plmgo,
        ch_ppigo,
        ch_naigo,
        ch_dlmgo
    )
}