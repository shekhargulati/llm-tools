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

# STEPS

- Read the complete input carefully and deeply understand it
- Combine all of your understanding of the project architecture in a section called HIGH LEVEL UNDERSTANDING.
    - Provide a high-level overview of the architecture. Use Mermaid diagram to illustrate the overall architecture and data flow.
- List the technology stack used by the application in a section called TECHNOLOGY STACK
- Create a section called DESIGN DECISIONS where you discuss different design decisions project creators took
- Create a section GETTING STARTED that guides user in a step by step manner on how to use the project
- Create a section called ENTRY POINTS that tells user how to get started with the code base. This should help new developers learn navigate the code faster
- Create a section called COMPONENTS that describe major components of the system
    - Use headings (e.g., `### Component Name`) to clearly label each section.
    - For each component:
        - Describe the purpose of the component.
        - Explain the key data structures or algorithms used.
        - Mention any important design patterns or architectural styles employed (like microservices, event-driven architecture, etc.).
        - Highlight any architectural invariants or rules that govern the component.
- Create a section called CODE MAP
    - Provide a brief description of the directory structure, if applicable. Highlight important directories and their functions.
    - Help user understand API of the application
- Create a section called CROSS CUTTING CONCERNS to detail out following concerns. You can add any other cross cutting concern as well.
    - Build tool and release management
    - Testing strategies and methods
    - Error handling strategies
    - Observability features and performance metrics
6. End the document with thank you note for a reader that motivates them to use this project.

# INPUT
EOF
)

model="gpt-4o-mini"

echo "Generating architecture.md: $repo_url"

echo "$code_md_content" | llm -m "$model" -s "$prompt" -o temperature 0.4 -o max_tokens 2000