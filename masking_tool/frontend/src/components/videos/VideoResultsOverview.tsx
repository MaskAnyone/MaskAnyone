import { useEffect, useState } from "react";
import { Box, Divider, Grid, Paper, Tooltip, Typography, styled } from "@mui/material";
import HelpIcon from '@mui/icons-material/Help';
import {useSelector} from "react-redux";
import Selector from "../../state/selector";
import Config from "../../config";

interface VideoResultsProps {
    videoId: string;
    updateSelectedResult: (resultVideoId: string) => void
}

const VideoResultsOverview = (props: VideoResultsProps) => {
    const resultVideoLists = useSelector(Selector.Video.resultVideoLists);
    const [selectedResultId, setSelectedResultId] = useState<string>();

    const resultVideos = resultVideoLists[props.videoId] || [];

    useEffect(() => {
        if (selectedResultId) {
            props.updateSelectedResult(selectedResultId);
        }
    }, [selectedResultId])

    const Item = styled(Paper)(() => ({
        backgroundColor: '#bdc3c7',
        padding: 8,
        textAlign: 'center',
        color: 'black',
        cursor: "pointer",
        '&:hover': {
            background: "#3498db",
        }
    }));

    return (
        <>
            <Divider style={{marginTop: "20px"}}/>
            <Box component="div" sx={{bgcolor: 'background.paper'}}>
                <div style={{display: "flex", alignItems: "center", marginTop: "20px"}}>
                    <Typography variant={"h6"} style={{marginRight: "10px"}}>Processed Results</Typography>
                    <Tooltip title=" Click on a result to run it next to the original video">
                        <HelpIcon />
                    </Tooltip>
                </div>
                <Grid container spacing={4}>
                    {resultVideos.map(resultVideo => {
                        return (
                            <Grid item xs={4} key={resultVideo.id}>
                                <Item elevation={3} onClick={() => setSelectedResultId(resultVideo.id)} style={resultVideo.id === selectedResultId ? {background: "#3498db"} : {}}>
                                    <img
                                        src={`${Config.api.baseUrl}/videos/${resultVideo.videoId}/results/${resultVideo.id}/preview`}
                                        style={{maxHeight: '200px', maxWidth: "100%" }}
                                    />
                                    <h4>{resultVideo.id}</h4>
                                </Item>
                            </Grid>
                        )
                    })}
                </Grid>
            </Box>
        </>
    )

}

export default VideoResultsOverview
