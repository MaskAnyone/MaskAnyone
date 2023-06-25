import { Tab, Tabs } from "@mui/material";
import { useState } from "react";
import TabPanel from "./ParamTabPanel";

const ParamterTabOverview = () => {
    const [selectedTab, setSelectedTab] = useState<number>(0)

    const handleTabChange = (event: React.SyntheticEvent, newValue: number) => {
        setSelectedTab(newValue);
    };

    const a11yProps = (index: number) => {
        return {
          id: `vertical-tab-${index}`,
          'aria-controls': `vertical-tabpanel-${index}`,
        };
    }
    return (
        <>
        <Tabs
        orientation="vertical"
        variant="scrollable"
        value={selectedTab}
        onChange={handleTabChange}
        sx={{ borderRight: 1, borderColor: 'divider' }}
    >
        <Tab label="Subject" {...a11yProps(0)} />
        <Tab label="Background" {...a11yProps(1)} />
        <Tab label="Voice" {...a11yProps(2)} />
    </Tabs>
    <TabPanel value={selectedTab} index={0}>
        Subject Params
    </TabPanel>
    <TabPanel value={selectedTab} index={1}>
        
    </TabPanel>
    <TabPanel value={selectedTab} index={2}>
        Coming soon! Stay tuned...
    </TabPanel> 
    </>
    )
}

export default ParamterTabOverview