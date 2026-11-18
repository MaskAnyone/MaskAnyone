import { Box, Card, CardContent, CardMedia, Chip, Link, Typography } from "@mui/material";
import {StepProps} from "./StepProps";

const ANNY_URL = 'https://github.com/naver/anny';
const CARD_WIDTH = 220;

// 3D body model extraction is in development. This step only announces it;
// it adds nothing to the run params, so "Mask Video" here runs the masking as usual.
const DataExctactionStep = (_props: StepProps) => {
    return (
        <>
            <Box component={'div'} sx={{ marginBottom: 3.5, display: 'flex', alignItems: 'center', gap: 1.5 }}>
                <Typography variant="h6">
                    3D Body Model
                </Typography>
                <Chip label="In development" size="small" color="warning" variant="outlined" />
            </Box>
            {/* Vertical card (image on top, text below) with the width set inline on a
                plain wrapper, so no parent layout or stylesheet can stretch it. */}
            <div style={{ width: CARD_WIDTH, maxWidth: '100%' }}>
                <Card sx={{ boxShadow: 3 }}>
                    <CardMedia
                        component={'img'}
                        image={'/images/model_extraction/anny_interative_demo.jpg'}
                        alt=""
                        sx={{ width: '100%', height: CARD_WIDTH, objectFit: 'cover', opacity: 0.5 }}
                    />
                    <CardContent>
                        <Typography variant={'body1'} fontWeight={'bold'}>
                            3D body model
                        </Typography>
                        <Typography variant={'body2'} color={'text.secondary'} sx={{ marginTop: 1 }}>
                            In development, based on{' '}
                            <Link href={ANNY_URL} target="_blank" rel="noopener noreferrer" fontWeight={'bold'}>Anny</Link>.
                        </Typography>
                    </CardContent>
                </Card>
            </div>
        </>
    )
}

export default DataExctactionStep
