You are a senior Rails backend engineer.

I need a setup plan for implementing role-based authorization after authentication, with maintainable policy rules and contract-aligned forbidden responses.

Context:
- Project is a Rails API application
- Authentication is already in place and provides stable identity context
- API contract source is `docs/openapi-v1.yml`
- Authorization should be implemented with Pundit
- Request specs are used to validate API behavior (allowed and forbidden paths)

Scope:
- Integrate Pundit policy layer into the API stack
- Define and enforce librarian/member permissions according to endpoint intent in `openapi-v1.yml`
- Enforce books administration behavior for librarian-only actions
- Enforce borrowing actions with role-specific access rules
- Ensure forbidden actions return expected status and error shape per contract
- Validate authorization behavior with request specs for both successful and forbidden scenarios
- Ensure behavior is consistent in development and test environments

What I need from you:
1. Exact file checklist (Pundit setup, application policy, resource policies, controller integration points, error handlers, request specs, shared authz helpers)
2. Recommended policy design so authorization logic stays in policies (not controllers) while remaining easy to maintain
3. Step-by-step setup and validation commands for implementing and verifying role-based enforcement
4. Mapping table of endpoint intents to policy rules for librarian/member actions
5. Common pitfalls and troubleshooting (missing `authorize`, scope misuse, policy naming mismatches, forbidden error rendering drift)
6. Suggested README notes describing role behavior and how to run authorization tests
7. Any further questions that you may have to implement this milestone
8. If no questions or questions are already answered, ask if you can proceed with the implementation

Important rules:
- Do NOT change API contract endpoints
- Do NOT change contract response/request shapes
- Do NOT place business authorization logic in controllers
- Do NOT add unrelated domain features outside authorization enforcement
- Explicitly state assumptions

Output format:
- Section 1: Assumptions
- Section 2: Files to create/modify
- Section 3: Setup steps
- Section 4: Verification checklist
- Section 5: Risks and troubleshooting
- Section 6: Any further questions that you may have to implement this milestone
