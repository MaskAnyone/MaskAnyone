import {Box, CircularProgress, Typography} from '@mui/material';
import PublishIcon from '@mui/icons-material/Publish';

const styles = {
    circularProgressBottom: {
        color: '#dfdfdf',
    },
    circularProgressTop: {
        position: 'absolute',
        left: 0,
    },
    waitingForUploadIcon: {
        color: '#bfbfbf',
    },
};

interface UploadProgressProps {
    value: number;
}

const UploadProgress = (props: UploadProgressProps) => {
    return (
        <Box component="div" position={'relative'} display={'inline-flex'}>
            <CircularProgress variant={'determinate'} value={100} sx={styles.circularProgressBottom} />
            <CircularProgress
                variant={'determinate'}
                value={props.value}
                color={'secondary'}
                sx={styles.circularProgressTop}
            />
            <Box
                top={0}
                left={0}
                bottom={0}
                right={0}
                component="div"
                position={'absolute'}
                display={'flex'}
                alignItems={'center'}
                justifyContent={'center'}
                children={props.value < 1 ? <PublishIcon sx={styles.waitingForUploadIcon} /> : (
                    <Typography variant={'caption'} component={'div'}>{`${Math.round(props.value)}%`}</Typography>
                )}
            />
        </Box>
    );
};

export default UploadProgress;
