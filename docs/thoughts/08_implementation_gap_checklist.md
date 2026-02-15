At this point, I've asked AI to review everything that we have done so far and compare with the specifications in the openAPI contract.
It identified some gaps, I've analyzed them and asked to create a gap checklist.
Then I've started to fix them, some manually, some with AI help.

The GAP checklist can be seen below and diff here https://github.com/santigolucass/library-management/pull/7

# Implementation Gap Checklist (Milestones 03-07)

This checklist maps remaining implementation work to the current milestone order and existing project files.

## 03 - Environment Setup (Docker/Postgres/dotenv)

### Files to verify/adjust
- `/Users/lucassantiago/workspace/library_management_workspace/library_management/docker-compose.yml`
- `/Users/lucassantiago/workspace/library_management_workspace/library_management/config/database.yml`
- `/Users/lucassantiago/workspace/library_management_workspace/library_management/.env.example`
- `/Users/lucassantiago/workspace/library_management_workspace/library_management/README.md`

### Remaining tasks
- Ensure `test` DB env vars are explicitly documented and used.
- Ensure JWT env vars used by auth are documented in `.env.example`.
- Ensure setup docs include seed step for demo readiness (`bin/rails db:seed`).

### Verification
- `docker compose up -d db`
- `bin/rails db:prepare`
- `RAILS_ENV=test bin/rails db:prepare`
- `bin/rails runner "ActiveRecord::Base.connection.execute('SELECT 1')"`
- `RAILS_ENV=test bin/rails runner "ActiveRecord::Base.connection.execute('SELECT 1')"`

## 04 - RSpec + SimpleCov

### Files to verify/adjust
- `/Users/lucassantiago/workspace/library_management_workspace/library_management/spec/rails_helper.rb`
- `/Users/lucassantiago/workspace/library_management_workspace/library_management/spec/spec_helper.rb`
- `/Users/lucassantiago/workspace/library_management_workspace/library_management/.rspec`
- `/Users/lucassantiago/workspace/library_management_workspace/library_management/README.md`

### Remaining tasks
- Add or confirm coverage gate policy (optional threshold but recommended for interview rigor).
- Document exact test commands by domain (`spec/models`, `spec/requests/auth`, etc.).
- Ensure request-spec helpers are standardized for auth headers and JSON parsing.

### Verification
- `bundle exec rspec`
- Confirm HTML report at `/Users/lucassantiago/workspace/library_management_workspace/library_management/coverage/index.html`

## 05 - Data Modeling (+ Model Specs)

### Files to modify
- `/Users/lucassantiago/workspace/library_management_workspace/library_management/app/models/borrowing.rb`
- `/Users/lucassantiago/workspace/library_management_workspace/library_management/app/models/book.rb`
- `/Users/lucassantiago/workspace/library_management_workspace/library_management/db/migrate/*` (new migration for active-borrow uniqueness and invariants)
- `/Users/lucassantiago/workspace/library_management_workspace/library_management/spec/models/borrowing_spec.rb`
- `/Users/lucassantiago/workspace/library_management_workspace/library_management/spec/models/book_spec.rb`
- `/Users/lucassantiago/workspace/library_management_workspace/library_management/db/seeds.rb`

### Remaining tasks
- Enforce "cannot borrow same book multiple times while active" at model and DB level.
- Add model-level rules to support borrow/return inventory consistency.
- Add overdue/active scopes useful for dashboards.
- Implement seeded demo users/books/borrowings (required by interview brief).

### Model test cases to add
- Duplicate active borrowing for same `user_id/book_id` is invalid.
- Same `user_id/book_id` after return is allowed.
- Borrow decreases `available_copies`; return increases `available_copies`.
- Cannot borrow when `available_copies == 0`.
- Overdue scope returns only active borrowings past due.
- Seeds create at least 1 librarian, 1 member, and sample books/borrowings idempotently.

## 06 - Authentication

### Files to verify/adjust
- `/Users/lucassantiago/workspace/library_management_workspace/library_management/app/controllers/api/v1/auth/registrations_controller.rb`
- `/Users/lucassantiago/workspace/library_management_workspace/library_management/app/controllers/api/v1/auth/sessions_controller.rb`
- `/Users/lucassantiago/workspace/library_management_workspace/library_management/app/controllers/application_controller.rb`
- `/Users/lucassantiago/workspace/library_management_workspace/library_management/spec/requests/auth/register_spec.rb`
- `/Users/lucassantiago/workspace/library_management_workspace/library_management/spec/requests/auth/login_spec.rb`
- `/Users/lucassantiago/workspace/library_management_workspace/library_management/spec/requests/auth/logout_spec.rb`

### Remaining tasks
- Keep strict OpenAPI error shape/status behavior checks for auth endpoints.
- Add missing edge-case specs around malformed/expired token handling consistency.
- Validate role handling in register (`librarian/member`) remains contract-compliant.

### Request test cases to add
- Register invalid payload returns `422` with `{ errors: ... }`.
- Login invalid credentials returns `401` with `{ error: ... }`.
- Logout with missing/invalid/replayed token returns `401`.

## 07 - Authorization

### Files to modify
- `/Users/lucassantiago/workspace/library_management_workspace/library_management/app/policies/book_policy.rb`
- `/Users/lucassantiago/workspace/library_management_workspace/library_management/app/policies/borrowing_policy.rb`
- `/Users/lucassantiago/workspace/library_management_workspace/library_management/app/controllers/api/v1/books_controller.rb`
- `/Users/lucassantiago/workspace/library_management_workspace/library_management/app/controllers/api/v1/borrowings_controller.rb`
- `/Users/lucassantiago/workspace/library_management_workspace/library_management/app/controllers/api/v1/dashboards_controller.rb`
- `/Users/lucassantiago/workspace/library_management_workspace/library_management/spec/requests/authorization/books_authorization_spec.rb`
- `/Users/lucassantiago/workspace/library_management_workspace/library_management/spec/requests/authorization/borrowings_authorization_spec.rb`
- `/Users/lucassantiago/workspace/library_management_workspace/library_management/spec/requests/authorization/dashboards_authorization_spec.rb`

### Remaining tasks
- Complete behavior that authorization unlocks.
- Implement `q` filtering in books index (contract requires search).
- Implement borrow conflict semantics (`409`) for unavailable/duplicate active borrow.
- Implement librarian dashboard `overdue_members` aggregation (currently empty).

### Request test cases to add
- Member cannot create/update/delete books (`403`), librarian can.
- Member can borrow only if available and not already active; conflict returns `409`.
- Librarian can return borrowings; member cannot.
- Member borrowings list only own; librarian sees all.
- Dashboard endpoints enforce role and return contract-shaped payloads with real computed data.
