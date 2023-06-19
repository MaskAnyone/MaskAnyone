# Masking Tool

## Installation
Please make sure you have installed [Docker](https://docs.docker.com/engine/installation/ "Install Docker") and [Docker Compose](https://docs.docker.com/compose/install/ "Install Docker Compose").

Clone the repo and then run the following commands in this directory.
```bash
docker-compose build
docker-compose run --rm yarn yarn install
docker-compose up -d
```

## Services
- Frontend: [https://localhost](https://localhost)
- Backend: [https://localhost/api/docs](https://localhost/api/docs)
- PGAdmin: [https://localhost:5433/](https://localhost:5433/) (Password: `dev`)

## Database
If you changed the schema of the DB please run the following command to refresh the schema dump.
This is to ensure that the DB schema dump is up-to-date for whenever someone sets up the project.
```bash
docker-compose exec postgres pg_dump --schema-only --username dev --create prototype > ./docker/postgres/docker-entrypoint-initdb.d/prototype.sql
```
