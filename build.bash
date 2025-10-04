apptainer build \
    --build-arg G4DATA_ARCHIVE_HOST_DIR="$(pwd)/g4data" \
    rgb-base.sif \
    def/rgb-base.def

function build {
    apptainer build \
        rgb-$1-base.sif \
        def/rgb-$1-base.def
    apptainer build \
        --build-arg BASE=rgb-$1-base.sif \
        rgb-$1.sif \
        def/rgb.def &&
        apptainer build \
            --build-arg FROM=rgb-$1.sif \
            rgb-$1-slim.sif \
            def/slim.def
}

build mpich &
build openmpi &
wait
