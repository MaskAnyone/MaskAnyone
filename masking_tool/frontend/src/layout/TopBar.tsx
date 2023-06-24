import {AppBar, Box, Button, IconButton, Toolbar, Typography} from "@mui/material";
import MenuIcon from '@mui/icons-material/Menu';
import { Link } from "react-router-dom";
import MaskIcon from '@mui/icons-material/Masks';

const styles = {
    appBar: (theme: any) => ({
        [theme.breakpoints.up('lg')]: {
            zIndex: 2000,
        },
        boxShadow: 'none',
    }),
    toolbar: {
        justifyContent: 'space-between',
    },
};

interface TopBarProps {
    isLargeScreen?: boolean;
    onOpenSideBar?: () => void;
}

const pages = [{name: 'Runs', url: '/runs'}, {name: 'Presets', url: '/presets'}]

const TopBar = (props: TopBarProps) => {
    return (
        <AppBar position={'fixed'} color={'primary'} sx={styles.appBar}>
            <Toolbar sx={styles.toolbar}>
            <MaskIcon sx={{ display: { xs: 'flex', md: 'flex' }, mr: 1 }} />
            <Typography
                variant="h6"
                noWrap
                component="a"
                href="/"
                sx={{
                mr: 2,
                display: { xs: 'none', md: 'flex' },
                fontFamily: 'monospace',
                fontWeight: 700,
                letterSpacing: '.12rem',
                color: 'inherit',
                textDecoration: 'none',
                }}
            >
                MaskAnyone
            </Typography>
                <Box sx={{ flexGrow: 1, display: { xs: 'flex', md: 'flex' } }}>
                    {pages.map((page) => (
                    <Button
                        key={page.name}
                        sx={{ my: 2, color: 'white', display: 'block' }}
                        component={Link}
                        to={page.url}
                    >
                        {page.name}
                    </Button>
                    ))}
                </Box>
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
