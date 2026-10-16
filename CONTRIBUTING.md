# Contributing to Spectronaut-nf

Thank you for your interest in contributing to Spectronaut-nf.

## Reporting bugs
Please open a GitHub Issue and include:
- A description of the problem.
- Steps to reproduce it.
- The Nextflow version and execution profile.
- Relevant error messages and logs.

Do not include sensitive data or licence files.

## Proposing changes
1. Fork the repository or create a feature branch.
2. Make your changes.
3. Run the available validation checks.
4. Confirm that the workflow configuration remains valid.
5. Submit a pull request describing the changes and testing performed.

## Testing
Run the repository-wide Nextflow lint check:

    nextflow lint .

If your changes affect workflow execution, test the relevant functionality using an appropriate test dataset.

## Pull requests
Please describe:
- What changed and why.
- Which components were affected.
- What tests were performed.
- Any compatibility implications.
