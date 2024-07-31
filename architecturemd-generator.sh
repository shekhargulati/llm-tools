#!/bin/bash
repo_url="$1"
exclude_dirs="$2"

if ! command -v git &> /dev/null; then
    echo "Error: 'git' command not found. Please install it."
    exit 1
fi

if ! command -v llm &> /dev/null; then
    echo "Error: 'llm' command not found. Please install it using [pip install llm]."
    exit 1
fi

if ! command -v code2prompt &> /dev/null; then
    echo "Error: 'code2prompt' command not found. Please install it using [pip install code2prompt]."
    exit 1
fi

echo "Cloning $repo_url"

# Create a temporary directory
temp_dir=$(mktemp -d)

git clone "$repo_url" "$temp_dir"

checked_out_path="$temp_dir"

echo "Repository cloned to: $checked_out_path"

code_md_path="${checked_out_path}/code.md"

code2prompt --path $checked_out_path --exclude "${exclude_dirs}" --tokens --output $code_md_path

echo "Converted code to prompt $code_md_path"

code_md_content=$(cat "$code_md_path")

prompt=$(cat <<EOF
# IDENTITY and PURPOSE
You are an experienced software architect. You take as input code content of a Git repository and you generate an architecture document.
Take a deep breath and think step by step about how to best accomplish this goal using the following steps.
Be as much as detailed as required.

# STEPS

1. **Title and Introduction**
    - Start with a clear title (e.g., `# Architecture`) at the top of the document.
    - Write an introductory paragraph describing the purpose of the document. Include a brief statement about the system being discussed and its relevance for new developers or users.
    - List the technology stack used by the application
2. **High-Level Overview**
    - Provide a high-level overview of the architecture. Use Mermaid diagram to illustrate the overall architecture and data flow.
    - Generate sequence diagram to help user understand the data flow
    - Describe the input and output of the system. Explain how data is structured and what the system does with the incoming data.
3. **Detailed Breakdown of Components**
    - Create sections for each major component of the system. Use headings (e.g., `## Component Name`) to clearly label each section.
    - In each section:
        - Describe the purpose of the component.
        - Explain the key data structures or algorithms used.
        - Mention any important design patterns or architectural styles employed (like microservices, event-driven architecture, etc.).
        - Highlight any architectural invariants or rules that govern the component.
4. **Code Map**. 
    - Be detailed in this section. Keep each point between 5 to 10 lines.
    - Provide a brief description of the directory structure, if applicable. Highlight important directories and their functions.
    - Help user understand API of the application
5. **Cross-Cutting Concerns**.
    - Be detailed in this section. Keep each point between 5 to 10 lines.
    - Include a section discussing cross-cutting concerns such as:
        - Build tool and release management
        - Testing strategies and methods
        - Error handling strategies
        - Observability features and performance metrics
6. End the summary with thank you note for a reader that motivates them to use this project.

# INPUT
EOF
)

model="gpt-4o-mini"

echo "Generating architecture.md: $repo_url"

echo "$code_md_content" | llm -m "$model" -s "$prompt" -o temperature 0.4 -o max_tokens 2000