import { Box, Button } from "@mui/material";

interface TabPanelProps {
    children?: React.ReactNode;
    index: number;
    value: number | boolean;
  }
  
const TabPanel = (props: TabPanelProps) => {
    const { children, value, index, ...other } = props;
  
    return (
      <div
        role="tabpanel"
        hidden={value !== index}
        id={`vertical-tabpanel-${index}`}
        aria-labelledby={`vertical-tab-${index}`}
        {...other}
      >
        {value === index && (
            <Box sx={{ pt: 0, pb: 1, pr: 1, pl: 1}}>
                {children}
            </Box>
        )}
      </div>
    )
}

export default TabPanel
  