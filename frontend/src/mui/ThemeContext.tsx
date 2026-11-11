import {createContext, ReactNode, useContext, useMemo, useState} from "react";
import {CssBaseline, PaletteMode, ThemeProvider} from "@mui/material";
import {createAppTheme} from "./theme";

interface ThemeContextValue {
    mode: PaletteMode;
    toggleMode: () => void;
}

const ThemeContext = createContext<ThemeContextValue>({
    mode: 'light',
    toggleMode: () => {},
});

export const useThemeMode = () => useContext(ThemeContext);

const getStoredMode = (): PaletteMode => {
    try {
        const stored = localStorage.getItem('theme-mode');
        if (stored === 'dark' || stored === 'light') return stored;
    } catch {}
    return 'light';
};

interface ThemeContextProviderProps {
    children: ReactNode;
}

export const ThemeContextProvider = ({ children }: ThemeContextProviderProps) => {
    const [mode, setMode] = useState<PaletteMode>(getStoredMode);

    const toggleMode = () => {
        setMode(prev => {
            const next = prev === 'light' ? 'dark' : 'light';
            try { localStorage.setItem('theme-mode', next); } catch {}
            return next;
        });
    };

    const theme = useMemo(() => createAppTheme(mode), [mode]);

    return (
        <ThemeContext.Provider value={{ mode, toggleMode }}>
            <ThemeProvider theme={theme}>
                <CssBaseline />
                {children}
            </ThemeProvider>
        </ThemeContext.Provider>
    );
};
