# Spectronaut Container

This directory contains the files required to build a **Spectronaut Apptainer/Singularity container** for use with `spectronaut-nf`.

## Files

```text
container/
├── README.md
├── Dockerfile
└── spectronaut.def
```

The Spectronaut `.deb` installer is **not included in this repository** because it is proprietary software.

---

## 1. Obtain the Spectronaut installer

Obtain the required Spectronaut `.deb` from an authorised source and place it in this directory.

For example:

```text
Spectronaut_21.1.260825.94842.deb
```

Do **not** commit the `.deb`, license files, or `.sif` image to GitHub.

---

## 2. Build with Apptainer

This is the recommended method on HPC systems.

From the `container/` directory:

```bash
apptainer build spectronaut.sif spectronaut.def
```

To overwrite an existing image:

```bash
apptainer build --force spectronaut.sif spectronaut.def
```

### WSL2 note

On some WSL2 installations, an unprivileged build may fail with:

```text
failed to mount binfmt_misc filesystem: invalid argument
```

In the tested WSL2 environment, this worked:

```bash
sudo apptainer build --force spectronaut.sif spectronaut.def
```

This does **not** mean `sudo` is required on HPC systems.

---

## 3. Build with Docker

If Docker is available, build the Docker image with:

```bash
docker build -t spectronaut:21.1.260825.94842 .
```

The final `.` is required because it specifies the Docker build context.

Test the image:

```bash
docker run --rm     spectronaut:21.1.260825.94842     dotnet --version
```

Test Spectronaut:

```bash
docker run --rm     spectronaut:21.1.260825.94842     dotnet /usr/lib/spectronaut/SpectronautCMD.dll
```

An unactivated image is expected to report:

```text
No valid license found!
```

---

## 4. Convert Docker image to Apptainer

Convert the Docker image to the final SIF:

```bash
apptainer build --force     spectronaut.sif     docker-daemon:spectronaut:21.1.260825.94842
```

Test the SIF:

```bash
apptainer exec spectronaut.sif dotnet --version
```

and:

```bash
apptainer exec spectronaut.sif     dotnet /usr/lib/spectronaut/SpectronautCMD.dll
```

---

## 5. License

**Do not store the Spectronaut license inside the container or repository.**

The license should be supplied separately and activated according to the Spectronaut licensing procedure.

---

## 6. Using the image with spectronaut-nf

After building the image, specify its path in the `spectronaut-nf` configuration:

```text
params.image_path = "/path/to/spectronaut.sif"
```

The raw Spectronaut `.d` data should remain on the HPC filesystem and be made available to the container through the appropriate Apptainer/Nextflow bind configuration.

---

## Quick reference

### Apptainer

```bash
apptainer build spectronaut.sif spectronaut.def
```

### Docker

```bash
docker build -t spectronaut:21.1.260825.94842 .
```

### Docker → SIF

```bash
apptainer build spectronaut.sif     docker-daemon:spectronaut:21.1.260825.94842
```

### Test

```bash
apptainer exec spectronaut.sif dotnet --version
```
