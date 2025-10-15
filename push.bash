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

success_or_exit "apptainer registry login --username $REGISTRY_USERNAME --password $REGISTRY_PASSWORD oras://ghcr.io"

for mpi in mpich openmpi; do
    apptainer verify rgb_$mpi.sif &
    apptainer verify rgb_$mpi-slim.sif &
done
wait

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
    auto_retry 999 "apptainer push rgb_$mpi.sif oras://ghcr.io/zhao-shihan/rgb:$mpi" &
    auto_retry 999 "apptainer push rgb_$mpi-slim.sif oras://ghcr.io/zhao-shihan/rgb:$mpi-slim" &
done
wait

auto_retry 999 "apptainer push rgb_$DEFAULT_MPI.sif oras://ghcr.io/zhao-shihan/rgb:latest"
auto_retry 999 "apptainer push rgb_$DEFAULT_MPI.sif oras://ghcr.io/zhao-shihan/rgb:$IMAGE_VERSION" &
auto_retry 999 "apptainer push rgb_$DEFAULT_MPI-slim.sif oras://ghcr.io/zhao-shihan/rgb:latest-slim" &
auto_retry 999 "apptainer push rgb_$DEFAULT_MPI-slim.sif oras://ghcr.io/zhao-shihan/rgb:$IMAGE_VERSION-slim" &
for mpi in mpich openmpi; do
    auto_retry 999 "apptainer push rgb_$mpi.sif oras://ghcr.io/zhao-shihan/rgb:latest-$mpi" &
    auto_retry 999 "apptainer push rgb_$mpi-slim.sif oras://ghcr.io/zhao-shihan/rgb:latest-$mpi-slim" &
    auto_retry 999 "apptainer push rgb_$mpi.sif oras://ghcr.io/zhao-shihan/rgb:$IMAGE_VERSION-$mpi" &
    auto_retry 999 "apptainer push rgb_$mpi-slim.sif oras://ghcr.io/zhao-shihan/rgb:$IMAGE_VERSION-$mpi-slim" &
done
wait
