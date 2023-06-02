import {useEffect} from "react";
import Api from "../../api";
import {useDispatch} from "react-redux";
import Event from "../../state/actions/event";
import {useParams} from "react-router";
import {Box, Button} from "@mui/material";
import Config from "../../config";
import MasksIcon from '@mui/icons-material/Masks';
import DoubleVideo from "./DoubleVideo";

const VideosPage = () => {
    const dispatch = useDispatch();
    const { videoName } = useParams<{ videoName: string }>();

    useEffect(() => {
        Api.fetchVideos().then(videos => {
            dispatch(Event.Video.videoListFetched({ videoList: videos }));
        });
    }, []);

    const maskVideo = () => {
        if (!videoName) {
            return;
        }

        Api.maskVideo(videoName);
    };

    return (
        <Box>
            <Box sx={{ marginBottom: 2 }}>
                <Button
                    variant={'contained'}
                    startIcon={<MasksIcon />}
                    children={'Mask Video'}
                    onClick={maskVideo}
                />
            </Box>
            {videoName && (
                <DoubleVideo videoName={videoName} />
            )}
        </Box>
    );
};

export default VideosPage;
