# Unicloud project 

## Requirements:
To run system it is required to have docker engine. We suggest using Docker desktop:
Download:
* [Windows](https://docs.docker.com/desktop/setup/install/windows-install/)
* [MacOc](https://docs.docker.com/desktop/setup/install/mac-install/)
* [Linux](https://docs.docker.com/desktop/setup/install/linux//)

But docker engine with docker compose is enough.

## Running intruction
1. Create project folder and go into it
    ```shell
    mkdir uc-project
    cd ud-project
    ```
2. Clone repositories
    ```shell
    git clone https://github.com/Project-UniCloud/uc-frontend
    git clone --recurse-submodules https://github.com/Project-UniCloud/uc-backend
    git clone --recurse-submodules https://github.com/Project-UniCloud/uc-adapter-aws
    git clone https://github.com/Project-UniCloud/uc-docker
    ```
3. Go to uc-docker project
   ```shell
   cd uc-docker
   ```
4. Run containers
   ```shell
   docker-compose up -d
   ```
   
## Building
To build all images execute:
```shell
docker-compose build
```

To build certain image execute: (with service name defined in docker-compose.yml)
```shell
docker-compose build {service-name}
```

## Stoping
To stop the containers execute:
```shell
docker-compose stop
```

And with certain container:
```shell
docker-compose stop {service-name}
```

## Removing containers
To remove the containers execute:
```shell
docker-compose down
```

And with certain container:
```shell
docker-compose down {service-name}
```

To remove volumes and networks also exeucte:
```shell
docker-compose down --volumes --remove-orphans
```

Enjoy :)