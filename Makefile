.PHONY: claude
claude:
	@echo "export ANTHROPIC_BASE_URL=http://localhost:4000" > envs/claude.env
	@echo "export ANTHROPIC_AUTH_TOKEN=sk-1234" >> envs/claude.env
	@echo "Environment variables written to envs/claude.env"
	@echo "Run: source envs/claude.env"

.PHONY: codex
codex:
	@echo "export OPENAI_API_KEY=sk-1234" > envs/codex.env
	@echo "Run: source envs/codex.env"
