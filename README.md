# Library Management API

## Local Infrastructure Setup (PostgreSQL + dotenv)

This project runs Rails locally and PostgreSQL in Docker Compose.

### 1. Install dependencies

```bash
bundle install
```

### 2. Configure environment files

`.env.development` and `.env.test` are used by `dotenv-rails`.

Use `.env.example` as the template:

```bash
cp .env.example .env.development
cp .env.example .env.test
```

Default local settings use PostgreSQL on host port `5433`.

### 3. Start PostgreSQL with Docker Compose

```bash
docker compose up -d db
docker compose ps
```

### 4. Prepare databases

```bash
bin/rails db:prepare
RAILS_ENV=test bin/rails db:prepare
```

### 5. Validate database connectivity

```bash
bin/rails runner "ActiveRecord::Base.connection.execute('SELECT 1')"
RAILS_ENV=test bin/rails runner "ActiveRecord::Base.connection.execute('SELECT 1')"
```

## Environment Variables

- `DB_HOST`
- `DB_PORT` (default local: `5433`)
- `DB_USERNAME`
- `DB_PASSWORD`
- `DB_NAME_DEVELOPMENT`
- `DB_NAME_TEST`

## Common Troubleshooting

- Port conflict on `5433`: choose another host port and update `DB_PORT`.
- Authentication errors (`PG::ConnectionBad`): ensure compose and `.env.*` credentials match.
- Test database issues: verify `RAILS_ENV=test` and `DB_NAME_TEST` are configured separately from development.

## Test Baseline Setup (RSpec + SimpleCov)

### Install and prepare

```bash
bundle install
docker compose up -d db
RAILS_ENV=test bin/rails db:prepare
```

### Run tests

```bash
bundle exec rspec
```

### View coverage report

Coverage HTML is generated at:

`coverage/index.html`

On macOS:

```bash
open coverage/index.html
```
