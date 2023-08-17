import * as THREE from 'three';
import React from "react";
// @ts-ignore
import { OrbitControls } from 'three/addons/controls/OrbitControls.js';
import Stats from 'three/examples/jsm/libs/stats.module'
import { connections } from '../../util/skeletonConnections';

const styles = {
    container: {
        position: 'relative' as const,
        width: 600,
        height: 350,
    },
    frameOverlay: {
        position: 'absolute' as const,
        top: 0,
        right: 4,
    },
};

interface PoseRenderer3DProps {
    pose: number[][][];
    frame: number;
}

class PoseRenderer3D extends React.Component<PoseRenderer3DProps, {}> {
    private readonly scene: THREE.Scene;
    private readonly camera: THREE.Camera;
    private readonly renderer: THREE.Renderer;
    private readonly orbitControls: OrbitControls;
    private readonly stats: Stats;
    private readonly spheres: THREE.Mesh[];
    private readonly connections: THREE.Line[];

    constructor(props: PoseRenderer3DProps) {
        super(props);

        this.scene = new THREE.Scene();
        this.camera = new THREE.PerspectiveCamera(75, 600 / 350, 0.1, 1000);
        this.renderer = new THREE.WebGLRenderer({ alpha: true});
        this.orbitControls = new OrbitControls(this.camera, this.renderer.domElement);
        this.stats = new Stats();
        this.spheres = [];
        this.connections = [];

        this.animate = this.animate.bind(this);
    }

    componentDidMount() {
        const containerElement = document.getElementById('three-renderer')!;

        this.init(containerElement);
        this.animate();
    }

    render() {
        return (
            <div id={'three-renderer'} style={styles.container}>
                <span style={styles.frameOverlay}>{this.props.frame}</span>
            </div>
        );
    }

    private init(containerElement: HTMLElement) {
        this.renderer.setSize(600, 350);
        containerElement.appendChild(this.renderer.domElement);

        this.camera.position.z = 1;
        this.orbitControls.update();
        this.scene.background = new THREE.Color(0xdddddd);

        (this.stats as any).domElement.style.position = 'absolute';
        containerElement.appendChild(this.stats.dom);

        this.scene.add(new THREE.AxesHelper(0.5));

        this.initLandmarks();
        this.initConnections();
    }

    private initLandmarks() {
        const dotMaterial = new THREE.MeshBasicMaterial( { color: 0x000000 } );

        for (const landmarkIndex in this.props.pose[0]) {
            const geometry = new THREE.SphereGeometry( 0.01, 16, 8 );
            const sphere = new THREE.Mesh(geometry, dotMaterial);

            this.scene.add(sphere);
            this.spheres.push(sphere);
        }
    }

    private initConnections() {
        const lineMaterial = new THREE.LineBasicMaterial({
            color: 0x0000ff,
            linewidth: 2,
        });

        for (const connectionFrom of Object.keys(connections).map(Number)) {
            // @ts-ignore
            for (const connectionTo of connections[connectionFrom]) {
                const geo = new THREE.BufferGeometry();
                const line = new THREE.Line(geo, lineMaterial);
                this.scene.add(line);
                this.connections.push(line);
            }
        }
    }

    private animate() {
        const currentPose = this.props.pose[this.props.frame];

        this.animateLandmarks(currentPose);
        this.animateConnections(currentPose);

        this.renderer.render(this.scene, this.camera);
        this.stats.update();

        requestAnimationFrame(this.animate)
    }

    private animateLandmarks(pose: number[][]) {
        const xAvg = pose.map(landmark => landmark[0]).reduce((acc, pos) => acc + pos, 0.0) / pose.length;
        // @ts-ignore
        const yAvg = pose.map(landmark => landmark[1]).reduce((acc, pos) => acc + pos, 0.0) / pose.length;

        for (const landmarkIndex in pose) {
            const landmark = pose[landmarkIndex];
            const sphere = this.spheres[landmarkIndex];

            sphere.position.x = landmark[0] - xAvg;
            // @ts-ignore
            sphere.position.y = -(landmark[1] - yAvg);
            // @ts-ignore
            sphere.position.z = landmark[2];
        }
    }

    private animateConnections(pose: number[][]) {
        const xAvg = pose.map(landmark => landmark[0]).reduce((acc, pos) => acc + pos, 0.0) / pose.length;
        // @ts-ignore
        const yAvg = pose.map(landmark => landmark[1]).reduce((acc, pos) => acc + pos, 0.0) / pose.length;

        let index = 0;
        for (const connectionFrom of Object.keys(connections).map(Number)) {
            // @ts-ignore
            for (const connectionTo of connections[connectionFrom]) {
                const connection = this.connections[index];

                connection.geometry.setFromPoints([
                    // @ts-ignore
                    new THREE.Vector3(pose[connectionFrom][0] - xAvg, -(pose[connectionFrom][1] - yAvg), pose[connectionFrom][2]),
                    // @ts-ignore
                    new THREE.Vector3(pose[connectionTo][0] - xAvg, -(pose[connectionTo][1] - yAvg), pose[connectionTo][2]),
                ]);

                index++;
            }
        }
    }
}

/*const PoseRenderer3D = () => {
    const sceneRef = useRef<THREE.Scene>(new THREE.Scene());
    const cameraRef = useRef<THREE.Camera>(new THREE.PerspectiveCamera(75, 800 / 450, 0.1, 1000));
    const rendererRef = useRef<THREE.Renderer>(new THREE.WebGLRenderer({ alpha: true}));
    const orbitControlsRef = useRef<OrbitControls>(new OrbitControls(cameraRef.current, rendererRef.current.domElement));
    const spheresRef = useRef<THREE.Mesh[]>([]);
    const [pose, setPose] = useState<number[][][]>(poseTed);

    useEffect(() => {
        rendererRef.current.setSize(800, 350);
        document.getElementById('three-renderer')!.appendChild(rendererRef.current.domElement);

        cameraRef.current.position.z = 1;
        orbitControlsRef.current.update();

        sceneRef.current.background = new THREE.Color(0xdddddd);

        const stats = new Stats();
        // @ts-ignore
        stats.domElement.style.position = 'absolute';
        document.getElementById('three-renderer')!.appendChild(stats.dom)

        let currentRealPose = 0;
        let currentPose = 0;

        const dotMaterial = new THREE.MeshBasicMaterial( { color: 0x000000 } );
        const lineMaterial = new THREE.LineBasicMaterial({
            color: 0x0000ff,
            linewidth: 2,
        });

        const axesHelper = new THREE.AxesHelper(0.2);
        sceneRef.current.add( axesHelper );

        for (const landmark of pose[currentPose]) {
            const geometry = new THREE.SphereGeometry( 0.01, 16, 8 );
            const sphere = new THREE.Mesh(geometry, dotMaterial);

            sceneRef.current.add(sphere);
            spheresRef.current.push(sphere);
        }

        const animate = () => {
            requestAnimationFrame(animate);

            // @ts-ignore
            const xAvg = pose[currentPose].map(landmark => landmark[0]).reduce((acc, pos) => acc + pos, 0.0) / pose[currentPose].length;
            // @ts-ignore
            const yAvg = pose[currentPose].map(landmark => landmark[1]).reduce((acc, pos) => acc + pos, 0.0) / pose[currentPose].length;

            for (const landmarkIndex in pose[currentPose]) {
                const landmark = pose[currentPose][landmarkIndex];
                const sphere = spheresRef.current[landmarkIndex];

                sphere.position.x = landmark[0] - xAvg;
                // @ts-ignore
                sphere.position.y = -(landmark[1] - yAvg);
                // @ts-ignore
                sphere.position.z = landmark[2];
            }

            /*for (const connectionFrom of Object.keys(connections).map(Number)) {
                // @ts-ignore
                for (const connectionTo of connections[connectionFrom]) {
                    const geo = new THREE.BufferGeometry().setFromPoints([
                        // @ts-ignore
                        new THREE.Vector3(pose[currentPose][connectionFrom][0] - xAvg, -(pose[currentPose][connectionFrom][1] - yAvg), pose[currentPose][connectionFrom][2]),
                        // @ts-ignore
                        new THREE.Vector3(pose[currentPose][connectionTo][0] - xAvg, -(pose[currentPose][connectionTo][1] - yAvg), pose[currentPose][connectionTo][2]),
                    ]);

                    const line = new THREE.Line(geo, lineMaterial);
                    sceneRef.current.add(line);
                }
            }*

            rendererRef.current.render(sceneRef.current, cameraRef.current);
            currentRealPose += 0.2;
            currentPose = Math.round(currentRealPose);

            if (!pose[currentPose]) {
                currentPose = 0;
                currentRealPose = 0;
            }

            /*for( var i = sceneRef.current.children.length - 1; i >= 0; i--) {
                const obj = sceneRef.current.children[i];
                sceneRef.current.remove(obj);
            }*

            stats.update();
        }
        animate();
    }, [pose]);

    return (
        <div id={'three-renderer'} style={{ position: 'relative' }}>
        </div>
    );
};*/

export default PoseRenderer3D;
