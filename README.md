# Embedded CI/CD & Semantic Versioning Template

A standardized repository template designed to enforce Semantic Versioning (SemVer 2.0.0), Conventional Commits, and automated GitHub Releases for embedded systems (e.g., ARM Cortex-M4F) and general C/C++ projects.

## Table of Contents
1. [Overview](#overview)
2. [Features](#features)
3. [Included Components](#included-components)
4. [How to Implement in Your Project](#how-to-implement-in-your-project)
5. [Versioning & Commit Standards](#versioning--commit-standards)

## Overview
This template provides a robust, reusable CI/CD architecture using GitHub Actions. It acts as a foundational blueprint for new repositories, ensuring that all future projects share a unified standard for code integration, release management, and changelog generation. 

## Features
- **Automated SemVer Releases:** Automatically calculates version bumps (Major, Minor, Patch) based on Git history.
- **Dynamic Changelogs:** Utilizes `git-cliff` to generate highly formatted, professional release notes.
- **Reusable Workflows:** Employs GitHub's `workflow_call` architecture, allowing central maintenance of the release pipeline.
- **Workflow Linting:** Built-in `actionlint` integration to catch YAML errors on Pull Requests before they merge.
- **Embedded Systems Ready:** Standardized hooks for local verification (`make target`), cross-compilation toolchains, and binary artifact deployment.

## Included Components
- `.github/workflows/lint.yml`: CI workflow that validates GitHub Actions YAML syntax.
- `.github/workflows/release.yml`: Reusable CD workflow for compiling binaries and publishing GitHub Releases.
- `.github/PULL_REQUEST_TEMPLATE.md`: Standardized checklist enforcing local verification and commit message formatting.
- `cliff.toml`: Configuration rules for parsing Conventional Commits into `RELEASE_NOTES.md`.
- `src/main.c` & `Makefile`: Base compilation targets to ensure the CI pipeline passes on a fresh clone.

## How to Implement in Your Project

### 1. Initialize from Template
Click the **Use this template** button at the top of this repository on GitHub to create a new project with this exact directory structure.

### 2. Configure Repository Permissions
To allow the automated workflows to publish tags and releases:
1. Go to **Settings > Actions > General**.
2. Under **Workflow permissions**, select **Read and write permissions**.
3. Click **Save**.

### 3. Call the Reusable Release Workflow
In your new project, you do not need to rewrite or maintain the complex release logic. Simply create a trigger file at `.github/workflows/trigger-release.yml`:

```yaml
name: Trigger Release
on:
  push:
    tags:
      - 'v[0-9]+.[0-9]+.[0-9]+*' # Enforces SemVer 2.0.0

jobs:
  call-release-template:
    uses: YOUR_USERNAME/gha-semver-template/.github/workflows/semver-release.yml@main
    with:
      build_command: "make clean && make target"
      artifact_path: "build/*"
```

## Versioning & Commit Standards
This repository enforces the [Conventional Commits](https://www.conventionalcommits.org/) specification. Your commit messages directly control the automated versioning engine.

**Format:** `<type>(<optional scope>): <short description>`

- **`feat:`** Introduces a new feature or functionality. Triggers a **MINOR** version bump (e.g., `1.0.0` ➔ `1.1.0`).
- **`fix:`** Patches a bug or hardware interfacing issue. Triggers a **PATCH** version bump (e.g., `1.0.0` ➔ `1.0.1`).
- **`docs:`, `style:`, `refactor:`, `test:`, `chore:`** Administrative, testing, or maintenance changes. **No version bump**.
- **Breaking Changes:** Appending an exclamation mark (e.g., `feat!: change EEPROM layout`) triggers a **MAJOR** version bump (e.g., `1.0.0` ➔ `2.0.0`).