import {useLocation} from "react-router";
import {Badge, Box, Button, ListItem, ListItemText} from "@mui/material";
import {Link} from "react-router-dom";

const styles = {
    item: {
        display: 'flex',
        width: 'calc(100% - 20px)',
    },
    icon: {
        width: '20px',
        height: '20px',
        display: 'flex',
        alignItems: 'center',
        marginRight: 2,
        marginLeft: 1,
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
    icon: any;
    badge: number;
}

const SideBarItem = (props: SideBarItemProps) => {
    const location = useLocation();

    return (
        <ListItem disableGutters={true} disablePadding={true} sx={styles.item}>
            <Button
                sx={styles.button}
                className={location.pathname.startsWith(props.url) ? 'active' : ''}
                children={(<>
                    <Box component="div" sx={styles.icon}>{props.icon}</Box>
                    <Badge badgeContent={props.badge} max={9} color={'secondary'} sx={{ '& .MuiBadge-badge': { marginTop: 1 } }}>
                        <ListItemText primary={props.title} secondary={props.subtitle} />
                    </Badge>
                </>)}
                component={Link}
                to={props.url}
            />
        </ListItem>
    );
};

export default SideBarItem;
