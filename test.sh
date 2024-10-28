#location=$(curl -sI https://github.com/ClementTsang/bottom/releases/latest | head -n1 | cut -d' ' -f2-)
#version=${location##*/}
#echo "https://github.com/ClementTsang/bottom/releases/latest/download/bottom_${version}_amd64.deb"
#version=${version%%[[:space:]]*} # Remove trailing whitespace, including newlines
#version=${version##*[[:space:]]} # Remove leading whitespace

#version=$(curl -s https://api.github.com/repos/ClementTsang/bottom/releases/latest | jq -r '.tag_name')
#echo "https://github.com/ClementTsang/bottom/releases/latest/download/bottom_${version}_amd64.deb"
#!/bin/bash

repo="ClementTsang/bottom"
# Get the latest release metadata
latest_release=$(curl -s --connect-timeout 5 "https://api.github.com/repos/$repo/releases/latest")
# Extract the asset URL
asset_url=$(echo "$latest_release" | jq -r '.assets[] | select(.name | endswith("_amd64.deb") and (contains("musl") | not)) | .browser_download_url')

# Display the results
echo "Download URL for amd64.deb: $asset_url"
curl -L -o /tmp/bottom-latest.deb $asset_url
