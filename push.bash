success_or_exit() {
    if eval "$1"; then
        >>/dev/null
    else
        exit 1
    fi
}

success_or_exit "apptainer registry login --username $1 --password $2 oras://ghcr.io"

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
