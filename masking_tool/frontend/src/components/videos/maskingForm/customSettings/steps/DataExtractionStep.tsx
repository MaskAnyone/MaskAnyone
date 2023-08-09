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
            <Typography variant="body1" sx={{ fontWeight: 500 }} mt={3}>
                Additional Data to be exported
            </Typography >
            <Box component="div" sx={{ display: 'flex', flexDirection: 'row', flexWrap: 'wrap', gap: '15px' }} mt={1}>
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