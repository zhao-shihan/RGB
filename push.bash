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

# Order matters! Page displays as the inverse order of completed push
auto_retry 999 "apptainer push rgb_openmpi-slim.sif oras://ghcr.io/zhao-shihan/rgb:openmpi-slim"
auto_retry 999 "apptainer push rgb_mpich-slim.sif oras://ghcr.io/zhao-shihan/rgb:mpich-slim"
auto_retry 999 "apptainer push rgb_openmpi.sif oras://ghcr.io/zhao-shihan/rgb:openmpi"
auto_retry 999 "apptainer push rgb_mpich.sif oras://ghcr.io/zhao-shihan/rgb:mpich"

# Push other tags
auto_retry 999 "apptainer push rgb_$DEFAULT_MPI-slim.sif oras://ghcr.io/zhao-shihan/rgb:slim" &
auto_retry 999 "apptainer push rgb_$DEFAULT_MPI.sif oras://ghcr.io/zhao-shihan/rgb:latest" &
auto_retry 999 "apptainer push rgb_$DEFAULT_MPI-slim.sif oras://ghcr.io/zhao-shihan/rgb:latest-slim" &
auto_retry 999 "apptainer push rgb_$DEFAULT_MPI.sif oras://ghcr.io/zhao-shihan/rgb:$IMAGE_VERSION" &
auto_retry 999 "apptainer push rgb_$DEFAULT_MPI-slim.sif oras://ghcr.io/zhao-shihan/rgb:$IMAGE_VERSION-slim" &
for mpi in mpich openmpi; do
    auto_retry 999 "apptainer push rgb_$mpi.sif oras://ghcr.io/zhao-shihan/rgb:latest-$mpi" &
    auto_retry 999 "apptainer push rgb_$mpi-slim.sif oras://ghcr.io/zhao-shihan/rgb:latest-$mpi-slim" &
    auto_retry 999 "apptainer push rgb_$mpi.sif oras://ghcr.io/zhao-shihan/rgb:$IMAGE_VERSION-$mpi" &
    auto_retry 999 "apptainer push rgb_$mpi-slim.sif oras://ghcr.io/zhao-shihan/rgb:$IMAGE_VERSION-$mpi-slim" &
done
wait
