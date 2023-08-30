import {Box, Typography} from "@mui/material";
import Assets from "../assets/assets";

const AboutPage = () => {
    return (
        <Box component={'div'}>
            <Box component={'div'} sx={{ display: 'flex', justifyContent: 'center', marginTop: 4, marginBottom: 4 }}>
                <img src={Assets.logos.logoBlack} width={250} />
            </Box>

            <Typography variant={'h4'}>About</Typography>
            <Typography variant={'body1'}>
                <strong>Mask Anyone</strong> Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.
            </Typography>

            <Typography variant={'h4'} sx={{ marginTop: 3 }}>References & Links</Typography>
            <Typography variant={'body1'}>
                <a href="https://storyset.com/technology">Technology illustrations by Storyset</a>
            </Typography>
        </Box>
    );
};

export default AboutPage;
