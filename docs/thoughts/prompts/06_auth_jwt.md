# Prompt - Authentication (JWT)

Used this prompt to guide GenAI for the authentication milestone.

---

You are a senior Rails backend engineer.

I need a setup plan for implementing authentication endpoints after data modeling, with JWT bearer flow aligned to the API contract.

Context:
- Project is a Rails API application
- API contract source is `docs/openapi-v1.yml`
- Core models already exist and authentication should rely on stable identity data
- Authentication stack is expected to use Devise + JWT-compatible patterns
- Error response formats must remain contract-consistent across auth endpoints

Scope:
- Implement registration endpoint: `POST /auth/register`
- Implement login endpoint: `POST /auth/login`
- Implement logout endpoint: `DELETE /auth/logout`
- Implement JWT bearer token issuance and authentication flow consistent with `openapi-v1.yml`
- Return authenticated user + token payload on successful register/login
- Apply token invalidation strategy for logout
- Ensure development and test environments behave consistently for auth flows

What I need from you:
1. Exact file checklist (routes, controllers, serializers/presenters, auth initializers, JWT config, request specs, support helpers)
2. Recommended auth flow design for register/login/logout that preserves OpenAPI request/response shapes
3. Step-by-step setup and validation commands (including request spec execution)
4. Token invalidation strategy options and chosen implementation tradeoffs
5. Common pitfalls (JWT expiry, revocation, header parsing, error mapping) and troubleshooting steps
6. Suggested README/API-auth notes for local usage and testing
7. Any further questions that you may have to implement this milestone
8. If no questions or questions are already answered, ask if you can proceed with the implementation

Important rules:
- Do NOT change API contract endpoints
- Do NOT change contract response/request shapes
- Do NOT implement authorization policies beyond what is required for authentication
- Do NOT add unrelated domain/business features
- Explicitly state assumptions

Output format:
- Section 1: Assumptions
- Section 2: Files to create/modify
- Section 3: Setup steps
- Section 4: Verification checklist
- Section 5: Risks and troubleshooting
- Section 6: Any further questions that you may have to implement this milestone
