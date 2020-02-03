asset=$1

if [ -z "$RELEASE_VERSION" ]; then
  echo "Error: no release version supplied!"
  exit 1 
fi

if [ ! -f "$asset" ]; then
  echo "Release asset does not exist!"
  exit 1 
fi

sha=$(shasum -a 256 "$asset" | awk '{print $1}')

echo "Stashing uncommitted work"
git stash --include-untracked

echo "Updating homebrew formula"
sed -E -i .bak 's/(https:\/\/github\.com\/benwainwright\/reithd\/releases\/download\/)[0-9]+\.[0-9]+\.[0-9]+\/reithd/\1\'"$release_version"'\/reithd/g' Formula/reithd.rb
sed -E -i .bak "s/(sha256 )'[0-9a-z]+'/\1'$sha'/g" Formula/reithd.rb

echo "Pushing change formula"
git add Formula/reithd.rb
git commit -m "Update homebrew formula to version $release_version"
git push

echo "Creating release on Github"
hub release create \
    --prerelease \
     --attach "$asset" \
     --edit \
     "$release_version"

echo "Fetching updated tags"
git fetch --tags
