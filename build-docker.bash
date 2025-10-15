for mpi in mpich openmpi; do
    bash singularity2docker.sh -n rgb-docker:$mpi rgb_$mpi.sif &
    bash singularity2docker.sh -n rgb-docker:$mpi-slim rgb_$mpi-slim.sif &
done
wait
