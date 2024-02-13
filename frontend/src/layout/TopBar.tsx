import {AppBar, Badge, Box, Button, IconButton, Toolbar, Tooltip, Typography} from "@mui/material";
import MenuIcon from '@mui/icons-material/Menu';
import { Link } from "react-router-dom";
import {useSelector} from "react-redux";
import Selector from "../state/selector";
import Paths from "../paths";
import Assets from "../assets/assets";
import LogoutIcon from "@mui/icons-material/Logout";
import KeycloakAuth from "../keycloakAuth";
import PersonIcon from '@mui/icons-material/Person';

const styles = {
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
    profileContainer: {
        display: 'flex',
        padding: 2,
        marginRight: 1,
        alignItems: 'center',
    },
    profilePicture: {
        width: '48px',
        height: '48px',
        borderRadius: '24px',
        backgroundColor: '#b9c0da',
        display: 'flex',
        justifyContent: 'center',
        alignItems: 'center',
    },
    profileText: {
        textAlign: 'right',
        paddingRight: 1.5,
    },
};

interface TopBarProps {
    isLargeScreen?: boolean;
    onOpenSideBar?: () => void;
}

const TopBar = (props: TopBarProps) => {
    const user = useSelector(Selector.Auth.user);
    const activeJobCount = useSelector(Selector.Job.openAndRunningJobCount);

    return (
        <AppBar position={'fixed'} color={'primary'} sx={styles.appBar}>
            <Toolbar sx={styles.toolbar}>
                <Button component={Link} to={Paths.videos} sx={{ color: 'white', marginLeft: '-16px' }}>
                    <img src={Assets.logos.logoWhite} height={50} style={{ pointerEvents: 'none' }} />
                </Button>

                <Box component="div" sx={styles.navigationContainer}>

                </Box>
                <Button
                    sx={styles.navigationButton}
                    component={Link}
                    to={Paths.runs}
                    children={<Badge badgeContent={activeJobCount} max={9} color={'secondary'}>Runs</Badge>}
                />
                <Button
                    sx={styles.navigationButton}
                    style={{ marginRight: '6px' }}
                    component={Link}
                    to={Paths.presets}
                    children={'My Presets'}
                />
                <Button
                    sx={styles.navigationButton}
                    style={{ marginRight: '6px' }}
                    component={Link}
                    to={Paths.workers}
                    children={'Workers'}
                />
                <Button
                    sx={styles.navigationButton}
                    component={Link}
                    to={Paths.about}
                    children={'About'}
                />
                {(!props.isLargeScreen) && (
                    <IconButton sx={{color: 'white'}} onClick={props.onOpenSideBar}>
                        <MenuIcon />
                    </IconButton>
                )}
                {props.isLargeScreen && (
                    <Box component={'div'} sx={{ display: 'flex', alignItems: 'center', marginLeft: 6 }}>
                        {user && (
                            <Box component={'div'} sx={styles.profileContainer}>
                                <Typography variant={'body2'} sx={styles.profileText}>
                                    <strong>{user.firstName} {user.lastName}</strong><br />
                                </Typography>
                                <Box component={'div'} sx={styles.profilePicture}>
                                    <PersonIcon style={{ color: 'rgba(0, 0, 0, 0.4)', width: 30, height: 30 }} />
                                </Box>
                            </Box>
                        )}
                        <Tooltip title={'Logout'}>
                            <IconButton sx={{color: 'white'}} onClick={KeycloakAuth.logout}>
                                <LogoutIcon />
                            </IconButton>
                        </Tooltip>
                    </Box>
                )}
            </Toolbar>
        </AppBar>
    );
};

export default TopBar;
