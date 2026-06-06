#!/bin/bash

# 1. Catch empty arguments
if [ -z "$1" ]; then
    echo "⚠️  Usage: ./upload.sh <path/to/file>"
    exit 1
fi

FILE="$1"

# 2. Make sure the file actually exists locally
if [ ! -f "$FILE" ]; then
    echo "❌ Error: File '$FILE' does not exist."
    exit 1
fi

echo "🔍 Finding the best GoFile server..."
server=$(curl -s https://api.gofile.io/servers | grep -o '"name":"[^"]*' | head -n 1 | cut -d'"' -f4)

if [ -z "$server" ]; then
    echo "❌ Failed to fetch a server. Is the GoFile API down?"
    exit 1
fi

echo "✅ Connected to: ${server}"
echo "🚀 Uploading '$FILE'..."

# 3. Upload the file
# -# displays a progress bar to stderr
# -F handles the multipart form upload
response=$(curl -# -F "file=@${FILE}" "https://${server}.gofile.io/contents/uploadfile")

# 4. Extract the downloadPage link natively (no jq required)
link=$(echo "$response" | grep -o '"downloadPage":"[^"]*' | cut -d'"' -f4)

if [ -n "$link" ]; then
    echo ""
    echo "🎉 Upload complete! Here is your link:"
    echo "➡️  $link"
else
    echo ""
    echo "❌ Upload failed or couldn't parse the response. Raw output:"
    echo "$response"
    exit 1
fi

