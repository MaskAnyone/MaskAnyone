import React from 'react';
import ReactDOM from 'react-dom/client';
import reportWebVitals from './reportWebVitals';
import App from "./App";
import {BrowserRouter} from "react-router-dom";
import {Provider} from "react-redux";
import {store} from "./state/store";
import {ThemeContextProvider} from "./mui/ThemeContext";
import Notifier from "./components/common/Notifier";

import './index.css'
import '@fontsource/ibm-plex-sans/300.css';
import '@fontsource/ibm-plex-sans/400.css';
import '@fontsource/ibm-plex-sans/500.css';
import '@fontsource/ibm-plex-sans/600.css';
import '@fontsource/ibm-plex-sans/700.css';
import '@fontsource/ibm-plex-mono/400.css';

const root = ReactDOM.createRoot(document.getElementById('root') as HTMLElement);

root.render(
    <Provider store={store}>
        <ThemeContextProvider>
            <BrowserRouter>
                <App />
            </BrowserRouter>
            <Notifier />
        </ThemeContextProvider>
    </Provider>
);

// If you want to start measuring performance in your app, pass a function
// to log results (for example: reportWebVitals(console.log))
// or send to an analytics endpoint. Learn more: https://bit.ly/CRA-vitals
reportWebVitals();
