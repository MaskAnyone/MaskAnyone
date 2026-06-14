import {Box, Button, keyframes, Paper, Typography} from "@mui/material";
import {Link} from "react-router-dom";
import Paths from "../paths";
import CloudUploadIcon from "@mui/icons-material/CloudUpload";
import TouchAppIcon from "@mui/icons-material/TouchApp";
import PlayCircleIcon from "@mui/icons-material/PlayCircle";
import DownloadIcon from "@mui/icons-material/Download";
import TipsAndUpdatesIcon from "@mui/icons-material/TipsAndUpdates";
import ContentCutIcon from "@mui/icons-material/ContentCut";
import SpeedIcon from "@mui/icons-material/Speed";
import AdsClickIcon from "@mui/icons-material/AdsClick";

const float = keyframes`
    0%, 100% { transform: translateY(0px); }
    50% { transform: translateY(-8px); }
`;

const pulse = keyframes`
    0%, 100% { opacity: 1; transform: scale(1); }
    50% { opacity: 0.7; transform: scale(0.95); }
`;

const bounce = keyframes`
    0%, 100% { transform: translateY(0); }
    25% { transform: translateY(-4px); }
    75% { transform: translateY(4px); }
`;

const spin = keyframes`
    0% { transform: rotate(0deg); }
    100% { transform: rotate(360deg); }
`;

interface TutorialStepProps {
    stepNumber: number;
    title: string;
    description: string;
    icon: React.ReactNode;
    reverse?: boolean;
}

const TutorialStep = ({stepNumber, title, description, icon, reverse}: TutorialStepProps) => (
    <Box
        component="div"
        sx={{
            display: 'flex',
            flexDirection: {xs: 'column', md: reverse ? 'row-reverse' : 'row'},
            alignItems: 'center',
            gap: 4,
            mb: 6,
        }}
    >
        <Box
            component="div"
            sx={{
                width: {xs: '100%', md: '45%'},
                aspectRatio: '16/9',
                backgroundColor: 'action.hover',
                border: 1,
                borderColor: 'divider',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                position: 'relative',
                overflow: 'hidden',
            }}
        >
            <Typography
                variant="overline"
                sx={{
                    position: 'absolute',
                    top: 8,
                    left: 12,
                    color: 'text.secondary',
                    fontSize: '0.65rem',
                }}
            >
                GIF placeholder
            </Typography>
            {icon}
        </Box>
        <Box component="div" sx={{width: {xs: '100%', md: '55%'}}}>
            <Typography
                variant="overline"
                color="text.secondary"
                sx={{fontFamily: '"IBM Plex Mono", monospace'}}
            >
                Step {stepNumber}
            </Typography>
            <Typography variant="h5" sx={{fontWeight: 600, mb: 1}}>
                {title}
            </Typography>
            <Typography variant="body1" color="text.secondary" sx={{lineHeight: 1.7}}>
                {description}
            </Typography>
        </Box>
    </Box>
);

const TutorialPage = () => {
    return (
        <Box component="div" sx={{maxWidth: 900, mx: 'auto', py: 4}}>
            <Typography variant="h3" sx={{fontWeight: 300, mb: 1}}>
                Getting Started
            </Typography>
            <Typography variant="body1" color="text.secondary" sx={{mb: 6}}>
                Learn how to anonymize videos in four simple steps.
            </Typography>

            <TutorialStep
                stepNumber={1}
                title="Upload your video"
                description="Drag and drop MP4 files into the upload zone, or click to browse. We'll automatically extract metadata and show you the video specs — resolution, frame rate, duration, and codec. You can upload multiple videos and manage them from the sidebar."
                icon={
                    <CloudUploadIcon
                        sx={{
                            fontSize: 80,
                            color: 'primary.main',
                            animation: `${float} 3s ease-in-out infinite`,
                        }}
                    />
                }
            />

            <TutorialStep
                stepNumber={2}
                title="Select subjects to mask"
                description="Click on people in the video frame to mark them for masking. Each click places a tracking point that follows the subject through the video. For complex scenes, right-click to add additional reference points. The AI will track your selections automatically."
                icon={
                    <TouchAppIcon
                        sx={{
                            fontSize: 80,
                            color: 'info.main',
                            animation: `${pulse} 2s ease-in-out infinite`,
                        }}
                    />
                }
                reverse
            />

            <TutorialStep
                stepNumber={3}
                title="Configure and run"
                description="Choose your masking style — blur, pixelate, silhouette, or solid color. Optionally enable skeleton extraction or face blendshapes for motion capture data. Hit 'Run' and track progress in the Runs page. Processing time depends on video length and your GPU."
                icon={
                    <PlayCircleIcon
                        sx={{
                            fontSize: 80,
                            color: 'success.main',
                            animation: `${spin} 4s linear infinite`,
                        }}
                    />
                }
            />

            <TutorialStep
                stepNumber={4}
                title="Review and export"
                description="Compare the original and masked videos side-by-side with synchronized playback. Download the masked video, or export skeleton data and face blendshapes as JSON/CSV for use in animation software. Each result is saved and can be re-downloaded anytime."
                icon={
                    <DownloadIcon
                        sx={{
                            fontSize: 80,
                            color: 'warning.main',
                            animation: `${bounce} 1.5s ease-in-out infinite`,
                        }}
                    />
                }
                reverse
            />

            <Paper
                sx={{
                    p: 3,
                    mb: 4,
                    backgroundColor: 'action.hover',
                    border: 1,
                    borderColor: 'divider',
                }}
            >
                <Box component="div" sx={{display: 'flex', alignItems: 'center', gap: 1, mb: 2}}>
                    <TipsAndUpdatesIcon color="warning" />
                    <Typography variant="h6" sx={{fontWeight: 600}}>
                        Pro Tips
                    </Typography>
                </Box>
                <Box component="div" sx={{display: 'flex', flexDirection: 'column', gap: 1.5}}>
                    <Box component="div" sx={{display: 'flex', alignItems: 'flex-start', gap: 1.5}}>
                        <ContentCutIcon sx={{color: 'text.secondary', fontSize: 20, mt: 0.25}} />
                        <Typography variant="body2" color="text.secondary">
                            <strong>Use Trim</strong> to extract short clips before masking — shorter videos process faster and let you iterate quickly.
                        </Typography>
                    </Box>
                    <Box component="div" sx={{display: 'flex', alignItems: 'flex-start', gap: 1.5}}>
                        <AdsClickIcon sx={{color: 'text.secondary', fontSize: 20, mt: 0.25}} />
                        <Typography variant="body2" color="text.secondary">
                            <strong>Right-click on the frame</strong> to manually place tracking points — useful when auto-detection misses a subject.
                        </Typography>
                    </Box>
                    <Box component="div" sx={{display: 'flex', alignItems: 'flex-start', gap: 1.5}}>
                        <SpeedIcon sx={{color: 'text.secondary', fontSize: 20, mt: 0.25}} />
                        <Typography variant="body2" color="text.secondary">
                            <strong>30fps is optimal</strong> — higher frame rates don't improve masking quality but increase processing time.
                        </Typography>
                    </Box>
                </Box>
            </Paper>

            <Box component="div" sx={{textAlign: 'center'}}>
                <Button
                    variant="contained"
                    size="large"
                    component={Link}
                    to={Paths.videos}
                    sx={{px: 6}}
                >
                    Get Started
                </Button>
            </Box>
        </Box>
    );
};

export default TutorialPage;
