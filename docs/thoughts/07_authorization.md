# Authorization

I will implement authorization after authentication to enforce role boundaries explicitly and keep permission logic maintainable.

Scope for this milestone:
- Integrate Pundit policy layer
- Enforce librarian/member permissions according to the OpenAPI contract
- Ensure forbidden actions return the expected error/status behavior

Key decisions:
- Centralize authorization logic in policies, not controllers
- Keep policy rules aligned with endpoint intent (books admin by librarian, borrowing actions role-specific)
- Validate authorization with request specs covering both allowed and forbidden paths

Success criteria:
- Role-based access is consistently enforced across endpoints
- Forbidden attempts return contract-aligned responses
- Authorization behavior is test-backed and presentation-ready
