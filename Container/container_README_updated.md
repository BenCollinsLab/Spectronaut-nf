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

## 1. Obtain the Spectronaut installer

Obtain the required Spectronaut `.deb` from an authorised source and place it in this directory.

For example:

```text
Spectronaut_21.1.260825.94842.deb
```

Do **not** commit the `.deb`, license files, or `.sif` image to GitHub.

# Recommended method: Docker → Apptainer

For HPC systems where unprivileged Apptainer builds are restricted, build the Docker image locally and then convert it to an Apptainer SIF image on the HPC.

## 2. Build the Docker image

From the `container/` directory:

```bash
docker build -t spectronaut:21.1.260825.94842 .
```

The final `.` is required because it specifies the Docker build context.

Check the image:

```bash
docker images | grep spectronaut
```

## 3. Test the Docker image

Check .NET:

```bash
docker run --rm     spectronaut:21.1.260825.94842     dotnet --version
```

Check Spectronaut:

```bash
docker run --rm     spectronaut:21.1.260825.94842     dotnet /usr/lib/spectronaut/SpectronautCMD.dll
```

If the image has not been activated, the expected message is:

```text
No valid license found!
Activate Spectronaut using 'activate' <serial/licenseFile> command.
```

This is expected and confirms that the Spectronaut command can start.

## 4. Save the Docker image

Save the tested Docker image as a tar archive:

```bash
docker save     -o spectronaut_21.1.260825.94842.tar     spectronaut:21.1.260825.94842
```

Transfer the archive to the HPC using your normal file-transfer method, for example:

```bash
scp spectronaut_21.1.260825.94842.tar     <HPC>:/path/to/container/
```

## 5. Convert Docker image to Apptainer SIF

On the HPC:

```bash
apptainer build --force     spectronaut.sif     docker-archive:spectronaut_21.1.260825.94842.tar
```

The final image will be:

```text
spectronaut.sif
```

## 6. Test the SIF image

Check .NET:

```bash
apptainer exec spectronaut.sif dotnet --version
```

Expected:

```text
8.0.425
```

Check that the Spectronaut executable exists:

```bash
apptainer exec spectronaut.sif     ls -lh /usr/lib/spectronaut/SpectronautCMD.dll
```

Run Spectronaut:

```bash
apptainer exec spectronaut.sif     dotnet /usr/lib/spectronaut/SpectronautCMD.dll
```

If the image has not been activated, the expected message is:

```text
No valid license found!
Activate Spectronaut using 'activate' <serial/licenseFile> command.
```

### Important

Use:

```bash
dotnet /usr/lib/spectronaut/SpectronautCMD.dll
```

and **not**:

```bash
dotnet dotnet /usr/lib/spectronaut/SpectronautCMD.dll
```

The second form attempts to execute `dotnet` as a .NET application and will fail.

# Alternative: Direct Apptainer build

If your system supports unprivileged Apptainer builds, the image can be built directly from the definition file:

```bash
apptainer build spectronaut.sif spectronaut.def
```

However, some HPC systems restrict the user/group operations required by Apptainer's fakeroot environment. For example:

```text
setgroups ... Operation not permitted
setegid ... Invalid argument
```

If this occurs, use the **Docker → Apptainer workflow above** instead.

On some WSL2 installations, a direct build may work with:

```bash
sudo apptainer build --force spectronaut.sif spectronaut.def
```

This is environment-specific and is not expected to be available on a typical HPC system.

## License

**Do not store the Spectronaut license inside the container or repository.**

The license should be supplied separately and activated according to the Spectronaut licensing procedure.

## Using the image with spectronaut-nf

After creating the SIF image, specify its path in the `spectronaut-nf` configuration:

```text
params.image_path = "/path/to/spectronaut.sif"
```

Raw Spectronaut `.d` data should remain on the HPC filesystem and be made available to the container through the appropriate Apptainer/Nextflow bind configuration.

## Quick reference

### Local machine

```bash
docker build -t spectronaut:21.1.260825.94842 .

docker run --rm     spectronaut:21.1.260825.94842     dotnet --version

docker save     -o spectronaut_21.1.260825.94842.tar     spectronaut:21.1.260825.94842
```

Transfer the `.tar` file to HPC.

### HPC

```bash
apptainer build --force     spectronaut.sif     docker-archive:spectronaut_21.1.260825.94842.tar

apptainer exec spectronaut.sif dotnet --version

apptainer exec spectronaut.sif     dotnet /usr/lib/spectronaut/SpectronautCMD.dll
```

The last command should report the license status. A `No valid license found!` message is expected before activation.
