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

# Minifiy the `LoadModule.lua` in the codegen, this is for building prod specifically
log "Minifying \`LoadModule.lua.txt\` codegen src.. (Renames the file for Darklua, then renames back)"
cp -f src/Codegen/LoadModuleCode/LoadModule.lua.txt src/Codegen/LoadModuleCode/LoadModule.lua
darklua process src/Codegen/LoadModuleCode/LoadModule.lua src/Codegen/LoadModuleCode/LoadModule.min.lua
mv src/Codegen/LoadModuleCode/LoadModule.min.lua src/Codegen/LoadModuleCode/LoadModule.min.lua.txt
rm -f src/Codegen/LoadModuleCode/LoadModule.lua
rm -f src/Codegen/LoadModuleCode/LoadModule.min.lua

# Run wally pkg install
log "Installing wally packages.."
wally install

# Minify & create `/dist` w/ darklua

log "Creating dist.."
mkdir -p dist

log "Minifying \"/src\".." 2
cp -rf src dist
darklua process dist/src dist/src

log "Minifying \"/submodules\".." 2
cp -rf submodules dist
darklua process dist/submodules dist/submodules

log "Minifying \"/Packages\".." 2
cp -rf Packages dist
darklua process dist/Packages dist/Packages

log "Minifying \"/tests\".." 2
cp -rf tests dist
darklua process dist/tests dist/tests

# Build models w/ Rojo
log "Building Rojo models.."
# Building with min.project.json for the GH releases ONLY!
rojo build min.project.json -o "$build_path/Maui.rbxm"
rojo build min.project.json -o "$build_path/Maui.rbxmx"

# Completed..?
echo # Newline end
log "Completed build for $version: $(realpath "$build_path")" # Print full dir
