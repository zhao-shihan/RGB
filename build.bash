apptainer build \
    --build-arg SOURCE_ARCHIVE_HOST_DIR="$(pwd)/src" \
    --build-arg G4DATA_ARCHIVE_HOST_DIR="$(pwd)/g4data" \
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

build mpich &
build openmpi &
wait
