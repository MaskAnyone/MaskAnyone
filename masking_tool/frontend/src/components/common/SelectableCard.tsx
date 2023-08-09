import SideBySideCardContent from "./SideBySideCardContent";
import React from "react";
import SideBySideCard from "./SideBySideCard";

interface SelectableCardProps {
    title: string;
    description: string;
    selected: boolean;
    onSelect: () => void;
}

const SelectableCard = (props: SelectableCardProps) => {
    return (
        <SideBySideCard>
            <SideBySideCardContent
                title={props.title}
                description={props.description}
                selectable={true}
                selected={props.selected}
                onSelect={props.onSelect}
            />
        </SideBySideCard>
    );
};

export default SelectableCard;
