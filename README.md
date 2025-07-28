# cli-ai-tools

## Overview


```sh
quay.io/che-incubator/cli-ai-tools:latest
```

This repository provides a pre-configured development environment, designed for use within Eclipse Che. It comes equipped with a comprehensive set of tools and configurations to support various development workflows, with a focus on Python and modern command-line utilities.



## AI-Powered Development

This environment is supercharged with powerful command-line AI tools to streamline your development process:

- **Aider (`aider`)**: Your AI pair-programming partner in the terminal. Aider works with local git repositories, allowing you to ask for new features, write tests, or refactor code, and it will apply the changes directly to your files.
- **RA.Aid (`ra-aid`)**: An open-source AI assistant that combines research, planning, and implementation to help you build software faster and smarter.

## Base Image

The environment is built upon the `quay.io/devfile/universal-developer-image:latest` base image.

## Key Features & Installed Software

### Shells

- **Fish (`fish`)**: The default shell for the primary user.
- **Zsh (`zsh`)**
- **Bash (`bash`)**

### Editors

- **Neovim (`nvim`)**
- **Vim (`vim`)**

### Python Environment

- **Python Version**: 3.12
- **Package Manager**: `uv` (installed via `curl ... | sh` and available in `/root/.cargo/bin`)
- **Virtual Environments**: Two separate Python virtual environments are created using Python 3.12:
  - `/opt/ra_aid_venv`: Contains `ra-aid` and its dependencies.
    - `ra-aid`
    - `protobuf==4.25.3`
    - `googleapis-common-protos==1.63.0`
  - `/opt/aider_chat_venv`: Contains `aider-chat`.
    - `aider-chat`

### Command-Line Utilities

- **Ripgrep (`rg`)**: A fast, line-oriented search tool.
- **Wget (`wget`)**: Utility for non-interactive download of files from the Web.
- `ca-certificates`

### Cloud IDE Tools

- **chectl**: CLI tool for Eclipse Che (installed at `/usr/local/bin/chectl`).

### Prompt Customization

- **Starship**: A minimal, blazing-fast, and infinitely customizable cross-shell prompt. It is configured system-wide for Bash, Zsh, and Fish.

### Fonts

- **FiraCode Nerd Font**: Version 3.4.0 installed system-wide for enhanced terminal aesthetics with ligatures and icons.

## Environment Configuration

### User

- **Default User ID**: `10001`

### Default Shell

- The default shell for user `10001` is **Fish (`fish`)**.

### PATH Configuration

The system `PATH` is augmented to include:

- `/root/.cargo/bin`: For the `uv` Python package manager.
- `/opt/ra_aid_venv/bin`: For executables from the `ra-aid` virtual environment.
- `/opt/aider_chat_venv/bin`: For executables from the `aider-chat` virtual environment.

### Starship Prompt

- **System-wide Configuration**: Starship is initialized for:
  - Bash: via `/etc/profile.d/starship.sh`
  - Zsh: via `/etc/zshrc`
  - Fish: via `/etc/fish/conf.d/starship.fish`
- **Custom Paths**: To avoid issues with user home directories in containerized environments, Starship uses:
  - `STARSHIP_CONFIG=/opt/starship/config/starship.toml`
  - `STARSHIP_CACHE=/opt/starship/cache`

## Usage Notes

- **Accessing Python Tools**: Tools like `uv`, `ra-aid`, and `aider` are directly accessible from the command line. The `PATH` includes the binary directories for `uv` (`/root/.cargo/bin`) and both Python virtual environments (`/opt/ra_aid_venv/bin` and `/opt/aider_chat_venv/bin`).
- **Starship Prompt**: The Starship prompt is automatically active in all configured shells (Fish, Zsh, Bash) upon starting a terminal session.
