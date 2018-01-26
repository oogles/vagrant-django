#!/usr/bin/env bash

# Source global provisioning settings
source /tmp/env.sh


# A function to test if an array contains an element.
# Stolen from this StackOverflow answer: https://stackoverflow.com/a/8574392/405174
function contains_element() {
    local e match="$1"
    shift
    for e; do [[ "$e" == "$match" ]] && return 0; done
    return 1
}


echo " "
echo " --- Install/configure python/virtualenv ---"

# Add BASE_PYTHON_VERSION to PYTHON_VERSIONS if it isn't already present,
# ensuring it is always installed
if [[ "$BASE_PYTHON_VERSION" ]]; then
    if ! contains_element "$BASE_PYTHON_VERSION" "${PYTHON_VERSIONS[@]}"; then
        PYTHON_VERSIONS+=("$BASE_PYTHON_VERSION")
    fi
fi

#
# Install/configure pyenv and pyenv-virtualenv plugin
#

PYENV_DIR="/home/webmaster/.pyenv"
PYENV_CMD="$PYENV_DIR/bin/pyenv"  # to avoid modifying $PATH in these provisioning scripts

echo " "
if [[ ! -d "$PYENV_DIR" ]]; then
    echo "Cloning pyenv repo..."
    su - webmaster -c "git clone https://github.com/pyenv/pyenv.git $PYENV_DIR"
else
    echo "Updating pyenv..."
    su - webmaster -c "cd $PYENV_DIR && git pull"
fi

echo " "
if [[ ! -d "$PYENV_DIR/plugins/pyenv-virtualenv" ]]; then
    echo "Cloning pyenv-virtualenv repo..."
    su - webmaster -c "git clone https://github.com/pyenv/pyenv-virtualenv.git $PYENV_DIR/plugins/pyenv-virtualenv"
else
    echo "Updating pyenv-virtualenv..."
    su - webmaster -c "cd $PYENV_DIR/plugins/pyenv-virtualenv && git pull"
fi

# Add necessary commands to .bashrc to enable use of the pyenv command in bash
echo " "
echo "Configuring user environment..."
comment="# pyenv integration"
if ! grep -Fxq "$comment" /home/webmaster/.bashrc ; then
cat <<EOF >> /home/webmaster/.bashrc

$comment
export PYENV_ROOT="\$HOME/.pyenv"
export PATH="\$PYENV_ROOT/bin:\$PATH"
if command -v pyenv 1>/dev/null 2>&1; then
    eval "\$(pyenv init -)"
fi
EOF
fi

#
# Install additional versions of python (and the system packages required to do
# so) if any are specified
#

# Install each specified version
if [[ ${#PYTHON_VERSIONS[@]} -ne 0 ]]; then
    echo " "
    echo "Installing necessary system packages..."

    # List obtained from pyenv wiki. For latest, see:
    # https://github.com/pyenv/pyenv/wiki/Common-build-problems
    apt-get -qq install make build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev xz-utils tk-dev

    echo " "
    echo "Installing additional python versions..."
    for i in ${PYTHON_VERSIONS[@]}; do
        echo "$i"
        su - webmaster -c "$PYENV_CMD install $i"
    done

    # Enable global commands for all installed versions of python, for use by tox
    echo " "
    echo "Enabling global commands..."
    su - webmaster -c "$PYENV_CMD global ${PYTHON_VERSIONS[@]} system"
fi


#
# Install and configure the virtualenv for the specified version of python
#

echo " "
echo "Creating virtualenv..."
VENV_DIR="$PYENV_DIR/versions/$PROJECT_NAME"
VENV_ACTIVATE_CMD="source $VENV_DIR/bin/activate"

if [[ -d "$VENV_DIR" ]]; then
    echo "Already exists."
else
    if [[ "$BASE_PYTHON_VERSION" ]]; then
        su - webmaster -c "$PYENV_CMD virtualenv $BASE_PYTHON_VERSION $PROJECT_NAME"
    else
        # No specific version of python specified, create the virtualenv with
        # the system version. In this case, pip and virtualenv need to be
        # manually installed first.

        # Install pip if it isn't already
        if ! command -v pip  >/dev/null; then
            wget -q https://bootstrap.pypa.io/get-pip.py
            python get-pip.py
            rm get-pip.py
        fi

        # Install virtualenv
        pip install -q virtualenv

        # Create the virtualenv
        su - webmaster -c "$PYENV_CMD virtualenv $PROJECT_NAME"
    fi

    if [[ "$?" -ne 0 ]]; then
        echo "--------------------------------------------------"
        echo "ERROR: Could not create virtualenv."
        echo "If specifying a python version in your Vagrantfile,"
        echo "ensure it is a valid version installable by pyenv,"
        echo "or leave it unspecified to use the system version."
        echo "Output above should indicate if pyenv could not"
        echo "install the specified version."
        echo "--------------------------------------------------"
        exit 1
    fi
fi

# Store the virtualenv activation command in env.sh to be accessible to later
# provisioning scripts, which may need to activate the virtualenv
"$PROVISION_DIR/scripts/utils/write_var.sh" 'VENV_ACTIVATE_CMD' "$VENV_ACTIVATE_CMD" "$PROVISION_DIR/env.sh"

# Update the webmaster user's profile to automatically activate the virtualenv
# when they SSH in
if ! grep -Fxq "$VENV_ACTIVATE_CMD" /home/webmaster/.profile ; then
    echo -e "\n# Automate virtualenv activation\n$VENV_ACTIVATE_CMD" >> /home/webmaster/.profile
fi


#
# Install Python dependencies from requirements.txt. If DEBUG is true, also
# install extra dev dependencies from dev_requirements.txt.
#

echo " "
echo " --- Install Python dependencies ---"
if [[ -f "$SRC_DIR/requirements.txt" ]]; then
    su - webmaster -c "$VENV_ACTIVATE_CMD && pip install -q -r $SRC_DIR/requirements.txt"
    echo "Done"
else
    echo "None found"
fi

if [[ "$DEBUG" -eq 1 ]]; then
    echo " "
    echo " ---  Install Python additional dev dependencies ---"
    if [[ -f "$SRC_DIR/dev_requirements.txt" ]]; then
        su - webmaster -c "$VENV_ACTIVATE_CMD && pip install -q -r $SRC_DIR/dev_requirements.txt"
        echo "Done"
    else
        echo "None found"
    fi
fi
