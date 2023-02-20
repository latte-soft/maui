#!/bin/sh -e

# Basic logging
log() {
    # Set the default value of the 2nd argument to 1
    local num_dashes=${2:-1}

    # Use printf to print the desired number of "-" characters followed by the arrow and the message
    printf '\033[1;94m%*s\033[m%s %s\n' "$num_dashes" '-' '>' "$1" >&2
}

# Store version.txt into variable for build dir
version=$(cat version.txt)

# Actual build path
build_path="build/$version"

# If version already in `./build`, remove
if [ -d "$build_path" ]; then
    log "Build for \"$version\" already exists, removing and rebuilding.."
    rm -rf "$build_path" # Remove build dir here
fi

# Make build dir (Make sure to build parent dirs)
mkdir -p "$build_path"

# Copy LICENSE.txt
cp LICENSE.txt "$build_path/LICENSE.txt"
log "Copied LICENSE.txt to $build_path/LICENSE.txt"

# Create base file for 2-way-sync thing
touch "$build_path/Maui.maui.lua"

# Minifiy the `LoadModule.lua` in the codegen, this is for building prod specifically
log "Minifying \`LoadModule.lua.txt\` codegen src.. (Renames the file for Darklua, then renames back)"
cp -f src/LoadModuleCode/LoadModule.lua.txt src/LoadModuleCode/LoadModule.lua
darklua process src/LoadModuleCode/LoadModule.lua src/LoadModuleCode/LoadModule.min.lua
mv src/LoadModuleCode/LoadModule.min.lua src/LoadModuleCode/LoadModule.min.lua.txt
rm -f src/LoadModuleCode/LoadModule.lua
rm -f src/LoadModuleCode/LoadModule.min.lua

# Run wally pkg install
log "Installing wally packages.."
wally install

# Build models w/ Rojo
log "Building Rojo models.."
rojo build -o "$build_path/Maui.rbxm"
rojo build -o "$build_path/Maui.rbxmx"

# Completed..?
echo # Newline end
log "Completed build for $version: $(realpath "$build_path")" # Print full dir
