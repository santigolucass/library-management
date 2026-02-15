# Authentication

I will implement authentication after data modeling so protected endpoints can rely on a stable identity context.

Scope for this milestone:
- Register (`POST /auth/register`)
- Login (`POST /auth/login`)
- Logout (`DELETE /auth/logout`)
- JWT bearer flow consistent with `openapi-v1.yml`

Key decisions:
- Return authenticated user + token on register/login
- Keep error response shapes consistent with the OpenAPI contract
- Treat logout as token invalidation strategy
