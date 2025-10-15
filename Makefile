.PHONY: claude
claude:
	@echo "export ANTHROPIC_BASE_URL=http://localhost:4000" > claude.env
	@echo "export ANTHROPIC_AUTH_TOKEN=sk-1234" >> claude.env
	@echo "Environment variables written to claude.env"
	@echo "Run: source claude.env"

.PHONY: codex
codex:
	@echo "export OPENAI_API_KEY=sk-1234" > codex.env
	@echo "Run: source codex.env"
