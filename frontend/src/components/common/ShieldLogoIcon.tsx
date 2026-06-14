import Assets from "../../assets/assets";

const ShieldSvg = Assets.logos.ShieldComponent;

interface ShieldLogoIconProps {
    color?: string;
}

const ShieldLogoIcon = (props: ShieldLogoIconProps) => {
    return (
        <ShieldSvg
            height={25}
            width={25}
            fill={props.color || 'white'}
        />
    );
};

export default ShieldLogoIcon;
