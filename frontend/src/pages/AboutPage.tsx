import {Box, Typography} from "@mui/material";
import Assets from "../assets/assets";

const AboutPage = () => {
    return (
        <Box component={'div'}>
            <Box component={'div'} sx={{ display: 'flex', justifyContent: 'center', marginTop: 4, marginBottom: 4 }}>
                <img src={Assets.logos.logoBlack} width={250} />
            </Box>

            <Typography variant={'h4'}>About</Typography>
            <Typography variant={'body1'} sx={{ marginTop: 2 }}>
                <strong>Mask Anyone</strong> is a <strong>de-identifiaction toolbox for videos</strong> that allows you to remove personal identifiable information from videos, while at the same time preserving utility. It provides a variety of algorithms that allows you to <strong>anonymize videos</strong> with just a few clicks. Anonymization algorithms can be selected and combined depending on what aspects of utility should be preserved and which computational resources are available.
            </Typography>
            <Typography variant={'body1'} sx={{ marginTop: 2 }}>
                MaskAnyone is a docker-packaged modern web app that is built with React, MaterialUI, FastAPI and PostgreSQL. It is designed to be easily extensible with new algorithms and to be scalable with multiple docker workers. It is also designed to be easily usable by non-technical users.
            </Typography>
            <Typography variant={'body1'} sx={{ marginTop: 2 }}>
                <em>This Project is the result of the 2023 Mastersproject at the "Intelligent Systems Group" at the Hasso Plattner Institute.</em>
            </Typography>


            <Typography variant={'h4'} sx={{ marginTop: 3 }}>References / Credits / Links</Typography>
            <ul>
                <li><a href="https://github.com/google/mediapipe">Googles' MediaPipe</a> for FaceMesh and Skeleton detection and Blendshape computation</li>
                <li><a href="https://github.com/ultralytics/ultralytics">UltraLytics' YOLOv8</a> for person detection</li>
                <li><a href="https://github.com/akanametov/yolov8-face">Azamat Kanametov's pre-trained model for Face Detection</a> based on the YOLOv8 architecture</li>
                <li>The <a href="https://github.com/RVC-Project/Retrieval-based-Voice-Conversion-WebUI/tree/main">RVC Project</a> for Voice Masking</li>
                <li><a href="https://www.blender.org/">Blender</a> + <a href="https://github.com/cgtinker/BlendArMocap">BlendARMocap</a></li>
                <li>The <a href="https://github.com/s0md3v/roop">Roop Project</a> and InsightFace's pretrained model for FaceSwapping</li>
                <li>The <a href="https://github.com/shubham-goel/4D-Humans">HumansIn4D Project</a> (Not yet included in the tool)</li>
                <li><a href="https://github.com/Walter0807/MotionBERT">MotionBert</a> (Not yet included in the tool)</li>
            </ul>

            <Typography variant={'body1'}>
                <a href="https://storyset.com/technology">Technology illustrations by Storyset</a>
            </Typography>
        </Box>
    );
};

export default AboutPage;
