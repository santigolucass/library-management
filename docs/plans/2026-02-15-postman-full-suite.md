# Postman Full Suite Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Build an importable Postman collection and environment that automatically test the Library Management API with positive, negative, authorization, and end-to-end role workflows.

**Architecture:** Create a new Postman collection JSON under `docs/postman/` with shared helper scripts at collection level, domain folders for auth/books/borrowings/dashboards, and a workflows folder for multi-request scenarios. Use collection variables to persist dynamic IDs/tokens and environment variables for configuration.

**Tech Stack:** Postman Collection v2.1 JSON, Postman test/pre-request scripts.

---

### Task 1: Scaffold Postman artifacts

**Files:**
- Create: `docs/postman/library-management.full-suite.postman_collection.json`
- Create: `docs/postman/library-management.local.postman_environment.json`
- Create: `docs/postman/README.md`

**Step 1: Write the failing verification command**
Run: `node -e "JSON.parse(require('fs').readFileSync('docs/postman/library-management.full-suite.postman_collection.json','utf8'))"`
Expected: FAIL because file does not exist yet.

**Step 2: Write minimal artifact skeletons**
- Add collection `info`, global `auth`, base variables, and empty folders.
- Add environment with `baseUrl` and test credential placeholders.

**Step 3: Re-run JSON parse verification**
Run: `node -e "JSON.parse(require('fs').readFileSync('docs/postman/library-management.full-suite.postman_collection.json','utf8')); JSON.parse(require('fs').readFileSync('docs/postman/library-management.local.postman_environment.json','utf8'))"`
Expected: PASS.

### Task 2: Implement request tests and negative coverage

**Files:**
- Modify: `docs/postman/library-management.full-suite.postman_collection.json`

**Step 1: Add auth/domain requests and scripts**
- Add explicit tests for `201/200/204` happy paths.
- Add explicit negative/auth tests for `401/403/404/409/422` mapped from OpenAPI.

**Step 2: Add helper assertions and variable management**
- Save tokens and IDs from responses.
- Add reusable helpers (status/error keys/schema checks) in collection-level tests.

**Step 3: Validate structure**
Run: `node -e "const c=JSON.parse(require('fs').readFileSync('docs/postman/library-management.full-suite.postman_collection.json','utf8')); if(!c.item || !c.item.length) process.exit(1); console.log(c.item.map(i=>i.name).join(','));"`
Expected: PASS with folder names.

### Task 3: Implement end-to-end workflows and execution docs

**Files:**
- Modify: `docs/postman/library-management.full-suite.postman_collection.json`
- Modify: `docs/postman/README.md`

**Step 1: Add workflow folders**
- `Workflow - Librarian Management`
- `Workflow - Member Borrow and Return`
- `Workflow - Authorization Matrix`

**Step 2: Add run instructions**
- Document Postman Runner.
- Document required env vars and reset guidance.

**Step 3: Verify loadability and basic consistency**
Run: `node -e "const fs=require('fs'); const c=JSON.parse(fs.readFileSync('docs/postman/library-management.full-suite.postman_collection.json','utf8')); const env=JSON.parse(fs.readFileSync('docs/postman/library-management.local.postman_environment.json','utf8')); if(c.info.schema!=='https://schema.getpostman.com/json/collection/v2.1.0/collection.json') process.exit(1); if(!env.values.find(v=>v.key==='baseUrl')) process.exit(1); console.log('ok');"`
Expected: `ok`.
