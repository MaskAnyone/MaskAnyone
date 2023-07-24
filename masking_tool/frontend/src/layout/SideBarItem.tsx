import { useLocation } from "react-router";
import { Badge, Box, Button, Checkbox, ListItem, ListItemText } from "@mui/material";
import { Link } from "react-router-dom";
import Config from "../config";
import { useState } from "react";

const styles = {
    item: {
        display: 'flex',
    },
    icon: {
        width: '64px',
        height: '36px',
        display: 'flex',
        alignItems: 'center',
    },
    button: (theme: any) => ({
        color: '#66788A',
        padding: '4px 0',
        justifyContent: 'flex-start',
        textTransform: 'none',
        letterSpacing: 0,
        width: '100%',
        fontWeight: theme.typography.fontWeightMedium,
        '&.active': {
            color: theme.palette.primary.main,
            borderColor: theme.palette.primary.main,
        },
        '&:first-child': {
            marginTop: 0,
        },
    }),
    listItemText: {
        '& .MuiTypography-root': {
            overflow: 'hidden',
            textOverflow: 'ellipsis',
        },
    },

};

interface SideBarItemProps {
    title: string;
    subtitle: string;
    videoId: string;
    badge: number;
    checked: boolean;
    anyChecked: boolean;
    active: boolean;
    onItemClicked: (videoId: string) => void;
    onCheckboxClicked: (e: React.MouseEvent<HTMLButtonElement>, videoId: string) => void;
}

const SideBarItem = (props: SideBarItemProps) => {
    const location = useLocation();
    const [checkboxStyle, setCheckboxStyle] = useState<{ visibility: 'hidden' | 'visible' }>({ visibility: 'hidden' })

    const getCheckboxStyle = (): { visibility: 'hidden' | 'visible' } => {
        if (props.anyChecked) {
            return { visibility: "visible" }
        } else {
            return checkboxStyle
        }
    }

    return (
        <ListItem
            disableGutters={true}
            disablePadding={true}
            sx={styles.item}
            onClick={() => { props.onItemClicked(props.videoId) }}
            onMouseEnter={e => {
                setCheckboxStyle({ visibility: 'visible' });
            }}
            onMouseLeave={e => {
                setCheckboxStyle({ visibility: 'hidden' })
            }}>
            <Button
                sx={styles.button}
                className={props.active ? 'active' : ''}
                children={(
                    <Box component="div" sx={{ display: 'flex', alignItems: 'center', width: '100%' }}>
                        <Badge badgeContent={props.badge} max={9} color={'secondary'} sx={{ '& .MuiBadge-badge': { marginTop: 0.75, marginRight: 1.25 } }}>
                            <img
                                style={{ width: '64px', objectFit: 'cover', marginRight: '8px', borderRadius: '4px' }}
                                src={Config.api.baseUrl + '/videos/' + props.videoId + '/preview'}
                            />
                        </Badge>

                        <ListItemText
                            primary={props.title}
                            secondary={props.subtitle}
                            sx={styles.listItemText}
                        />

                        <Checkbox
                            style={getCheckboxStyle()}
                            checked={props.checked}
                            onClick={(e) => props.onCheckboxClicked(e, props.videoId)}
                        />
                    </Box>
                )}
            />
        </ListItem>
    );
};

export default SideBarItem;
