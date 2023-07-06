import {useEffect, useState} from "react";
import {useParams} from "react-router";
import {Box, Divider} from "@mui/material";
import DoubleVideo from "../components/videos/DoubleVideo";
import VideoRunParams from "../components/videos/VideoRunParams";
import VideoResultsOverview from "../components/videos/VideoResultsOverview";
import {useDispatch} from "react-redux";
import Command from "../state/actions/command";

const VideosPage = () => {
    const dispatch = useDispatch();
    const { videoId } = useParams<{ videoId: string }>();
    const [selectedResultId, setSelectedResultId] = useState<string>();

    useEffect(() => {
        if (videoId) {
            dispatch(Command.Video.fetchResultVideoList({ videoId }));
        }
    }, [videoId]);

    return (
        <Box component="div">
            {videoId && (<VideoRunParams videoId={videoId} />)}
            <Divider style={{marginBottom: "15px"}}/>
            {videoId && <DoubleVideo videoId={videoId} resultVideoId={selectedResultId} />}
            {videoId && <VideoResultsOverview key={videoId} videoId={videoId} updateSelectedResult={setSelectedResultId} />}
        </Box>
    );
};

export default VideosPage;
