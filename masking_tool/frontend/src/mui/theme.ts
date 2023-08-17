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
                root: ({ ownerState }) => ({
                    borderRadius: 8,
                    padding: ownerState.variant === 'contained' ? '8px 24px': undefined,
                }),
            },
        },
        MuiCard: {
            styleOverrides: {
                root: {
                    borderRadius: 8,
                },
            },
        },
        MuiDialog: {
            styleOverrides: {
                paper: {
                    borderRadius: 12,
                },
            },
        },
    },
});
