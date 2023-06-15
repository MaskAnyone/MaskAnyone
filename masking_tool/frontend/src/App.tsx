import React from 'react';
import {CssBaseline} from "@mui/material";
import {Navigate, Route, Routes} from "react-router";
import PageLayout from "./layout/PageLayout";
import VideosPage from "./components/videos/VideosPage";
import BlendshapesPage from './components/blendshapesRenderer/BlendshapesPage';

const App = () => {
    return (<>
        <CssBaseline />
        <Routes>
            <Route path={'/'} element={<PageLayout />}>
                <Route path={'/blendshapesrendering'} element={<BlendshapesPage />} />
                <Route path={'/videos'} element={<VideosPage />} />
                <Route path={'/videos/:videoName'} element={<VideosPage />} />
                <Route index={true} element={<Navigate to={'/videos'} replace={true} />} />
            </Route>
        </Routes>
    </>);
};

export default App;
