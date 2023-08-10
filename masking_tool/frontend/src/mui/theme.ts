import {createTheme} from "@mui/material";

export const theme = createTheme({
    components: {
        MuiButtonBase: {
            styleOverrides: {
                root: {
                    borderRadius: 8,
                },
            },
        },
        MuiButton: {
            styleOverrides: {
                root: {
                    borderRadius: 8,
                    padding: '8px 24px',
                },
            },
        },
        MuiCard: {
            styleOverrides: {
                root: {
                    borderRadius: 8,
                },
            },
        },
    },
});
