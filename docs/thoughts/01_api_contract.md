# API Contract

I defined the OpenAPI specification first to formalize:

- Authentication flow
- Role-based permissions
- Consistent error structure
- Borrowing constraints (409 for conflicts)
- Dashboard response shapes

This ensures the backend follows a strict contract and simplifies request specs later.

---

Prompt used: [prompts/01_openapi_generation.md](prompts/01_openapi_generation.md)