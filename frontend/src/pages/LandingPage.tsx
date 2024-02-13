import {Box, Button, Typography} from "@mui/material";
import KeycloakAuth from "../keycloakAuth";
import Selector from "../state/selector";
import {useSelector} from "react-redux";
import Assets from "../assets/assets";

const LandingPage = () => {
    const authProviderInitialized = useSelector(Selector.Auth.initialized);

    return (
        <Box component="div">
            <Box component={'div'} sx={{ display: 'flex', justifyContent: 'center', marginTop: 4, marginBottom: 4 }}>
                <img src={Assets.logos.logoBlack} width={250} />
            </Box>
            <Typography variant={'h4'} sx={{ textAlign: 'center' }}>Video de-identification made simple.</Typography>
            <Box component={'div'} sx={{display: 'flex', justifyContent: 'center', marginTop: 4}}>
                <video autoPlay loop muted style={{width: '100%', maxWidth: '900px'}}>
                    <source src={'/videos/example1.mp4'} type="video/mp4"/>
                </video>
            </Box>
            <Box component={'div'} sx={{ display: 'flex', justifyContent: 'center', marginTop: 4 }}>
                <Button
                    children={'Get Started'}
                    variant={'contained'}
                    disabled={!authProviderInitialized}
                    onClick={KeycloakAuth.login}
                    color={'secondary'}
                />
            </Box>
        </Box>
    );
};

export default LandingPage;
