<p align="center"><img width="300" height="300" src="frontend/public/favicon.png" alt="Logo"></p>

<h1 align="center" style=font-size:200px>MaskAnyone - The de-identification toolbox for video data.</h1>

<a name="overview"></a>
## Overview

MaskAnyone is a **de-identifiaction toolbox for videos** that allows you to remove personal identifiable information from videos, while at the same time preserving utility. It provides a variety of algorithms that allows you to **anonymize videos** with just a few clicks. Anonymization algorithms can be selected and combined depending on what aspects of utility should be preserved and which computational resources are available.

MaskAnyone is a docker-packaged modern web app that is built with React, MaterialUI, FastAPI and PostgreSQL. It is designed to be easily extensible with new algorithms and to be scalable with multiple docker workers. It is also designed to be easily usable by non-technical users.


_This Project is the result of the 2023 Mastersproject at the "Intelligent Systems Group" at the Hasso Plattner Institute._


<a name="features"></a>
## Features

<table>
  <thead>
    <tr>
      <th>✨</th>
      <th>Feature</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>✅</td>
      <td>Streamlined and simple to use UI</td>
    </tr>
    <tr>
      <td>📆</td>
      <td>Hiding Individuals (Blurring/Blackingout of Face or Body)</td>
    </tr>
    <tr>
      <td>📆</td>
      <td>Removal of Individuals (Background Estimation)</td>
    </tr>
     <tr>
      <td>📆</td>
      <td>Replacement of Individuals with kinematic Skeleton and Facemesh</td>
    </tr>
    <tr>
      <td>📆</td>
      <td>Monocular Video to animated 3D Skeleton</td>
    </tr>
     <tr>
      <td>📆</td>
      <td>Monocular Video to animated blender character</td>
    </tr>
     <tr>
      <td>📆</td>
      <td>Monocular Video to blendshapes facial model</td>
    </tr>
    <tr>
      <td>🤝</td>
      <td>Completely parameterizable algorithms</td>
    </tr>
    <tr>
      <td>📲</td>
      <td>Faceswapping for preserving expression</td>
    </tr>
    <tr>
      <td>❌</td>
      <td>Voice Masking (Swapping or Removal)</td>
    </tr>
    <tr>
      <td>⏱</td>
      <td>Predefined and custom presets</td>
    </tr>
    <tr>
      <td>🗓 📆</td>
      <td>Scalability with mutliple docker workers</td>
    </tr>
    <tr>
      <td>🔎</td>
      <td>Extensability trough algorithms as docker containers and json schemas.</td>
    </tr>
  </tbody>
</table>

<a name="started"></a>
## Getting Started

<a name="setup"></a>
### Installation

Follow these steps to install MaskAnoyone:

Make sure you have installed [Docker](https://docs.docker.com/get-docker/) on your system and set the appropriate permissions.
Note: Currently if you want to use MaskAnyone with all its functions, it required around 35GB of space on your computer due to a large variety of pre-trained models. If you want a more lightweight installation without faceswapping and blender exports, comment out lines 48-72 in `docker-compose.yml` and the resulting system size will be around 15GB. (Add a "#" at the beginning of each line)

Clone this repository and then run the following commands in this directory.
If this is the first time you are running the project, this process can take a while depending on your internet connection. If your connection times out, just run the command again.

```bash
docker-compose build
docker-compose run --rm yarn yarn install
docker-compose up -d postgres
```
Wait a few seconds
```bash
docker-compose up -d
```

<a name="run"></a>
### Running the Application
Once you have installed the application, you can always start up the application with 

```bash
docker-compose up -d
```

The application will then be reachable under [https://localhost](https://localhost)

<a name="devs"></a>
## For developers

In this section we have collected some further information for developers. Please also refer to our report for further elaboration of the architecture.

### Services
- Frontend: [https://localhost](https://localhost)
- Backend: [https://localhost/api/docs](https://localhost/api/docs)
- PGAdmin: [https://localhost:5433/](https://localhost:5433/) (Password: `dev`)

### Debugging
Run the application with 
```bash
docker-compose up
```
to get the live output of the applicaiton and see where it might crash.
Alternatively you can use `docker-compose logs -f` if you already started the application using the detached (`-d`) flag.

### Algorithms

**Adding a new algorithm**
1. Write your algorithm code and create an entrypoint file that accepts command line arguments as follows:
  - `--in-path` The input path of the video that should be masked.
  - `--out-path` The output path were the masked video should be written to.
  - `--backend-update-url` An url to send progress status updates to. This is used to update the progress bar in the frontend.
  - `--out-path-extra` If the algoritm produces an additional output file, this argument can be used to specify the path to that file.
  You can also further define any argument you want in the same format. The above mentioned are just system used arguments that should be present in every algorithm.

2. Package the algorithm in a docker container including all dependencies. Make sure the dockerfile copies your algorithm during build.
3. Create a new folder for the algorithm-worker under /docker/python/workers 
4. Place the dockerfile and required other files in that folder
5. Create a config file for your worker in `/workers/docker_worker/configs` with the name of that worker. It should have the following form:

```
{
    "image_name": "name", <- As in 2. 
    "run_command": "python3", <- The command that runs the algorithm in the docker container
    "entry_point": "/myalgo/run.py", <- the entrypoint of the algorithm in the docker container
    "can_send_progress_update": true, <- if the algorithm is able to send progress updates to the frontend
    "can_produce_extra_file": false, <- if the algorithm is able to produce additional output files
    "accepted_subjects": [ <- the target of the algorithm. Can be "body" or "face"
        "face"
    ],
    "argument_schema": { <- currently not used but can be used for backend validation
        "type": "object",
        "properties": {}
    }
}
```

5. Add the worker to the `docker-compose.yml`.` 
  ```my-worker-name:
    build:
      context: ./docker/python/workers/my-worker-name
    command: "python docker_worker.py " <- dont change
    env_file:
      - ./app.env <- dont change
    volumes:
      - ./workers:/app <- dont change
    environment:
      WORKER_TYPE: "name" <- as in step 2.
    depends_on:
      - python
    ```
6. Register the algorithm in workers: In `/workers/config.py` add the name of your algorithm folder as in 2. to the AVAILABLE_DOCKER_MODELS list.
7. Register the algorithm in the frontend: In `frontend/src/util/maskingMethids.ts`, add the algorithm to the maskingMethods dictionary, as the other algorithms.

```
skeleton: {
        name: "MyAlgorithmName",
        description: "Description of the algorithm",
        imagePath: 'path/to/previer/of/algorithm/result.png',
        parameterSchema: MyFormSchema, <- defines the accepted parameters as RJSF schema
        defaultValues: { <- Set default values for the parameters
            maskingModel: "mediapipe", <- maskingModel ALWAYS HAS TO BE a paramter with the name of the algorithm as in 6.
            numPoses: 1,
            confidence: 0.5,
            timeseries: false
        },
        backendFormat: {
            "body": "skeleton", <- key can be "body" or "face" and the value can be anything that is a single word descritoption of your method.
        }
    },
```

**Adapting accepted/default parameters of an algorithm**
Open `frontend/src/util/maskingMethids.ts` and find your algorithm, then adapt default paramters or the paramterSchema.

**Adding new target faces for FaceSwapping**
Add the face file (as .jpg) to `/docker/python/workers/roop/faces`. Then open `frontend/src/util/formSchemas.ts` and add the name of the file without extension to the enum in the `faceswapFormSchema` variable. Finally, run `docker-compose build` again to make the changes effective.

**Adding new voices for VoiceSwapping**
A list of pre-trained voice models can be found under: [Link](https://docs.google.com/spreadsheets/d/1tAUaQrEHYgRsm1Lvrnj14HFHDwJWl0Bd9x0QePewNco/edit#gid=1977693859). Add the code to download to `/docker/python/workers/basic_masking/scripts/download_voice_models.py` and refer to the examples of other downloads in this file. The resulting file should be saved under: `{model_base_path}/weights/modelName/model.pth` and the index file under `{model_base_path}/weights/modelName/index_file.pth`. Then add modelName to the available options in `frontend/src/util/formSchemas.ts` in the enum in the `rvcSchema` variable. Finally run `docker-compose build` to make the changes effective and to start the download of the model.

### Database

**Export Schema**
If you changed the schema of the DB please run the following command to refresh the schema dump.
This is to ensure that the DB schema dump is up-to-date for whenever someone sets up the project.
```bash
docker-compose exec postgres pg_dump --schema-only --username dev --create prototype > ./docker/postgres/docker-entrypoint-initdb.d/prototype.sql
```
You can also include the `--schema-only` parameter to omit the data in the dump.

**Reset DB**
To reset the DB to the latest schema simply run the following commands.
```bash
docker-compose down -v
docker-compose up -d postgres
```
Wait a few seconds
```bash
docker-compose up -d
```

## Status of the project
Mask Anyone was developed as a prototype showcasing different possibilities in the field of person de-identification in videos. 
While it can already produce very convincing results for a considerable subset of videos, there are still a number of issues that need to be addressed: 
- Frame Cuts (which can lead to weird effects)
- Leaky Frames (where e.g. the person could not be detected and is thus will not be masked and is  visible)
- Audio masking leads to inaudible results if multiple speakers are overlapping
- Face and Hands can not be properly detected by mediapipe if the person is farther away. (This can be fixed as soon as the new holistic model is released)

Additionally, due to the vastly different requirements of different processing methods and models, the worker pipeline 
    has also become more and more complex during the development process. As such, refactorings will be needed for additional features to retain performance, correctness and reliability.

### Making it production ready
In its current state, Mask Anyone is not ready to be deployed into production for real-world usecases. 
It has, however, been built with this eventual goal in mind. As such, the following additions will be necessary to make Mask Anyone production-ready:
- Multi-tenant support: currently, the concept of a "user" does not exist. Consequently, everything lives within the same workspace meaning that all users accessing an instance of Mask Anyone will see all the data and videos of the other users. For hosting Mask Anyone locally this is fine. However, for running Mask Anyone on a server, the concept of "users" must be introduced and any relevant data items must indiciate which user they belong to. With this addition, Mask Anyone can be used by many users simultaneously without data privacy issues.
- Introduce Authentication / Access and Identity Management
  - User-Facing: as mentioned above, there are currently no "users" and as such there is also no login-functionality. This must be added as well. Our recommendation would be to include a [Keycloak](https://www.keycloak.org/) instance in the infrastructure and use it for any authentication-related requirements. The general idea would be:
    - Set up Keycloak
    - Configure frontend to perform user login using the Keycloak service (see Keycloak documentation)
    - When triggering API requests in the frontend, send along a JWT token which identifies the user and was retrieved through the login
    - Configure the backend to validate the JWT tokens the frontend sends through the API and ensure that the user is allowed to access the requested resources (e.g. owns them)
  - Backend / Worker communication
    - As both the backend and worker services live in a controlled environment, less complicated authentication procedures are necessary. Our recommendation for this would be to simply generate a secret which the worker must send along with each request to the backend. Therefore, only those who have access to this secret will be able to finalize a worker setup to communicate with the backend
- Setup production infrastructure
  - The infrastructure currently provided is set up in a way that runs all our services in dev / debug modes. This can be inefficient and unsecure and is therefore not recommended for production
  - A separate Docker-based infrastructure should be set up and configured specifically for production deployment of Mask Anyone
  - Specifically for the frontend, please note that it must be built into a set of static files which can then be hosted by a webserver like Nginx. The infrastructure required for that is consequently much different to the dev infrastructure where the frontend is served through a node development server.
- Reducing the System Size: Currently there are lots of duplicate dependancies for the docker containers. Due to version conflicts in dependancies of some algorithms it is not possible to place them in a single container without adapting the algorithms code.
  - Introduce better staged builds to speed up installation process
  - Identify largest dependancy and possibly introduce shared dependacies where possible

### Credits
We thank the authors of different implementations we packaged in our project. Our project relies heavily on the work of

- Googles' [MediaPipe](https://github.com/google/mediapipe) for FaceMesh and Skeleton detection and Blendshape computation
- UltraLytics' [YOLOv8](https://github.com/ultralytics/ultralytics) for person detection
- Azamat Kanametov's pre-trained model for [Face Detection](https://github.com/akanametov/yolov8-face) based on the YOLOv8 architecture
- The [RVC](https://github.com/RVC-Project/Retrieval-based-Voice-Conversion-WebUI/tree/main) Project for Voice Masking
- [Blender](https://www.blender.org/) + [BlendARMocap](https://github.com/cgtinker/BlendArMocap)
- The [Roop Project](https://github.com/s0md3v/roop) and InsightFace's pretrained model for FaceSwapping
- The [HumansIn4D](https://github.com/shubham-goel/4D-Humans) Project (Not yet included in the tool)
- [MotionBert](https://github.com/Walter0807/MotionBERT) (Not yet included in the tool)

and many more.
