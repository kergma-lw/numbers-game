# AGENTS

<!-- BEGIN ORDO MANAGED SECTION -->
## Ordo workflows

Ordo workflows are the canonical operational entrypoints for this repository.
When a workflow covers the task, use it instead of reproducing its checks manually.

### Command line

- Discover workflow entries → `ordo-playbook workflows list`
- Inspect one workflow contract → `ordo-playbook workflows show <workflow>`
- Review, check, plan, or explain without making changes → `ordo-playbook <mode> <workflow>`
- Execute a workflow → `ordo-playbook run <workflow>`
- Suggest the next workflow → `ordo-playbook next`
- Show workflow connections → `ordo-playbook graph`
- Read the detailed reference → `ordo-help`
- Pass caller values with repeatable `--input KEY=VALUE`; use `--input-file KEY=PATH` for raw file content.

### Inspect

- Repository status → `ordo-playbook run global-status`
- View an issue → `ordo-playbook run issue-view --input number=<issue-number>`
- View issue comments → `ordo-playbook run issue-view-comments --input number=<issue-number> --input limit=<limit>`
- Inspect a pull request → `ordo-playbook run pr-view --input pull_number=<pull-number>`
- Digest a pull request → `ordo-playbook run pr-digest --input pr_repository=<owner/repo> --input pull_number=<pull-number>`
- List backlog stories → `ordo-playbook run stories-backlog`
- List in-progress stories → `ordo-playbook run stories-in-progress`

### Task lifecycle

- Create a task → `ordo-playbook run create-task --input title=<title> --input body=<body>`
- Move a task to Ready → `ordo-playbook run task-to-ready --input issue_number=<issue-number>`
- Start or resume a task → `ordo-playbook run set-active-task --input issue_number=<issue-number>`
- Commit the active task worktree → `ordo-playbook run task-commit --input message=<message>`
- Move the local task to review → `ordo-playbook run task-to-review`
- Publish a prepared task → `ordo-playbook run publish-task`
- Merge a published task → `ordo-playbook run merge-task [--input merge_method=<merge-method>] [--input base_branch=<base-branch>]`
- Close a merged task → `ordo-playbook run close-task [--input close_comment=<close-comment>]`
- Cancel a task → `ordo-playbook run cancel-task --input reason=<reason>`

### Context

- Show current task context → `ordo-playbook run current-task-context`

### Collaboration

- Comment on an issue → `ordo-playbook run issue-comment --input number=<issue-number> --input body=<body>`

### Verify

- Run all tests → `ordo-playbook run verify-all-tests`

### Create

- Create a story → `ordo-playbook run create-story --input title=<title> --input body=<body>`

### Story

- Show story tasks → `ordo-playbook run story-tasks-show --input issue_number=<issue-number>`
- Add a story task reference → `ordo-playbook run story-task-add --input issue_number=<story-number> --input task_repository=<owner/repo> --input task_issue_number=<task-number>`
- Show ready story tasks → `ordo-playbook run story-tasks-ready --input issue_number=<story-number>`

### Emergency

- Force-close an issue → `ordo-playbook run force-close-issue --input number=<issue-number> --input confirm_break_glass=FORCE_CLOSE --input close_comment=<close-comment>`

### Field update

- Set task size → `ordo-playbook run set-task-size --input issue_number=<issue-number> --input size=<XS|S|M|L|XL>`
- Set task estimate → `ordo-playbook run set-task-estimate --input issue_number=<issue-number> --input estimate=<estimate>`
- Set task iteration → `ordo-playbook run set-task-iteration --input issue_number=<issue-number> --input iteration=<iteration>`
- Set task priority → `ordo-playbook run set-task-priority --input issue_number=<issue-number> --input priority=<P0|P1|P2|P3>`

If no workflow in this section is an obvious match, say that no known matching workflow is available. Do not invoke discovery merely to search for one, invent a workflow, or silently replace a workflow with a manual command sequence.

If a workflow covers the task, use it as the canonical entrypoint instead of reproducing its checks manually.

Prefer the minimal command sequence that answers the request. Do not run
unrelated preflight commands or replace a suitable workflow with a guessed
manual command sequence.
<!-- END ORDO MANAGED SECTION -->

## Authoring rules

- All project documentation must be written in English.
- Issue text and issue comments must also be written in English.
- Avoid generic catch-all glossary files.

## Python environment

- The project-local virtual environment is `.venv`.
- Create or recreate this environment with `/usr/bin/python3.12 -m venv .venv`.
- Use this environment for testing, local runs, dependency installation, and other Python-based project commands.
- Prefer invoking tools through the virtual environment explicitly, for example `.venv/bin/python`, or activate it before running project commands.

## Operational workflows (Ordo-first)

- `ordo-playbook` is the canonical operational entrypoint.
- If a suitable workflow exists, do not use a direct command instead of it.
- `ordo-playbook` command modes from `--help`:
  - Discovery: `workflows`
  - Execution: `review`, `check`, `plan`, `explain`, `run`, `next`
- Example:
  - inspect available workflows: `ordo-playbook workflows list`
  - execute a workflow: `ordo-playbook run <workflow>`
- Use `ordo-playbook workflows list` as the default discovery surface.
- If a suitable `ordo-*`/`ordo-playbook` workflow exists, run it directly.
- Do not run unrelated preflight shell commands (`ls`, `pwd`, ad-hoc env checks, etc.) before an Ordo workflow unless they are strictly required for the workflow to succeed or the user explicitly asked for them.
- Prefer the minimal command sequence that answers the user request.
- Do not improvise operational entrypoints from memory or by guessing the most likely shell command.
- Hard rule: do not replace a missing or unknown workflow with a self-chosen “obvious” direct command (`gh`, `git`, `npm`, `python`, helper script, ad-hoc one-liner, etc.) just because the intent seems clear.
- If no suitable workflow exists yet:
  - inspect the current Ordo help/discovery surface;
  - propose how the missing workflow should look;
  - discuss it with the user before executing any legacy ritual directly.
- Do not treat legacy helper scripts or TUI commands as the primary interface.
- A direct command or temporary legacy bypass is allowed only when the user explicitly asks for it or explicitly approves the bypass.

## End-user workflow verification

- Do not write automated tests for concrete end-user project workflows. Do not duplicate their YAML composition in Python tests with mocked probe or action results.
- Verify these workflows through `ordo-playbook check`, `review`, and, when safe and authorized, a trial `run`. Do not execute side-effecting workflows merely to validate them.
- Automated tests for engine semantics, connectors, and reusable primitives remain in scope; this rule does not weaken their testing requirements.

## GitHub and project operations

- Prefer the corresponding `ordo-playbook` workflow for GitHub and project operations.
- GitHub writing rule: issue titles, bodies, comments, labels, and project field values must be in English only.
- Keep API responses lean: request only the fields needed for the decision.

## Commit inspection restraint

- Use `ordo-playbook run task-commit` as the canonical commit entrypoint.
- Do not perform discretionary Git inspection immediately before invoking `task-commit`.
- Where a controlling instruction requires pre-commit inspection, perform only that minimum required read-only inspection. Do not add unrelated preflight commands, repeated test runs, or exploratory checks.
- Inspection is not authorization to change files, broaden scope, repair incidental findings, or alter tests. If it reveals a concern outside the accepted task, report it and wait for an explicit instruction.
- Do not rerun verification solely because a read-only inspection occurred. Run only the verification required by the accepted task or an explicitly requested final verification.
