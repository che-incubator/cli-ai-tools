FROM quay.io/devfile/universal-developer-image:latest

USER root

# Install EPEL repository, core dependencies, Python 3.12, and Starship
# Also clean yum caches to reduce image size.
RUN yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm && \
    yum install -y \
    fish \
    neovim \
    vim \
    wget \
    zsh \
    ripgrep \
    ca-certificates \
    bzip2 \
    python3.12 && \
    yum copr enable -y atim/starship && \
    yum install -y starship && \
    yum clean all && \
    rm -rf /var/cache/yum

# Install uv - the fast Python package installer and resolver
# Use UV_INSTALL_DIR to force a system-wide installation in /usr/local,
# which places the 'uv' binary in /usr/local/bin. This is a persistent location.
RUN curl -LsSf https://astral.sh/uv/install.sh | env UV_INSTALL_DIR="/usr/local/bin" sh

# Copy the requirements file for ra-aid
COPY ra-aid-requirements.txt /tmp/ra-aid-requirements.txt

# Create a Python virtual environment for the ra-aid package and install dependencies from ra-aid-requirements.txt
RUN uv venv /opt/ra_aid_venv --python 3.12 \
    # && uv pip install protobuf==4.25.3 googleapis-common-protos==1.63.0 ra-aid
    # TODO: Temporary fix for this issue: https://github.com/ai-christianson/RA.Aid/issues/252
    # TODO: After the issue is fixed, uncomment the line above and remove requirements file.
    && uv pip install --no-cache-dir -r /tmp/ra-aid-requirements.txt --python /opt/ra_aid_venv/bin/python

# Create a Python virtual environment for the aider-chat package and install it
RUN uv venv /opt/aider_chat_venv --python 3.12 \
    && uv pip install aider-chat --python /opt/aider_chat_venv/bin/python

# Add the bin directories of both virtual environments to the PATH
ENV PATH="/opt/ra_aid_venv/bin:/opt/aider_chat_venv/bin:${PATH}"

# Install Goose
ENV GOOSE_VERSION=v1.28.0
RUN mkdir -p /opt/goose-install && \
    curl -L -o /opt/goose-install/goose.tar.bz2 \
    https://github.com/block/goose/releases/download/${GOOSE_VERSION}/goose-x86_64-unknown-linux-gnu.tar.bz2 && \
    tar -xjf /opt/goose-install/goose.tar.bz2 -C /opt/goose-install && \
    mv /opt/goose-install/goose /usr/local/bin/goose && \
    chmod +x /usr/local/bin/goose && \
    rm -rf /opt/goose-install 

# Install OpenCode
ENV OPENCODE_VERSION=v1.3.13
RUN mkdir -p /opt/opencode-install && \
    curl -L -o /opt/opencode-install/opencode.tar.gz \
    https://github.com/anomalyco/opencode/releases/download/${OPENCODE_VERSION}/opencode-linux-x64.tar.gz && \
    tar -xzf /opt/opencode-install/opencode.tar.gz -C /opt/opencode-install && \
    mv /opt/opencode-install/opencode /usr/local/bin/opencode && \
    chmod +x /usr/local/bin/opencode && \
    rm -rf /opt/opencode-install 

# Pre-configure Paths & Permissions
# We pre-create the nested folders Goose expects to avoid "Permission Denied"
# when they try to mkdir at runtime.
RUN mkdir -p \
    /home/user/.local/bin \
    /home/user/.local/share/goose \
    /home/user/.local/state/goose/logs \
    /home/user/.config/goose \
    /home/user/.cache/goose && \
    chown -R 10001:0 /home/user/.local && \
    chmod -R g=u /home/user

# Install chectl
RUN curl -Lo /usr/local/bin/chectl https://che-incubator.github.io/chectl/install.sh && \
    chmod +x /usr/local/bin/chectl

# Download and install FiraCode Nerd Font
RUN mkdir -p /usr/local/share/fonts/FiraCode && \
    cd /tmp && \
    curl -Lo FiraCode.zip https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/FiraCode.zip && \
    unzip FiraCode.zip -d /usr/local/share/fonts/FiraCode && \
    rm FiraCode.zip && \
    fc-cache -fv /usr/local/share/fonts/

# Configure Starship for system-wide use with /opt storage
RUN mkdir -p /opt/starship/config /opt/starship/cache && \
    touch /opt/starship/config/starship.toml && \
    chown -R 10001:0 /opt/starship && \
    chmod -R u=rwX,go=rX /opt/starship

# Set environment variables for Starship to use the /opt locations
ENV STARSHIP_CONFIG="/opt/starship/config/starship.toml"
ENV STARSHIP_CACHE="/opt/starship/cache"

# Bash: Add Starship init to a new script in /etc/profile.d/ for system-wide effect (Bash only)
RUN echo 'if [ -n "$BASH_VERSION" ]; then eval "$(starship init bash)"; fi' > /etc/profile.d/starship.sh && \
    chmod +x /etc/profile.d/starship.sh

# Zsh: Create /etc/zshrc with completion initialization and Starship init
RUN printf '%s\n' \
    '# System-wide Zshrc configured by Dockerfile' \
    '' \
    '# Initialize Zsh completion system to ensure SDKMAN and other tools work correctly' \
    'if typeset -f compinit >/dev/null; then' \
    '  autoload -Uz compinit && compinit -u' \
    'fi' \
    '' \
    '# Initialize Zsh bash completion compatibility (for SDKMAN, etc.)' \
    'if typeset -f bashcompinit >/dev/null; then' \
    '  autoload -Uz bashcompinit && bashcompinit' \
    'fi' \
    '' \
    '# Initialize Starship prompt' \
    'if command -v starship >/dev/null; then' \
    '  eval "$(starship init zsh)"' \
    'fi' > /etc/zshrc

# Fish: Add Starship init to a new script in /etc/fish/conf.d/ for system-wide effect
RUN mkdir -p /etc/fish/conf.d && \
    echo 'if command -v starship > /dev/null; starship init fish | source; end' > /etc/fish/conf.d/starship.fish

USER 10001

# Set fish as default shell for the user
ENV SHELL="/usr/bin/fish"
