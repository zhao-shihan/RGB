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

apptainer build \
    --build-arg PACKAGE_HOST_DIR="$(pwd)/pkg" \
    --build-arg DATA_HOST_DIR="$(pwd)/data" \
    rgb_base.sif \
    def/rgb_base.def

function build {
    apptainer build \
        rgb_$1-base.sif \
        def/rgb_$1-base.def
    apptainer build \
        --build-arg BASE=rgb_$1-base.sif \
        rgb_$1.sif \
        def/rgb.def &&
        apptainer build \
            --build-arg FROM=rgb_$1.sif \
            rgb_$1-slim.sif \
            def/slim.def
}

build mpich
build openmpi
