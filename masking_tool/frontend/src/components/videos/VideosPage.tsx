import {useEffect, useState} from "react";
import {useDispatch} from "react-redux";
import {useParams} from "react-router";
import {Box, Divider} from "@mui/material";
import DoubleVideo from "./DoubleVideo";
import VideoRunParams from "./VideoRunParams";
import VideoResultsOverview from "./VideoResultsOverview";
import Command from "../../state/actions/command";

const VideosPage = () => {
    const dispatch = useDispatch();
    const { videoName } = useParams<{ videoName: string }>();

    const [selectedResult, setSelectedResult] = useState<string|undefined>()

    const updateSelectedResult = (resultVideoName: string) => {
        setSelectedResult(resultVideoName)
    }

    useEffect(() => {
        dispatch(Command.Video.fetchVideoList({}));
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
