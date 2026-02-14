# Planning

The backend will be built as a Rails API-only application.

Main design decisions:
- Versioned API under /api/v1
- JWT authentication
- Role-based authorization (librarian/member)
- Thin controllers, business logic in services
- Contract-first approach using OpenAPI

I decided to define the API contract before implementing controllers to:
- Clarify response shapes
- Align status codes
- Avoid refactoring later
- Enable frontend integration in parallel

