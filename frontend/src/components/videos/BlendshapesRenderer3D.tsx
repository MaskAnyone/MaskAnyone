import { Canvas } from "@react-three/fiber"
import { Character } from "./BlendshapeCharacter"
import { Color } from "three"
import { useTheme } from "@mui/material"

interface BlendshapesRenderer3DProps {
    blendshapes: any;
    fps: number;
}

const BlendshapesRenderer3D = (props: BlendshapesRenderer3DProps) => {
    const theme = useTheme();
    const canvasBg = theme.palette.mode === 'dark' ? '#2d2d2d' : '#e8e8e8';

    return (
        <Canvas
            camera={{ fov: 10 }} shadows
            style={{ backgroundColor: canvasBg, height: 350 }}
        >
            <ambientLight intensity={0.5} />
            <pointLight position={[10, 10, 10]} color={new Color(1, 1, 0)} intensity={0.5} castShadow />
            <pointLight position={[-10, 0, 10]} color={new Color(1, 0, 0)} intensity={0.5} castShadow />
            <pointLight position={[0, 0, 10]} intensity={0.5} castShadow />
            <Character fps={props.fps} blendshapes={props.blendshapes} />
        </Canvas>

    )
}

export default BlendshapesRenderer3D
