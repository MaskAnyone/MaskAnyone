import SideBySideCardContent from "./SideBySideCardContent";
import React from "react";
import SideBySideCard from "./SideBySideCard";
import {ButtonBase} from "@mui/material";

interface CheckableCardProps {
    title: string;
    description: string;
    checked: boolean;
    imagePath: String;
    onSelect: () => void;
}

const CheckableCard = (props: CheckableCardProps) => {
    return (
        <ButtonBase onClick={props.onSelect} sx={{ textAlign: 'inherit' }}>
            <SideBySideCard>
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
