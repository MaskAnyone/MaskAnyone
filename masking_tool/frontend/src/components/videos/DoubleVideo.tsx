import { Box, FormControl, FormControlLabel, Radio, RadioGroup } from "@mui/material";
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
import {OnProgressProps} from "react-player/base";
import ResultSelector, {ResultViews} from "./ResultSelector";


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
    const originalPath = Config.api.baseUrl + '/videos/' + props.videoId;
    const resultPath = originalPath + '/results/' + props.resultVideoId;
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

    useEffect(() => {
        setView(ResultViews.video);

        if (!props.resultVideoId) {
            return;
        }

        dispatch(Command.Video.fetchBlendshapes({ resultVideoId: props.resultVideoId }));
        dispatch(Command.Video.fetchMpKinematics({ resultVideoId: props.resultVideoId }));
    }, [props.resultVideoId]);

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
            return (
                <BlendshapesRenderer3D
                    blendshapes={blendshapes || []}
                />
            )
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

    const handleVideoProgress = (progressProps: OnProgressProps) => {
        if (seeking) {
            return;
        }

        setPlayed(progressProps.played);
        setPlayedSeconds(progressProps.playedSeconds);
        setFrame(Math.round(progressProps.playedSeconds * videoFPS));
    };

    return (
        <Box component="div">
            <Box component={'div'} sx={{ display: 'flex', flexDirection: 'row' }}>
                <ReactPlayer
                    ref={video1Ref}
                    url={originalPath}
                    playing={playing}
                    onProgress={handleVideoProgress}
                    onDuration={setDuration}
                    onPause={() => setPlaying(false)}
                    progressInterval={33}
                    volume={volume1}
                    width='100%'
                    height='100%'
                    style={{ maxWidth: '50%' }}
                />
                {displaySelectedView()}
            </Box>
            <Box component={'div'} sx={{ display: 'flex', justifyContent: 'flex-end' }}>
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
                onTogglePlaying={setPlaying}
                seeking={seeking}
                onToggleSeeking={setSeeking}
                position={played}
                onPositionChange={setPlayed}
                playedSeconds={playedSeconds}
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
