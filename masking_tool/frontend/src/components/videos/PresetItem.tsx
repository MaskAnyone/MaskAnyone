import { Box, Grid, Paper, Typography } from "@mui/material";
import MasksIcon from '@mui/icons-material/Masks';
import { ReactElement } from "react";

const style = {
    textAlign: 'center',
    height: '50px',
    backgroundColor: '#fff'
}

interface PresetItemProps {
    name: string,
    icon?: ReactElement,
    previewImagePath?: string
    hideInfo?: boolean
    onClick?: () => void
}

const PresetItem = (props: PresetItemProps) => {
    const {name, previewImagePath} = props
    const hideInfo = props.hideInfo || false
    const onClick = props.onClick || function(){}
    const icon = props.icon || <MasksIcon />

    
    return(
        <Paper sx={style} onClick={onClick}>
            <Box>
                <Grid container>
                    <Grid item xs={4}>
                        {previewImagePath ? <img 
                            src={require(previewImagePath)} 
                        /> :  icon}
                    </Grid>
                    <Grid item xs={8} sx={{ fontWeight: 400 }}><Typography>{name}</Typography></Grid>
                </Grid>
                {hideInfo ? <></> : <Grid container>
                    <Grid item xs={12}></Grid>
                </Grid>}
            </Box>
        </Paper>
    )
}

export default PresetItem