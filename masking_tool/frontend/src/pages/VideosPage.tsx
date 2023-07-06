import {useState} from "react";
import {useParams} from "react-router";
import {Box, Divider} from "@mui/material";
import DoubleVideo from "../components/videos/DoubleVideo";
import VideoRunParams from "../components/videos/VideoRunParams";
import VideoResultsOverview from "../components/videos/VideoResultsOverview";

const VideosPage = () => {
    const { videoId } = useParams<{ videoId: string }>();

    const [selectedResult, setSelectedResult] = useState<string|undefined>()

    const updateSelectedResult = (resultVideoName: string) => {
        setSelectedResult(resultVideoName)
    }

    return (
        <Box component="div">
            {videoId && (<VideoRunParams videoId={videoId} />)}
            <Divider style={{marginBottom: "15px"}}/>
            {videoId && (<DoubleVideo videoId={videoId} selectedResult={selectedResult}/>)}
            {videoId && (<VideoResultsOverview key={videoId} videoId={videoId} updateSelectedResult={updateSelectedResult} />)}
        </Box>
    );
};

export default VideosPage;
