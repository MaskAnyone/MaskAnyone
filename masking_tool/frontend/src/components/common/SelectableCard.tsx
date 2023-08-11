import SideBySideCardContent from "./SideBySideCardContent";
import React from "react";
import SideBySideCard from "./SideBySideCard";
import {ButtonBase} from "@mui/material";

const styles = {
    container: {
        textAlign: 'inherit',
        whiteSpace: 'initial',
    },
};

interface SelectableCardProps {
    title: string;
    description: string;
    selected: boolean;
    imagePath: string;
    onSelect: () => void;
    style?: React.CSSProperties;
}

const SelectableCard = (props: SelectableCardProps) => {
    return (
        <ButtonBase onClick={props.onSelect} sx={styles.container} style={props.style}>
            <SideBySideCard image={props.imagePath}>
                <SideBySideCardContent
                    title={props.title}
                    description={props.description}
                    selectable={true}
                    selected={props.selected}
                    onSelect={props.onSelect}
                />
            </SideBySideCard>
        </ButtonBase>
    );
};

export default SelectableCard;
