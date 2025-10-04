for mpi in mpich openmpi; do
    apptainer sign rgb-$mpi.sif
    apptainer sign rgb-$mpi-slim.sif
done
