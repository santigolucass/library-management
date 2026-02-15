# Postman Full Automated Suite

## Files
- `library-management.full-suite.postman_collection.json`: full automated test suite
- `library-management.local.postman_environment.json`: local environment variables

## Coverage
- Positive paths: register/login/logout, books, borrowings, dashboards
- Negative/auth paths: `401`, `403`, `404`, `409`, `422`
- End-to-end workflows:
  - Librarian management flow
  - Member borrow and librarian return flow
  - Authorization matrix flow

## Import into Postman
1. Open Postman and click **Import**.
2. Import both JSON files from `docs/postman/`.
3. Select environment **Library Management API - Local**.
4. Run the collection with Collection Runner.

## Notes
- The suite auto-generates unique test users per run using `runId`.
- Ensure the API is running at `http://localhost:3000/api/v1`.
- Requests are ordered and share state through variables.
