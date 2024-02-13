import {AppBar, Box, Button, Toolbar} from "@mui/material";
import {Outlet} from "react-router";
import {Link} from "react-router-dom";
import Paths from "../paths";
import Assets from "../assets/assets";
import KeycloakAuth from "../keycloakAuth";
import {useSelector} from "react-redux";
import Selector from "../state/selector";

const styles = {
    root: {
        width: '100%',
        height: '100%',
        fontFamily: 'Roboto',
    },
    content: (theme: any) => ({
        padding: 1,
        paddingTop: '64px',
        width: '100%',
        height: '100%',
        boxSizing: 'border-box',
        backgroundColor: '#F9FAFB',
        [theme.breakpoints.up('sm')]: {
            padding: 2,
            paddingTop: '84px',
        },
        [theme.breakpoints.up('md')]: {
            padding: 2.5,
            paddingTop: '88px',
        },
    }),
    appBar: (theme: any) => ({
        [theme.breakpoints.up('lg')]: {
            zIndex: 1200,
        },
        boxShadow: 'none',
    }),
    toolbar: {
        justifyContent: 'space-between',
    },
    navigationContainer: {
        flexGrow: 1,
        display: { xs: 'flex', md: 'flex' },
    },
    navigationButton: {
        my: 2,
        color: 'white',
        display: 'block',
    },
};

const LandingPageLayout = () => {
    const authProviderInitialized = useSelector(Selector.Auth.initialized);

    return (
        <Box component="div" sx={styles.root}>
            <AppBar position={'fixed'} color={'primary'} sx={styles.appBar}>
                <Toolbar sx={styles.toolbar}>
                    <Button component={Link} to={'/'} sx={{ color: 'white', marginLeft: '-16px' }}>
                        <img src={Assets.logos.logoWhite} height={50} style={{ pointerEvents: 'none' }} />
                    </Button>

                    <Box component="div" sx={styles.navigationContainer}>
                    </Box>

                    <Button
                        sx={styles.navigationButton}
                        component={Link}
                        to={'/'}
                        children={'Home'}
                    />
                    <Button
                        sx={styles.navigationButton}
                        component={Link}
                        to={Paths.about}
                        children={'About'}
                    />
                    <Button
                        sx={{ marginLeft: 1 }}
                        children={'Login'}
                        variant={'contained'}
                        disabled={!authProviderInitialized}
                        onClick={KeycloakAuth.login}
                        color={'secondary'}
                    />
                </Toolbar>
            </AppBar>
            <Box component="div" sx={styles.content}>
                <Outlet />
            </Box>
        </Box>
    );
};

export default LandingPageLayout;
