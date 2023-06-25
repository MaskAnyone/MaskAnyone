import { Box } from "@mui/system";

interface PresetSelectionProps {
    videoId: string;
}

enum HidingStrategy {
    Blur,
    Blackout,
    Estimate
}

enum HidingSubjects {
    Background,
    Person,
    Head
}

enum PersonDetectionTypes {
    BBox,
    Silhouette
}

type BlurParams<T extends HidingSubjects> = {
    type: HidingStrategy.Blur
    kernelSize: number
} & (T extends HidingSubjects.Background ? {} : { additionalBorder: number });

type BlackoutParams<T extends HidingSubjects> = {
    type: HidingStrategy.Blackout
    color: `rgba(${number}, ${number}, ${number}, ${number})`
} & (T extends HidingSubjects.Background ? {} : { additionalBorder: number });

type EstimationParams = {
    type: HidingStrategy.Estimate
}

type PersonDetectionParamsBBox = {
    model: 'Yolo'
    type: PersonDetectionTypes.BBox
    confidence: number
} 

type PersonDetectionParamsSilhouette = {
    model: 'Yolo'
    type: PersonDetectionTypes.Silhouette
    confidence: number
    smoothingFactor: number
} | {
    model: 'MediaPipe'
    type: PersonDetectionTypes.Silhouette
    confidence: number
    smoothingFactor: number
}   

type HidingParams = {
    bg: BlurParams<HidingSubjects.Background> | BlackoutParams<HidingSubjects.Background>
} & ({
    personDetection: PersonDetectionParamsBBox
    personHidingParams: BlurParams<HidingSubjects.Person> | BlackoutParams<HidingSubjects.Person>
    headHidingParams: BlurParams<HidingSubjects.Head> | BlackoutParams<HidingSubjects.Head>
} | {
    personDetection: PersonDetectionParamsSilhouette
    personHidingParams: BlurParams<HidingSubjects.Person> | BlackoutParams<HidingSubjects.Person> | EstimationParams
    headHidingParams: BlurParams<HidingSubjects.Head> | BlackoutParams<HidingSubjects.Head> | EstimationParams
})

type BodyMaskingParams = {

}

type HeadMaskingParams = {
}

type MaskingParams = {
    body: BodyMaskingParams,
    head: HeadMaskingParams
}

type Preset = {
    name: string,
    hiding: HidingParams,
    masking: MaskingParams
}

const PresetSelection = (props: PresetSelectionProps) => {
    const presets = []
    return(
        <Box>
            
        </Box>
    )
}

export default PresetSelection