echo "Updating dependencies..."
sudo apt-get install -y zip jq curl openjdk-8-jre
if [ -d "server/" ]; then
    echo "Backing up old server..."
    [ -d "backups/" ] || mkdir "backups"
    timestamp=$(date | tr " " "-")
    mv server/ backups/${timestamp}/
    echo "Server successfully backed up to backups/${timestamp}/"
fi

if [ -d "repo/" ]; then
  pushd "repo" > /dev/null
  echo "Fetching repo..."
  git fetch
  echo "Pulling new commits..."
  git pull
  popd > /dev/null
else
  echo "Cloning repo..."
  git clone -b master --progress https://github.com/JLefebvre55/MinecraftModpack_Server repo
fi

pushd "repo" > /dev/null

echo "Building server..."

chmod +x ./.scripts/buildServer.sh
./.scripts/buildServer.sh

pushd "build" > /dev/null

rm -f server.zip

echo "Moving server..."

mv server/ ../../server/

popd > /dev/null

echo "Cleaning up build..."

rm -rf build

popd > /dev/null

cd server

echo "Launching server for file generation..."

chmod +x launch.sh
./launch.sh

echo "Agreeing to EULA..."

sed -i 's/false/true/g' eula.txt

# MACOS OPTION:
# sed -e 's/false/true/g' -I '' eula.txt

echo "Launching server (once more, with feeling)..."

./launch.sh