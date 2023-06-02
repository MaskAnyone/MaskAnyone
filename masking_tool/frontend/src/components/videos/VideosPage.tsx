import {useEffect} from "react";
import Api from "../../api";
import {useDispatch} from "react-redux";
import Event from "../../state/actions/event";
import {useParams} from "react-router";
import {Box, Button} from "@mui/material";
import Config from "../../config";
import MasksIcon from '@mui/icons-material/Masks';

const VideosPage = () => {
    const dispatch = useDispatch();
    const { videoName } = useParams<{ videoName: string }>();

    useEffect(() => {
        Api.fetchVideos().then(videos => {
            dispatch(Event.Video.videoListFetched({ videoList: videos }));
        });
    }, []);

    return (
        <Box>
            <Box sx={{ marginBottom: 2 }}>
                <Button variant={'contained'} startIcon={<MasksIcon />}>Mask Video</Button>
            </Box>
            {videoName && (
                <video controls={true} key={videoName} style={{ maxWidth: '100%' }}>
                    <source src={Config.api.baseUrl + '/videos/' + videoName} type={'video/mp4'} key={videoName} />
                </video>
            )}
        </Box>
    );
};

export default VideosPage;
