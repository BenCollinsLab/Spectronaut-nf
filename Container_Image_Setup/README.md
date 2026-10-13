# Spectronaut Container (Docker / Apptainer / Singularity)

This repo builds a container image for running **Spectronaut** (command-line
mode, `SpectronautCMD`) on Linux, HPC clusters, or anywhere Docker/Apptainer
is available.

> **You must supply your own Spectronaut `.deb` installer and a valid
> Biognosys license.** This repo does not, and cannot, distribute
> Spectronaut itself.

## Repo contents

```
.
├── Dockerfile          # Build with Docker
├── apptainer.def        # Build natively with Apptainer/Singularity
└── README.md
```

## Before you start

1. Download the Spectronaut Linux `.deb` installer from Biognosys (you need
   an active license/account) — e.g. `Spectronaut_21.0.0.deb`.
2. Place it in the same directory as the `Dockerfile` / `apptainer.def`.
3. Note the exact version number in the filename — you'll pass it as a
   build argument below.

---

## Option A: Build with Docker

Requires Docker installed locally (root/Docker-group access).

```bash
git clone <this-repo-url>
cd spectronaut-container

# Put your .deb in this directory first, e.g.:
#   Spectronaut_21.0.0.deb

docker build \
  --build-arg SN_VERSION=21.0.0 \
  -t spectronaut:21.0.0 .
```

Run it:

```bash
docker run --rm -it \
  -v /path/to/data:/data \
  -v /path/to/output:/output \
  spectronaut:21.0.0 --version
```

### Converting the Docker image to Apptainer/Singularity later

If you built with Docker but need to run on an HPC cluster with
Apptainer/Singularity:

```bash
# Export the built image to a tarball
docker save spectronaut:21.0.0 -o spectronaut_21.0.0.tar

# On the HPC system, convert it:
apptainer build spectronaut_21.0.0.sif docker-archive://spectronaut_21.0.0.tar
```

---

## Option B: Build natively with Apptainer or Singularity (no Docker needed)

This is the recommended path on an HPC login node, where Docker usually
isn't available but Apptainer/Singularity is.

Requires Apptainer ≥1.1 (or Singularity-CE) and either root, `--fakeroot`
support, or a remote build service.

```bash
git clone <this-repo-url>
cd spectronaut-container

# Put your .deb in this directory first, e.g.:
#   Spectronaut_21.0.0.deb

# Standard build (requires root/sudo)
apptainer build --build-arg SN_VERSION=21.0.0 \
  spectronaut_21.0.0.sif apptainer.def

# OR, if you don't have root but fakeroot is enabled for your account:
apptainer build --fakeroot --build-arg SN_VERSION=21.0.0 \
  spectronaut_21.0.0.sif apptainer.def

# OR, using Sylabs' remote build service (no local privilege needed):
apptainer build --remote --build-arg SN_VERSION=21.0.0 \
  spectronaut_21.0.0.sif apptainer.def
```

If your site's Apptainer version doesn't support `--build-arg` templating,
edit `apptainer.def` and replace every `{{ SN_VERSION }}` with your literal
version string (e.g. `21.0.0`) before building.

### Running

```bash
apptainer run --bind $HOME:$HOME spectronaut_21.0.0.sif --version
```

or, to call the binary explicitly instead of relying on the default
runscript:

```bash
apptainer exec --bind $HOME:$HOME spectronaut_21.0.0.sif spectronaut --version
```

Bind your actual data/output/license paths as needed:

```bash
apptainer exec \
  --bind $HOME:$HOME \
  --bind /path/to/data:/data \
  --bind /path/to/output:/output \
  spectronaut_21.0.0.sif \
  spectronaut <SpectronautCMD-subcommand-and-flags>
```

### Example Slurm batch job

```bash
#!/bin/bash
#SBATCH --job-name=spectronaut
#SBATCH --cpus-per-task=16
#SBATCH --mem=64G
#SBATCH --time=12:00:00

apptainer exec \
  --bind $HOME:$HOME \
  --bind /scratch/$USER/data:/data \
  --bind /scratch/$USER/output:/output \
  spectronaut_21.0.0.sif \
  spectronaut directdia -i /data -o /output
```

Adjust CPU/memory/time to your actual search size and spectral library.

---

## Licensing

Spectronaut requires an active Biognosys license to run, activated with:

```bash
apptainer exec --bind $HOME:$HOME spectronaut_21.0.0.sif \
  spectronaut activate <license-key-or-offline-activation-file>
```

Activation state is typically stored under the invoking user's home
directory, which is why `--bind $HOME:$HOME` (or an equivalent bind) is
required for every run — without it, Spectronaut cannot find or write its
license/config data and will fail with a licensing error on startup.

Contact `support@biognosys.com` for license keys, offline activation files,
or questions about license behavior in containerized/HPC environments.

---

## Troubleshooting

- **`executable file not found in $PATH`** — call the binary by its
  actual name (`spectronaut`), not the internal DLL name
  (`SpectronautCMD`). Confirm with:
  ```bash
  apptainer exec spectronaut_21.0.0.sif cat /bin/spectronaut
  ```
- **License / `ArgumentNullException` on startup** — almost always means
  `$HOME` isn't bound/writable inside the container. Double-check your
  `--bind $HOME:$HOME` flag and that the directory is writable.
- **`dotnet8` package not found** — Ubuntu 22.04's default repos don't
  include .NET; both build files add the Microsoft package repo first.
  If your `.deb` already bundles/depends on the right runtime, you can
  remove that block.

## Customizing for a different Spectronaut version

Both `Dockerfile` and `apptainer.def` take the version as a build
argument (`SN_VERSION`) rather than hardcoding it — just point to whichever
`.deb` you've downloaded and pass its version string at build time.
