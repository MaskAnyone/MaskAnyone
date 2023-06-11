import {Box} from "@mui/material";
import Config from "../../config";
import {useEffect, useRef} from "react";


interface DoubleVideoProps {
    videoName: string;
    selectedResult: string | undefined
}

const DoubleVideo = (props: DoubleVideoProps) => {
    const video1Ref = useRef<HTMLVideoElement>(null);
    const video2Ref = useRef<HTMLVideoElement>(null);
    const originalPath = Config.api.baseUrl + '/videos/' + props.videoName;
    const resultPath = Config.api.baseUrl + '/results/result/' + props.videoName.split('.')[0] + '/' + props.selectedResult;

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
    }, []);

    return (
        <Box>
            <video controls={true} key={originalPath} style={{ width: '49%' }} ref={video1Ref}>
                <source src={originalPath} type={'video/mp4'} key={originalPath} />
            </video>
            <video controls={true} key={resultPath} style={props.selectedResult == undefined ? {display: 'none', width: '49%'} : {width: '49%'}} ref={video2Ref}>
                <source src={resultPath} type={'video/mp4'} key={resultPath} />
            </video>
        </Box>
    );
};

export default DoubleVideo;
