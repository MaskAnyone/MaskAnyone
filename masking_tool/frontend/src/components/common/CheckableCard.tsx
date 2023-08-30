import SideBySideCardContent from "./SideBySideCardContent";
import React from "react";
import SideBySideCard from "./SideBySideCard";
import {ButtonBase} from "@mui/material";

interface CheckableCardProps {
    title: string;
    description: string;
    checked: boolean;
    imagePath: string;
    onSelect: () => void;
}

const CheckableCard = (props: CheckableCardProps) => {
    return (
        <ButtonBase onClick={props.onSelect} sx={{ textAlign: 'inherit' }}>
            <SideBySideCard image={props.imagePath}>
                <SideBySideCardContent
                    title={props.title}
                    description={props.description}
                    checkable={true}
                    selected={props.checked}
                    onSelect={props.onSelect}
                />
            </SideBySideCard>
        </ButtonBase>
    );
};

export default CheckableCard;
