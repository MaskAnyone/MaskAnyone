import SideBySideCardContent from "./SideBySideCardContent";
import React from "react";
import SideBySideCard from "./SideBySideCard";

interface CheckableCardProps {
    title: string;
    description: string;
    checked: boolean;
    imagePath: String;
    onSelect: () => void;
}

const CheckableCard = (props: CheckableCardProps) => {
    return (
        <SideBySideCard>
            <SideBySideCardContent
                title={props.title}
                description={props.description}
                checkable={true}
                selected={props.checked}
                onSelect={props.onSelect}
            />
        </SideBySideCard>
    );
};

export default CheckableCard;
