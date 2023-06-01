import React from 'react';
import {CssBaseline} from "@mui/material";
import {Navigate, Route, Routes} from "react-router";
import PageLayout from "./layout/PageLayout";
import VideosPage from "./components/videos/VideosPage";

const App = () => {
    return (<>
        <CssBaseline />
        <Routes>
            <Route path={'/'} element={<PageLayout />}>
                <Route path={'/videos'} element={<VideosPage />} />
                <Route index={true} element={<Navigate to={'/videos'} replace={true} />} />
            </Route>
        </Routes>
    </>);
};

export default App;
