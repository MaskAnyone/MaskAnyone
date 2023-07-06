import * as THREE from 'three';
import {useEffect, useRef, useState} from "react";
// @ts-ignore
import { OrbitControls } from 'three/addons/controls/OrbitControls.js';
import poseTed from '../../mockData/ted_kid_pose.json';
import { connections } from '../../util/skeletonConnections';

const PoseRenderer3D = () => {
    const sceneRef = useRef<THREE.Scene>(new THREE.Scene());
    const cameraRef = useRef<THREE.Camera>(new THREE.PerspectiveCamera(75, 800 / 450, 0.1, 1000));
    const rendererRef = useRef<THREE.Renderer>(new THREE.WebGLRenderer({ alpha: true}));
    const orbitControlsRef = useRef<OrbitControls>(new OrbitControls(cameraRef.current, rendererRef.current.domElement));
    const [pose, setPose] = useState<number[][][]>(poseTed)

    useEffect(() => {
        rendererRef.current.setSize(800, 350);
        document.getElementById('three-renderer')!.appendChild(rendererRef.current.domElement);
      
        cameraRef.current.position.z = 1;
        orbitControlsRef.current.update();

        let currentRealPose = 0;
        let currentPose = 0;

        const animate = () => {
            requestAnimationFrame( animate );

            const material = new THREE.MeshBasicMaterial( { color: 0x000000 } );

            // @ts-ignore
            const xAvg = pose[currentPose].map(landmark => landmark[0]).reduce((acc, pos) => acc + pos, 0.0) / pose[currentPose].length;
            // @ts-ignore
            const yAvg = pose[currentPose].map(landmark => landmark[1]).reduce((acc, pos) => acc + pos, 0.0) / pose[currentPose].length;

            for (const landmark of pose[currentPose]) {
                const geometry = new THREE.SphereGeometry( 0.01, 16, 8 );
                const sphere = new THREE.Mesh( geometry, material );
                // @ts-ignore
                sphere.position.x = landmark[0] - xAvg;
                // @ts-ignore
                sphere.position.y = -(landmark[1] - yAvg);
                // @ts-ignore
                sphere.position.z = landmark[2];
                sceneRef.current.add(sphere);
            }

            const mat = new THREE.LineBasicMaterial({
                color: 0x0000ff,
                linewidth: 2,
            });

            for (const connectionFrom of Object.keys(connections).map(Number)) {
                // @ts-ignore
                for (const connectionTo of connections[connectionFrom]) {
                    const geo = new THREE.BufferGeometry().setFromPoints([
                        // @ts-ignore
                        new THREE.Vector3(pose[currentPose][connectionFrom][0] - xAvg, -(pose[currentPose][connectionFrom][1] - yAvg), pose[currentPose][connectionFrom][2]),
                        // @ts-ignore
                        new THREE.Vector3(pose[currentPose][connectionTo][0] - xAvg, -(pose[currentPose][connectionTo][1] - yAvg), pose[currentPose][connectionTo][2]),
                    ]);

                    const line = new THREE.Line(geo, mat);
                    sceneRef.current.add(line);
                }
            }

            rendererRef.current.render(sceneRef.current, cameraRef.current);
            currentRealPose += 0.2;
            currentPose = Math.round(currentRealPose);

            if (!pose[currentPose]) {
                currentPose = 0;
                currentRealPose = 0;
            }

            for( var i = sceneRef.current.children.length - 1; i >= 0; i--) {
                const obj = sceneRef.current.children[i];
                sceneRef.current.remove(obj);
            }
        }
        animate();
    }, [pose]);

    return (
        <div id={'three-renderer'}>
        </div>
    );
};

export default PoseRenderer3D;
