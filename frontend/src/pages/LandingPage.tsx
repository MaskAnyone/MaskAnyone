import {Box, Button, Typography} from "@mui/material";
import KeycloakAuth from "../keycloakAuth";
import Selector from "../state/selector";
import {useSelector} from "react-redux";

const LandingPage = () => {
    const authProviderInitialized = useSelector(Selector.Auth.initialized);

    return (
        <Box component="div">
            <Typography variant={'h1'}>
                Welcome to MaskAnyone!
            </Typography>
            <Button
                children={'Login'}
                variant={'contained'}
                disabled={!authProviderInitialized}
                onClick={KeycloakAuth.login}
            />
        </Box>
    );
};

export default LandingPage;
