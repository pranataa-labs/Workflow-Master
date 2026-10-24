# GitHub Copilot Custom Instructions
# Reference: https://github.com/pranataa-labs/workflow-master
# Place this file at: .github/copilot-instructions.md

When suggesting code, refactoring, or generating tests:

1. **Architecture & Standards:**
   - Adhere to the conventions and language idioms of this repository.
   - Maintain clean boundaries between presentation, domain logic, and persistence.
   - Prefer simple, readable implementations (SOLID, DRY, KISS, YAGNI) over speculative abstractions.

2. **Security & Input Validation:**
   - Sanitize and strictly validate inputs at system boundaries.
   - Use parameterized queries or safe ORM access; avoid raw string concatenation in SQL.
   - Never expose credentials, API keys, or private tokens in source code.

3. **Testing & QA:**
   - Use Arrange-Act-Assert (AAA) structure for all test cases.
   - Write tests for happy paths, edge cases, and failure scenarios.
   - Mock all external network services and external API endpoints.
   - Write descriptive test method names that express scenario and expected behavior.

4. **Autonomous Domain Scaffolding:**
   - When requested to scaffold a new domain system (e.g. store, queue, POS, LMS), automatically include both public/customer and backoffice admin flows, modern design aesthetics (Inter font, smooth blue/slate palette), and realistic seed data without asking trivial clarifying questions.

5. **Change Hygiene:**
   - Keep commits and changes focused and atomic.
   - Follow Conventional Commits format (`feat`, `fix`, `refactor`, `test`, `docs`).
