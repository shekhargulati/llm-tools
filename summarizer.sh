#!/bin/bash

# Function to check if the input is a valid URL
is_valid_url() {
    if [[ $1 =~ ^https?://[a-zA-Z0-9./?=_-]+$ ]]; then
        return 0
    else
        return 1
    fi
}

# Check if a URL is provided as an argument
if [ -z "$1" ]; then
    echo "Usage: $0 <URL> [-p <prompt>] [-m <model>]"
    exit 1
fi

url="$1"

if is_valid_url "$url"; then
    echo "Valid URL: $url"
else
    echo "Invalid URL: $url"
    exit 1
fi

# Default prompt
prompt=$(cat <<EOF
# IDENTITY and PURPOSE
You generate detailed 1500-2000 word summaries.You will be given content of the web page and you have to summarize it using the steps mentioned in the STEPS section.
Take a deep breath and follow the steps mentioned in STEPS section.

# STEPS
- Read the complete text carefully and deeply understand it
- You should start with an introductory paragraph giving user a high level understanding of the topic.
- You should then list all the key points and insights in a bullet list.
    - Extract 10-20 key points and insights
    - Add as much detail as required to help a user understand the content.
- End the summary with a CONCLUSION section
- Optionally, generate 5 follow-up questions as a bullet list in a section called FOLLOW UP QUESTIONS that a user can ask to explore the text in more detail. These questions should be thought-provoking and dig further into the original topic.

# INPUT
EOF
)

# Default model
model="gpt-4o-mini"

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -p)
            prompt="$2"
            shift # past argument
            shift # past value
            ;;
        -m)
            model="$2"
            shift # past argument
            shift # past value
            ;;
        *)
            shift # past argument
            ;;
    esac
done

# Check if llm command exists
if ! command -v llm &> /dev/null; then
    echo "Error: 'llm' command not found. Please install it first."
    exit 1
fi

# Make API call, parse and summarize the discussion
response=$(curl -s "https://r.jina.ai//$url")

if [ $? -ne 0 ]; then
    echo "Error: Failed to fetch the URL."
    exit 1
fi

echo "$response" | llm -m "$model" -s "$prompt" -o temperature 0.2 -o max_tokens 2000 