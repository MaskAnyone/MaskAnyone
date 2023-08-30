import {Box, Typography} from "@mui/material";

const AboutPage = () => {
    return (
        <Box component={'div'}>
            <Typography variant={'h4'}>About</Typography>
            <Typography variant={'body1'}>
                <strong>MASK ANYONE</strong> ...
            </Typography>

            <Typography variant={'h4'} sx={{ marginTop: 3 }}>References & Links</Typography>
            <Typography variant={'body1'}>
                <a href="https://storyset.com/technology">Technology illustrations by Storyset</a>
            </Typography>
        </Box>
    );
};

export default AboutPage;
