import {useState} from "react";
import {Box, useMediaQuery, useTheme} from "@mui/material";
import SideBar from "./SideBar";
import TopBar from "./TopBar";
import {Outlet} from "react-router";

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
        '&.left-padding': {
            paddingLeft: '288px',
            [theme.breakpoints.up('sm')]: {
                paddingLeft: '296px',
            },
            [theme.breakpoints.up('md')]: {
                paddingLeft: '312px',
            },
        },
        [theme.breakpoints.up('sm')]: {
            padding: 2,
            paddingTop: '72px',
        },
        [theme.breakpoints.up('md')]: {
            padding: 4,
            paddingTop: '88px',
        },
    }),
};

const PageLayout = () => {
    const [sideBarOpen, setSideBarOpen] = useState<boolean>(false);
    const theme = useTheme();
    const isLargeScreen = useMediaQuery(theme.breakpoints.up('lg'), {
        defaultMatches: true,
    });

    return (
        <Box component="div" sx={styles.root}>
            <SideBar
                open={sideBarOpen}
                isLargeScreen={isLargeScreen}
                onClose={() => setSideBarOpen(false)}
            />
            <TopBar
                isLargeScreen={isLargeScreen}
                onOpenSideBar={() => setSideBarOpen(!sideBarOpen)}
            />
            <Box component="div" sx={styles.content} className={isLargeScreen ? 'left-padding' : ''}>
                <Outlet />
            </Box>
        </Box>
    );
};

export default PageLayout;
