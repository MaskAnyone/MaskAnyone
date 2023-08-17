import {AppBar, Badge, Box, Button, IconButton, Toolbar, Typography} from "@mui/material";
import MenuIcon from '@mui/icons-material/Menu';
import { Link } from "react-router-dom";
import MaskIcon from '@mui/icons-material/Masks';
import {useSelector} from "react-redux";
import Selector from "../state/selector";
import Paths from "../paths";
import Assets from "../assets/assets";

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
};

interface TopBarProps {
    isLargeScreen?: boolean;
    onOpenSideBar?: () => void;
}

const TopBar = (props: TopBarProps) => {
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
                    component={Link}
                    to={Paths.workers}
                    children={'Workers'}
                />
                {(!props.isLargeScreen) && (
                    <IconButton sx={{color: 'white'}} onClick={props.onOpenSideBar}>
                        <MenuIcon />
                    </IconButton>
                )}
            </Toolbar>
        </AppBar>
    );
};

export default TopBar;
