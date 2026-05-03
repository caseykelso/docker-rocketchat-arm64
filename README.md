:whale: Dockerfiles for [Rocket.Chat](https://github.com/RocketChat/Rocket.Chat) with ARM64/AArch64 Support

## DockerHub
* [Dockerhub docker-rocketchat-arm64 tags](https://hub.docker.com/r/caseykelso/docker-rocketchat-arm64/tags)
* [Docker hub docker-rocketchat-arm64 project](https://hub.docker.com/r/caseykelso/docker-rocketchat-arm64)

Note that I just upgraded from 7.12.7 to 8.4.0, this is the upgrade steps, I built all of the intermediate releases:

First upgrade your Mongo
5->6->7->8.0->8.2.0

RocketChat
7.12.2->7.12.7->7.13.6->8.0.4->8.1.3->8.2.3->8.4.0


## Upgrade Steps

1. Back up your deployment.

2. Upgrade Rocketchat from 7.12.2 to 7.12.7

A. Modify your docker-compose.yml:
```bash
image: caseykelso/docker-rocketchat-arm64:7.12.7
```

B. Upgrade the Docker container
```bash
docker compose down
docker compose pull
docker compose up
```

C. Verify that it comes up. I had to make a change to mongodb after the upgrade to fix things.
```bash
docker exec -it rocketchat-mongo-1 mongosh
```

At the MongoDb shell enter
```bash
cfg = rs.conf()
cfg.members[0].host = "localhost:27017"
rs.reconfig(cfg, { force: true })
```

exit the mongo shell, and restart docker and verify the upgrade works
```bash
docker compose restart
```

3. Upgrade Rocketchat from 7.12.7 to 7.13.6

A. Modify your docker-compose.yml:
```bash
image: caseykelso/docker-rocketchat-arm64:7.13.6
```

B. Upgrade the Docker container
```bash
docker compose down
docker compose pull
docker compose up
```

Verify that Rocketchat boots up and works after the migration.


### 4. Upgrade MongoDb from 5 to 6

A. Modify your docker-compose.yml
```bash
  mongo:
    image: mongo:6
```

B. Confirm the MongoDb Compatibility Version is set to 5 before upgrading

Enter the MongoDb Shell
```bash
docker exec -it rocketchat-mongo-1 mongosh
```

In the shell confirm the compatibility version is set.
```bash
db.adminCommand({ setFeatureCompatibilityVersion: 5.0" })
```

C. Upgrade the Docker container
```bash
docker compose down
docker compose pull
docker compose up
```

D. Verify that Rocketchat boots up and works after the migration.

E. Update the Compatibility Version in MongoDb

Enter the MongoDb Shell
```bash
docker exec -it rocketchat-mongo-1 mongosh
```

In the shell confirm the compatibility version is set.
```bash
db.adminCommand({ setFeatureCompatibilityVersion: 6.0" })
```

### 5. Upgrade MongoDb from 6 to 7

A. Modify your docker-compose.yml
```bash
  mongo:
    image: mongo:7
```

B. Upgrade the Docker container
```bash
docker compose down
docker compose pull
docker compose up
```

C. Verify that Rocketchat boots up and works after the migration.

D. Update the Compatibility Version in MongoDb

Enter the MongoDb Shell
```bash
docker exec -it rocketchat-mongo-1 mongosh
```

In the shell set the compatibility version to 7.0
```bash
db.adminCommand({ setFeatureCompatibilityVersion: 7.0", confirm: true })
```


### 6. Upgrade MongoDb from 7 to 8.0

A. Modify your docker-compose.yml
```bash
  mongo:
    image: mongo:8.0
```

B. Upgrade the Docker container
```bash
docker compose down
docker compose pull
docker compose up
```

C. Verify that Rocketchat boots up and works after the migration.

D. Update the Compatibility Version in MongoDb

Enter the MongoDb Shell
```bash
docker exec -it rocketchat-mongo-1 mongosh
```

In the shell set the compatibility version to 8.0
```bash
db.adminCommand({ setFeatureCompatibilityVersion: 8.0", confirm: true })
```

### 6. Upgrade MongoDb from 8.0 to 8.2

A. Modify your docker-compose.yml
```bash
  mongo:
    image: mongo:8.2
```

B. Upgrade the Docker container
```bash
docker compose down
docker compose pull
docker compose up
```

C. Verify that Rocketchat boots up and works after the migration.

D. I purposefully do not update the compatibility verison.


### 7. Upgrade Rocketchat from 7.13.6 to 8.0.4

A. Modify your docker-compose.yml:
```bash
image: caseykelso/docker-rocketchat-arm64:8.0.4
```

B. Upgrade the Docker container
```bash
docker compose down
docker compose pull
docker compose up
```

Verify that Rocketchat boots up and works after the migration.


### 8. Upgrade Rocketchat from 8.0.4 to 8.1.3

A. Modify your docker-compose.yml:
```bash
image: caseykelso/docker-rocketchat-arm64:8.1.3
```

B. Upgrade the Docker container
```bash
docker compose down
docker compose pull
docker compose up
```

Verify that Rocketchat boots up and works after the migration.


### 9. Upgrade Rocketchat from 8.1.3 to 8.2.3

A. Modify your docker-compose.yml:
```bash
image: caseykelso/docker-rocketchat-arm64:8.2.3
```

B. Upgrade the Docker container
```bash
docker compose down
docker compose pull
docker compose up
```

Verify that Rocketchat boots up and works after the migration.

### 10. Upgrade Rocketchat from 8.2.3 to 8.3.2

A. Modify your docker-compose.yml:
```bash
image: caseykelso/docker-rocketchat-arm64:8.3.2
```

B. Upgrade the Docker container
```bash
docker compose down
docker compose pull
docker compose up
```

Verify that Rocketchat boots up and works after the migration.


### 11. Upgrade Rocketchat from 8.3.2 to 8.4.0

A. Modify your docker-compose.yml:
```bash
image: caseykelso/docker-rocketchat-arm64:8.4.0
```

B. Upgrade the Docker container
```bash
docker compose down
docker compose pull
docker compose up
```

Verify that Rocketchat boots up and works after the migration.


