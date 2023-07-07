import {useLocation} from "react-router";
import {Badge, Box, Button, ListItem, ListItemText} from "@mui/material";
import {Link} from "react-router-dom";
import Config from "../config";

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
};

interface SideBarItemProps {
    url: string;
    title: string;
    subtitle: string;
    videoId: string;
    badge: number;
}

const SideBarItem = (props: SideBarItemProps) => {
    const location = useLocation();

    return (
        <ListItem disableGutters={true} disablePadding={true} sx={styles.item}>
            <Button
                sx={styles.button}
                className={location.pathname.startsWith(props.url) ? 'active' : ''}
                children={(
                    <Box component="div" sx={{ display: 'flex', alignItems: 'center' }}>
                        <img
                            style={{ width: '64px', objectFit: 'cover', marginRight: '8px', borderRadius: '4px' }}
                            src={Config.api.baseUrl + '/videos/' + props.videoId + '/preview'}
                        />
                        <Badge badgeContent={props.badge} max={9} color={'secondary'} sx={{ '& .MuiBadge-badge': { marginTop: 1 } }}>
                            <ListItemText primary={props.title} secondary={props.subtitle} />
                        </Badge>
                    </Box>
                )}
                component={Link}
                to={props.url}
            />
        </ListItem>
    );
};

export default SideBarItem;
