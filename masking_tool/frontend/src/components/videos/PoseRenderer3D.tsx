import * as THREE from 'three';
import React from "react";
// @ts-ignore
import { OrbitControls } from 'three/addons/controls/OrbitControls.js';
import Stats from 'three/examples/jsm/libs/stats.module'
import {skeletonConnections, skeletonLandmarks} from '../../util/skeletonConnections';

const styles = {
    container: {
        position: 'relative' as const,
        width: 600,
        height: 400,
    },
    frameOverlay: {
        position: 'absolute' as const,
        top: 0,
        right: 4,
    },
};

interface PoseRenderer3DProps {
    mpKinematics?: any[];
    frame: number;
}

class PoseRenderer3D extends React.Component<PoseRenderer3DProps, {}> {
    private readonly scene: THREE.Scene;
    private readonly camera: THREE.Camera;
    private readonly renderer: THREE.Renderer;
    private readonly orbitControls: OrbitControls;
    private readonly stats: Stats;
    private readonly spheres: Record<string, THREE.Mesh>;
    private readonly connections: THREE.Line[];
    private animationId: any;

    constructor(props: PoseRenderer3DProps) {
        super(props);

        this.scene = new THREE.Scene();
        this.camera = new THREE.PerspectiveCamera(75, 600 / 400, 0.1, 1000);
        this.renderer = new THREE.WebGLRenderer({ alpha: true});
        this.orbitControls = new OrbitControls(this.camera, this.renderer.domElement);
        this.stats = new Stats();
        this.spheres = {};
        this.connections = [];

        this.animate = this.animate.bind(this);
    }

    componentDidMount() {
        const containerElement = document.getElementById('three-renderer')!;

        this.init(containerElement);
        this.animate();
    }

    componentWillUnmount() {
        cancelAnimationFrame(this.animationId);
    }

    render() {
        if (!this.props.mpKinematics) {
            return null;
        }

        return (
            <div id={'three-renderer'} style={styles.container}>
                <span style={styles.frameOverlay}>{this.props.frame} / {this.props.mpKinematics.length}</span>
            </div>
        );
    }

    private init(containerElement: HTMLElement) {
        this.renderer.setSize(600, 400);
        containerElement.appendChild(this.renderer.domElement);

        this.camera.position.z = 1.5;

        this.orbitControls.update();
        this.scene.background = new THREE.Color(0xdddddd);

        (this.stats as any).domElement.style.position = 'absolute';
        containerElement.appendChild(this.stats.dom);

        this.scene.add(new THREE.AxesHelper(0.5));

        this.initLandmarks();
        this.initConnections();
    }

    private initLandmarks() {
        const dotMaterial = new THREE.MeshBasicMaterial( { color: 0x444444 } );
        for (let i = 0; i < skeletonLandmarks.length; i++) {
            const geometry = new THREE.SphereGeometry( 0.02, 16, 8 );
            const sphere = new THREE.Mesh(geometry, dotMaterial);

            this.scene.add(sphere);
            this.spheres[skeletonLandmarks[i]] = sphere;
        }
    }

    private initConnections() {
        const lineMaterial = new THREE.LineBasicMaterial({
            color: 0xff8b28,
            linewidth: 4,
        });

        for (const connectionFrom of Object.keys(skeletonConnections)) {
            // @ts-ignore
            for (const connectionTo of skeletonConnections[connectionFrom]) {
                const geo = new THREE.BufferGeometry();
                const line = new THREE.Line(geo, lineMaterial);
                this.scene.add(line);
                this.connections.push(line);
            }
        }
    }

    private animate() {
        this.animationId = requestAnimationFrame(this.animate);

        const currentFrameData = this.props.mpKinematics![Math.min(this.props.frame, this.props.mpKinematics!.length - 1)];
        if (!currentFrameData) {
            return;
        }

        const currentPose = currentFrameData['world_landmarks'];

        // Check if there is a pose available to be rendered
        if (Object.keys(currentPose).length < 1) {
            return;
        }

        this.animateLandmarks(currentPose);
        this.animateConnections(currentPose);

        this.renderer.render(this.scene, this.camera);
        this.stats.update();
    }

    private animateLandmarks(pose: Record<string, /*number|*/{x: number, y: number, z: number}>) {
        for (const identifier of skeletonLandmarks) {
            const landmark = pose[identifier];
            const sphere = this.spheres[identifier];

            sphere.position.x = landmark.x;
            sphere.position.y = -landmark.y;
            sphere.position.z = landmark.z;
        }
    }

    private animateConnections(pose: Record<string, /*number|*/{x: number, y: number, z: number}>) {
        let index = 0;
        for (const connectionFrom of Object.keys(skeletonConnections)) {
            // @ts-ignore
            for (const connectionTo of skeletonConnections[connectionFrom]) {
                const connection = this.connections[index];

                connection.geometry.setFromPoints([
                    new THREE.Vector3(pose[connectionFrom].x, -pose[connectionFrom].y, pose[connectionFrom].z),
                    new THREE.Vector3(pose[connectionTo].x, -pose[connectionTo].y, pose[connectionTo].z),
                ]);

                index++;
            }
        }
    }
}

export default PoseRenderer3D;
