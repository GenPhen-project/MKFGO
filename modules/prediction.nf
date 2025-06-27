process EXTRACT_FEATURES {
    tag "Feature extraction"
    
    input:
        tuple val(go_type), path(fasta)
        
    output:
        tuple val(go_type), path("${go_type}_features/*")
        
    script:
        """
        mkdir -p ${go_type}_features
        python ../testing/generate_pssm_feature.py ${fasta} ${go_type}_features/
        python ../testing/generate_ss_feature.py ${fasta} ${go_type}_features/
        python ../testing/generate_interpro_feature.py ${fasta} ${go_type}_features/
        """
}

process HAND_CRAFT {
    tag "Hand-craft prediction"
    
    input:
        tuple val(go_type), path(features)
        
    output:
        tuple val(go_type), path("${go_type}_hc_predictions/*")
        
    script:
        """
        mkdir -p ${go_type}_hc_predictions
        python ../testing/hand_craft_method.py ${go_type} ${features}
        mv *.txt ${go_type}_hc_predictions/
        """
}

process PLM {
    tag "PLM prediction"
    
    input:
        tuple val(go_type), path(features)
        
    output:
        tuple val(go_type), path("${go_type}_plm_predictions/*")
        
    script:
        """
        mkdir -p ${go_type}_plm_predictions
        python ../testing/plm_method.py ${go_type} ${features}
        mv *.txt ${go_type}_plm_predictions/
        """
}

process PPI {
    tag "PPI prediction"
    
    input:
        tuple val(go_type), path(features)
        
    output:
        tuple val(go_type), path("${go_type}_ppi_predictions/*")
        
    script:
        """
        mkdir -p ${go_type}_ppi_predictions
        python ../testing/ppi_method.py ${go_type} ${features}
        mv *.txt ${go_type}_ppi_predictions/
        """
}

process GLM {
    tag "GLM prediction"
    input:
        tuple val(go_type), path(features)
        
    when:
        params.use_dlmgo
        
    output:
        tuple val(go_type), path("${go_type}_glm_predictions/*")
        
    script:
        """
        mkdir -p ${go_type}_glm_predictions
        python ../testing/glm_method.py ${go_type} ${features}
        mv *.txt ${go_type}_glm_predictions/
        """
}

process ENSEMBLE {
    tag "Ensemble prediction"
    
    input:
        tuple val(go_type), path(hc), path(plm), path(ppi), path(glm)
        
    output:
        tuple val(go_type), path("${go_type}_ensemble_predictions/*")
        
    script:
        """
        mkdir -p ${go_type}_ensemble_predictions
        python ../testing/ensemble_method.py ${go_type} ${params.use_dlmgo} ${hc} ${plm} ${ppi} ${glm}
        mv *.txt ${go_type}_ensemble_predictions/
        """
}
