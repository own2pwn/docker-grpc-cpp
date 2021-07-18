set -e
docker buildx build \
    --push -t own2pwn/debian-grpc-cpp:v1.39.0-debug \
    --platform linux/amd64,linux/arm64 \
    -f Debug.dockerfile . \
&& docker buildx build \
    --push -t own2pwn/debian-grpc-cpp:v1.39.0-release \
    --platform linux/amd64,linux/arm64 \
    -f Release.dockerfile .
