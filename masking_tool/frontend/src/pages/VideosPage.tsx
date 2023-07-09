import {useEffect, useState} from "react";
import {useParams} from "react-router";
import {Box, Divider} from "@mui/material";
import DoubleVideo from "../components/videos/DoubleVideo";
import VideoResultsOverview from "../components/videos/VideoResultsOverview";
import {useDispatch} from "react-redux";
import Command from "../state/actions/command";
import VideoTaskBar from "../components/videos/VideoTaskBar";

const VideosPage = () => {
    const dispatch = useDispatch();
    const { videoId, resultVideoId } = useParams<{ videoId: string, resultVideoId: string }>();

    useEffect(() => {
        if (videoId) {
            dispatch(Command.Video.fetchResultVideoList({ videoId }));
        }
    }, [videoId]);

    useEffect(() => {
        if (videoId && resultVideoId) {
            dispatch(Command.Video.fetchDownloadableResultFiles({ videoId, resultVideoId }));
        }
    }, [videoId, resultVideoId]);

    if (!videoId) {
        return null;
    }

    return (
        <Box component="div">
            <VideoTaskBar videoId={videoId} resultVideoId={resultVideoId} />
            <DoubleVideo videoId={videoId} resultVideoId={resultVideoId} />
            <VideoResultsOverview key={videoId} videoId={videoId} resultVideoId={resultVideoId} />
        </Box>
    );
};

export default VideosPage;
