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

set -e # Fail-fast mechanism for localized errors

# ============================================================
# 1. THE BURNED CREDENTIALS & CONFIGURATION
# ============================================================
GITHUB_USER="XXXXX"           # <-- Replace with your GitHub Username
GITHUB_EMAIL="XXXXX"          # <-- Replace with your Email Address
GITHUB_TOKEN="XXXXX"          # <-- Replace with your GitHub PAT (Requires 'repo' scope)
GEMINI_API_KEY="XXXXX"        # <-- Replace with your Gemini API Key
DEV_BASE_DIR="/home/{USERNAME}/Development" # <-- Replace with your local work environment

# Terminal Colors for Aesthetic Output
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
PINK='\033[1;35m'
NC='\033[0m' # No Color

# ============================================================
# 2. GITHUB API AUTO-PROVISIONING ENGINE (INTERACTIVE)
# ============================================================
function ensure_github_repo_exists() {
    while true; do
        echo -e "${PINK}[+] Let me just check GitHub to see if our repository '$TARGET_REPO' is already there...${NC}"
        
        HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" -H "Authorization: token $GITHUB_TOKEN" "https://api.github.com/repos/$GITHUB_USER/$TARGET_REPO")
        
        if [ "$HTTP_STATUS" == "404" ]; then
            echo -e "\n${YELLOW}[!] Oh my, I couldn't find '$TARGET_REPO' under your GitHub account, Sir.${NC}"
            echo "Would you like me to forge it for you, or did we perhaps misspell the name?"
            echo "  c) Please create '$TARGET_REPO' as a new private repository."
            echo "  r) Let me retry with a corrected spelling."
            echo "  a) Abort the sequence for now."
            echo ""
            read -p "What would you like to do? (c/r/a): " USER_CHOICE
            
            case $USER_CHOICE in
                c|C)
                    echo -e "${PINK}[+] Wonderful. I am instructing the GitHub API to forge your new repository...${NC}"
                    CREATE_RESP=$(curl -s -w "\n%{http_code}" -X POST \
                        -H "Authorization: token $GITHUB_TOKEN" \
                        -H "Accept: application/vnd.github.v3+json" \
                        -d "{\"name\":\"$TARGET_REPO\", \"private\":true}" \
                        "https://api.github.com/user/repos")
                        
                    CREATE_STATUS=$(echo "$CREATE_RESP" | tail -n1)
                    if [ "$CREATE_STATUS" == "201" ]; then
                        echo -e "${GREEN}[+] All set! GitHub repository '$TARGET_REPO' is now securely forged.${NC}"
                        break
                    else
                        echo -e "${RED}[-] I apologize, Sir. Failed to create the repository. GitHub returned HTTP $CREATE_STATUS.${NC}"
                        exit 1
                    fi
                    ;;
                r|R)
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
    
    ensure_github_repo_exists
    
    echo -e "${PINK}[+] Securely linking to your GitHub origin...${NC}"
    AUTH_REPO_URL="https://${GITHUB_USER}:${GITHUB_TOKEN}@github.com/${GITHUB_USER}/${TARGET_REPO}.git"
    git remote add origin "$AUTH_REPO_URL"
    
    echo -e "${PINK}[+] Writing your initial security perimeters and README...${NC}"
    echo "# YotchApps | $TARGET_REPO" > README.md
    echo "Enterprise scaffolding initialized by N.A.T.H.A.L.I.E." >> README.md
    
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
    
    # Spawn a new shell, load Cloud Shell bashrc, activate the new venv, and stay in src/
    exec bash --rcfile <(echo '. ~/.bashrc; source "../bin/activate"')
    ;;

  # ============================================================
  # PROTOCOL 2: COGNITIVE PUSH (THE GEMINI AI PIPELINE)
  # ============================================================
  2)
    echo -e "\n${YELLOW}[!] Preparing to sync your beautiful code to GitHub.${NC}"
    
    if [ ! -d ".git" ]; then
        echo -e "${RED}[-] I apologize, Sir, but I don't see a .git folder here. Are we in the right directory?${NC}"
        exit 1
    fi

    if git config --get remote.origin.url > /dev/null 2>&1; then
        REPO_URL=$(git config --get remote.origin.url)
        TARGET_REPO=$(basename -s .git "$REPO_URL")
    else
        TARGET_REPO=${PWD##*/}
    fi
    
    ensure_github_repo_exists
    
    AUTH_REPO_URL="https://${GITHUB_USER}:${GITHUB_TOKEN}@github.com/${GITHUB_USER}/${TARGET_REPO}.git"
    git remote remove origin 2>/dev/null || true
    git remote add origin "$AUTH_REPO_URL"
    
    if [ ! -f "README.md" ]; then
      echo -e "${PINK}[-] I noticed you don't have a README.md yet.${NC}"
      if [ "$GEMINI_API_KEY" != "XXXXX" ] && command -v jq &> /dev/null; then
          echo -e "${PINK}[+] Waking my cognitive subsystems to draft a brilliant description for you...${NC}"
          DIR_TREE=$(ls -1)
          
          # Pass strings as arguments to prevent JSON/Bash quoting conflicts
          README_PROMPT="You are an elite DevSecOps architect. Write a short, powerful, enterprise-grade description based on these files. Return ONLY the text, no markdown formatting or quotes. Files:"
          PAYLOAD=$(jq -n --arg prompt "$README_PROMPT" --arg tree "$DIR_TREE" '{ contents: [{ parts: [{ text: ($prompt + "\n\n" + $tree) }] }] }')
          
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

    echo -e "${PINK}[+] Gathering all your brilliant changes...${NC}"
    git add .
    
    if git diff --cached --quiet; then
        echo -e "${GREEN}[-] It seems your code is already perfectly synced, Sir. Nothing to commit today.${NC}"
        exit 0
    fi
    
    COMMIT_MSG=""
    if [ "$GEMINI_API_KEY" != "XXXXX" ] && command -v jq &> /dev/null; then
        echo -e "${PINK}[+] Asking my AI core to review your code and write the perfect commit message...${NC}"
        DIFF_PREVIEW=$(git diff --cached | head -c 3000)
        
        # SECURITY FIX: Pass strings as arguments to prevent JSON/Bash quoting conflicts
        COMMIT_PROMPT="You are an elite version control AI. Read this git diff and write a single, concise Conventional Commit message (e.g. feat: added holiday radar). Return ONLY the message string. Do not include markdown, quotes, or explanations. Diff:"
        PAYLOAD=$(jq -n --arg prompt "$COMMIT_PROMPT" --arg diff "$DIFF_PREVIEW" '{ contents: [{ parts: [{ text: ($prompt + "\n\n" + $diff) }] }] }')
        
        API_RESPONSE=$(curl -s -X POST "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$GEMINI_API_KEY" -H "Content-Type: application/json" -d "$PAYLOAD")
        COMMIT_MSG=$(echo "$API_RESPONSE" | jq -r '.candidates[0].content.parts[0].text' | tr -d '\n' | tr -d '"')
    fi
    
    if [ -z "$COMMIT_MSG" ] || [ "$COMMIT_MSG" == "null" ]; then
        COMMIT_MSG="Automated Push: $(date "+%Y-%m-%d %H:%M:%S") - Architecture sync"
    fi
    
    echo -e "${PINK}[+] Committing as: \"$COMMIT_MSG\"${NC}"
    git commit -m "$COMMIT_MSG" || true
    git branch -M main

    echo -e "${PINK}[+] Sending it up to GitHub...${NC}"
    if ! git push -u origin main > /dev/null 2>&1; then
      echo -e "${YELLOW}[-] GitHub hesitated, but I am asserting your local code as the absolute truth (Force Push)...${NC}"
      git push -u origin main --force
    fi
    echo -e "${GREEN}✅ Sync complete! Your codebase is safe and sound.${NC}"
    ;;

  # ============================================================
  # PROTOCOL 3: SECURE PULL / CLONE
  # ============================================================
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