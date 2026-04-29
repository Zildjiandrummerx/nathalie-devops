#!/bin/bash
# ==============================================================================
# N.A.T.H.A.L.I.E. OMNI-CLI: DEVELOPMENT & VERSION CONTROL MATRIX
# ==============================================================================
# This is a monolithic DevSecOps terminal interface. It handles Python virtual 
# environment scaffolding, AI-driven GitHub pushes, authenticated cloning, and
# dynamic GitHub Repository Auto-Provisioning via the REST API.
#
# SECURITY NOTICE: 
# This is a scrubbed template. Duplicate this file as 'nathalie.sh', input 
# your credentials below, and ensure 'nathalie.sh' is added to your .gitignore.
# ==============================================================================

# FAIL-FAST MECHANISM:
# Instructs bash to exit immediately if any command returns a non-zero (error) status.
# This prevents the script from snowballing errors (e.g., trying to git push if git init failed).
set -e 

# ============================================================
# 1. THE BURNED CREDENTIALS & CONFIGURATION
# ============================================================
# These variables act as the localized Service Account for the CLI.
GITHUB_USER="XXXXX"           # <-- Replace with your GitHub Username
GITHUB_EMAIL="XXXXX"          # <-- Replace with your Email Address
GITHUB_TOKEN="XXXXX"          # <-- Replace with your GitHub PAT (Requires 'repo' scope)
GEMINI_API_KEY="XXXXX"        # <-- Replace with your Gemini API Key
DEV_BASE_DIR="/home/{USERNAME}/Development" # <-- Replace with your local work environment

# TERMINAL AESTHETICS (ANSI Escape Codes):
# Used to provide visual hierarchy and feedback in the terminal UI.
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
PINK='\033[1;35m'
NC='\033[0m' # No Color

# ============================================================
# 2. GITHUB API AUTO-PROVISIONING ENGINE (INTERACTIVE)
# ============================================================
# This function dynamically checks if a repository exists in the cloud.
# If it does not, it pauses to ask the user if they made a typo, or if 
# they want the script to forge the repository for them instantly.
function ensure_github_repo_exists() {
    # Infinite loop to allow the user to retry if they make a spelling mistake
    while true; do
        echo -e "${PINK}[+] Let me just check GitHub to see if our repository '$TARGET_REPO' is already there...${NC}"
        
        # SENDS A SILENT GET REQUEST:
        # Pings the GitHub API and extracts ONLY the HTTP status code (e.g., 200 or 404)
        HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" -H "Authorization: token $GITHUB_TOKEN" "https://api.github.com/repos/$GITHUB_USER/$TARGET_REPO")
        
        if [ "$HTTP_STATUS" == "404" ]; then
            # 404 means the repo is missing. Trigger interactive failsafe.
            echo -e "\n${YELLOW}[!] Oh my, I couldn't find '$TARGET_REPO' under your GitHub account, Sir.${NC}"
            echo "Would you like me to forge it for you, or did we perhaps misspell the name?"
            echo "  c) Please create '$TARGET_REPO' as a new private repository."
            echo "  r) Let me retry with a corrected spelling."
            echo "  a) Abort the sequence for now."
            echo ""
            read -p "What would you like to do? (c/r/a): " USER_CHOICE
            
            case $USER_CHOICE in
                c|C)
                    # EXECUTE REPOSITORY CREATION:
                    # Sends a POST request to GitHub with the burned token to forge a Private repo
                    echo -e "${PINK}[+] Wonderful. I am instructing the GitHub API to forge your new repository...${NC}"
                    CREATE_RESP=$(curl -s -w "\n%{http_code}" -X POST \
                        -H "Authorization: token $GITHUB_TOKEN" \
                        -H "Accept: application/vnd.github.v3+json" \
                        -d "{\"name\":\"$TARGET_REPO\", \"private\":true}" \
                        "https://api.github.com/user/repos")
                        
                    # Extract the HTTP status code from the last line of the curl output
                    CREATE_STATUS=$(echo "$CREATE_RESP" | tail -n1)
                    if [ "$CREATE_STATUS" == "201" ]; then
                        echo -e "${GREEN}[+] All set! GitHub repository '$TARGET_REPO' is now securely forged.${NC}"
                        break # Break the while loop; repo now exists
                    else
                        echo -e "${RED}[-] I apologize, Sir. Failed to create the repository. GitHub returned HTTP $CREATE_STATUS.${NC}"
                        exit 1
                    fi
                    ;;
                r|R)
                    # Update the TARGET_REPO variable and let the while loop restart the API check
                    read -p "Please type the correct repository name: " CORRECTED_NAME
                    if [ -n "$CORRECTED_NAME" ]; then
                        TARGET_REPO="$CORRECTED_NAME"
                    fi
                    ;;
                a|A)
                    echo -e "${RED}[-] Sequence aborted. I'll be here when you need me.${NC}"
                    exit 1
                    ;;
                *)
                    echo -e "${RED}[-] Invalid option, Sir. Aborting for safety.${NC}"
                    exit 1
                    ;;
            esac

        elif [ "$HTTP_STATUS" == "200" ]; then
            # 200 OK: Repo exists. Safe to proceed.
            echo -e "${GREEN}[+] Perfect. I see '$TARGET_REPO' is active and waiting for us on GitHub.${NC}"
            break
        else
            echo -e "${RED}[-] Oh dear, GitHub returned an unexpected status code: $HTTP_STATUS${NC}"
            exit 1
        fi
    done
}

# ============================================================
# 3. THE INTERACTIVE MENU MATRIX
# ============================================================
echo -e "${CYAN}"
echo "================================================================================="
echo "                               N.A.T.H.A.L.I.E."
echo "   (Neural Algorithmic Topology Heuristics And Logical Infrastructure Engine)"
echo "================================================================================="
echo -e "${NC}"
echo -e "Hello again, Sir. How can I assist you with your architecture today?"
echo "  1) Scaffold a beautiful new project (VENV + Git + GitHub Sync)"
echo "  2) Let me handle the push (AI Commits & GitHub Sync)"
echo "  3) Fetch a repository from the cloud"
echo ""
read -p "Please select a protocol [1] [2] [3]: " PROTOCOL

case $PROTOCOL in
  # ============================================================
  # PROTOCOL 1: THE SCAFFOLDER
  # ============================================================
  # Purpose: Creates a secure, inverted directory topology. 
  # The Virtual Environment (venv) is the parent, and the Git repo (src) is the child.
  # This prevents Git from accidentally tracking massive Python libraries.
  1)
    echo -e "\n${YELLOW}[!] Initiating scaffolding sequence. I'll make sure everything is perfect.${NC}"
    read -p "What shall we name our new project? " PROJECT_NAME
    
    TARGET_DIR="$DEV_BASE_DIR/$PROJECT_NAME"
    SRC_DIR="$TARGET_DIR/src"
    TARGET_REPO="$PROJECT_NAME"
    
    if [ -d "$TARGET_DIR" ]; then
        echo -e "${RED}[-] Oh dear, the folder '$TARGET_DIR' already exists. We wouldn't want to overwrite your hard work!${NC}"
        exit 1
    fi
    
    echo -e "${PINK}[+] Crafting your Python Virtual Environment at $TARGET_DIR...${NC}"
    python3 -m venv "$TARGET_DIR"
    
    echo -e "${PINK}[+] Setting up the Source Code matrix...${NC}"
    mkdir -p "$SRC_DIR"
    
    echo -e "${PINK}[+] Waking up Git and preparing your timeline...${NC}"
    cd "$SRC_DIR"
    git init
    git config --global user.name "$GITHUB_USER"
    git config --global user.email "$GITHUB_EMAIL"
    git config --global init.defaultBranch main
    
    # Calls the API function to ensure GitHub is ready to receive this code
    ensure_github_repo_exists
    
    echo -e "${PINK}[+] Securely linking to your GitHub origin...${NC}"
    # Embeds the Personal Access Token directly into the origin URL to bypass password prompts
    AUTH_REPO_URL="https://${GITHUB_USER}:${GITHUB_TOKEN}@github.com/${GITHUB_USER}/${TARGET_REPO}.git"
    git remote add origin "$AUTH_REPO_URL"
    
    echo -e "${PINK}[+] Writing your initial security perimeters and README...${NC}"
    echo "# YotchApps | $TARGET_REPO" > README.md
    echo "Enterprise scaffolding initialized by N.A.T.H.A.L.I.E." >> README.md
    
    # Generate the initial .gitignore file inside src/
    echo "__pycache__/" > .gitignore
    echo ".env" >> .gitignore
    
    echo -e "${PINK}[+] Uploading our genesis payload to the cloud...${NC}"
    git add .
    git commit -m "chore: automated genesis commit and scaffolding by N.A.T.H.A.L.I.E."
    git branch -M main
    git push -u origin main
    
    echo ""
    echo -e "${GREEN}✅ Everything is ready, Sir. Your project is deployed and secured.${NC}"
    echo ""
    echo -e "${CYAN}[+] Dropping you into your active environment... (type 'exit' whenever you wish to leave)${NC}"
    
    # ADVANCED BASH MANEUVER: 
    # Spawns an interactive bash sub-shell, sources the user's .bashrc profile, 
    # and automatically activates the newly created python venv.
    exec bash --rcfile <(echo '. ~/.bashrc; source "../bin/activate"')
    ;;

  # ============================================================
  # PROTOCOL 2: COGNITIVE PUSH (THE GEMINI AI PIPELINE)
  # ============================================================
  # Purpose: Stages code, uses Google's Gemini AI to analyze the diffs and 
  # write a professional commit message, and pushes to GitHub.
  2)
    echo -e "\n${YELLOW}[!] Preparing to sync your beautiful code to GitHub.${NC}"
    
    if [ ! -d ".git" ]; then
        echo -e "${RED}[-] I apologize, Sir, but I don't see a .git folder here. Are we in the right directory?${NC}"
        exit 1
    fi

    # EXTRACT TARGET REPO:
    # Read the current remote URL to figure out the repo name. If none exists, fallback to folder name.
    if git config --get remote.origin.url > /dev/null 2>&1; then
        REPO_URL=$(git config --get remote.origin.url)
        TARGET_REPO=$(basename -s .git "$REPO_URL")
    else
        TARGET_REPO=${PWD##*/}
    fi
    
    ensure_github_repo_exists
    
    # Re-inject the tokenized URL in case the token was updated or missing
    AUTH_REPO_URL="https://${GITHUB_USER}:${GITHUB_TOKEN}@github.com/${GITHUB_USER}/${TARGET_REPO}.git"
    git remote remove origin 2>/dev/null || true
    git remote add origin "$AUTH_REPO_URL"
    
    # ----------------------------------------------------
    # AI DOCUMENTATION GENERATOR
    # ----------------------------------------------------
    if [ ! -f "README.md" ]; then
      echo -e "${PINK}[-] I noticed you don't have a README.md yet.${NC}"
      if [ "$GEMINI_API_KEY" != "XXXXX" ] && command -v jq &> /dev/null; then
          echo -e "${PINK}[+] Waking my cognitive subsystems to draft a brilliant description for you...${NC}"
          
          # Read the current directory structure to give the AI context
          DIR_TREE=$(ls -1)
          
          # SECURITY: Using jq --arg prevents bash quotes from breaking the JSON payload
          README_PROMPT="You are an elite DevSecOps architect. Write a short, powerful, enterprise-grade description based on these files. Return ONLY the text, no markdown formatting or quotes. Files:"
          PAYLOAD=$(jq -n --arg prompt "$README_PROMPT" --arg tree "$DIR_TREE" '{ contents: [{ parts: [{ text: ($prompt + "\n\n" + $tree) }] }] }')
          
          # Call the Gemini API and extract the response
          AI_DESC=$(curl -s -X POST "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$GEMINI_API_KEY" -H "Content-Type: application/json" -d "$PAYLOAD" | jq -r '.candidates[0].content.parts[0].text')
          
          echo "# YotchApps | $TARGET_REPO" > README.md
          echo "$AI_DESC" >> README.md
          echo -e "${GREEN}[+] I've drafted and saved your new documentation.${NC}"
      else
          echo -e "${PINK}[+] I've created a standard placeholder for you instead.${NC}"
          echo "# YotchApps Framework" > README.md
          echo "An enterprise-grade software architecture." >> README.md
      fi
    fi

    # ----------------------------------------------------
    # STAGE & AI COMMIT GENERATION
    # ----------------------------------------------------
    echo -e "${PINK}[+] Gathering all your brilliant changes...${NC}"
    git add .
    
    # Check if there's actually anything to commit to prevent empty push errors
    if git diff --cached --quiet; then
        echo -e "${GREEN}[-] It seems your code is already perfectly synced, Sir. Nothing to commit today.${NC}"
        exit 0
    fi
    
    COMMIT_MSG=""
    if [ "$GEMINI_API_KEY" != "XXXXX" ] && command -v jq &> /dev/null; then
        echo -e "${PINK}[+] Asking my AI core to review your code and write the perfect commit message...${NC}"
        
        # Grab the first 3000 chars of the git diff to stay within API payload limits
        DIFF_PREVIEW=$(git diff --cached | head -c 3000)
        
        # SECURITY: Using jq --arg to safely pass the diff payload
        COMMIT_PROMPT="You are an elite version control AI. Read this git diff and write a single, concise Conventional Commit message (e.g. feat: added holiday radar). Return ONLY the message string. Do not include markdown, quotes, or explanations. Diff:"
        PAYLOAD=$(jq -n --arg prompt "$COMMIT_PROMPT" --arg diff "$DIFF_PREVIEW" '{ contents: [{ parts: [{ text: ($prompt + "\n\n" + $diff) }] }] }')
        
        API_RESPONSE=$(curl -s -X POST "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$GEMINI_API_KEY" -H "Content-Type: application/json" -d "$PAYLOAD")
        
        # Extract the commit string and strip out any newlines or quotes the AI might have added
        COMMIT_MSG=$(echo "$API_RESPONSE" | jq -r '.candidates[0].content.parts[0].text' | tr -d '\n' | tr -d '"')
    fi
    
    # FALLBACK: If API fails, network drops, or key is missing, use standard timestamp
    if [ -z "$COMMIT_MSG" ] || [ "$COMMIT_MSG" == "null" ]; then
        COMMIT_MSG="Automated Push: $(date "+%Y-%m-%d %H:%M:%S") - Architecture sync"
    fi
    
    echo -e "${PINK}[+] Committing as: \"$COMMIT_MSG\"${NC}"
    git commit -m "$COMMIT_MSG" || true
    git branch -M main

    # ----------------------------------------------------
    # SECURE PUSH TO GITHUB
    # ----------------------------------------------------
    echo -e "${PINK}[+] Sending it up to GitHub...${NC}"
    # Tries to push cleanly first. If it fails (due to divergent history), executes a Force Push.
    if ! git push -u origin main > /dev/null 2>&1; then
      echo -e "${YELLOW}[-] GitHub hesitated, but I am asserting your local code as the absolute truth (Force Push)...${NC}"
      git push -u origin main --force
    fi
    echo -e "${GREEN}✅ Sync complete! Your codebase is safe and sound.${NC}"
    ;;

  # ============================================================
  # PROTOCOL 3: SECURE PULL / CLONE
  # ============================================================
  # Purpose: Fetches a repository from your GitHub using the embedded token.
  # This bypasses the need for SSH keys or manual password prompts.
  3)
    echo -e "\n${YELLOW}[!] Preparing to retrieve your repository.${NC}"
    read -p "Which repository would you like me to fetch for you, Sir? " REPO_NAME
    
    TARGET_DIR="$DEV_BASE_DIR/$REPO_NAME"
    if [ -d "$TARGET_DIR" ]; then
        echo -e "${RED}[-] I'm sorry, but the directory $TARGET_DIR already exists. I cannot clone it here.${NC}"
        exit 1
    fi
    
    TARGET_REPO="$REPO_NAME"
    ensure_github_repo_exists
    
    cd "$DEV_BASE_DIR"
    echo -e "${PINK}[+] Reaching into the cloud and pulling '$TARGET_REPO' down to your machine...${NC}"
    AUTH_REPO_URL="https://${GITHUB_USER}:${GITHUB_TOKEN}@github.com/${GITHUB_USER}/${TARGET_REPO}.git"
    
    git clone "$AUTH_REPO_URL"
    
    echo -e "${GREEN}✅ Safe and sound. '$TARGET_REPO' is now waiting for you in $TARGET_DIR.${NC}"
    ;;

  *)
    echo -e "${RED}[-] I'm sorry, Sir, I didn't recognize that command. Terminating sequence.${NC}"
    exit 1
    ;;
esac