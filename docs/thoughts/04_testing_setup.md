# Testing Setup

I will establish the test baseline before domain and auth implementation to enforce confidence from the first behavior changes.

Scope for this milestone:
- Install and configure RSpec
- Install and configure SimpleCov
- Generate HTML coverage reports for local inspection

Key decisions:
- Treat request specs as first-class for API contract validation
- Keep SimpleCov reporting simple and visible (`coverage/index.html`)
- Ensure test setup works cleanly with the PostgreSQL + dotenv configuration

Success criteria:
- `bundle exec rspec` runs successfully
- Coverage artifacts are generated in HTML format
- Test stack is ready for model/auth/authz milestones
