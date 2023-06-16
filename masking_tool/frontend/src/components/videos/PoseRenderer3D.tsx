import * as THREE from 'three';
import {useEffect, useRef} from "react";
// @ts-ignore
import { OrbitControls } from 'three/addons/controls/OrbitControls.js';
import pose from './ted_kid_pose.json';

console.log(pose);

/*const pose = [
    [ 0.4029371440410614 , 0.28430885076522827 , -0.11227834969758987 ],
    [ 0.408744215965271 , 0.2696499824523926 , -0.11536327749490738 ],
    [ 0.41174575686454773 , 0.2703370451927185 , -0.11556244641542435 ],
    [ 0.41428515315055847 , 0.27104923129081726 , -0.11551360040903091 ],
    [ 0.4048270285129547 , 0.2692281901836395 , -0.09287286549806595 ],
    [ 0.4045993983745575 , 0.26883724331855774 , -0.09306186437606812 ],
    [ 0.40439507365226746 , 0.2681329548358917 , -0.09313029795885086 ],
    [ 0.42736369371414185 , 0.28087368607521057 , -0.09936695545911789 ],
    [ 0.41250163316726685 , 0.27583184838294983 , 0.0026515075005590916 ],
    [ 0.409321129322052 , 0.30043932795524597 , -0.1035434901714325 ],
    [ 0.4039127230644226 , 0.29965314269065857 , -0.07565401494503021 ],
    [ 0.4520743787288666 , 0.35483673214912415 , -0.12950585782527924 ],
    [ 0.40968334674835205 , 0.3690517246723175 , 0.09930572658777237 ],
    [ 0.47934651374816895 , 0.4488471746444702 , -0.21076436340808868 ],
    [ 0.412402480840683 , 0.4603283107280731 , 0.03953075781464577 ],
    [ 0.4302556812763214 , 0.4467233419418335 , -0.2804437577724457 ],
    [ 0.38589274883270264 , 0.4517500400543213 , -0.17462298274040222 ],
    [ 0.41850244998931885 , 0.4555438160896301 , -0.31053426861763 ],
    [ 0.37615740299224854 , 0.45084118843078613 , -0.21014641225337982 ],
    [ 0.41669416427612305 , 0.43706026673316956 , -0.3083927035331726 ],
    [ 0.3766995072364807 , 0.43945127725601196 , -0.22289538383483887 ],
    [ 0.41978514194488525 , 0.43712615966796875 , -0.2787270247936249 ],
    [ 0.3809009790420532 , 0.44034093618392944 , -0.18777601420879364 ],
    [ 0.4438345730304718 , 0.5647016167640686 , -0.07566715776920319 ],
    [ 0.4164477586746216 , 0.5642601847648621 , 0.07561110705137253 ],
    [ 0.44726818799972534 , 0.710669755935669 , -0.07772917300462723 ],
    [ 0.4189775586128235 , 0.7121257185935974 , 0.11397501081228256 ],
    [ 0.45955613255500793 , 0.8630850315093994 , -0.050821453332901 ],
    [ 0.41676923632621765 , 0.8559620976448059 , 0.18774296343326569 ],
    [ 0.46593591570854187 , 0.8876655101776123 , -0.05475960299372673 ],
    [ 0.4267466068267822 , 0.8819929361343384 , 0.19038227200508118 ],
    [ 0.4289036691188812 , 0.8990801572799683 , -0.16540822386741638 ],
    [ 0.3843114376068115 , 0.8914090991020203 , 0.11587833613157272 ],
];*/

const connections = {
    0: [1, 4],
    1: [2],
    2: [3],
    3: [7],
    4: [5],
    5: [6],
    6: [8],
    9: [10],
    11: [12, 13, 23],
    12: [14, 24],
    13: [15],
    14: [16],
    15: [17, 19, 21],
    16: [18, 20, 22],
    17: [19],
    18: [20],
    23: [24, 25],
    24: [26],
    25: [27],
    26: [28],
    27: [29, 31],
    28: [30, 32],
    29: [31],
    30: [32],
};

const PoseRenderer3D = () => {
    const sceneRef = useRef<THREE.Scene>(new THREE.Scene());
    const cameraRef = useRef<THREE.Camera>(new THREE.PerspectiveCamera(75, 800 / 450, 0.1, 1000));
    const rendererRef = useRef<THREE.Renderer>(new THREE.WebGLRenderer({ alpha: true }));
    const orbitControlsRef = useRef<OrbitControls>(new OrbitControls(cameraRef.current, rendererRef.current.domElement));

    useEffect(() => {
        rendererRef.current.setSize(800, 450);
        document.getElementById('test-renderer-three')!.appendChild(rendererRef.current.domElement);
        /*
        const material = new THREE.MeshBasicMaterial( { color: 0x000000 } );

        const xAvg = pose.map(landmark => landmark[0]).reduce((acc, pos) => acc + pos, 0.0) / pose.length;
        const yAvg = pose.map(landmark => landmark[1]).reduce((acc, pos) => acc + pos, 0.0) / pose.length;

        for (const landmark of pose) {
            const geometry = new THREE.SphereGeometry( 0.01, 16, 8 );
            const sphere = new THREE.Mesh( geometry, material );
            sphere.position.x = landmark[0] - xAvg;
            sphere.position.y = -(landmark[1] - yAvg);
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
                    new THREE.Vector3(pose[connectionFrom][0] - xAvg, -(pose[connectionFrom][1] - yAvg), pose[connectionFrom][2]),
                    new THREE.Vector3(pose[connectionTo][0] - xAvg, -(pose[connectionTo][1] - yAvg), pose[connectionTo][2]),
                ]);

                const line = new THREE.Line(geo, mat);
                sceneRef.current.add(line);
            }
        }

         */

        /*const geometry = new THREE.SphereGeometry( 0.2, 32, 16 );
        const material = new THREE.MeshBasicMaterial( { color: 0xffff00 } );
        const sphere = new THREE.Mesh( geometry, material );
        sceneRef.current.add(sphere);

        const geometry2 = new THREE.SphereGeometry( 0.2, 32, 16 );
        const material2 = new THREE.MeshBasicMaterial( { color: 0xffff00 } );
        const sphere2 = new THREE.Mesh( geometry2, material2 );
        sphere2.position.x = 1;
        sphere2.position.y = 1;
        sceneRef.current.add(sphere2);*/

        /*const mat = new THREE.LineBasicMaterial({
            color: 0x0000ff
        });

        const points = [];
        points.push( new THREE.Vector3( 0, 0, 0 ) );
        points.push( new THREE.Vector3( 1, 1, 0 ) );

        const geo = new THREE.BufferGeometry().setFromPoints( points );

        const line = new THREE.Line( geo, mat );
        sceneRef.current.add( line );*/

        //cameraRef.current.position.x = -2;
        cameraRef.current.position.z = 1;
        //cameraRef.current.position.y = 2;
        orbitControlsRef.current.update();


        let currentRealPose = 0;
        let currentPose = 0;

        function animate() {
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
    }, []);

    return (
        <div id={'test-renderer-three'}>
        </div>
    );
};

export default PoseRenderer3D;
