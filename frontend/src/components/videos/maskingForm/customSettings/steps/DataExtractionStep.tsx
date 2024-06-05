import { Box, Typography } from "@mui/material";
import CheckableCard from "../../../../common/CheckableCard";
import {StepProps} from "./StepProps";

const DataExctactionStep = (props: StepProps) => {
    const threeDParams = {};

    const handleSkeletonChanged = () => {
        // @todo not in use;
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
                    title={"3D Skeleton"}
                    description={"Will create a 3D Skeleton that can be rendered directly in the Browser"}
                    imagePath={'/images/model_extraction/skeleton.png'}
                    checked={false}
                    onSelect={() => handleSkeletonChanged()}
                />
            </Box >
        </>
    )
}

export default DataExctactionStep
