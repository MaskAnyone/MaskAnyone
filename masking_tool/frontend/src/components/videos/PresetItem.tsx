import { Box, Grid, Paper, Typography } from "@mui/material";
import MasksIcon from '@mui/icons-material/Masks';
import { ReactElement } from "react";

interface PresetItemProps {
    name: string,
    icon?: ReactElement,
    previewImagePath?: string
    hideInfo?: boolean
    selected: boolean
    onClick?: () => void
}

const PresetItem = (props: PresetItemProps) => {
    const {name, selected, previewImagePath} = props
    const hideInfo = props.hideInfo || false
    const onClick = props.onClick || function(){}
    const icon = props.icon || <MasksIcon />

    const getStyle = () => {
        let style: any = {
            textAlign: 'center',
            display: "flex",
            flexDirection: "column",
            justifyContent: "center",
            height: '50px',
            backgroundColor: '#fff',
            cursor: 'pointer'
        }
        if(selected) {
            style['borderWidth'] = "2px"
            style['borderColor'] = "#1976D2"
            return style
        }
        return style
    }
    
    return(
        <Paper sx={getStyle()} onClick={onClick} variant={"outlined"}>
            <Grid container>
                <Grid item xs={12} >
                    <Grid container>
                    <Grid item xs={4}>
                        {previewImagePath ? <img 
                            src={require(previewImagePath)} 
                        /> :  icon}
                    </Grid>
                    <Grid item xs={8} sx={{ fontWeight: 400 }}><Typography>{name}</Typography></Grid>
                </Grid>
                </Grid>
                {hideInfo ? <></> : <Grid item xs={12}></Grid>}
                </Grid>
        </Paper>
    )
}

export default PresetItem