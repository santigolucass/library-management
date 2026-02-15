# Data Modeling

I will define the data model and validate it with model specs before authentication, so identity and authorization are built on stable, tested data structures.

Scope for this milestone:
- `User` model with role support (`librarian`, `member`)
- `Book` model with inventory fields
- `Borrowing` model linking users and books with borrowing lifecycle timestamps
- Core DB-level constraints needed by the OpenAPI contract
- RSpec model tests for validations, associations, and key invariants

Key decisions:
- Keep models aligned with `openapi-v1.yml` fields
- Prepare `User` to support `devise` + JWT without changing API contract shapes
- Encode borrowing invariants in model/database boundaries where possible
- Cover critical domain rules with specs before moving to authentication
