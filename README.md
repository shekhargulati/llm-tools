# llm-tools

A collection of CLI LLM tools that I built and use daily.

> I am building a course on how to build production apps using LLMs. We will cover topics like prompt engineering, RAG, search, testing and evals, fine tuning, feedback analysis, and agents. You can register now and get 50% discount. Register using the form – https://forms.gle/twuVNs9SeHzMt8q68

## Prerequisites

1. [llm cli utility](https://llm.datasette.io/en/stable/index.html). You can install it using `pip install llm` or `pipx install llm`

2. [yt-dlp](https://github.com/yt-dlp/yt-dlp). A feature-rich command-line audio/video downloader. You can install using `pip install yt-dlp`

3. Set OPENAI_API_KEY environment variables. All these utilities default to using OpenAI API and `gpt-4o-mini` model.

## Using Tools

### Tool 1: Web page summarizer

To summarize a web page. Make sure to make these scripts executable `chmod +x summarizer.sh`

```
./summarizer.sh https://shekhargulati.com/2024/04/28/why-you-should-consider-building-your-own-ai-assistants/ -m 'gpt-4o-mini'
```

### Tool 2: Youtube Video Summarizer

To summarize a youtube video. Make sure to make these scripts executable `chmod +x yt-summarizer.sh`

```
./yt-summarizer.sh https://www.youtube.com/watch\?v\=w-cmMcMZoZ4
```
