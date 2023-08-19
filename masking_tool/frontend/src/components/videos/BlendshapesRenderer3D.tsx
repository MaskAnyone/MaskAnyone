import { Canvas } from "@react-three/fiber"
import { Character } from "./BlendshapeCharacter"
import { Color } from "three"

interface BlendshapesRenderer3DProps {
    blendshapes: any;
}

const BlendshapesRenderer3D = (props: BlendshapesRenderer3DProps) => {
    return (
        <Canvas
            camera={{ fov: 10 }} shadows
            style={{ backgroundColor: '#FAD972', height: 350 }}
        >
            <ambientLight intensity={0.5} />
            <pointLight position={[10, 10, 10]} color={new Color(1, 1, 0)} intensity={0.5} castShadow />
            <pointLight position={[-10, 0, 10]} color={new Color(1, 0, 0)} intensity={0.5} castShadow />
            <pointLight position={[0, 0, 10]} intensity={0.5} castShadow />
            <Character blendshapes={props.blendshapes} />
        </Canvas>

    )
}

export default BlendshapesRenderer3D
