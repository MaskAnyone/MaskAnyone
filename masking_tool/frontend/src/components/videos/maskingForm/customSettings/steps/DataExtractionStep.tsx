import { Box, Typography } from "@mui/material";
import CheckableCard from "../../../../common/CheckableCard";
import { StepProps } from "./HidingStep";

const DataExctactionStep = (props: StepProps) => {
    const threeDParams = props.runParams.threeDModelCreation

    const handleBlenderChanged = () => {
        props.onParamsChange({
            ...props.runParams,
            threeDModelCreation: {
                ...threeDParams,
                blender: !threeDParams.blender,
                blenderParams: {}
            }
        })
    }

    const handleSkeletonChanged = () => {
        props.onParamsChange({
            ...props.runParams,
            threeDModelCreation: {
                ...threeDParams,
                skeleton: !threeDParams.skeleton,
                skeletonParams: {}
            }
        })
    }

    const handleBlendshapesChanged = () => {
        props.onParamsChange({
            ...props.runParams,
            threeDModelCreation: {
                ...threeDParams,
                blendshapes: !threeDParams.blendshapes,
                blendshapesParams: {}
            }
        })
    }

    return (
        <>
            <Box component={'div'} sx={{ marginBottom: 3.5 }}>
                <Typography variant="h6">
                    Do you want to export additional data?
                </Typography >
                <Typography variant={'body2'}>
                    If besides masking the video you also want to work with the kinematic information, you can extract them here. Please beware that this can slow down the masking process.
                </Typography>
            </Box>
            <Box component="div" sx={{ display: 'flex', flexDirection: 'row', flexWrap: 'wrap', gap: '24px' }} mt={1}>
                <CheckableCard
                    title={"Blender 3D Character"}
                    description={"Will create a 3D model in Blender based on a MediaPipe Skeleton."}
                    imagePath={""}
                    checked={threeDParams.blender}
                    onSelect={() => handleBlenderChanged()}
                />
                <CheckableCard
                    title={"3D Skeleton"}
                    description={"Will create a 3D Skeleton that can be rendered directly in the Browser"}
                    imagePath={""}
                    checked={threeDParams.skeleton}
                    onSelect={() => handleSkeletonChanged()}
                />
                <CheckableCard
                    title={"Facial 3D Model"}
                    description={"Will create a Blendshapes based 3D facial model"}
                    imagePath={""}
                    checked={threeDParams.blendshapes}
                    onSelect={() => handleBlendshapesChanged()}
                />
            </Box >
        </>
    )
}

export default DataExctactionStep