import {Card, Box, CardMedia} from "@mui/material";
import React from "react";

const styles = {
    card: {
        width: 320,
        height: 170,
        boxShadow: 3,
    },
    leftSideContainer: {
        display: 'flex',
        flexDirection: 'row',
        position: 'relative',
    },
};

interface SideBySideCardProps {
    children?: React.ReactElement|React.ReactElement[];
}

const SideBySideCard = (props: SideBySideCardProps) => {
    return (
        <Card sx={styles.card}>
            <Box component={'div'} sx={{ display: 'flex', flexDirection: 'row', position: 'relative' }}>
                {props.children}
                <CardMedia
                    component={'img'}
                    image={'https://picsum.photos/150/150'}
                    sx={{ width: 160, height: 170 }}
                />
            </Box>
        </Card>
    );
};

export default SideBySideCard;
