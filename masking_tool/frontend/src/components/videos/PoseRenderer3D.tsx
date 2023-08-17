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
    private animationId: any;

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

    componentWillUnmount() {
        cancelAnimationFrame(this.animationId);
    }

    render() {
        return (
            <div id={'three-renderer'} style={styles.container}>
                <span style={styles.frameOverlay}>{this.props.frame} / {this.props.pose.length}</span>
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
        this.animationId = requestAnimationFrame(this.animate);

        const currentPose = this.props.pose[Math.min(this.props.frame, this.props.pose.length - 1)];

        this.animateLandmarks(currentPose);
        this.animateConnections(currentPose);

        this.renderer.render(this.scene, this.camera);
        this.stats.update();
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

export default PoseRenderer3D;
