import {useEffect, useState} from "react";
import Api from "../../api";
import {useDispatch} from "react-redux";
import Event from "../../state/actions/event";
import {useParams} from "react-router";
import {Box, Divider} from "@mui/material";
import Config from "../../config";
import DoubleVideo from "./DoubleVideo";
import VideoRunParams from "./VideoRunParams";
import VideoResultsOverview from "./VideoResultsOverview";

const VideosPage = () => {
    const dispatch = useDispatch();
    const { videoName } = useParams<{ videoName: string }>();

    const [selectedResult, setSelectedResult] = useState<string|undefined>()

    const updateSelectedResult = (resultVideoName: string) => {
        setSelectedResult(resultVideoName)
    }

    useEffect(() => {
        Api.fetchVideos().then(videos => {
            dispatch(Event.Video.videoListFetched({ videoList: videos }));
        });
    }, []);

    return (
        <Box>
            {videoName && (<VideoRunParams videoName={videoName} />)}
            <Divider style={{marginBottom: "15px"}}/>
            {videoName && (<DoubleVideo videoName={videoName} selectedResult={selectedResult}/>)}
            {videoName && (<VideoResultsOverview key={videoName} videoName={videoName} updateSelectedResult={updateSelectedResult} />)}
        </Box>
    );
};

export default VideosPage;
