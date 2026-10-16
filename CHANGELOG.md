# Changelog

This file records user-facing changes identified by comparing version tags in the
[Spectronaut-nf repository](https://github.com/BenCollinsLab/Spectronaut-nf).
Entries are based on repository contents and tagged commits. Older versions for which
a reliable tag-to-tag change history was not available are not reconstructed here.

## [v2.8.0](https://github.com/BenCollinsLab/Spectronaut-nf/releases/tag/v2.8.0)

### Changed
- Reorganised the Spectronaut container build materials under `Container/`, replacing
  the earlier `Container_Image_Setup/` location.
- Updated the container build definition to install the .NET 8 SDK and a supplied
  Spectronaut Debian package.
- Updated container documentation with Apptainer/Singularity and Docker build, test,
  and conversion instructions, including notes for WSL2.
- Retained the Nextflow workflow changes from v2.7.0; `main.nf` is unchanged between
  the v2.7.0 and v2.8.0 tags.

## [v2.7.0](https://github.com/BenCollinsLab/Spectronaut-nf/releases/tag/v2.7.0)

### Changed
- Updated raw-file handling for Pulsar Stage 1 to use absolute paths.
- Changed the Pulsar Stage 1 output to retain the raw-file value alongside the
  generated PSAR file, and passed the raw-file path directly to Spectronaut.
- Adjusted the individual-file workflow so raw files are passed without the previous
  list-wrapping operation.
- Updated the Nextflow manifest version to `v2.7.0`.

## [v2.6.0](https://github.com/BenCollinsLab/Spectronaut-nf/releases/tag/v2.6.0)

### Notes
- The `v2.6.0` tag points to the same commit as `v2.5.1`; the repository contents
  are identical between these two tags.

## [v2.5.1](https://github.com/BenCollinsLab/Spectronaut-nf/releases/tag/v2.5.1)

### Fixed / Changed
- Changed the `RANDOM_SLEEP` channel to use `Channel.value(file(...))`.
- Captured the combined KIT output as a single value and passed it to the DIA search
  processes, rather than passing a collected channel.
- Changed the Pulsar Stage 1 raw-file input from a `path` input to a `val` input.
- Removed an obsolete Pulsar Stage 3 process definition.

## [v2.5.0](https://github.com/BenCollinsLab/Spectronaut-nf/releases/tag/v2.5.0)

### Added
- Added a `RANDOM_SLEEP` input to the DIA search processes and passed the
  `scripts/random_sleep.sh` script through the workflow.

### Changed
- Added support for grouping raw files into batches for DIA search, with batch size
  derived from the configured batch size.
- Added workflow logging for the combined KIT output and DIA batches.
- Updated raw-file channel handling and passed the random-sleep script to both
  individual-file and batch DIA search processes.

## [v2.4.0](https://github.com/BenCollinsLab/Spectronaut-nf/releases/tag/v2.4.0)

### Changed
- Refactored Spectronaut execution-mode selection for host and container execution.
- Added explicit checks requiring `image_path` for container mode and `spec_bin`
  for host mode.
- Selected the Spectronaut command-line DLL path according to the execution mode.
- Expanded license handling to accept either a license-file path or a license value,
  with validation for missing, non-file, and empty license files.
- Updated workflow setup and configuration alongside these changes.

## [v2.3.0](https://github.com/BenCollinsLab/Spectronaut-nf/releases/tag/v2.3.0)

### Added
- Added container-build materials and documentation for running Spectronaut command-line
  mode using Docker or Apptainer/Singularity.
- Added a Dockerfile and container definition files for building an image from a
  separately obtained Spectronaut `.deb` installer.
- Documented the need to provide a valid Spectronaut license and the proprietary
  installer separately.

### Changed
- Updated the Nextflow workflow and supporting modules as part of the container-related
  release.

## [v2.2.0](https://github.com/BenCollinsLab/Spectronaut-nf/releases/tag/v2.2.0)

- Baseline version for the tag-to-tag comparisons documented above. A more detailed
  entry for this release has not been added because the available comparison evidence
  does not establish its changes relative to an earlier tagged release.
