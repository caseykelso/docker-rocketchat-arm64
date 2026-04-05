# :whale: Rocket.Chat Docker Image for ARM64/AArch64

Self-contained Docker image for Rocket.Chat with ARM64 support that **automatically handles MongoDB replica set initialization**.

## 🚀 Key Features

- **Fully Self-Contained**: No external scripts or init containers needed
- **Automatic MongoDB Setup**: Waits for MongoDB, initializes replica set if needed, waits for primary
- **ARM64 Optimized**: Built specifically for aarch64 architecture
- **Production Ready**: Uses official Rocket.Chat releases with GPG verification
- **Minimal Compose**: Your `docker-compose.yml` stays simple and clean

## 📋 How It Works

The image includes an entrypoint script that:

1. **Waits for MongoDB** to accept connections
2. **Checks if replica set is initialized** 
3. **If not initialized**, runs `rs.initiate()` with proper configuration
4. **Waits for primary election** to complete
5. **Only then starts Rocket.Chat**

This eliminates race conditions where Rocket.Chat would start before MongoDB's replica set was ready, preventing errors like:
- `ReadConcernMajorityNotAvailableYet`
- `MongoTopologyClosedError: Topology is closed`

## 🐳 Usage

### Simple Production Setup

```yaml
version: '3.8'

services:
  rocketchat:
    image: caseykelso/docker-rocketchat-arm64:7.12.6
    container_name: rocketchat
    restart: unless-stopped
    environment:
      - ROOT_URL=http://your-domain.com
      - MONGO_URL=mongodb://mongo:27017/rocketchat?replicaSet=rs0
      - MONGO_OPLOG_URL=mongodb://mongo:27017/local?replicaSet=rs0
    ports:
      - "3000:3000"
    depends_on:
      - mongo

  mongo:
    image: mongo:5
    container_name: mongodb
    restart: unless-stopped
    command: mongod --oplogSize 128 --replSet rs0
    volumes:
      - mongodb_data:/data/db

volumes:
  mongodb_data:
```

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `ROOT_URL` | Rocket.Chat access URL | `http://localhost:3000` |
| `MONGO_URL` | MongoDB connection string | `mongodb://mongo:27017/rocketchat?replicaSet=rs0` |
| `MONGO_OPLOG_URL` | MongoDB oplog URL | `mongodb://mongo:27017/local?replicaSet=rs0` |
| `PORT` | Port to listen on | `3000` |

## 🔧 Building & Pushing

This repository uses GitHub Actions to automatically build and push to Docker Hub when pushing to `7.*` branches.

**Manual build:**
```bash
# Build for ARM64
docker buildx build --platform linux/arm64 -t caseykelso/docker-rocketchat-arm64:7.12.6 --push .

# Or load locally for testing
docker buildx build --platform linux/arm64 -t caseykelso/docker-rocketchat-arm64:7.12.6 --load .
```

## 🏷️ Version Tags

Images are tagged with the Rocket.Chat version:
- `7.12.6` - Rocket.Chat 7.12.6
- `latest` - Points to latest stable (on default branch)

## 🐙 Architecture Support

- **Primary**: `linux/arm64` (aarch64/ARM64)
- **Compatible**: Raspberry Pi 4, AWS Graviton, Azure Ampere, Apple Silicon (via emulation)

## 📦 What's Included

- Node.js 22 (from `node:22-bookworm-slim`)
- Deno 1.43.5 (for potential future use)
- Rocket.Chat server (version specified in tag)
- MongoDB Shell (`mongosh`) for replica set management
- Sharp image processing compiled natively for ARM64

## 🔒 Security

- Official Rocket.Chat releases with GPG signature verification
- Non-root user execution (`rocketchat:rocketchat`)
- Minimal base image (Debian Bookworm slim)
- Automatic cleanup of build dependencies

## 🐛 Troubleshooting

If you encounter startup issues:

1. **Check MongoDB logs** - Ensure it's accepting connections
2. **Verify network** - Containers must be on same Docker network
3. **Check replica set status** - Connect to MongoDB and run `rs.status()`
4. **Review Rocket.Chat logs** - Look for connection or initialization errors

## 📄 License

This is a packaging script. Rocket.Chat itself is licensed under [MIT](https://github.com/RocketChat/Rocket.Chat/blob/develop/LICENSE).

---
*Built with :muscle: for ARM64 systems*