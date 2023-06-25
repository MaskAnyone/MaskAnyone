import React from 'react';
import {CssBaseline} from "@mui/material";
import {Navigate, Route, Routes} from "react-router";
import PageLayout from "./layout/PageLayout";
import VideosPage from "./pages/VideosPage";
import RunsPage from './pages/RunsPage';
import PresetsPage from './pages/PresetsPage';

const App = () => {
    return (<>
        <CssBaseline />
        <Routes>
            <Route path={'/'} element={<PageLayout />}>
                <Route path={'/videos'} element={<VideosPage />} />
                <Route path={'/videos/:videoId'} element={<VideosPage />} />
                <Route index={true} element={<Navigate to={'/videos'} replace={true} />} />
                <Route path={'/runs'} element={<RunsPage />} />
                <Route path={'/presets'} element={<PresetsPage />} />
            </Route>
        </Routes>
    </>);
};

export default App;
