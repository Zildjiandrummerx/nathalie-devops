# N.A.T.H.A.L.I.E. | Cognitive DevOps CLI

> **N**eural **A**lgorithmic **T**opology **H**euristics **A**nd **L**ogical **I**nfrastructure **E**ngine

## The Vision: Zero-Friction Architecture
In modern software engineering, the gap between an idea and a deployed, version-controlled environment is filled with repetitive friction: creating directories, scaffolding virtual environments, writing boilerplate documentation, initializing Git, logging into GitHub, creating repositories, and linking remote origins.

**N.A.T.H.A.L.I.E.** is a monolithic, AI-driven Bash CLI engineered to completely obliterate that friction. It acts as an automated DevOps partner, transforming a 15-minute setup process into a 5-second keystroke.

---

## Core Capabilities (The Omni-Matrix)

### 1. Inverted Topology Scaffolding
Standard Python tutorials teach developers to place the `venv` inside the working directory. This creates `.gitignore` bloat and security risks. N.A.T.H.A.L.I.E. engineers an inverted, highly secure topology:
*   The `venv/` is generated as the **Parent** directory.
*   The `src/` (and `.git/` repository) is generated as the **Child** directory. 
*   *Result:* Git has absolute zero physical awareness of the Python environment binaries living above it, permanently preventing accidental dependency leaks.

### 2. GitHub REST API Auto-Provisioning
The CLI bypasses the GitHub web interface entirely. Utilizing an authenticated `curl` wrapper around the GitHub REST API, it dynamically scans the cloud for the target repository. If it returns a `404 Not Found`, the CLI automatically POSTs a payload to forge a new, private GitHub repository on the fly before linking the local origin.

### 3. Cognitive Version Control (Google Gemini AI)
N.A.T.H.A.L.I.E. is integrated directly with the Google Gemini 1.5 Flash LLM via REST API. 
*   **Auto-Documentation:** If a `README.md` is missing, the engine maps the local directory tree, feeds it to Gemini, and generates a professional, context-aware project description.
*   **Auto-Committing:** Before pushing, the engine extracts the Git diff, pipes it to the AI, and generates a strict, highly accurate *Conventional Commit* message based purely on the code changes. 

### 4. Subshell Navigation Physics
Bash scripts traditionally operate in isolated child processes. To ensure a seamless developer experience, Protocol 1 concludes with an `exec bash` sequence. It dynamically injects the `source activate` command and drops the user into an interactive, fully activated virtual environment inside the `src/` folder the moment the script finishes.

---

## The Protocols

The CLI operates on a strict, interactive 3-tier menu matrix:

1. **Protocol 1 (The Scaffolder):** Builds the inverted Venv/Src matrix, auto-creates the GitHub repo, pushes the genesis commit, and drops the user into the active terminal.
2. **Protocol 2 (Cognitive Push):** Analyzes code diffs, queries Gemini AI for commit messages and documentation, and forcefully syncs the local directory to the remote cloud.
3. **Protocol 3 (Secure Clone):** Authenticates and fetches target repositories directly from the cloud without requiring manual token inputs.

---

## Installation & Security

> ⚠️ **SECURITY NOTICE:** To achieve absolute Zero-Trust, the active bash script utilizing Personal Access Tokens is explicitly ignored via `.gitignore`. The file tracked in this repository (`nathalie.template.sh`) is a scrubbed architectural blueprint.

**To run locally:**
1. Clone this repository.
2. Duplicate the template: `cp nathalie.template.sh nathalie.sh`
3. Insert your `GITHUB_TOKEN` and `GEMINI_API_KEY` into the variables at the top of `nathalie.sh`.
4. Make it executable: `chmod +x nathalie.sh`
5. (Optional) Alias it in your `~/.bashrc` for global access: `alias nathalie="~/Development/cli-tools/nathalie.sh"`