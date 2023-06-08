import {useEffect} from "react";
import Api from "../../api";
import {useDispatch} from "react-redux";
import Event from "../../state/actions/event";
import {useParams} from "react-router";
import {Box, Divider} from "@mui/material";
import Config from "../../config";
import DoubleVideo from "./DoubleVideo";
import VideoRunParams from "./VideoRunParams";

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
            {videoName && (<VideoRunParams videoName={videoName} />)}
            <Divider style={{marginBottom: "15px"}}/>
            {videoName && (<DoubleVideo videoName={videoName} />)}
        </Box>
    );
};

export default VideosPage;
