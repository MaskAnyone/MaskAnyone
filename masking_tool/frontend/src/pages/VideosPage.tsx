import {useEffect, useState} from "react";
import {useDispatch} from "react-redux";
import {useParams} from "react-router";
import {Box, Divider} from "@mui/material";
import DoubleVideo from "../components/videos/DoubleVideo";
import VideoRunParams from "../components/videos/VideoRunParams";
import VideoResultsOverview from "../components/videos/VideoResultsOverview";
import Command from "../state/actions/command";
import PoseRenderer3D from "../components/videos/PoseRenderer3D";

const VideosPage = () => {
    const dispatch = useDispatch();
    const { videoId } = useParams<{ videoId: string }>();

    const [selectedResult, setSelectedResult] = useState<string|undefined>()

    const updateSelectedResult = (resultVideoName: string) => {
        setSelectedResult(resultVideoName)
    }

    useEffect(() => {
        dispatch(Command.Video.fetchVideoList({}));
    }, []);

    return (
        <Box>
            {videoId && (<VideoRunParams videoId={videoId} />)}
            <Divider style={{marginBottom: "15px"}}/>
            {videoId && (<DoubleVideo videoId={videoId} selectedResult={selectedResult}/>)}
            {videoId && (<VideoResultsOverview key={videoId} videoId={videoId} updateSelectedResult={updateSelectedResult} />)}

            {/*<PoseRenderer3D />*/}
        </Box>
    );
};

export default VideosPage;