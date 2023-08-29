def produces_out_vid(run_params: dict):
    masking_params = run_params["videoMasking"]
    voice_masking_strategy = run_params["voiceMasking"]["maskingStrategy"]["key"]
    if voice_masking_strategy != "none" and voice_masking_strategy != "preserve":
        return True
    for video_part in masking_params:
        if masking_params[video_part]["hidingStrategy"]["key"] != "none":
            return True
        if masking_params[video_part]["maskingStrategy"]["key"] != "none":
            return True
    return False


def produces_kinematics(run_params: dict):
    if run_params["threeDModelCreation"]["skeleton"]:
        return True
    return False


def produces_blendshapes(run_params: dict):
    if run_params["threeDModelCreation"]["blendshapes"]:
        return True
    return False


def produces_out_audio(run_params: dict):
    if run_params["voiceMasking"]["maskingStrategy"]["key"] == "switch":
        return True

    return False
