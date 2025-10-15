# RGB (*R*OOT and *G*eant4 *b*asic image)

These containers ship pre-built, optimized ROOT, Geant4, MPI, etc. and their dependencies.

## Contents

- [RGB (*R*OOT and *G*eant4 *b*asic image)](#rgb-root-and-geant4-basic-image)
  - [Contents](#contents)
  - [Quick start](#quick-start)
    - [How to pull](#how-to-pull)
    - [How to run](#how-to-run)
      - [Simple usage](#simple-usage)
      - [Recommended usage](#recommended-usage)
    - [Container contents](#container-contents)
    - [Build your own container](#build-your-own-container)
    - [Build and run your own apps](#build-and-run-your-own-apps)
  - [Notice](#notice)
    - [About SIMD](#about-simd)
  - [How to build and push](#how-to-build-and-push)

## Quick start

### How to pull

**Pull the apptainer image by:**
```bash
apptainer pull oras://ghcr.io/zhao-shihan/rgb:<version>-<mpi>-<aux>
```
**Pull the docker image by:**
```bash
docker pull ghcr.io/zhao-shihan/rgb-docker:<version>-<mpi>-<aux>
```
Docker images are converted from apptainer images.

About image tags (note: remove leading and trailing `-` in tag):
- **`<version>` can be `latest`, a certain version (e.g. `25.10.14`), or nothing (same as `latest`)**
- **`<mpi>` can be `mpich`, `openmpi`, or nothing (same as `mpich`).**
- **`<aux>` can be nothing or `slim`. Images with `slim` do not contain G4 data, smaller in size, but you need to install Geant4 data in your machine and setup environment variables.**

For example, `apptainer pull oras://ghcr.io/zhao-shihan/rgb:25.10.14-mpich` pulls down an v25.10.15 container that MPI library is MPICH, `apptainer pull oras://ghcr.io/zhao-shihan/rgb:openmpi-slim` pulls down the latest container that MPI library is OpenMPI and without geant4 data, `apptainer pull oras://ghcr.io/zhao-shihan/rgb:latest-mpich-slim` pulls down the latest container that MPI library is MPICH and without geant4 data.

**For apptainer image, you should choose the correct MPI tag that compatible with MPI that installed in your machine, in order to do parallel computation correctly.** 

If you don't care about MPI and just want a multi-purpose container , then
```
apptainer pull oras://ghcr.io/zhao-shihan/rgb:mpich
docker pull ghcr.io/zhao-shihan/rgb:mpich
```
should be good enough.

### How to run

This section shows how to run with the apptainer image. The usage of docker image is similar but in docker convention.

#### Simple usage

The container contains ROOT and Geant4 libraries, you can use applications (r.g. `root`) directly by

- `apptainer run rgb.sif root` (or `apptainer run rgb.sif root` for Tianhe-2 specialization), or simply
- `./rgb.sif root`, after executed `chmod +x rgb.sif`

and it should show the ROOT interface. 

#### Recommended usage

However, in some cases you may want to use the container from everywhere on you machine.
A recommended usage is to make the container executable and add it to `PATH`.

First, make the container executable by

- `chmod +x rgb.sif`

Then, copy/move the container to an installation directory (e.g. `path/to/install`), and (optionally) shorten its name (e.g. `rgb`) by

- `mv rgb.sif path/to/install/rgb`

After that, add the following line in e.g. `~/.bashrc`:

- `export PATH=path/to/install:$PATH`

This line adds the RGB container directory into the `PATH`.
After restarted the terminal/session, you can use the container by entering `rgb` directly:

- `rgb root`
  
and it should show the ROOT interface.

**In the remaining part, we assume that the container is used in this way, but you can always switch to the form of `apptainer run`.**

### Container contents

ROOT utilities are available, for example

- `rgb root` (`root.exe` for Tianhe-2 specialization)
- `rgb hadd`
- `rgb rootcling`

You can also check the Geant4 version or complie flags:

- `rgb geant4-config --version`
- `rgb geant4-config --cflags`

RGB is a basic library container, and it can be used to compile programs depending on ROOT and/or Geant4.
So it provides common build tools like GCC, CMake, and Ninja:

- `rgb g++ --version`
- `rgb cmake --version`
- `rgb ninja --version`

There are many other packages pre-installed in the container.
Except for ROOT and Geant4, you can check all APT-installed packages:

- `rgb apt list`

or list something specific:

- `rgb apt list libgsl-dev`

### Build your own container

You can also write your own [apptainer definition file](https://apptainer.org/docs/user/latest/definition_files.html) and build your own container based on RGB.
This makes use of ROOT and Geant4 installed in RGB, and saves time from compiling them.
Check [https://apptainer.org/docs/user/latest/build_a_container.html]() for more.

### Build and run your own apps

You can also compile your favorite applications that depend on ROOT/Geant4 with RGB, and run with it:

- Configure: `rgb cmake -G Ninja path/to/src`
- Build: `rgb ninja`
- Run: `rgb path/to/your/app`

## Notice

### About SIMD

SIMD support is enabled and auto-detected at runtime, by probing the host CPU features. Supported instruction sets includes x86-64-v3 (up to AVX2, AVX, FMA, etc., binaries in /opt/x86-64-v3) and x86-64-v2 (up to SSE4.2, SSSE3, SSE3, etc., binaries in /opt/x86-64-v2).
It will automatically choose the most advanced instruction sets available on your machine. Almost all x86 machines produced after 2010 supports x86-64-v2.

## How to build and push

```bash
# build
bash build.bash
# sign apptainer image
bash sign.bash
# convert apptainer images to docker images
sudo bash build-docker.bash
# push
bash push.bash <version tag> <username> <token>
sudo bash push-docker.bash <version tag> <username> <token>
```
