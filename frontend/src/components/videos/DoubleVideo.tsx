import { Box } from "@mui/material";
import Config from "../../config";
import { useEffect, useMemo, useRef, useState } from "react";
import PoseRenderer3D from "./PoseRenderer3D";
import BlendshapesRenderer3D from "./BlendshapesRenderer3D";
import { useDispatch, useSelector } from "react-redux";
import Selector from "../../state/selector";
import Command from "../../state/actions/command";
import { ResultVideo } from "../../state/types/ResultVideo";
import ControlBar from "./player/ControlBar";
import ReactPlayer from 'react-player';
import { OnProgressProps } from "react-player/base";
import ResultSelector, { ResultViews } from "./ResultSelector";
import KeycloakAuth from "../../keycloakAuth";


interface DoubleVideoProps {
    videoId: string;
    resultVideoId?: string;
}

const DoubleVideo = (props: DoubleVideoProps) => {
    const dispatch = useDispatch();
    const videoList = useSelector(Selector.Video.videoList);
    const blendshapesList = useSelector(Selector.Video.blendshapesList);
    const mpKinematicsList = useSelector(Selector.Video.mpKinematicsList);
    const resultLists = useSelector(Selector.Video.resultVideoLists);
    const resultList = resultLists[props.videoId] || [];
    const resultVideo = resultList.find((resultVideo: ResultVideo) => resultVideo.videoResultId === props.resultVideoId);
    const video1Ref = useRef<ReactPlayer>(null);
    const video2Ref = useRef<ReactPlayer>(null);
    const videoBasePath = `${Config.api.baseUrl}/videos/${props.videoId}`;
    const originalPath = `${videoBasePath}?token=${KeycloakAuth.getToken()}`;
    const resultPath = `${videoBasePath}/results/${props.resultVideoId}?token=${KeycloakAuth.getToken()}`;
    const [view, setView] = useState<ResultViews>(ResultViews.video)
    const [frame, setFrame] = useState<number>(0);


    const [playing, setPlaying] = useState<boolean>(false);
    const [seeking, setSeeking] = useState<boolean>(false);
    const [played, setPlayed] = useState<number>(0);
    const [playedSeconds, setPlayedSeconds] = useState<number>(0);
    const [duration, setDuration] = useState<number>(0);
    const [volume1, setVolume1] = useState<number>(1);
    const [volume2, setVolume2] = useState<number>(1);


    const blendshapes = blendshapesList[props.resultVideoId || '']
    const mpKinematics = mpKinematicsList[props.resultVideoId || '']

    const videoFPS = useMemo(
        () => videoList.find(video => video.id === props.videoId)?.videoInfo.fps || 0,
        [videoList, props.videoId],
    );

    const resetVideos = () => {
        setPlaying(false);
        video1Ref.current?.seekTo(0);
        video2Ref.current?.seekTo(0);
        setPlayed(0);
        setPlayedSeconds(0);
    };

    useEffect(() => {
        setView(ResultViews.video);

        if (!props.resultVideoId) {
            return;
        }

        dispatch(Command.Video.fetchBlendshapes({ resultVideoId: props.resultVideoId }));
        dispatch(Command.Video.fetchMpKinematics({ resultVideoId: props.resultVideoId }));
    }, [props.resultVideoId]);

    useEffect(() => {
        resetVideos();
    }, [props.videoId, props.resultVideoId]);

    useEffect(() => {
        if (video2Ref.current) {
            video2Ref.current.seekTo(played);
        }
    }, [video2Ref.current]);

    const displaySelectedView = () => {
        if (view === ResultViews.video && props.resultVideoId) {
            return (
                <ReactPlayer
                    ref={video2Ref}
                    url={resultPath}
                    playing={playing}
                    volume={volume2}
                    width='100%'
                    height='100%'
                />
            );
        }
        if (view === ResultViews.blendshapes3D && props.resultVideoId) {
            if (blendshapes.length > 0) {
                return (
                    <BlendshapesRenderer3D
                        blendshapes={blendshapes || []}
                        fps={videoFPS}
                    />
                )
            } else {
                return <>No valid result produced</>
            }

        }
        if (view === ResultViews.skeleton3D) {
            return (
                <PoseRenderer3D
                    mpKinematics={mpKinematics || []}
                    frame={frame}
                />
            )
        }
    };

    useEffect(() => {
        if (!video1Ref.current || !seeking) {
            return;
        }

        video1Ref.current.seekTo(played);

        if (video2Ref.current) {
            video2Ref.current.seekTo(played);
        }
    }, [played]);

    const updatePlayedSeconds = (newPlayedSeconds: number) => {
        setPlayedSeconds(newPlayedSeconds);
        setFrame(Math.round(newPlayedSeconds * videoFPS));
    };

    const handleVideoProgress = (progressProps: OnProgressProps) => {
        if (seeking) {
            return;
        }

        setPlayed(progressProps.played);
        updatePlayedSeconds(progressProps.playedSeconds);
    };

    const handleTogglePlaying = (newPlaying: boolean) => {
        setPlaying(newPlaying);

        if (newPlaying) {
            if (video1Ref.current) {
                video1Ref.current.seekTo(played);
            }

            if (video2Ref.current) {
                video2Ref.current.seekTo(played);
            }
        }
    };

    return (
        <Box component="div">
            <Box component={'div'} sx={{ display: 'flex', flexDirection: 'row', justifyContent: 'space-between' }}>
                <Box component={'div'} sx={{ width: 'calc(50% - 8px)', maxHeight: '420px' }}>
                    <ReactPlayer
                        ref={video1Ref}
                        url={originalPath}
                        playing={playing}
                        onProgress={handleVideoProgress}
                        onSeek={updatePlayedSeconds}
                        onDuration={setDuration}
                        onPause={() => setPlaying(false)}
                        onEnded={resetVideos}
                        progressInterval={33}
                        volume={volume1}
                        width='100%'
                        height='100%'
                    />
                </Box>
                <Box component={'div'} sx={{ width: 'calc(50% - 8px)', maxHeight: '420px' }}>
                    {displaySelectedView()}
                </Box>
            </Box>
            {/* @todo not in use right now */}
            <Box component={'div'} sx={{ /*display: 'flex',*/ justifyContent: 'flex-end', display: 'none' }}>
                {props.resultVideoId && (
                    <ResultSelector
                        value={view}
                        onValueChange={setView}
                        resultVideo={resultVideo}
                    />
                )}
            </Box>
            <ControlBar
                playing={playing}
                onTogglePlaying={handleTogglePlaying}
                seeking={seeking}
                onToggleSeeking={setSeeking}
                position={played}
                onPositionChange={setPlayed}
                playedSeconds={playedSeconds}
                frame={frame}
                duration={duration}
                video2Available={Boolean(view === ResultViews.video && props.resultVideoId)}
                volume1={volume1}
                volume2={volume2}
                onVolume1Change={setVolume1}
                onVolume2Change={setVolume2}
            />
        </Box>
    );
};

export default DoubleVideo;
