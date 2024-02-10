# MaskAnyone - Production Setup
This document describes the process of setting up a production environment for MaskAnyone.

## Prerequisites
Make sure you have installed [Docker](https://docs.docker.com/get-docker/) on your system and set the appropriate permissions. 
Furthermore, please also ensure that you have sufficient hard drive space available for the setup.
We recommend at least 50GB of free space.

We offer two types of setups:
- **Local Setup (Single-Tenant)**: The local setup is meant for running MaskAnyone locally on your own computer or laptop for your personal use only. It is mostly equivalent to the server setup except for the missing authentication/login process and reduced scalability capabilities (no horizontal scaling over multiple computers).
- **Server Setup (Multi-Tenant)**: The server setup is meant for running MaskAnyone on a server accessible to multiple users. It includes an authentication/login setup out of the box and allows for horizontal scalability by adding more instances to the setup.

Select the correct setup type for your use-case and follow the related instructions below.

## Local Setup (Single-Tenant)

**Step 1: Open a terminal on your computer/laptop.**
Make sure you have the necessary permissions to execute the following commands. 
This is quite specific to your operating system but in general you need to be able to create some files and run docker commands.

**Step 2: Create the `docker-compose.yml` file.**
Navigate to an empty directory of your choice and create a new file called `docker-compose.yml` with the following contents.
```yaml
version: '3'

services:
  proxy:
    image: ghcr.io/maskanyone/maskanyone/proxy:${MASK_ANYONE_VERSION}
    ports:
      - "443:443"
    restart: "on-failure"

  frontend:
    image: ghcr.io/maskanyone/maskanyone/frontend:${MASK_ANYONE_VERSION}

  postgres:
    image: ghcr.io/maskanyone/maskanyone/postgres:${MASK_ANYONE_VERSION}
    environment:
      POSTGRES_DB: postgres
      POSTGRES_USER: ${MASK_ANYONE_DB_USER}
      POSTGRES_PASSWORD: ${MASK_ANYONE_DB_PASSWORD}
    volumes:
      - data-postgres:/var/lib/postgresql/data

  backend:
    image: ghcr.io/maskanyone/maskanyone/backend:${MASK_ANYONE_VERSION}
    depends_on:
      - postgres
    environment:
      BACKEND_PG_HOST: postgres
      BACKEND_PG_PORT: 5432
      BACKEND_PG_USER: ${MASK_ANYONE_DB_USER}
      BACKEND_PG_PASSWORD: ${MASK_ANYONE_DB_PASSWORD}
      BACKEND_PG_DATABASE: prototype

volumes:
  data-postgres:
    driver: local
```

**Step 3: Configure the environment variables.**
Create a new file named `.env` in the same directory as the `docker-compose.yml` file and fill it with the following content.
Make sure to replace the password placeholders with your own strong passwords.
Since you're running this on your personal computer, we assume that your data is protected already anyway.
It is still recommended to use a fairly strong password.
```dotenv
MASK_ANYONE_DB_USER=maskanyone
MASK_ANYONE_DB_PASSWORD=<your-strong-password-1>
```

**Step 4: Pull/build the infrastructure.**
Run the following command:
```bash
docker-compose build
```

**Step 5: Start the application for the first time.**
To do so first start the database container.
```bash
docker-compose up -d postgres
```
Then wait for 30 seconds to give it some time to prepare the database.
Afterward, start all the other containers as well.
```bash
docker-compose up -d
```

**Step 6: Verify that MaskAnyone is running.**
First check that all containers are up and running:
```bash
docker-compose ps
```
If you find that a container is not running, you can try to identify the issue by looking at its logs:
```bash
docker-compose logs -f <container-name>
```
If your containers are running, then please try accessing MaskAnyone at [https://localhost](https://localhost) using your browser.

## Server Setup (Multi-Tenant)

**Step 1: Open a terminal on your server.**
This can, for example, be done via ssh. Make sure you have the necessary permissions to execute the following commands.
This setup assumes that you're using a Linux(i.e. Debian)-based system. 
However, generally speaking, Mask Anyone should also run on any other common operating system by following this setup.

**Step 2: Create the `docker-compose.yml` file.**
Navigate to an empty directory of your choice and create a new file called `docker-compose.yml` with the following contents.
```yaml
version: '3'

services:
  proxy:
    image: ghcr.io/maskanyone/maskanyone/proxy:${MASK_ANYONE_VERSION}
    ports:
      - "443:443"
    restart: "on-failure"

  frontend:
    image: ghcr.io/maskanyone/maskanyone/frontend:${MASK_ANYONE_VERSION}

  postgres:
    image: ghcr.io/maskanyone/maskanyone/postgres:${MASK_ANYONE_VERSION}
    environment:
      POSTGRES_DB: postgres
      POSTGRES_USER: ${MASK_ANYONE_DB_USER}
      POSTGRES_PASSWORD: ${MASK_ANYONE_DB_PASSWORD}
    volumes:
      - data-postgres:/var/lib/postgresql/data

  keycloak:
    image: ghcr.io/maskanyone/maskanyone/keycloak:${MASK_ANYONE_VERSION}
    depends_on:
      - postgres
    environment:
      KEYCLOAK_ADMIN: ${MASK_ANYONE_KC_ADMIN_USER}
      KEYCLOAK_ADMIN_PASSWORD: ${MASK_ANYONE_KC_ADMIN_PASSWORD}
      KC_DB_URL: jdbc:postgresql://postgres:5432/keycloak
      KC_DB_USERNAME: ${MASK_ANYONE_DB_USER}
      KC_DB_PASSWORD: ${MASK_ANYONE_DB_PASSWORD}

  backend:
    image: ghcr.io/maskanyone/maskanyone/backend:${MASK_ANYONE_VERSION}
    depends_on:
      - postgres
    environment:
      BACKEND_PG_HOST: postgres
      BACKEND_PG_PORT: 5432
      BACKEND_PG_USER: ${MASK_ANYONE_DB_USER}
      BACKEND_PG_PASSWORD: ${MASK_ANYONE_DB_PASSWORD}
      BACKEND_PG_DATABASE: prototype

volumes:
  data-postgres:
    driver: local
```

**Step 3: Configure the environment variables.**
Create a new file named `.env` in the same directory as the `docker-compose.yml` file and fill it with the following content.
Make sure to replace the password placeholders with your own strong passwords. 
These passwords should be different from each other and have a high level of entropy.
Optimally the password should be long (20+ characters) and contain a mix of upper and lower case letters, numbers, and special characters.
Consider using a password generator (e.g. `pwgen -cnys 32` on Linux).
```dotenv
MASK_ANYONE_DB_USER=maskanyone
MASK_ANYONE_DB_PASSWORD=<your-strong-password-1>

MASK_ANYONE_KC_ADMIN_USER=admin
MASK_ANYONE_KC_ADMIN_PASSWORD=<your-strong-password-2>
```

**Step 4: Pull/build the infrastructure.**
Run the following command:
```bash
docker-compose build
```

**Step 5: Start the application for the first time.**
To do so first start the database container.
```bash
docker-compose up -d postgres
```
Then wait for 30 seconds to give it some time to prepare the database. 
Afterward, start all the other containers as well.
```bash
docker-compose up -d
```

**Step 6: Verify that MaskAnyone is running.**
First check that all containers are up and running:
```bash
docker-compose ps
```
If you find that a container is not running, you can try to identify the issue by looking at its logs:
```bash
docker-compose logs -f <container-name>
```
If your containers are running, then please try accessing MaskAnyone at [https://localhost](https://localhost). 
Keep in mind that this URL points to localhost and will therefore only work if you try accessing it from within your server. 
Assuming that you're accessing your server via ssh, you should be able to access MaskAnyone via its IP (e.g. `https://<your-server-ip`) in your browser instead. 

### Server Setup - Additional Workers
If you want to add additional worker servers to your setup, you can do so by following the steps below.

tbd

## Interacting with the application after the initial setup
The setup steps outlined above are only necessary for the initial setup of the application.
Afterward you can interact with the application using the following commands.
- **Start the application**: `docker-compose up -d`
- **Stop the application**: `docker-compose down`
- **View the logs of a specific container**: `docker-compose logs -f <container-name>`
- **View the status of all containers**: `docker-compose ps`
- **Reset the database**: `docker-compose down -v` (This will delete all data in the database and is irreversible)
