import { Box, Grid, Paper, Tooltip, Typography } from "@mui/material";
import MasksIcon from '@mui/icons-material/Masks';
import { ReactElement } from "react";
import HelpIcon from '@mui/icons-material/Help';
interface PresetItemProps {
    name: string,
    icon?: ReactElement,
    previewImagePath?: string
    selected: boolean
    description?: string
    onClick?: () => void
}

const PresetItem = (props: PresetItemProps) => {
    const {name, selected, previewImagePath, description} = props
    const onClick = props.onClick || function(){}
    const icon = props.icon || <MasksIcon />

    const getStyle = () => {
        let style: any = {
            textAlign: 'center',
            display: "flex",
            flexDirection: "column",
            justifyContent: "center",
            height: '80px',
            backgroundColor: '#fff',
            cursor: 'pointer',
            position: "relative"
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
                </Grid>
                {description? 
                    <Tooltip title={description} sx={{position: "absolute", bottom: "10px", right: "10px"}}>
                        <HelpIcon />
                    </Tooltip>: <></>}
        </Paper>
    )
}

export default PresetItem