import React, { useEffect } from 'react';
import { Box, CircularProgress, CssBaseline, Typography } from "@mui/material";
import {Navigate, Route, Routes, useLocation, useNavigate} from "react-router";
import ErrorBoundary from "./components/common/ErrorBoundary";
import PageLayout from "./layout/PageLayout";
import VideosPage from "./pages/VideosPage";
import RunsPage from './pages/RunsPage';
import PresetsPage from './pages/PresetsPage';
import Command from "./state/actions/command";
import {useDispatch, useSelector} from "react-redux";
import Paths from "./paths";
import WorkersPage from "./pages/WorkersPage";
import VideosMaskingPage from "./pages/VideosMaskingPage"
import LandingPage from "./pages/LandingPage";
import AboutPage from "./pages/AboutPage";
import KeycloakAuth, {switchToLocalAuthMode} from "./keycloakAuth";
import {store} from "./state/store";
import Event from "./state/actions/event";
import Selector from "./state/selector";
import LandingPageLayout from "./layout/LandingPageLayout";
import Api from "./api";
import VideoMaskingEditorPage from "./pages/VideosMaskingEditorPage";
import TutorialPage from "./pages/TutorialPage";

interface ParsedToken {
    sub?: string;
    email?: string | null;
    given_name?: string | null;
    family_name?: string | null;
}

const initializeKeycloak = () => {
    KeycloakAuth.initialize().then(loggedIn => {
        if (loggedIn) {
            const tokenParsed = KeycloakAuth.getTokenParsed() as ParsedToken | undefined;
            if (tokenParsed) {
                store.dispatch(Event.Auth.userAuthenticated({
                    user: {
                        id: tokenParsed.sub!,
                        email: tokenParsed.email || null,
                        firstName: tokenParsed.given_name || null,
                        lastName: tokenParsed.family_name || null,
                    }
                }));
            }
        }

        store.dispatch(Event.Auth.authProviderInitialized({}));
    });
};

const App = () => {
    const dispatch = useDispatch();
    const navigate = useNavigate();
    const authProviderInitialized = useSelector(Selector.Auth.initialized);
    const user = useSelector(Selector.Auth.user);
    const location = useLocation();

    useEffect(() => {
        Api.fetchPlatformMode()
            .then(platformMode => {
                if (platformMode === 'local') {
                    switchToLocalAuthMode();
                }

                initializeKeycloak();
            })
            .catch(() => {
                dispatch(Command.Notification.enqueueNotification({
                    severity: 'error',
                    message: 'Could not establish communication with the backend.',
                }));
            });
    // eslint-disable-next-line react-hooks/exhaustive-deps
    }, []);

    useEffect(() => {
        if (authProviderInitialized && !user && !['/', '/about'].includes(location.pathname)) {
            navigate('/');
        }

        if (authProviderInitialized && user) {
            dispatch(Command.Video.fetchVideoList({}));
            dispatch(Command.Job.fetchJobList({}));
            dispatch(Command.Worker.fetchWorkerList({}));
            dispatch(Command.Preset.fetchPresetList({}));
        }
    // eslint-disable-next-line react-hooks/exhaustive-deps
    }, [authProviderInitialized, user]);

    if (!authProviderInitialized) {
        return (
            <Box component="div" sx={{ display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', height: '100vh', gap: 2 }}>
                <CircularProgress />
                <Typography variant="body2" color="text.secondary">Loading...</Typography>
            </Box>
        );
    }

    if (!user) {
        return (<>
            <CssBaseline />
            <Routes>
                <Route path={'/'} element={<LandingPageLayout />}>
                    <Route path={Paths.about} element={<AboutPage />} />
                    <Route path={Paths.tutorial} element={<TutorialPage />} />
                    <Route index={true} element={<LandingPage />} />
                </Route>
            </Routes>
        </>);
    }

    return (<>
        <CssBaseline />
        <ErrorBoundary>
            <Routes>
                <Route path={'/'} element={<PageLayout />}>
                    <Route path={Paths.videos} element={<VideosPage />} />
                    <Route path={Paths.videoDetails} element={<VideosPage />} />
                    <Route path={Paths.videoRunMasking} element={<VideosMaskingPage />} />
                    <Route path={Paths.videoMaskingEditor} element={<VideoMaskingEditorPage />} />
                    <Route path={Paths.videoResultMaskingEditor} element={<VideoMaskingEditorPage />} />
                    <Route path={Paths.resultVideoDetails} element={<VideosPage />} />
                    <Route path={Paths.runs} element={<RunsPage />} />
                    <Route path={Paths.presets} element={<PresetsPage />} />
                    <Route path={Paths.workers} element={<WorkersPage />} />
                    <Route path={Paths.about} element={<AboutPage />} />
                    <Route path={Paths.tutorial} element={<TutorialPage />} />
                    <Route index={true} element={<Navigate to={Paths.videos} replace={true} />} />
                </Route>
            </Routes>
        </ErrorBoundary>
    </>);
};

export default App;
