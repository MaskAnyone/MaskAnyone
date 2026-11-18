import {Badge, Box, Button, Checkbox, ListItem, ListItemText, TextField} from "@mui/material";
import { Link } from "react-router-dom";
import Config from "../config";
import React, { useRef, useState } from "react";
import { useNavigate } from "react-router";
import KeycloakAuth from "../keycloakAuth";

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
        color: 'text.secondary',
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
    url: string;
    title: string;
    subtitle: string;
    videoId: string;
    badge: number;
    checked: boolean;
    anyChecked: boolean;
    active: boolean;
    onCheckboxClicked: (videoId: string) => void;
    onRename: (videoId: string, newName: string) => void;
}

const SideBarItem = (props: SideBarItemProps) => {
    const navigate = useNavigate();
    const [checkboxStatus, setCheckboxStatus] = useState<'hidden' | 'visible'>('hidden');
    const [editing, setEditing] = useState(false);
    const [editName, setEditName] = useState(props.title);
    const clickTimeoutRef = useRef<ReturnType<typeof setTimeout> | null>(null);

    const handleCheckboxClick = (e: React.MouseEvent<HTMLButtonElement>) => {
        e.preventDefault();
        e.stopPropagation();
        props.onCheckboxClicked(props.videoId);
    };

    const handleTextClick = (e: React.MouseEvent) => {
        e.preventDefault();
        e.stopPropagation();
        clickTimeoutRef.current = setTimeout(() => {
            navigate(props.url);
        }, 250);
    };

    const handleDoubleClick = (e: React.MouseEvent) => {
        e.preventDefault();
        e.stopPropagation();
        if (clickTimeoutRef.current) {
            clearTimeout(clickTimeoutRef.current);
            clickTimeoutRef.current = null;
        }
        setEditName(props.title);
        setEditing(true);
    };

    const commitRename = () => {
        setEditing(false);
        const trimmed = editName.trim();
        if (trimmed && trimmed !== props.title) {
            props.onRename(props.videoId, trimmed);
        }
    };

    const handleKeyDown = (e: React.KeyboardEvent) => {
        if (e.key === 'Enter') {
            commitRename();
        } else if (e.key === 'Escape') {
            setEditing(false);
            setEditName(props.title);
        }
    };

    return (
        <ListItem
            disableGutters={true}
            disablePadding={true}
            sx={styles.item}
            onMouseEnter={() => setCheckboxStatus('visible')}
            onMouseLeave={() => setCheckboxStatus('hidden')}>
            <Button
                sx={styles.button}
                className={props.active ? 'active' : ''}
                children={(
                    <Box component="div" sx={{ display: 'flex', alignItems: 'center', width: '100%' }}>
                        <Badge badgeContent={props.badge} max={9} color={'secondary'} sx={{ '& .MuiBadge-badge': { marginTop: 0.75, marginRight: 1.25 } }}>
                            <img
                                style={{ width: '64px', objectFit: 'cover', marginRight: '8px', borderRadius: '4px' }}
                                src={Config.api.baseUrl + '/videos/' + props.videoId + '/preview?token=' + KeycloakAuth.getToken()}
                                alt={props.title}
                            />
                        </Badge>

                        {editing ? (
                            <TextField
                                value={editName}
                                onChange={e => setEditName(e.target.value)}
                                onBlur={commitRename}
                                onKeyDown={handleKeyDown}
                                onClick={e => e.stopPropagation()}
                                onMouseDown={e => e.stopPropagation()}
                                autoFocus
                                size="small"
                                variant="standard"
                                sx={{ flex: 1 }}
                                inputProps={{ style: { fontSize: '0.875rem' } }}
                            />
                        ) : (
                            <ListItemText
                                primary={props.title}
                                secondary={props.subtitle}
                                sx={styles.listItemText}
                                onClick={handleTextClick}
                                onDoubleClick={handleDoubleClick}
                            />
                        )}

                        <Checkbox
                            style={{ visibility: props.anyChecked ? 'visible' : checkboxStatus }}
                            checked={props.checked}
                            onClick={handleCheckboxClick}
                            onMouseDown={e => e.stopPropagation()}
                            inputProps={{ 'aria-label': `Select ${props.title}` } as any}
                        />
                    </Box>
                )}
                component={Link}
                to={props.url}
            />
        </ListItem>
    );
};

export default SideBarItem;
