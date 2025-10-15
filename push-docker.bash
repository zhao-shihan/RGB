# RGB image build scripts
# Copyright (C) 2024-2025  Shihan Zhao
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

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
success_or_exit "docker tag rgb-docker:$DEFAULT_MPI-slim ghcr.io/zhao-shihan/rgb-docker:slim"
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

# Order matters! Page displays as the inverse order of completed push
auto_retry 999 "docker push ghcr.io/zhao-shihan/rgb-docker:openmpi-slim"
auto_retry 999 "docker push ghcr.io/zhao-shihan/rgb-docker:mpich-slim"
auto_retry 999 "docker push ghcr.io/zhao-shihan/rgb-docker:openmpi"
auto_retry 999 "docker push ghcr.io/zhao-shihan/rgb-docker:mpich"

# Push other tags
auto_retry 999 "docker push ghcr.io/zhao-shihan/rgb-docker:slim" &
auto_retry 999 "docker push ghcr.io/zhao-shihan/rgb-docker:latest" &
auto_retry 999 "docker push ghcr.io/zhao-shihan/rgb-docker:latest-slim" &
auto_retry 999 "docker push ghcr.io/zhao-shihan/rgb-docker:$IMAGE_VERSION" &
auto_retry 999 "docker push ghcr.io/zhao-shihan/rgb-docker:$IMAGE_VERSION-slim" &
for mpi in mpich openmpi; do
    auto_retry 999 "docker push ghcr.io/zhao-shihan/rgb-docker:latest-$mpi" &
    auto_retry 999 "docker push ghcr.io/zhao-shihan/rgb-docker:latest-$mpi-slim" &
    auto_retry 999 "docker push ghcr.io/zhao-shihan/rgb-docker:$IMAGE_VERSION-$mpi" &
    auto_retry 999 "docker push ghcr.io/zhao-shihan/rgb-docker:$IMAGE_VERSION-$mpi-slim" &
done
wait
