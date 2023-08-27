import { Box, FormControl, FormControlLabel, Grid, Radio, RadioGroup } from "@mui/material";
import Config from "../../config";
import { useEffect, useMemo, useRef, useState } from "react";
import PoseRenderer3D from "./PoseRenderer3D";
import BlendshapesRenderer3D from "./BlendshapesRenderer3D";
import { useDispatch, useSelector } from "react-redux";
import Selector from "../../state/selector";
import Command from "../../state/actions/command";
import { ResultVideo } from "../../state/types/ResultVideo";


interface DoubleVideoProps {
    videoId: string;
    resultVideoId?: string;
}

enum views {
    video = "video",
    blendshapes3D = "blendshapes3D",
    skeleton3D = "skeleton3D"
}

const DoubleVideo = (props: DoubleVideoProps) => {
    const dispatch = useDispatch();
    const videoList = useSelector(Selector.Video.videoList);
    const blendshapesList = useSelector(Selector.Video.blendshapesList);
    const mpKinematicsList = useSelector(Selector.Video.mpKinematicsList);
    const resultLists = useSelector(Selector.Video.resultVideoLists);
    const resultList = resultLists[props.videoId] || [];
    const resultVideo = resultList.find((resultVideo: ResultVideo) => resultVideo.videoResultId === props.resultVideoId);
    const video1Ref = useRef<HTMLVideoElement>(null);
    const video2Ref = useRef<HTMLVideoElement>(null);
    const originalPath = Config.api.baseUrl + '/videos/' + props.videoId;
    const resultPath = originalPath + '/results/' + props.resultVideoId;
    const [view, setView] = useState<views>(views.video)
    const [frame, setFrame] = useState<number>(0);

    const blendshapes = blendshapesList[props.resultVideoId || '']
    const mpKinematics = mpKinematicsList[props.resultVideoId || '']


    const videoFPS = useMemo(
        () => videoList.find(video => video.id === props.videoId)?.videoInfo.fps || 0,
        [videoList, props.videoId],
    );

    useEffect(() => {
        setView(views.video);

        if (!props.resultVideoId) {
            return;
        }

        dispatch(Command.Video.fetchBlendshapes({ resultVideoId: props.resultVideoId }));
        dispatch(Command.Video.fetchMpKinematics({ resultVideoId: props.resultVideoId }));
    }, [props.resultVideoId]);

    const displaySelectedView = () => {
        if (view === views.video && props.resultVideoId) {
            return (
                <video controls={false} key={resultPath} style={{ width: '100%' }} ref={video2Ref}>
                    <source src={resultPath} type={'video/mp4'} key={resultPath} />
                </video>
            );
        }
        if (view === views.blendshapes3D && props.resultVideoId) {
            return (
                <BlendshapesRenderer3D
                    blendshapes={blendshapes}
                />
            )
        }
        if (view === views.skeleton3D) {
            return (
                <PoseRenderer3D
                    mpKinematics={mpKinematics || []}
                    frame={frame}
                />
            )
        }
    };

    useEffect(() => {
        if (view !== views.skeleton3D) {
            return;
        }

        setFrame(0);

        const interval = setInterval(
            () => {
                setFrame(Math.round(video1Ref.current!.currentTime * videoFPS));
            },
            16, // Poll often enough for 60fps
        );

        return () => clearInterval(interval);
    }, [view]);

    useEffect(() => {
        if (!video1Ref.current || !video2Ref.current) {
            return;
        }

        video1Ref.current.addEventListener('play', () => {
            video2Ref.current?.play();
        });

        video1Ref.current.addEventListener('pause', () => {
            video2Ref.current?.pause();
        });

        const updateCurrentVideoTime = () => {
            if (!video1Ref.current || !video2Ref.current) {
                return;
            }

            video2Ref.current.currentTime = video1Ref.current.currentTime;
        };

        video1Ref.current.addEventListener('seeking', updateCurrentVideoTime);

        video1Ref.current.addEventListener('seeked', updateCurrentVideoTime);
    }, [originalPath, resultPath]);

    return (
        <Box component="div">
            <Grid container rowSpacing={2} columnSpacing={{ xs: 1, sm: 2, md: 3 }}>
                <Grid item xs={6} >
                    <video controls={true} key={originalPath} style={{ width: '100%' }} ref={video1Ref}>
                        <source src={originalPath} type={'video/mp4'} key={originalPath} />
                    </video>
                </Grid>
                <Grid item xs={6}>
                    {displaySelectedView()}
                </Grid>
                <Grid item xs={12}>
                    <Grid container>
                        <Grid item xs={6}></Grid>
                        <Grid item xs={6} sx={{ textAlign: "center" }}>
                            {props.resultVideoId && (
                                <FormControl>
                                    <RadioGroup row value={view} onChange={(e, v) => setView(views[v as keyof typeof views])}>
                                        {Boolean(resultVideo?.videoResultExists) && <FormControlLabel value={views.video} control={<Radio />} label="Show Masked Video" />}
                                        {Boolean(resultVideo?.kinematicResultsExists) && <FormControlLabel value={views.skeleton3D} control={<Radio />} label="Show 3D Skeleton" />}
                                        {Boolean(resultVideo?.blendshapeResultsExists) && <FormControlLabel value={views.blendshapes3D} control={<Radio />} label="Show animated 3D Face" />}
                                    </RadioGroup>
                                </FormControl>
                            )}
                        </Grid>
                    </Grid>
                </Grid>
            </Grid>
        </Box>
    );
};

export default DoubleVideo;
