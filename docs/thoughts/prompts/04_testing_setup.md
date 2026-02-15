# Prompt - Setup RSpec + SimpleCov

Use this prompt to guide GenAI for the testing baseline milestone.

---

You are a senior Rails backend engineer.

I need a setup plan for establishing the test baseline before domain and authentication implementation.

Context:
- Project is a Rails API application using Bundler
- PostgreSQL is used for persistence
- Environment configuration uses dotenv (`.env.development`, `.env.test`, `.env.example`)
- Request specs should be treated as first-class for API contract validation
- Coverage reporting should remain simple and locally visible at `coverage/index.html`

Scope:
- Install and configure RSpec for the project test stack
- Install and configure SimpleCov to run with RSpec
- Ensure SimpleCov generates HTML coverage output for local inspection
- Ensure test setup works cleanly with PostgreSQL + dotenv configuration
- Add minimal baseline spec structure (including request spec readiness) without introducing business/domain/auth logic
- Validate the milestone success criteria via executable commands and observable artifacts

What I need from you:
1. Exact file-level checklist for setup (Gemfile entries, RSpec config files, test helper files, coverage config touchpoints)
2. Recommended configuration content and ordering (RSpec + SimpleCov boot sequence)
3. Step-by-step setup commands and validation commands (including `bundle exec rspec`)
4. Common pitfalls and troubleshooting steps specific to Rails + PostgreSQL + dotenv + SimpleCov
5. Suggested README updates so future milestones can rely on this baseline
6. Any further questions that you may have to implement this milestone
7. If no questions or questions are already answered, ask if you can proceed with the implementation

Important rules:
- Do NOT implement application business logic
- Do NOT change API contract endpoints
- Do NOT implement domain/auth/authz features in this milestone
- Keep setup minimal, deterministic, and easy to verify
- Explicitly state assumptions

Output format:
- Section 1: Assumptions
- Section 2: Files to create/modify
- Section 3: Setup steps
- Section 4: Verification checklist
- Section 5: Risks and troubleshooting
- Section 6: Any further questions that you may have to implement this milestone
