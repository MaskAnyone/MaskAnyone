import { Button, Dialog, DialogTitle, DialogContent, DialogContentText, TextField, DialogActions, IconButton } from "@mui/material"
import { useState } from "react"
import TuneIcon from '@mui/icons-material/Tune';
import validator from '@rjsf/validator-ajv8';
import Form from '@rjsf/mui';
import { RJSFSchema } from "@rjsf/utils";

interface MethodSettingProps {
    children?: React.ReactNode
    formSchema: RJSFSchema
    methodName: string
    onSet: (params: object) => void
}

const MethodSettings = (props: MethodSettingProps) => {
    const [open, setOpen] = useState(false)
    const [localParams, setLocalParams] = useState([])
    const {formSchema, methodName, onSet} = props

    const onSetOpen = () => {
        // @todo reset params to global form
        setOpen(true)
    }

    const handleParamsSet = () => {
        onSet(localParams)
        setOpen(false)
    }

    const log = (type: any) => console.log.bind(console, type);

    return (
        <div>
            <IconButton onClick={onSetOpen}aria-label="Adjust method parameters">
                <TuneIcon />
            </IconButton>
            <Dialog open={open} onClose={() =>  setOpen(false)}>
            <DialogTitle>Customize parameters for {methodName}</DialogTitle>
            <DialogContent>
                <Form
                    schema={formSchema}
                    validator={validator}
                    onChange={log('changed')}
                    onSubmit={log('submitted')}
                    onError={log('errors')}

                />,
            </DialogContent>
            <DialogActions>
                <Button onClick={() => setOpen(false)}>Cancel</Button>
                <Button onClick={handleParamsSet}>Set</Button>
            </DialogActions>
            </Dialog>
      </div>
    )
}

export default MethodSettings