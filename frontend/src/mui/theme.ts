import {createTheme, PaletteMode} from "@mui/material";

const fontFamily = '"IBM Plex Sans", "Helvetica Neue", Arial, sans-serif';
const monoFontFamily = '"IBM Plex Mono", "Courier New", monospace';

export const createAppTheme = (mode: PaletteMode) => {
    const isLight = mode === 'light';

    return createTheme({
        palette: {
            mode,
            primary: {
                main: isLight ? '#161616' : '#f4f4f4',
                dark: isLight ? '#000000' : '#ffffff',
                light: isLight ? '#393939' : '#c6c6c6',
            },
            secondary: {
                main: isLight ? '#525252' : '#a8a8a8',
                dark: isLight ? '#393939' : '#c6c6c6',
                light: isLight ? '#6f6f6f' : '#6f6f6f',
            },
            background: {
                default: isLight ? '#ffffff' : '#161616',
                paper: isLight ? '#ffffff' : '#262626',
            },
            text: {
                primary: isLight ? '#161616' : '#f4f4f4',
                secondary: isLight ? '#525252' : '#c6c6c6',
                disabled: isLight ? '#a8a8a8' : '#6f6f6f',
            },
            divider: isLight ? '#e0e0e0' : '#393939',
            error: {
                main: '#da1e28',
            },
            warning: {
                main: '#f1c21b',
            },
            success: {
                main: isLight ? '#198038' : '#42be65',
            },
            info: {
                main: isLight ? '#0043ce' : '#4589ff',
            },
        },
        typography: {
            fontFamily,
            h1: { fontWeight: 300, letterSpacing: '-0.02em' },
            h2: { fontWeight: 300, letterSpacing: '-0.02em' },
            h3: { fontWeight: 400 },
            h4: { fontWeight: 400 },
            h5: { fontWeight: 600 },
            h6: { fontWeight: 600 },
            subtitle1: { fontWeight: 600, letterSpacing: '0.01em' },
            subtitle2: { fontWeight: 600, letterSpacing: '0.01em' },
            body1: { fontWeight: 400, fontSize: '0.875rem', lineHeight: 1.5 },
            body2: { fontWeight: 400, fontSize: '0.8125rem', lineHeight: 1.5 },
            button: { fontWeight: 600, textTransform: 'none', letterSpacing: '0.02em' },
            caption: { fontSize: '0.75rem' },
            overline: { fontFamily: monoFontFamily, fontSize: '0.75rem', letterSpacing: '0.08em' },
        },
        shape: {
            borderRadius: 0,
        },
        components: {
            MuiButtonBase: {
                styleOverrides: {
                    root: {
                        borderRadius: 0,
                    },
                },
            },
            MuiButton: {
                styleOverrides: {
                    root: ({ ownerState }) => ({
                        borderRadius: 0,
                        padding: ownerState.variant === 'contained' ? '8px 24px' : undefined,
                        boxShadow: 'none',
                        '&:hover': {
                            boxShadow: 'none',
                        },
                    }),
                },
            },
            MuiCard: {
                styleOverrides: {
                    root: ({ theme }) => ({
                        borderRadius: 0,
                        border: `1px solid ${theme.palette.divider}`,
                        boxShadow: 'none',
                    }),
                },
            },
            MuiPaper: {
                styleOverrides: {
                    root: ({ theme }) => ({
                        borderRadius: 0,
                        boxShadow: 'none',
                        border: `1px solid ${theme.palette.divider}`,
                    }),
                },
            },
            MuiDialog: {
                styleOverrides: {
                    paper: {
                        borderRadius: 0,
                    },
                },
            },
            MuiChip: {
                styleOverrides: {
                    root: {
                        borderRadius: 0,
                        fontWeight: 500,
                    },
                },
            },
            MuiTableHead: {
                styleOverrides: {
                    root: ({ theme }) => ({
                        '& .MuiTableCell-head': {
                            fontWeight: 600,
                            fontSize: '0.75rem',
                            textTransform: 'uppercase' as const,
                            letterSpacing: '0.06em',
                            color: theme.palette.text.secondary,
                        },
                    }),
                },
            },
            MuiAppBar: {
                styleOverrides: {
                    root: ({ theme }) => ({
                        boxShadow: 'none',
                        borderBottom: `1px solid ${theme.palette.divider}`,
                    }),
                },
            },
            MuiDrawer: {
                styleOverrides: {
                    paper: ({ theme }) => ({
                        borderRight: `1px solid ${theme.palette.divider}`,
                    }),
                },
            },
            MuiLinearProgress: {
                styleOverrides: {
                    root: ({ theme }) => ({
                        borderRadius: 0,
                        backgroundColor: theme.palette.divider,
                    }),
                },
            },
        },
    });
};
