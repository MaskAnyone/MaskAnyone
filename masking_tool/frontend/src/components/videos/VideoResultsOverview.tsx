import { useEffect, useState } from "react";
import Api from "../../api";
import { Divider, Grid, Paper, Tooltip, styled } from "@mui/material";
import HelpIcon from '@mui/icons-material/Help';

interface VideoResultsProps {
    videoId: string;
    updateSelectedResult: (resultVideoName: string) => void
}

const VideoResultsOverview = (props: VideoResultsProps) => {

    const [results, setResults] = useState<string[]>([])
    const [resultPreviews, setResultPreviews] = useState<any[]>([])
    const [loading, setLoading] = useState<boolean>(true)
    const [selectedResultIdx, setSelectedResultIdx] = useState<number|undefined>()

    useEffect(() => {
        Api.fetchVideoResults(props.videoId).then(results => {
            setResults(results)
        });
    }, []);

    useEffect(() => {
        let previewPromises: Promise<any>[] = []
        for(const result of results) {
            previewPromises.push(Api.fetchResultPreview(props.videoId, result))
        }
        Promise.all(previewPromises).then(previews => {
            setResultPreviews(previews)
            setLoading(false)

        })
    }, [results]);

    useEffect(() => {
        if(selectedResultIdx != undefined) {
            props.updateSelectedResult(results[selectedResultIdx])
        }
    }, [selectedResultIdx])

    const Item = styled(Paper)(() => ({
        backgroundColor: '#bdc3c7',
        padding: 8,
        textAlign: 'center',
        color: 'black',
        cursor: "pointer",
        '&:hover': {
            background: "#3498db",
        }
    }));

    const isSelected = (idx: number) => {
        return idx == selectedResultIdx
    }


    return (
        <>
            {!loading ?
                <>
                    <Divider style={{marginTop: "20px"}}/>

                    <div style={{display: "flex", alignItems: "center", marginTop: "20px"}}>
                        <h3 style={{marginRight: "10px"}}>Processed Results</h3>
                        <Tooltip title=" Click on a result to run it next to the original video">
                            <HelpIcon />
                        </Tooltip>
                    </div>
                    <Grid container spacing={4}>
                        {resultPreviews.map((preview_image, idx) => {
                            return (
                                <Grid item xs={4} key={idx}>
                                    <Item elevation={3} onClick={() => setSelectedResultIdx(idx)} style={isSelected(idx) ? {background: "#3498db"} : {}}>
                                        <img src={`data:image/jpeg;base64, ${preview_image}`} style={{maxHeight: '200px', maxWidth: "100%" }}/>
                                        <h4>{results[idx]}</h4>
                                    </Item>
                                </Grid>
                            )
                        })}
                    </Grid>
                </> :  <></>}
        </>
    )

}

export default VideoResultsOverview
