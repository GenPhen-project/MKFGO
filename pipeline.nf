#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

params {
    use_dlmgo = true
    input_fasta = 'test_seq.fasta'
    go_types = ['MF', 'BP', 'CC']
    outdir = 'results'  // Add output directory parameter
}

// Import modules
include { EXTRACT_FEATURES; HAND_CRAFT; PLM; PPI; GLM; ENSEMBLE } from './modules/prediction'

workflow {
    // Input validation
    if (!file(params.input_fasta).exists()) {
        error "Input FASTA file ${params.input_fasta} does not exist"
    }
    
    // Create and validate channels
    Channel
        .fromPath(params.input_fasta)
        .ifEmpty { error "Cannot find FASTA file: ${params.input_fasta}" }
        .splitFasta()
        .set { sequences }

    Channel
        .from(params.go_types)
        .ifEmpty { error "No GO types specified" }
        .set { go_types }

    go_type_channel = go_types.cross(sequences)
    
    // Feature extraction
    def features = EXTRACT_FEATURES(go_type_channel)
    
    // Prediction methods
    def hc_predictions = HAND_CRAFT(go_type_channel, features)
    def plm_predictions = PLM(go_type_channel, features)
    def ppi_predictions = PPI(go_type_channel, features)
    
    // Conditional DLMGO execution
    if (params.use_dlmgo) {
        def glm_predictions = GLM(go_type_channel, features)
        def ensemble_input = [
            hc_predictions,
            plm_predictions,
            ppi_predictions,
            glm_predictions
        ]
    } else {
        def ensemble_input = [
            hc_predictions,
            plm_predictions,
            ppi_predictions
        ]
    }
    
    // Ensemble prediction with improved error handling
    ensemble_results = ENSEMBLE(
        go_type_channel,
        ensemble_input.collect()
    )

    // Save and report results
    ensemble_results
        .map { go_type, predictions -> 
            def output_file = file("${params.outdir}/${go_type}_predictions.txt")
            output_file.text = predictions
            return [go_type, output_file]
        }
        .view { go_type, file -> 
            """
            \nResults for GO type: ${go_type}
            Saved to: ${file.absolutePath}
            """
        }
}

// Define workflow completion handler at script level
workflow.onComplete {
    log.info """
    Pipeline completed at: ${workflow.complete}
    Execution status: ${workflow.success ? 'SUCCESS' : 'FAILED'}
    Duration: ${workflow.duration}
    """
}
