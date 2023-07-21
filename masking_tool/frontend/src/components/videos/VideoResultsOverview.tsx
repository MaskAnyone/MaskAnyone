import {Box, Paper, Typography, styled, Card, CardMedia, CardContent, IconButton} from "@mui/material";
import { useSelector } from "react-redux";
import Selector from "../../state/selector";
import Config from "../../config";
import { useNavigate } from "react-router";
import Paths from "../../paths";
import MoreVertIcon from '@mui/icons-material/MoreVert';

interface VideoResultsProps {
    videoId: string;
    resultVideoId?: string;
}

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

const VideoResultsOverview = (props: VideoResultsProps) => {
    const navigate = useNavigate();
    const resultVideoLists = useSelector(Selector.Video.resultVideoLists);

    const resultVideos = resultVideoLists[props.videoId] || [];

    const selectResultVideo = (resultVideoId: string) => {
        navigate(Paths.makeResultVideoDetailsUrl(props.videoId, resultVideoId));
    };

    return (
        <Box component="div">
            <Box component={'div'}>
                <Typography variant={"h6"} style={{ marginRight: "10px" }}>Processed Results</Typography>
            </Box>
            <Box component={'div'} sx={{ overflowX: 'auto', whiteSpace: 'nowrap', padding: 1.5, margin: '-4px -12px' }}>
                {resultVideos.map(resultVideo => (
                    <Card variant={'outlined'} sx={{ width: '250px', display: 'inline-block', marginRight: '16px', cursor: 'pointer', '&:hover': { boxShadow: '0 0 13px 0 #c8c8c8' }, '&.selected': { boxShadow: '0 0 13px 0 #777'}}} className={resultVideo.id === props.resultVideoId ? 'selected' : undefined} onClick={() => selectResultVideo(resultVideo.id)}>
                        <CardMedia
                            sx={{ height: 150 }}
                            image={`${Config.api.baseUrl}/videos/${resultVideo.videoId}/results/${resultVideo.id}/preview`}
                        />
                        <CardContent sx={{ position: 'relative' }}>
                            <Typography gutterBottom variant="h6" component="div">
                                Result
                            </Typography>
                            <Typography variant="body2" color="text.secondary">
                                20.07.2023
                            </Typography>
                            <IconButton sx={{ position: 'absolute', top: 4, right: 0 }}>
                                <MoreVertIcon />
                            </IconButton>
                        </CardContent>
                    </Card>
                ))}
            </Box>
        </Box>
    )

}

export default VideoResultsOverview
