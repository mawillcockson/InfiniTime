#!/bin/sh
set -eu
IMGTOOL_URL="git+https://github.com/mcu-tools/mcuboot.git#egg=imgtool&subdirectory=scripts"

if ! command -v imgtool; then
    if [ -f ~/.local/bin/imgtool ]; then
        echo "imgtool already installed"
    else
        python3 -m pip install --user --upgrade \
            pip \
            setuptools \
            wheel \
            pipx
        python3 -m pipx install "${IMGTOOL_URL}"
    fi

    if ! command -v imgtool; then
        PATH="${PATH}:~/.local/bin"
    fi

    if ! command -v imgtool; then
        echo "can't add imgtool to \$PATH"
        exit 1
    fi
fi

if ! command -v adafruit-nrfutil; then
    if [ -f ~/.local/bin/adafruit-nrfutil ]; then
        echo "adafruit-nrfutil already installed"
    else
        python3 -m pip install --user --upgrade \
            pip \
            setuptools \
            wheel \
            pipx
        python3 -m pipx install adafruit-nrfutil
    fi

    if ! command -v adafruit-nrfutil; then
        PATH="${PATH}:~/.local/bin"
    fi

    if ! command -v adafruit-nrfutil; then
        echo "can't add adafruit-nrfutil to \$PATH"
        exit 1
    fi
fi

cd ~/projects/InfiniTime
imgtool create \
    --align 4 \
    --version 1.0.0 \
    --header-size 32 \
    --slot-size 475136 \
    --pad-header \
    ./build/src/pinetime-mcuboot-app.bin \
    ./build/src/pinetime-mcuboot-app-modified.bin

adafruit-nrfutil dfu genpkg \
    --dev-type 0x0052 \
    --application ./build/src/pinetime-mcuboot-app-modified.bin \
     ./build/src/dfu.zip
