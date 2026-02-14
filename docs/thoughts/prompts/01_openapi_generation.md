# Prompt – OpenAPI Generation

I used the following prompt to generate the OpenAPI 3.1 specification:

---

You are a senior API architect.

Generate a complete OpenAPI 3.1 YAML specification for a Library Management System backend built as a Rails API-only application.

Requirements:

Authentication:
- JWT Bearer authentication
- Endpoints:
  - POST /auth/register
  - POST /auth/login
  - DELETE /auth/logout
- Consistent JSON error responses

User Roles:
- librarian
- member

Books:
- CRUD operations
- Search by title, author, or genre via query parameter
- Only librarians can create/update/delete
- Both roles can read

Borrowing:
- Member can borrow a book if available
- Cannot borrow the same book twice while active
- Librarian can mark a borrowing as returned
- Borrowing includes:
  - borrowed_at
  - due_at (2 weeks after borrow date)
  - returned_at (nullable)

Dashboards:
- GET /dashboard/librarian
  - total books
  - total borrowed books
  - books due today
  - members with overdue books
- GET /dashboard/member
  - active borrowings
  - overdue borrowings

Technical Constraints:
- Use OpenAPI 3.1
- Include:
  - components.schemas
  - components.securitySchemes (Bearer JWT)
- Define request and response schemas explicitly
- Include proper HTTP status codes:
  - 200 OK
  - 201 Created
  - 204 No Content
  - 401 Unauthorized
  - 403 Forbidden
  - 404 Not Found
  - 409 Conflict
  - 422 Unprocessable Entity
- Use consistent response structure:
  - Success responses: { data: ... }
  - Error responses: { error: string }
  - Validation errors: { errors: { field: [messages] } }

Important:
- Do NOT include implementation details.
- Output valid YAML only.
- Ensure schema reusability using $ref.
- Keep it clean and production-grade.

---

After generation, I manually reviewed:
- HTTP status codes
- Error schema consistency
- Required vs optional fields
- Role-based access expectations

