#!/bin/bash
# Check if a URL is provided as an argument
if [ -z "$1" ]; then
    echo "Usage: $0 <URL>"
    exit 1
fi

# Check if llm command exists
if ! command -v llm &> /dev/null; then
    echo "Error: 'llm' command not found. Please install it first."
    exit 1
fi

# Check if yt-dlp command exists
if ! command -v yt-dlp &> /dev/null; then
    echo "Error: 'yt-dlp' command not found. Please install it first."
    exit 1
fi

video_url="$1"
echo "processing video $video_url"

uuid=$(uuidgen)

# Construct the file path
file_path="./subtitles/${uuid}.txt"

echo "downloading subtitles to $file_path"

yt-dlp --quiet --write-auto-sub --convert-subs=srt --skip-download $video_url --output  $file_path

srt_file_path="${file_path}.en.srt"

subtitles_content=$(cat "$srt_file_path")

prompt=$(cat <<EOF
# IDENTITY and PURPOSE
You are an expert at summarizing and extracting key insights from Youtube videos. You will be given Youtube subtitles in the SRT (SubRip Subtitle) format. 
Take a deep breath and think step by step about how to best accomplish this goal using the following steps.

# STEPS
- Read the complete youtube subtitle text carefully and deeply understand it
- You should start with an introductory paragraph giving user a high level understanding of the topic.
- Extract key points and insights from the input text and group them in to logical groups. A group can have key points from different parts of the video 
- You should it create 10-20 logical groups
- Each group should a have logical group name that best describe the points covered in the group
    - There can be 5-10 key points per group
    - Each key point should be detailed and upto 100 words
    - With each key point also mention the timestamp
- End the summary with a motivational quote that goes with the video content.

# OUTPUT FORMAT

Start with an high level summary.

## Group 1
- Key point 1 (02:30)
- Key point 2 (05:30)
- Key point 3 (12:30)
- Key point 4 (32:30)
- Key point 5 (42:30)

## Group 2
- Key point 6 (04:30)
- Key point 7 (08:30)
- Key point 8 (50:30)
- Key point 9 (52:30)

## Group 3
- Key point 10 (31:30)
- Key point 11 (33:30)
- Key point 12 (35:30)

Let me end the summary with a quote: "Quote 1"

# OUTPUT

1. Do not start group name with Group 1 or Group 2 suffixes
2. Make sure you have 5-10 key points per group
3. Make sure that summary length should be between 1200 to 1600 words

# INPUT
EOF
)

model="gpt-4o-mini"

echo "Summmary of the Youtube Video: $video_url"

echo "$subtitles_content" | llm -m "$model" -s "$prompt" -o temperature 0.2 -o max_tokens 2000 