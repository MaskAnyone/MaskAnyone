import React, { useEffect } from 'react';
import { CssBaseline } from "@mui/material";
import {Navigate, Route, Routes, useLocation, useNavigate} from "react-router";
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
import KeycloakAuth from "./keycloakAuth";
import {store} from "./state/store";
import Event from "./state/actions/event";
import Selector from "./state/selector";
import LandingPageLayout from "./layout/LandingPageLayout";

const initializeKeycloak = () => {
    KeycloakAuth.initialize().then(loggedIn => {
        if (loggedIn) {
            const tokenParsed = KeycloakAuth.instance.tokenParsed!;
            store.dispatch(Event.Auth.userAuthenticated({
                user: {
                    id: tokenParsed.sub!,
                    email: (tokenParsed as any).email || null,
                    firstName: (tokenParsed as any).given_name || null,
                    lastName: (tokenParsed as any).family_name || null,
                }
            }));
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
        initializeKeycloak();
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
    }, [authProviderInitialized, user]);

    if (!authProviderInitialized) {
        return null;
    }

    if (!user) {
        return (<>
            <CssBaseline />
            <Routes>
                <Route path={'/'} element={<LandingPageLayout />}>
                    <Route path={Paths.about} element={<AboutPage />} />
                    <Route index={true} element={<LandingPage />} />
                </Route>
            </Routes>
        </>);
    }

    return (<>
        <CssBaseline />
        <Routes>
            <Route path={'/'} element={<PageLayout />}>
                <Route path={Paths.videos} element={<VideosPage />} />
                <Route path={Paths.videoDetails} element={<VideosPage />} />
                <Route path={Paths.videoRunMasking} element={<VideosMaskingPage />} />
                <Route path={Paths.resultVideoDetails} element={<VideosPage />} />
                <Route path={Paths.runs} element={<RunsPage />} />
                <Route path={Paths.presets} element={<PresetsPage />} />
                <Route path={Paths.workers} element={<WorkersPage />} />
                <Route path={Paths.about} element={<AboutPage />} />
                <Route index={true} element={<Navigate to={Paths.videos} replace={true} />} />
            </Route>
        </Routes>
    </>);
};

export default App;
