import {AppBar, IconButton, Toolbar} from "@mui/material";
import MenuIcon from '@mui/icons-material/Menu';

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

const TopBar = (props: TopBarProps) => {
    return (
        <AppBar position={'fixed'} color={'primary'} sx={styles.appBar}>
            <Toolbar sx={styles.toolbar}>
                {(!props.isLargeScreen) && (
                    <IconButton color={'secondary'} onClick={props.onOpenSideBar}>
                        <MenuIcon />
                    </IconButton>
                )}
            </Toolbar>
        </AppBar>
    );
};

export default TopBar;
