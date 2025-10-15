success_or_exit() {
    if eval "$1"; then
        >>/dev/null
    else
        exit 1
    fi
}

success_or_exit "echo $2 | docker login ghcr.io --username $1 --password-stdin"

for mpi in mpich openmpi; do
    success_or_exit "docker tag rgb-docker:$mpi ghcr.io/zhao-shihan/rgb-docker:$mpi"
    success_or_exit "docker tag rgb-docker:$mpi-slim ghcr.io/zhao-shihan/rgb-docker:$mpi-slim"
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
    auto_retry 999 "docker push ghcr.io/zhao-shihan/rgb-docker:$mpi" &
    auto_retry 999 "docker push ghcr.io/zhao-shihan/rgb-docker:$mpi-slim" &
done
wait
