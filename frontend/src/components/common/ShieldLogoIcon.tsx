import Assets from "../../assets/assets";

interface ShieldLogoIconProps {
    color?: string;
}

const ShieldLogoIcon = (props: ShieldLogoIconProps) => {
    return (
        <Assets.logos.ShieldComponent
            height={25}
            width={25}
            fill={props.color || 'white'}
        />
    );
};

export default ShieldLogoIcon;
