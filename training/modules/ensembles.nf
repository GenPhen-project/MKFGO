process CREATE_SAMPLE_FILE {
    tag "Create unified sample file"
    
    input:
    path hfrgo_predictions
    path plmgo_predictions
    path ppigo_predictions
    path naigo_predictions
    path dlmgo_predictions
    
    output:
    path "ensemble_data/*", emit: sample_data
    
    script:
    """
    mkdir -p ensemble_data
    python ${baseDir}/../training/Create_Single_Sample_File.py \
        --hfrgo ${hfrgo_predictions} \
        --plmgo ${plmgo_predictions} \
        --ppigo ${ppigo_predictions} \
        --naigo ${naigo_predictions} \
        --dlmgo ${dlmgo_predictions} \
        --outdir ensemble_data/
    """
}

process TRAIN_ENSEMBLE {
    tag "Train ensemble model"
    
    input:
    path sample_data
    
    output:
    path "ensemble_model/*", emit: model
    
    script:
    """
    mkdir -p ensemble_model
    python ${baseDir}/../training/MLP_Ensemble_SKL.py \
        --input ${sample_data} \
        --outdir ensemble_model/
    """
}