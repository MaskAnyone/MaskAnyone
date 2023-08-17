import { Box, FormControl, FormControlLabel, Grid, Radio, RadioGroup } from "@mui/material";
import Config from "../../config";
import { useEffect, useRef, useState } from "react";
import PoseRenderer3D from "./PoseRenderer3D";
import BlendshapesRenderer3D from "./BlendshapesRenderer3D";
import poseTed from '../../mockData/ted_kid_pose.json';


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
    const video1Ref = useRef<HTMLVideoElement>(null);
    const video2Ref = useRef<HTMLVideoElement>(null);
    const originalPath = Config.api.baseUrl + '/videos/' + props.videoId;
    const resultPath = originalPath + '/results/' + props.resultVideoId;
    const [view, setView] = useState<views>(views.video)
    const [frame, setFrame] = useState<number>(0);
    const frameRef = useRef<number>(frame);
    frameRef.current = frame;

    const displaySelectedView = () => {
        if (view === views.video && props.resultVideoId) {
            return (
                <video controls={false} key={resultPath} style={{ width: '100%' }} ref={video2Ref}>
                    <source src={resultPath} type={'video/mp4'} key={resultPath} />
                </video>
            );
        }
        if (view === views.blendshapes3D && props.resultVideoId) {
            return (<BlendshapesRenderer3D resultVideoId={props.resultVideoId} />)
        }
        if (view === views.skeleton3D) {
            return (
                <PoseRenderer3D
                    pose={poseTed}
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
        const animateFrame = () => {
            setFrame(frameRef.current + 1);
            if (frameRef.current < 200) {
                setTimeout(animateFrame, 100);
            }
        }
        animateFrame();
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

        let pollTimeout: any;

        /*const pollCurrentVideoFrame = () => {
            console.log(video1Ref.current!.currentTime, Math.round(video1Ref.current!.currentTime * 30));
            pollTimeout = setTimeout(pollCurrentVideoFrame, 15);
        };

        // pollCurrentVideoFrame();

        return () => clearTimeout(pollTimeout);*/

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
                            {(
                                <FormControl>
                                    <RadioGroup row value={view} onChange={(e, v) => setView(views[v as keyof typeof views])}>
                                        <FormControlLabel value={views.video} control={<Radio />} label="Show Masked Video" />
                                        <FormControlLabel value={views.skeleton3D} control={<Radio />} label="Show 3D Skeleton" />
                                        <FormControlLabel value={views.blendshapes3D} control={<Radio />} label="Show animated 3D Face" />
                                    </RadioGroup>
                                </FormControl>)}
                        </Grid>
                    </Grid>
                </Grid>
            </Grid>
        </Box>
    );
};

export default DoubleVideo;
