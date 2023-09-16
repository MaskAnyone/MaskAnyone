import { Card, CardContent, CardMedia, IconButton, Radio, Typography } from "@mui/material"
import Config from "../../../../config"

interface RadioCardProps {
    title: string
    description: string
    imagePath: string
    selected: boolean
    value: string
    onSelect: (value: string) => void
}

const RadioCard = (props: RadioCardProps) => {
    return (
        <Card variant={'outlined'}
            sx={{ width: '250px', display: 'inline-block', marginRight: '16px', cursor: 'pointer', '&:hover': { boxShadow: '0 0 13px 0 #c8c8c8' }, '&.selected': { boxShadow: '0 0 13px 0 #777' } }}
            className={props.selected ? 'selected' : undefined}
            onClick={() => props.onSelect(props.value)}>
            <CardContent>
                <Radio
                    checked={props.selected}
                />
                <Typography gutterBottom variant="h6" component="div">
                    {props.title}
                </Typography>
                <Typography variant="body2" color="text.secondary">
                    {props.description}
                </Typography>
            </CardContent>
            <CardMedia
                sx={{ height: 150 }}
                image={props.imagePath}
            />

        </Card>
    )
}

export default RadioCard