import React, {useEffect} from 'react';
import {CssBaseline} from "@mui/material";
import {Navigate, Route, Routes} from "react-router";
import PageLayout from "./layout/PageLayout";
import VideosPage from "./pages/VideosPage";
import RunsPage from './pages/RunsPage';
import PresetsPage from './pages/PresetsPage';
import Command from "./state/actions/command";
import {useDispatch} from "react-redux";
import Paths from "./paths";

const App = () => {
    const dispatch = useDispatch();

    useEffect(() => {
        dispatch(Command.Video.fetchVideoList({}));
        dispatch(Command.Job.fetchJobList({}));
    }, []);

    return (<>
        <CssBaseline />
        <Routes>
            <Route path={'/'} element={<PageLayout />}>
                <Route path={Paths.videos} element={<VideosPage />} />
                <Route path={Paths.videoDetails} element={<VideosPage />} />
                <Route path={Paths.resultVideoDetails} element={<VideosPage />} />
                <Route path={Paths.runs} element={<RunsPage />} />
                <Route path={Paths.presets} element={<PresetsPage />} />
                <Route index={true} element={<Navigate to={Paths.videos} replace={true} />} />
            </Route>
        </Routes>
    </>);
};

export default App;
