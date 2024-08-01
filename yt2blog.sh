#!/bin/bash
# Check if a URL is provided as an argument
if [ -z "$1" ]; then
    echo "Usage: $0 <URL>"
    exit 1
fi

if [ -z "$2" ]; then
    echo "Usage: $1 <Topic>"
    exit 1
fi

if [ -z "$3" ]; then
    echo "Usage: $2 <Instructions seperated by new line>"
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
topic="$2"
instructions="$3"
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
You are an expert at writing SEO optimized blogs. You will be given Youtube subtitles in the SRT (SubRip Subtitle) format and you have to write a blog considering the instructions shared by the user. 
Take a deep breath and think step by step about how to best accomplish this goal using the following steps.

# STEPS
- Read the complete youtube subtitle text carefully and deeply understand it
- Follow the user intructions below to write on topic ${topic}
 - ${instructions}
- Use your knowledge to add details. Do not restrict yourself to only use video subtitles. 

# OUTPUT

- Generate output in markdown format 
- Do not generate markdown code block
- Explain each point in detail. Write multiple paragraphs if requied to explain the point
- Make sure to add important quotes from video subtitles

# INPUT
EOF
)

model="gpt-4o-mini"

echo "Generate blog: $video_url"

echo "$subtitles_content" | llm -m "$model" -s "$prompt" -o temperature 0.7 -o max_tokens 2000 