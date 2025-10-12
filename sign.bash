for mpi in mpich openmpi; do
    apptainer sign rgb_$mpi.sif
    apptainer sign rgb_$mpi-slim.sif
done
