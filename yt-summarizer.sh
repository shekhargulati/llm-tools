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
- Extract key points and insights from the input text and group them in to logical groups. 
    - You can create 10-20 logical groups
- For each group come up with logical group name. 
    - Group name length should be 10-20 words long 
    - Use group name the heading
- For each logical group extract can have 5-10 key points
    - Each key point should be detailed and upto 100 words
    - With each key point also mention the timestamp

# OUTPUT FORMAT

## Group Name 1
1. Key point 1
2. Key point 2

## Group Name 2
1. Key point 3
2. Key point 4
3. Key point 5
4. Key point 6
5. Key point 7 

# OUTPUT

1. Do not create groups with name Group Name 1, Group Name 2

# INPUT
EOF
)

model="gpt-4o-mini"

echo "Summmary of the Youtube Video: $video_url"

echo "$subtitles_content" | llm -m "$model" -s "$prompt" -o temperature 0.2 -o max_tokens 2000 