import {useLocation} from "react-router";
import {Box, Button, ListItem} from "@mui/material";
import {Link} from "react-router-dom";

const styles = {
    item: {
        display: 'flex',
        paddingTop: 1,
        paddingBottom: 1,
        margin: '0 12px',
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
        padding: '10px 8px',
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
    label: string;
    icon: any;
}

const SideBarItem = (props: SideBarItemProps) => {
    const location = useLocation();

    return (
        <Box>
            <ListItem disableGutters={true} sx={styles.item}>
                <Button
                    sx={styles.button}
                    className={location.pathname.startsWith(props.url) ? 'active' : ''}
                    children={(<>
                        <Box sx={styles.icon}>{props.icon}</Box>
                        {props.label}
                    </>)}
                    component={Link}
                    to={props.url}
                />
            </ListItem>
        </Box>
    );
};

export default SideBarItem;
