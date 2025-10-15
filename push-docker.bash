success_or_exit() {
    if eval "$1"; then
        >>/dev/null
    else
        exit 1
    fi
}

IMAGE_VERSION=$1
REGISTRY_USERNAME=$2
REGISTRY_PASSWORD=$3
DEFAULT_MPI=mpich

success_or_exit "docker login ghcr.io --username $REGISTRY_USERNAME --password $REGISTRY_PASSWORD"

success_or_exit "docker tag rgb-docker:$DEFAULT_MPI ghcr.io/zhao-shihan/rgb-docker:latest"
success_or_exit "docker tag rgb-docker:$DEFAULT_MPI ghcr.io/zhao-shihan/rgb-docker:$IMAGE_VERSION"
success_or_exit "docker tag rgb-docker:$DEFAULT_MPI-slim ghcr.io/zhao-shihan/rgb-docker:latest-slim"
success_or_exit "docker tag rgb-docker:$DEFAULT_MPI-slim ghcr.io/zhao-shihan/rgb-docker:$IMAGE_VERSION-slim"
for mpi in mpich openmpi; do
    success_or_exit "docker tag rgb-docker:$mpi ghcr.io/zhao-shihan/rgb-docker:$mpi"
    success_or_exit "docker tag rgb-docker:$mpi ghcr.io/zhao-shihan/rgb-docker:latest-$mpi"
    success_or_exit "docker tag rgb-docker:$mpi ghcr.io/zhao-shihan/rgb-docker:$IMAGE_VERSION-$mpi"
    success_or_exit "docker tag rgb-docker:$mpi-slim ghcr.io/zhao-shihan/rgb-docker:$mpi-slim"
    success_or_exit "docker tag rgb-docker:$mpi-slim ghcr.io/zhao-shihan/rgb-docker:latest-$mpi-slim"
    success_or_exit "docker tag rgb-docker:$mpi-slim ghcr.io/zhao-shihan/rgb-docker:$IMAGE_VERSION-$mpi-slim"
done

auto_retry() {
    local max_attempts=$1
    local command="$2"
    local wait_time=5

    local attempt=0
    while [ $attempt -lt $max_attempts ]; do
        if eval $command; then
            break
        else
            attempt=$((attempt + 1))
            echo "Attempt $attempt failed, retrying in $wait_time seconds..."
            sleep $wait_time
        fi
    done
    if [ $attempt -eq $max_attempts ]; then
        echo "Command failed after $max_attempts attempts."
    fi
}

for mpi in mpich openmpi; do
    auto_retry 999 "docker push ghcr.io/zhao-shihan/rgb-docker:$IMAGE_VERSION-$mpi" &
    auto_retry 999 "docker push ghcr.io/zhao-shihan/rgb-docker:$IMAGE_VERSION-$mpi-slim" &
done
wait

auto_retry 999 "docker push ghcr.io/zhao-shihan/rgb-docker:latest"
auto_retry 999 "docker push ghcr.io/zhao-shihan/rgb-docker:latest-slim" &
auto_retry 999 "docker push ghcr.io/zhao-shihan/rgb-docker:$IMAGE_VERSION" &
auto_retry 999 "docker push ghcr.io/zhao-shihan/rgb-docker:$IMAGE_VERSION-slim" &
for mpi in mpich openmpi; do
    auto_retry 999 "docker push ghcr.io/zhao-shihan/rgb-docker:$mpi" &
    auto_retry 999 "docker push ghcr.io/zhao-shihan/rgb-docker:$mpi-slim" &
    auto_retry 999 "docker push ghcr.io/zhao-shihan/rgb-docker:latest-$mpi" &
    auto_retry 999 "docker push ghcr.io/zhao-shihan/rgb-docker:latest-$mpi-slim" &
done
wait
