# Prompt - Setup Docker/Postgres + Dotenv

Used this prompt to guide AI for the environment setup milestone.

---

You are a senior Rails backend engineer.

I need a setup plan for local infrastructure before implementing business features.

Context:
- Project is a Rails API
- API contract exists at `docs/openapi-v1.yml`
- I want PostgreSQL running with Docker Compose
- I want to use dotenv for environment variables

Scope:
- Add Docker and Docker Compose setup for PostgreSQL
- Configure `config/database.yml` to use environment variables
- Configure dotenv with `.env.development`, `.env.test` and `.env.example`
- Ensure both development and test DB settings are covered

What I need from you:
1. Minimal file checklist (compose file, env files, database config touchpoints)
2. Recommended env vars and naming conventions
3. Step-by-step setup and validation commands
4. Common pitfalls (port collisions, credentials mismatch, test DB config)
5. Suggested README notes for this setup
6. Any further questions that you may have to implement this milestone
7. If no questions or questions are already answered, ask if you can proceed with the implementation

Important rules:
- Do NOT implement application business logic
- Do NOT change API contract endpoints
- Explicitly state assumptions

Output format:
- Section 1: Assumptions
- Section 2: Files to create/modify
- Section 3: Setup steps
- Section 4: Verification checklist
- Section 5: Risks and troubleshooting
- Section 6: Any further questions that you may have to implement this milestone
