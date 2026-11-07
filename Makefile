# LiteLLM master key: from the environment, else from .env, else the demo default.
LITELLM_MASTER_KEY ?= $(or $(shell sed -n 's/^[[:space:]]*LITELLM_MASTER_KEY[[:space:]]*=[[:space:]]*//p' .env 2>/dev/null | tail -n 1 | tr -d "\"'\r"),sk-1234)

.PHONY: claude
claude:
	@mkdir -p envs
	@echo "export ANTHROPIC_BASE_URL=http://localhost:4000" > envs/claude.env
	@echo "export ANTHROPIC_AUTH_TOKEN=$(LITELLM_MASTER_KEY)" >> envs/claude.env
	@echo "Environment variables written to envs/claude.env"
	@echo "Run: source envs/claude.env"

.PHONY: codex
codex:
	@mkdir -p envs
	@echo "export OPENAI_API_KEY=$(LITELLM_MASTER_KEY)" > envs/codex.env
	@echo "Run: source envs/codex.env"
