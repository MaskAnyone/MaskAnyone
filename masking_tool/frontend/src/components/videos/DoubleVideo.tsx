import {Box, Grid} from "@mui/material";
import Config from "../../config";
import {useEffect, useRef, useState} from "react";
import PoseRenderer3D from "./PoseRenderer3D";


interface DoubleVideoProps {
    videoId: string;
    selectedResult: string | undefined
}

enum views {
    video,
    blendshapes3D,
    skeleton3D
}

const DoubleVideo = (props: DoubleVideoProps) => {
    const video1Ref = useRef<HTMLVideoElement>(null);
    const video2Ref = useRef<HTMLVideoElement>(null);
    const originalPath = Config.api.baseUrl + '/videos/' + props.videoId;
    const resultPath = Config.api.baseUrl + '/results/result/' + props.videoId + '/' + props.selectedResult;
    const [view, setView] = useState<views>(views.video)

    const displaySelectedView = () => {
         if(view==views.video) {
            return (
            <video controls={false} key={resultPath} style={{width: '100%'}} ref={video2Ref}>
                <source src={resultPath} type={'video/mp4'} key={resultPath} />
            </video>)
         }
        if(view==views.blendshapes3D) {
            return (<></>)
         }
        if(view==views.skeleton3D) {
            return <PoseRenderer3D />
        }
    }

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
        <Box>
            <Grid container rowSpacing={2} columnSpacing={{ xs: 1, sm: 2, md: 3 }}>
                <Grid item xs={6} >
                    <video controls={true} key={originalPath} style={{width: '100%'}} ref={video1Ref}>
                        <source src={originalPath} type={'video/mp4'} key={originalPath} />
                    </video>
                </Grid>
                <Grid item xs={6}>
                    {props.selectedResult && displaySelectedView()}
                </Grid>
                <Grid item xs={12}>
                </Grid>
            </Grid>
        </Box>
    );
};

export default DoubleVideo;
