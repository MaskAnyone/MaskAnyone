import React, { useEffect } from "react";
import { Navigate, useParams } from "react-router";
import { Box, Typography } from "@mui/material";
import Paths from "../paths";
import DoubleVideo from "../components/videos/DoubleVideo";
import VideoResultsOverview from "../components/videos/VideoResultsOverview";
import { useDispatch, useSelector } from "react-redux";
import Command from "../state/actions/command";
import VideoTaskBar from "../components/videos/VideoTaskBar";
import VideoMetadataBar from "../components/videos/VideoMetadataBar";
import Assets from "../assets/assets";
import Selector from "../state/selector";

const VideosPage = () => {
    const dispatch = useDispatch();
    const videoList = useSelector(Selector.Video.videoList);
    const openAndRunningJobCount = useSelector(Selector.Job.openAndRunningJobCount);
    const { videoId, resultVideoId } = useParams<{ videoId: string, resultVideoId: string }>();
    const currentVideo = videoList.find(v => v.id === videoId);

    useEffect(() => {
        if (videoId) {
            dispatch(Command.Video.fetchResultsList({ videoId }));
        }
    // eslint-disable-next-line react-hooks/exhaustive-deps
    }, [videoId, openAndRunningJobCount]);

    useEffect(() => {
        if (videoId && resultVideoId) {
            dispatch(Command.Video.fetchDownloadableResultFiles({ videoId, resultVideoId }));
        }
    // eslint-disable-next-line react-hooks/exhaustive-deps
    }, [videoId, resultVideoId]);

    if (!videoId && videoList.length > 0) {
        return <Navigate to={Paths.makeVideoDetailsUrl(videoList[0].id)} replace />;
    }

    return (
        <Box component="div">
            {videoList.length < 1 ? (
                <Box component={'div'} sx={{ display: 'flex', flexDirection: 'column', alignItems: 'center', marginTop: 15 }}>
                    <img src={Assets.illustrations.empty} alt={'Empty'} width={300} />
                    <Typography variant={'body1'}>
                        No videos yet. To get started, please upload a video that you want to mask!
                    </Typography>
                </Box>
            ) : (<>
                <VideoTaskBar videoId={videoId!} resultVideoId={resultVideoId} />
                {currentVideo && <VideoMetadataBar video={currentVideo} />}
                <DoubleVideo videoId={videoId!} resultVideoId={resultVideoId} />
                <VideoResultsOverview key={videoId} videoId={videoId!} resultVideoId={resultVideoId} />
            </>)}
        </Box>
    );
};

export default VideosPage;
