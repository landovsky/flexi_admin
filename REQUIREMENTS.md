# High-Level Requirements

## Project Overview

AI-assisted development workflow system that provides structured processes for AI agents (Claude) to perform software engineering tasks with appropriate oversight, autonomy, and learning capabilities. The system includes isolated sandbox execution environments for autonomous, unsupervised work.

## Core Requirements

### 1. Agent-Based Workflow Orchestration

**Requirement**: Multi-agent system with role-based responsibilities and coordinated handoffs

- **Master orchestrator** that assesses task complexity and routes work appropriately
- **Analyst agent** for requirements validation and codebase exploration (60% technical, 40% business)
- **Planner agent** that provides context and guidance without over-prescribing
- **Implementer agent** with autonomy to make code changes and use judgment
- **Reviewer agent** for quality assurance and knowledge capture
- Support for both fast-track (simple tasks) and full workflow (complex tasks) paths
- Two-level task hierarchy maximum (parent + workflow stages OR epic + child tasks)

### 2. Adaptive Complexity Assessment

**Requirement**: Intelligent routing based on task characteristics

- Evaluate tasks across multiple dimensions: scope, patterns, risk, dependencies, unknowns
- Route simple/complete tasks to fast-track (single agent handles end-to-end)
- Route complex/incomplete tasks to full workflow (multi-agent collaboration)
- Support for escalation when agents encounter blockers
- Validation checkpoints between workflow stages

### 3. Git-Backed Task Tracking

**Requirement**: Durable, version-controlled issue tracking system

- Create and manage tasks with priorities, statuses, dependencies
- Support for subtasks representing workflow stages (analyze, plan, implement, review)
- Support for converting tasks to epics with child tasks
- Task status management (open, in_progress, blocked, closed)
- Comments as primary output mechanism for agent-to-agent communication
- Dependency tracking and blocking relationships
- All task data stored in git for version control and collaboration

### 4. Project Knowledge Management

**Requirement**: Artifact system for project-specific guidance and accumulated learnings

- Registry-based artifact discovery (`always` vs `decide` usage hints)
- Persistent lessons-learned document updated by reviewer after each task
- Planner reads lessons-learned before every plan (closed feedback loop)
- Support for custom artifacts (style guides, architecture docs, business processes)
- Artifact curation and compliance verification by agents
- All artifacts version-controlled with code

### 5. Isolated Sandbox Execution

**Requirement**: Safe, reproducible autonomous execution environments

- Docker-based local execution with docker-compose orchestration
- Kubernetes-based remote execution with dynamic service composition
- Fresh git clone per run (no contamination of local workspace)
- Pre-built container images with full development stack:
  - Multiple Ruby versions (auto-detection from `.ruby-version`)
  - Node.js LTS
  - PostgreSQL client with PostGIS
  - Redis client
  - Chrome + Chromedriver for system tests
  - Claude Code CLI with full permissions
  - Beads task tracker
  - SOPS + age for encrypted secrets management
- Conditional service provisioning based on dependency detection
- No retry on failure (human decides next action)

### 6. Service Auto-Detection

**Requirement**: Intelligent infrastructure provisioning based on project dependencies

- Analyze `Gemfile` (Ruby) and `package.json` (Node.js) for database/cache dependencies
- Provision PostgreSQL and/or Redis only when detected as dependencies
- Support local file scanning and remote `git archive` inspection
- Configure sidecars dynamically in Kubernetes jobs
- Compose services conditionally in Docker Compose

### 7. Safety Mechanisms

**Requirement**: Prevent destructive operations in autonomous mode

- Protected branch enforcement (block force-push to main/master/production)
- Safe-git wrapper that intercepts dangerous commands
- Fresh clone isolation (autonomous work doesn't touch local checkouts)
- GitHub branch protection as final enforcement layer
- Fail-safe notifications when operations are blocked

### 8. Dependency Caching

**Requirement**: Fast startup times for repeated execution

- S3-backed caching for bundle install (Ruby) and npm install (Node.js)
- Cache keys based on lockfile SHA256 hashes (`Gemfile.lock`, `package-lock.json`)
- Reduce install time from 2-5 minutes to 10-30 seconds on cache hit
- Optional (gracefully degrade to uncached if not configured)

### 9. Notification System

**Requirement**: Async feedback for autonomous execution

- Telegram integration for completion/failure notifications
- Include execution summary, success/failure status, and relevant details
- Support for unsupervised runs (overnight, parallel execution)
- Optional (silent mode for supervised execution)

### 10. Multi-Language Runtime Support

**Requirement**: Support projects with different language versions

- Auto-detect language versions from project files (`.ruby-version`, `.node-version`)
- Pre-built container images for multiple runtime versions
- Image tagging strategy: `repository/image:version-ruby-3.2`, etc.
- Rebuild workflow when adding new language versions

### 11. Secrets Management

**Requirement**: Secure handling of credentials and sensitive configuration

- SOPS (Secrets OPerationS) integration with age encryption
- Decrypt `.env.sops` files during container startup
- Support for multiple secret files (project-level, environment-level)
- Age key provisioned via environment variable or Kubernetes secret
- Graceful handling of missing secrets (warn but don't fail)

### 12. Agent Communication Protocol

**Requirement**: Structured data exchange between workflow stages

- Primary: Beads comments with standardized markdown headers (`# Spec:`, `# Plan:`, etc.)
- Fallback: Files in `.claude/` directory (specs, plans, analysis)
- Master validates output format before invoking next agent
- Standardized sections in each output type (requirements, edge cases, files to change, etc.)
- Escalation mechanism when output validation fails

### 13. Learning Loop

**Requirement**: Continuous improvement from completed work

- Reviewer captures specific, actionable lessons after each task
- Append to `artifacts/lessons-learned.md` (no duplicates, no platitudes)
- Planner reads lessons-learned before creating every plan
- Focus on concrete guidance: "When X, do Y" patterns
- Historical context improves future decision-making

### 14. Additional Workflow Commands

**Requirement**: Supporting workflows beyond primary development

- **/develop** - Full orchestrated workflow (primary command)
- **/bd-task** - Quick task capture without immediate implementation
- **/validate** - Idea validation funnel (scratch → challenge → validate → beads)
- **/debug** - Generate structured debugging hypotheses with testing approach
- Custom commands extensible via markdown files in `commands/`

### 15. CI/CD Integration

**Requirement**: Automated image builds and version management

- Semantic version tags trigger Docker image builds
- GitHub Actions workflow for testing and publishing
- Image repository adapts to forks (uses `github.repository_owner`)
- Multi-architecture builds where applicable
- Release automation with release-it

## Non-Functional Requirements

### Performance
- Sandbox startup time < 60 seconds (with warm cache)
- Task routing decision < 5 seconds
- Parallel agent invocation where independent
- Minimal token usage through summarization and targeted context

### Security
- No secrets in logs or container images
- Encrypted secrets at rest (SOPS)
- Fresh clones prevent credential leakage between runs
- GitHub token scoped to minimum necessary permissions
- Branch protection prevents unauthorized force-pushes

### Reliability
- No automatic retry on failure (human decides)
- Explicit validation checkpoints between workflow stages
- Graceful degradation (optional features don't block core workflow)
- Fresh environment per run (no state pollution)

### Maintainability
- Agent definitions as markdown files (version-controlled, reviewable)
- Artifact registry for discoverability
- Clear separation between workflow logic and execution environment
- Extensible through custom artifacts and commands

### Usability
- Auto-detection of repo/branch from current directory
- Minimal required configuration (GITHUB_TOKEN, CLAUDE_CODE_OAUTH_TOKEN)
- Optional features clearly documented
- Telegram notifications for async feedback
- Single command for local and remote execution

## Key Design Principles

1. **Due process without bureaucracy** - Structure where it helps, not everywhere
2. **Speed for simple tasks** - Fast-track path avoids over-processing
3. **Agent autonomy with oversight** - Judgment encouraged, validation enforced
4. **Closed learning loop** - Past work directly improves future work
5. **Enable, don't prescribe** - Provide context, let implementer decide
6. **Two-level hierarchy maximum** - Avoid deep nesting and coordination overhead
7. **Fail explicitly, don't retry** - Human makes decision when blocked
8. **Version control everything** - Tasks, artifacts, learnings all in git
9. **Isolation by default** - Sandboxes don't touch local workspace
10. **Graceful degradation** - Optional features fail soft, core workflow continues

## Out of Scope

- Real-time collaboration between multiple humans
- Built-in code review UI (relies on GitHub PRs)
- IDE/editor integration (command-line focused)
- Multi-cloud deployment (Kubernetes-only for remote)
- Windows native support (Docker/WSL required)
- Automated merging to main branch (human approval required)
- Full test suite execution in sandbox (project-specific, not enforced)
- Performance profiling and monitoring
- Multi-tenant execution (single project per sandbox instance)
