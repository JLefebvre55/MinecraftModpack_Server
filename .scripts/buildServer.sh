#!/bin/bash
set -e

modpack_config=modpack.json
modpack_url=https://raw.githubusercontent.com/JLefebvre55/MinecraftModpack/master/modpack.json
server_output_zip=server.zip
workspace_path=$(pwd)
download_forge_pattern='https://files.minecraftforge.net/maven/net/minecraftforge/forge/%version%/forge-%version%-installer.jar'
download_minecraft_pattern='https://s3.amazonaws.com/Minecraft.Download/versions/%mcversion%/minecraft_server.%mcversion%.jar'

url_download_list=()
curse_mod_projectIds=()
curse_mod_fileIds=()
curse_mod_names=()

function download_file {
    download_url="$1"
    if [ "$2" ]; then
        progress_flag='-#'
    else
        progress_flag='-s'
    fi
    curl -O -J -L --globoff --compressed $progress_flag "$download_url" || (echo "Failed to download $download_url" && exit 1)
}

function server_structure {
    if [ -d "build" ]; then
        echo 'Old build found, deleting...'
        rm -rf "build"
    fi

    echo 'Creating build folder...'
    [ -d "build" ] || mkdir "build"
    [ -d "build/server" ] || mkdir "build/server"

    cd "build"

    echo 'Fetching modpack JSON...'
    download_file "${modpack_url}" true

    # Rename any JSON to modpack.json?

    # echo 'Creating server launch scripts...'
    # echo "java -Xmx4G -jar forge*server.jar nogui" > launch.sh
    # echo "@echo off" > launch.bat
    # echo "java -Xmx4G -jar forge*server.jar nogui" >> launch.bat
}

function install_curse_mods {

    echo 'Downloading CurseForge mods...'
    pushd "server/mods" > /dev/null
    export -f download_file

    index=0
    while [ $index -lt ${#curse_mod_projectIds[@]} ]; do
        modname=${curse_mod_names[$index]}
        projectId=${curse_mod_projectIds[$index]}
        fileId=${curse_mod_fileIds[$index]}

        download_url=$(curl -s "https://addons-ecs.forgesvc.net/api/v2/addon/${projectId}/file/${fileId}/download-url" | sed 's/ /%20/g')

        echo "Mod $((index+1)): Downloading ${modname} (ID ${projectId}:${fileId}, URL: ${download_url})..."

        download_file "${download_url}" true
        index=$(( index + 1 ))
    done
    echo "$((index+1)) CurseForge mods downloaded.\n"
    popd > /dev/null
}

function install_forge {

    pushd "server" > /dev/null
    
    echo "Downloading Forge installer version $forge_version..."
    download_file ${download_forge_pattern//%version%/${forge_version}} true

    echo "Running Forge installer -> server..."

    java -jar *installer.jar --installServer

    echo "Deleting installer..."

    rm -f *installer.jar

    popd > /dev/null
}

# function install_minecraft {
#     minecraft_version=$(jq -r '.minecraftVersion' "${workspace_path}/build/${modpack_config}")

#     echo "Downloading minecraft server version $minecraft_version"
#     download_file ${download_minecraft_pattern//%mcversion%/${minecraft_version}} true
# }

function read_mods {
    echo 'Reading Forge version and mods from modpack JSON...'

    save_ifs=$IFS
    IFS=$'\n'
    forge_version=$(jq -r '.forgeVersion' "${workspace_path}/build/${modpack_config}")
    url_download_list=($(jq -r '.mods.urls[] // {} | .url' "${workspace_path}/build/${modpack_config}"))
    curse_mod_projectIds=($(jq -r '.mods.curse[] // {} | .projectId' "${workspace_path}/build/${modpack_config}"))
    curse_mod_fileIds=($(jq -r '.mods.curse[] // {} | .fileId' "${workspace_path}/build/${modpack_config}"))
    curse_mod_names=($(jq -r '.mods.curse[] // {} | .name' "${workspace_path}/build/${modpack_config}"))
    IFS=$save_ifs
}

function install_mods {
    echo 'Downloading non-CurseForge mods...'
    pushd "server/mods" > /dev/null
    export -f download_file
    echo ${url_download_list[@]} | xargs -n 1 -P 8 -I {} -d ' ' bash -c 'download_file "{}" && printf '.''
    printf 'Finished downloading non-CurseForge mods.\n'
    popd > /dev/null
}

function copy_overrides {
    echo 'Copying overridden files...'
    cp -r -v "$workspace_path/overrides/." ./server/
}

### Main ###

server_structure

read_mods

install_forge

# echo "Moving launch scripts..."

# mv launch.sh ./server/
# mv launch.bat ./server/

echo "Creating mods folder..."

[ -d "server/mods" ] || mkdir "server/mods"

# install_minecraft

if [ ! "$url_download_list" == 'null' ]; then
    install_mods
else
    echo "No non-CurseForge mods found; proeceeding..."
fi

if [ ! "$curse_mod_projectIds" == 'null' ]; then
    install_curse_mods
else
    echo "No CurseForge mods found; proceeding..."
fi

echo "All mods downloaded."

if [ -d "$workspace_path/overrides/" ]; then
    copy_overrides
else
    echo "No 'overriddes' folder found; proceeding..."
fi

echo "Server built."

echo 'Compressing...'
zip -9 -r "$server_output_zip" .

echo "Created $server_output_zip successfully."