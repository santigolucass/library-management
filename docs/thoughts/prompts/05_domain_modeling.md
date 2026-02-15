# Prompt - Domain Modeling (Before Auth)

Used this prompt to guide the AI for the data-modeling-first milestone.

---

You are a senior Rails API architect.

I need a setup and implementation plan for defining stable core domain data models and validating them with model specs before authentication work begins.

Context:
- Project is a Rails API application
- API contract source is `docs/openapi-v1.yml`
- Test stack uses RSpec (model specs should be first-class in this milestone)
- Authentication is planned later (Devise + JWT), but model shapes must remain API-contract compatible
- PostgreSQL is the database and should enforce critical invariants where appropriate

Scope:
- Create `User` model with role support for `librarian` and `member`
- Create `Book` model with inventory-related fields required by the contract
- Create `Borrowing` model linking users and books, including lifecycle timestamps
- Add core DB-level constraints needed to support contract integrity
- Add RSpec model tests for validations, associations, and key domain invariants
- Keep implementation aligned with `openapi-v1.yml` fields and naming
- Prepare `User` to support future Devise + JWT integration without changing API contract shapes

What I need from you:
1. Clear assumptions and mapping from `openapi-v1.yml` fields to each model
2. Exact files to create/modify (models, migrations, enums/constants, specs, factory/fixture touchpoints if needed)
3. Step-by-step implementation sequence (migrations first, then model rules, then specs)
4. DB constraint strategy (nullability, foreign keys, checks, uniqueness/indexes) and why each is needed
5. Model spec plan for validations, associations, roles, inventory behavior, and borrowing invariants
6. Verification commands and expected outcomes before marking milestone complete
7. Any further questions that you may have to implement this milestone
8. If no questions or questions are already answered, ask if you can proceed with the implementation

Important rules:
- Do NOT implement authentication/authorization flows yet
- Do NOT change API contract endpoints or response/request shapes
- Do NOT add unrelated business features outside `User`, `Book`, and `Borrowing`
- Encode invariants at both model and database boundaries when feasible
- Explicitly state assumptions

Output format:
- Section 1: Assumptions
- Section 2: Files to create/modify
- Section 3: Implementation steps
- Section 4: Verification checklist
- Section 5: Risks and troubleshooting
- Section 6: Any further questions that you may have to implement this milestone
