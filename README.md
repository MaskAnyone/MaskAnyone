<p align="center"><img width="300" height="300" src="frontend/public/favicon.png" alt="Logo"></p>

<h1 align="center" style=font-size:200px>MaskAnyone - The de-identification toolbox for video data.</h1>

<a name="overview"></a>
## Overview

MaskAnyone is a **de-identifiaction toolbox for videos** that allows you to remove personal identifiable information from videos, while at the same time preserving utility. It provides a variety of algotihms that allows you to **anonymize videos** with just a few clicks. Anonymization algorithms can be selected and combined depending on what aspects of utility should be preserved and which computational ressources are available.

MaskAnyone is a docker-packaged modern web app that is built with React, MaterialUI, FastAPI and PostgreSQL. It is designed to be easily extensible with new algorithms and to be scalable with multiple docker workers. It is also designed to be easily usable by non-technical users.


_This Project is the result of the 2023 Mastersproject at the "Intelligent Systems Group" at the Hasso-Plattner-Institute._


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

Make sure you have installed [Docker](https://docs.docker.com/get-docker/) on your system and set the appropriate permissions. Then run the following command:

Clone this repository and then run the following commands in this directory.
If this is the first time you are running the project, this process can take a while depending on your internetconnection. If your connection times out, just run the command again.

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

Further services can be found under:
- Backend: [https://localhost/api/docs](https://localhost/api/docs)
- PGAdmin: [https://localhost:5433/](https://localhost:5433/) (Password: `dev`)

<a name="devs"></a>
## For developers

In this section we have collected some further information for developers. Please also refer to our report for further elaboration of the architecture.

### Services
- Frontend: [https://localhost](https://localhost)
- Backend: [https://localhost/api/docs](https://localhost/api/docs)
- PGAdmin: [https://localhost:5433/](https://localhost:5433/) (Password: `dev`)

### Algorithms

**Adding a new algorithm**

**Adapting accepted/default parameters of an algorithm**

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

