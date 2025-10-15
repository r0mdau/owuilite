# owuilite

Getting started guide adopting OpenWebUI and LiteLLM

## Pre-Requisites

Have docker and docker compose up and running.

## Getting started

The fastest way to start using OpenWebUI chat application is to start it using docker

```bash
docker run -p 3000:8080 --network=host -v open-webui:/app/backend/data --name open-webui ghcr.io/open-webui/open-webui:v0.6.33
```

Then it is proposed to use docker compose to launch the whole solution

```bash
docker compose up
```

### Configure clis

Set the environment variables to point to local LiteLLM

```bash
make claude
source claude.env

make codex
source codex.env
```

Configure Codex LiteLLM API endpoint

```bash
cat > ~/.codex/config.toml << 'EOF'
# Recall that in TOML, root keys must be listed before tables.
model = "gpt-5-codex"
model_provider = "openai-chat-completions"

[model_providers.openai-chat-completions]
name = "LiteLLM using Responses API"
base_url = "http://localhost:4000"
env_key = "OPENAI_API_KEY"
wire_api = "responses"
EOF
