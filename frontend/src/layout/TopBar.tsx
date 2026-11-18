import {useEffect, useState} from "react";
import {AppBar, Badge, Box, Button, Chip, IconButton, Toolbar, Tooltip, Typography} from "@mui/material";
import MenuIcon from '@mui/icons-material/Menu';
import MemoryIcon from '@mui/icons-material/Memory';
import Brightness4Icon from '@mui/icons-material/Brightness4';
import Brightness7Icon from '@mui/icons-material/Brightness7';
import { Link } from "react-router-dom";
import {useSelector} from "react-redux";
import Selector from "../state/selector";
import Paths from "../paths";
import Assets from "../assets/assets";
import LogoutIcon from "@mui/icons-material/Logout";
import KeycloakAuth from "../keycloakAuth";
import PersonIcon from '@mui/icons-material/Person';
import Api from "../api";
import {useThemeMode} from "../mui/ThemeContext";

const styles = {
    appBar: {
        zIndex: 1300,  // Higher than Drawer (1200) to always stay on top
        boxShadow: 'none',
    },
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
        backgroundColor: 'divider',
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

interface SystemResources {
    gpu: { name: string; vram_gb: number } | null;
    ram_total_gb: number | null;
    cpu_model: string | null;
    cpu_count: number | null;
}

const TopBar = (props: TopBarProps) => {
    const user = useSelector(Selector.Auth.user);
    const activeJobCount = useSelector(Selector.Job.openAndRunningJobCount);
    const [resources, setResources] = useState<SystemResources | null>(null);
    const {mode, toggleMode} = useThemeMode();

    useEffect(() => {
        Api.fetchSystemResources()
            .then(setResources)
            .catch(() => {});
    }, []);

    const resourceTooltip = resources
        ? [
            resources.gpu ? `GPU: ${resources.gpu.name} (${resources.gpu.vram_gb} GB VRAM)` : 'GPU: Not detected',
            resources.ram_total_gb ? `RAM: ${resources.ram_total_gb} GB` : null,
            resources.cpu_model ? `CPU: ${resources.cpu_model}` : null,
            resources.cpu_count ? `Cores: ${resources.cpu_count}` : null,
        ].filter(Boolean).join('\n')
        : '';

    // Show "Resources" if any system info is available
    const hasResources = resources && (resources.gpu || resources.ram_total_gb);

    return (
        <AppBar position={'fixed'} sx={{...styles.appBar, backgroundColor: '#161616'}}>
            <Toolbar sx={styles.toolbar}>
                <Button component={Link} to={Paths.videos} sx={{ color: 'white', marginLeft: '-16px', flexShrink: 0 }}>
                    <img src={Assets.logos.logoWhite} height={50} style={{ pointerEvents: 'none' }} alt="MaskAnyone" />
                </Button>

                <Box component="div" sx={styles.navigationContainer}>
                    {hasResources && (
                        <Tooltip title={<span style={{ whiteSpace: 'pre-line' }}>{resourceTooltip}</span>}>
                            <Chip
                                icon={<MemoryIcon sx={{ fontSize: '1rem !important' }} />}
                                label="Resources"
                                size="small"
                                sx={{
                                    alignSelf: 'center',
                                    ml: 1,
                                    backgroundColor: 'transparent',
                                    color: 'rgba(255,255,255,0.5)',
                                    border: 'none',
                                    '& .MuiChip-icon': { color: 'rgba(255,255,255,0.4)' },
                                    fontFamily: '"IBM Plex Mono", monospace',
                                    fontSize: '0.65rem',
                                    height: '24px',
                                    '&:hover': {
                                        backgroundColor: 'rgba(255,255,255,0.1)',
                                        color: 'rgba(255,255,255,0.8)',
                                        '& .MuiChip-icon': { color: 'rgba(255,255,255,0.7)' },
                                    },
                                }}
                            />
                        </Tooltip>
                    )}
                </Box>
                <Button
                    sx={styles.navigationButton}
                    component={Link}
                    to={Paths.runs}
                    children={<Badge badgeContent={activeJobCount} max={9} color={'secondary'}>Runs</Badge>}
                />
                {/*<Button
                    sx={styles.navigationButton}
                    style={{ marginRight: '6px' }}
                    component={Link}
                    to={Paths.presets}
                    children={'My Presets'}
                />*/}
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
                <Tooltip title={mode === 'light' ? 'Switch to dark mode' : 'Switch to light mode'}>
                    <IconButton sx={{color: 'white'}} onClick={toggleMode} aria-label={mode === 'light' ? 'Switch to dark mode' : 'Switch to light mode'}>
                        {mode === 'light' ? <Brightness4Icon /> : <Brightness7Icon />}
                    </IconButton>
                </Tooltip>
                {(!props.isLargeScreen) && (
                    <IconButton sx={{color: 'white'}} onClick={props.onOpenSideBar} aria-label="Open navigation menu">
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
                                    <PersonIcon style={{ color: 'rgba(255, 255, 255, 0.5)', width: 30, height: 30 }} />
                                </Box>
                            </Box>
                        )}
                        <Tooltip title={'Logout'}>
                            <IconButton sx={{color: 'white'}} onClick={KeycloakAuth.logout} aria-label="Logout">
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
