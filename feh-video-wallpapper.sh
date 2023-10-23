
#!/bin/bash

# Function to clean up and exit gracefully
cleanup() {
    echo "Cleaning up and exiting."
    rm -rf "$frames_dir"
    exit 0
}

# Trap Ctrl+C and call cleanup function
trap cleanup SIGINT

# Check if the input video file is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <input_video.mp4>"
    exit 1
fi

# Check if feh is installed
if ! command -v feh &> /dev/null; then
    echo "Error: feh is not installed. Please install it before running this script."
    exit 1
fi

# Create a directory for frames
frames_dir="$HOME/.video_to_wallpaper_frames"
mkdir -p "$frames_dir"

# Extract frames from the video if not already done at 30 FPS
video_basename=$(basename "$1")
frame_prefix="$frames_dir/${video_basename%.*}_frame"
if [ ! -f "$frame_prefix%04d.png" ]; then
    ffmpeg -i "$1" -vf "fps=30" "$frame_prefix%04d.png"
fi

# Get the list of frames
frames=("$frame_prefix"*.png)

# Calculate frame duration based on 60 FPS playback
frame_duration=$(echo "scale=3; 1 / 90" | bc)

# Loop through frames and set them as wallpaper at 60 FPS
while true; do
    for frame in "${frames[@]}"; do
        feh --bg-center "$frame"
        sleep "$frame_duration"
    done
done

