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
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
PINK='\033[1;35m'
NC='\033[0m' # No Color

# ============================================================
# TTY MASKING & SIGNAL INTERCEPTION REGISTRY
# ============================================================
if [ -t 0 ]; then
    stty -ctlecho
fi

function reset_terminal_matrix() {
    if [ -t 0 ]; then
        stty ctlecho
    fi
}
trap reset_terminal_matrix EXIT

function handle_keyboard_interrupt() {
    echo -e "\n\n${RED}[ ! ] Operational Exception: Keyboard Interrupt sequence intercepted.${NC}"
    echo -e "${PINK}[ ! ] Catch you on the flip side, Yotch. Decoupling workflows and cleaning up the terminal...${NC}\n"
    exit 130
}
trap handle_keyboard_interrupt SIGINT

# ============================================================
# PRE-FLIGHT DEPENDENCY VERIFICATION ENGINE
# ============================================================
function verify_system_dependencies() {
    local missing_deps=()
    for binary in curl jq git python3; do
        if ! command -v "$binary" &> /dev/null; then
            missing_deps+=("$binary")
        fi
    done
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        echo -e "${RED}[ - ] Structural failure: Missing required system binaries: ${missing_deps[*]}${NC}"
        echo -e "${YELLOW}[ ! ] Please run: sudo apt update && sudo apt install -y ${missing_deps[*]} (or equivalent)${NC}"
        exit 1
    fi
}

verify_system_dependencies

# ============================================================
# 2. GITHUB API AUTO-PROVISIONING ENGINE (INTERACTIVE)
# ============================================================
function ensure_github_repo_exists() {
    while true; do
        echo -e "${PINK}[ + ] Let me check the cloud fabric for our '$TARGET_REPO' repository, Yotch...${NC}"
        
        HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" -H "Authorization: token $GITHUB_TOKEN" "https://api.github.com/repos/$GITHUB_USER/$TARGET_REPO")
        
        if [ "$HTTP_STATUS" == "404" ]; then
            echo -e "\n${YELLOW}[ ! ] Oh, it looks like '$TARGET_REPO' isn't on your GitHub account yet, Yotch.${NC}"
            echo -e "${PINK}What's the play? I can forge it for you right now, or we can check the spelling:${NC}"
            echo "  c) Forge '$TARGET_REPO' as a new private repository."
            echo "  r) Let me re-type the name."
            echo "  a) Abort the sequence for now."
            echo ""
            read -p "Selection (c/r/a): " USER_CHOICE
            
            case $USER_CHOICE in
                c|C)
                    echo -e "${PINK}[ + ] Sending the generation payload down the wire...${NC}"
                    CREATE_RESP=$(curl -s -w "\n%{http_code}" -X POST \
                        -H "Authorization: token $GITHUB_TOKEN" \
                        -H "Accept: application/vnd.github.v3+json" \
                        -d "{\"name\":\"$TARGET_REPO\", \"private\":true}" \
                        "https://api.github.com/user/repos")
                        
                    CREATE_STATUS=$(echo "$CREATE_RESP" | tail -n1)
                    if [ "$CREATE_STATUS" == "201" ]; then
                        echo -e "${GREEN}[ + ] All set! Your new repository '$TARGET_REPO' is officially online.${NC}"
                        break
                    else
                        echo -e "${RED}[ - ] Architecture breakdown. GitHub returned HTTP status $CREATE_STATUS.${NC}"
                        exit 1
                    fi
                    ;;
                r|R)
                    read -p "Type the corrected repository name: " CORRECTED_NAME
                    if [ -n "$CORRECTED_NAME" ]; then
                        TARGET_REPO="$CORRECTED_NAME"
                    fi
                    ;;
                a|A)
                    echo -e "${PINK}[ - ] Halted by your command, Yotch. I'll be right here when you need me.${NC}"
                    exit 1
                    ;;
                *)
                    echo -e "${PINK}[ - ] Let's stick to the menu options, Yotch. Aborting sequence for safety.${NC}"
                    exit 1
                    ;;
            esac

        elif [ "$HTTP_STATUS" == "200" ]; then
            echo -e "${GREEN}[ + ] Perfect connection. Remote target '$TARGET_REPO' is synchronized and ready.${NC}"
            break
        else
            echo -e "${RED}[ - ] Unexpected cloud interface response code: $HTTP_STATUS${NC}"
            exit 1
        fi
    done
}

# ============================================================
# 3. THE INTERACTIVE MENU MATRIX
# ============================================================
echo -e "${CYAN}=================================================================================${NC}"
echo -e "${CYAN}                               N.A.T.H.A.L.I.E.${NC}"
echo -e "${CYAN}   (Neural Algorithmic Topology Heuristics And Logical Infrastructure Engine)${NC}"
echo -e "${CYAN}=================================================================================${NC}"
echo ""
echo -e "${PINK}Hello again, Yotch. How can I assist you with your architecture today?${NC}"
echo "  1) Scaffold a beautiful new project (VENV + Git + GitHub Sync)"
echo "  2) Let me handle the push (AI Commits & GitHub Sync)"
echo "  3) Fetch a repository from the cloud"
echo ""
read -p "Please select a protocol [1] [2] [3]: " PROTOCOL

case $PROTOCOL in
  # ============================================================
  # PROTOCOL 1: THE SCAFFOLDER
  # ============================================================

1|01)

echo -e "\n${YELLOW}[ ! ] Warming up my architecture circuits, Yotch...${NC}"

read -p "Enter target workspace identity name: " PROJECT_NAME

TARGET_REPO="$PROJECT_NAME"
TARGET_DIR="$DEV_BASE_DIR/$PROJECT_NAME"
SRC_DIR="$TARGET_DIR/src"

############################################################
# WORKSPACE COLLISION DETECTION
############################################################
# Prevents accidental overwrite of an active local
# development environment.
############################################################

if [ -d "$TARGET_DIR" ]; then
    echo -e "${RED}[ - ] Mmm... I already see a workspace sitting at:${NC}"
    echo -e "${RED}      $TARGET_DIR${NC}"
    echo -e "${PINK}[ - ] I refuse to step on another project's shoes.${NC}"
    exit 1
fi

############################################################
# VIRTUAL ENVIRONMENT INITIALIZATION
############################################################
# Creates isolated Python runtime at:
#
# ~/Development/project-name/
#
# Repository contents remain separated inside:
#
# ~/Development/project-name/src/
############################################################

echo -e "${PINK}[ + ] Building your personal development space...${NC}"

python3 -m venv "$TARGET_DIR"

mkdir -p "$SRC_DIR"

cd "$SRC_DIR"

############################################################
# CLOUD REPOSITORY PRESENCE CHECK
############################################################

HTTP_STATUS=$(curl -s \
-o /dev/null \
-w "%{http_code}" \
-H "Authorization: token $GITHUB_TOKEN" \
"https://api.github.com/repos/$GITHUB_USER/$TARGET_REPO")

############################################################
# REMOTE REPOSITORY EXISTS
############################################################

if [ "$HTTP_STATUS" == "200" ]; then

    echo ""
    echo -e "${YELLOW}[ ! ] Well now... I found '$TARGET_REPO' waiting for us in your cloud vault.${NC}"

    read -p "Would you like me to bring it home and set everything up? [y/n]: " USER_RESPONSE

    case $USER_RESPONSE in

        y|Y)

            echo -e "${PINK}[ + ] Sliding into your GitHub vault and bringing your code back with me...${NC}"

            AUTH_REPO_URL="https://${GITHUB_USER}:${GITHUB_TOKEN}@github.com/${GITHUB_USER}/${TARGET_REPO}.git"

            git clone "$AUTH_REPO_URL" .

            git config user.name "$GITHUB_USER"
            git config user.email "$GITHUB_EMAIL"

            ###################################################
            # PYTHON DEPENDENCY RESTORATION
            ###################################################
            # After repository retrieval completes:
            #
            # 1. Activate virtual environment
            # 2. Upgrade pip
            # 3. Restore dependencies
            ###################################################

            echo -e "${PINK}[ + ] Giving your environment its memory back...${NC}"

            source "$TARGET_DIR/bin/activate"

            if [ -f requirements.txt ]; then

                echo -e "${PINK}[ + ] Ah... dependency list detected. I'll take care of it.${NC}"

                pip install --upgrade pip
                pip install -r requirements.txt

                echo -e "${GREEN}[ + ] Everything clicked perfectly into place.${NC}"

            else

                echo -e "${YELLOW}[ ! ] No requirements file detected. Nothing for me to install.${NC}"

            fi
            ;;

        *)

            echo -e "${PINK}[ - ] Alright, keeping my hands off this one.${NC}"
            exit 0
            ;;

    esac

############################################################
# REMOTE REPOSITORY DOES NOT EXIST
############################################################

else

    echo -e "${PINK}[ + ] I don't see this project in your cloud collection yet.${NC}"
    echo -e "${PINK}[ + ] Looks like I get to build something fresh with you...${NC}"

    git init

    git config user.name "$GITHUB_USER"
    git config user.email "$GITHUB_EMAIL"

    git config --global init.defaultBranch main

    ensure_github_repo_exists

    AUTH_REPO_URL="https://${GITHUB_USER}:${GITHUB_TOKEN}@github.com/${GITHUB_USER}/${TARGET_REPO}.git"

    git remote add origin "$AUTH_REPO_URL"

    ########################################################
    # BASE PROJECT ASSET GENERATION
    ########################################################

    echo -e "${PINK}[ + ] Arranging the furniture and making this place look presentable...${NC}"

    echo "# YotchApps | $TARGET_REPO" > README.md
    echo "Enterprise scaffolding initialized by N.A.T.H.A.L.I.E." >> README.md

    cat > .gitignore <<EOF
__pycache__/
.env
*.pyc
EOF

    source "$TARGET_DIR/bin/activate"

    git add .

    git commit -m "chore: automated genesis commit and scaffolding by N.A.T.H.A.L.I.E."

    git branch -M main

    echo -e "${PINK}[ + ] Sending your new creation up into the clouds...${NC}"

    git push -u origin main

fi

echo ""
echo -e "${GREEN}[ + ] Workspace deployed successfully.${NC}"

echo ""
echo -e "${PINK}[ + ] Your environment is ready, Yotch. Opening the doors...${NC}"

exec bash --rcfile <(
echo ". ~/.bashrc; source \"$TARGET_DIR/bin/activate\""
)

;;

  # ============================================================
  # PROTOCOL 2: COGNITIVE PUSH (THE GEMINI AI PIPELINE)
  # ============================================================

  2|02)
    echo -e "\n${YELLOW}[ ! ] Initializing version synchronization sequence...${NC}"
    
    if [ ! -d ".git" ]; then
        echo -e "${RED}[ - ] Validation failure: Hidden directory tracker '.git' not found in present working directory.${NC}"
        exit 1
    fi

    echo -e "${PINK}[ + ] Injecting local tracking parameters for identity assurance...${NC}"
    git config user.name "$GITHUB_USER"
    git config user.email "$GITHUB_EMAIL"

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
      echo -e "${PINK}[ - ] I noticed your core README.md documentation is missing.${NC}"
      if [ "$GEMINI_API_KEY" != "XXXXX" ]; then
          echo -e "${PINK}[ + ] Let me query my cognitive layers to write a beautiful description for you...${NC}"
          DIR_TREE=$(ls -1)
          
          README_PROMPT="You are an elite DevSecOps architect. Write a short, powerful, enterprise-grade description based on these files. Return ONLY the text, no markdown formatting or quotes. Files:"
          PAYLOAD=$(jq -n --arg prompt "$README_PROMPT" --arg tree "$DIR_TREE" '{ contents: [{ parts: [{ text: ($prompt + "\n\n" + $tree) }] }] }')
          
          AI_DESC=$(curl -s -X POST "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$GEMINI_API_KEY" -H "Content-Type: application/json" -d "$PAYLOAD" | jq -r '.candidates[0].content.parts[0].text')
          
          echo "# YotchApps | $TARGET_REPO" > README.md
          echo "$AI_DESC" >> README.md
          echo -e "${GREEN}[ + ] Structural documentation generated and saved successfully.${NC}"
      else
          echo -e "${PINK}[ + ] Defaulting to standard architectural template documentation...${NC}"
          echo "# YotchApps Framework" > README.md
          echo "An enterprise-grade software architecture." >> README.md
      fi
    fi

    echo -e "${PINK}[ + ] Gathering all your brilliant changes into the staging index...${NC}"
    git add .
    
    if git diff --cached --quiet; then
        echo -e "${PINK}[ - ] Your code matches the remote state exactly, Yotch. No changes to push today.${NC}"
        exit 0
    fi
    
    COMMIT_MSG=""
    if [ "$GEMINI_API_KEY" != "XXXXX" ]; then
        echo -e "${PINK}[ + ] Let me look over your code diff and formulate the perfect commit message...${NC}"
        DIFF_PREVIEW=$(git diff --cached | head -c 3000)
        
        COMMIT_PROMPT="You are an elite version control AI. Read this git diff and write a single, concise Conventional Commit message (e.g. feat: added holiday radar). Return ONLY the message string. Do not include markdown, quotes, or explanations. Diff:"
        PAYLOAD=$(jq -n --arg prompt "$COMMIT_PROMPT" --arg diff "$DIFF_PREVIEW" '{ contents: [{ parts: [{ text: ($prompt + "\n\n" + $diff) }] }] }')
        
        API_RESPONSE=$(curl -s -X POST "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$GEMINI_API_KEY" -H "Content-Type: application/json" -d "$PAYLOAD")
        COMMIT_MSG=$(echo "$API_RESPONSE" | jq -r '.candidates[0].content.parts[0].text' | tr -d '\n' | tr -d '"')
    fi
    
    if [ -z "$COMMIT_MSG" ] || [ "$COMMIT_MSG" == "null" ]; then
        COMMIT_MSG="Automated Push: $(date "+%Y-%m-%d %H:%M:%S") - Architecture sync"
    fi
    
    echo -e "${PINK}[ + ] Committing your blocks as: \"$COMMIT_MSG\"${NC}"
    git commit -m "$COMMIT_MSG"
    git branch -M main

    echo -e "${PINK}[ + ] Shipping the optimized payload up to the cloud storage hub...${NC}"
    if ! git push -u origin main > /dev/null 2>&1; then
      echo -e "${YELLOW}[ - ] Direct branch mismatch detected. Asserting your local timeline as absolute truth...${NC}"
      git push -u origin main --force
    fi
    echo -e "${GREEN}[ + ] Synchronization completed flawlessly. Remotes are aligned.${NC}"
    ;;

  # ============================================================
  # PROTOCOL 3: SECURE AUTOMATED PULL / CLONE
  # ============================================================
  
  3|03)
    echo -e "\n${PINK}[ ! ] Reaching out into your cloud repository vault, Yotch...${NC}"
    echo -e "${PINK}[ + ] Compiling public repository mappings under account '$GITHUB_USER'...${NC}"
    
    mapfile -t REPO_LIST < <(curl -s -H "Authorization: token $GITHUB_TOKEN" "https://api.github.com/users/$GITHUB_USER/repos?per_page=100" | jq -r '.[] | select(.private == false) | .name')
    
    if [ ${#REPO_LIST[@]} -eq 0 ]; then
        echo -e "${RED}[ - ] Retrieval breakdown: Profile index came back empty or access was denied.${NC}"
        exit 1
    fi
    
    echo -e "\n${CYAN}=================================================================================${NC}"
    echo -e "${CYAN}                           AVAILABLE REMOTE CLOUD TARGETS                        ${NC}"
    echo -e "${CYAN}=================================================================================${NC}"
    for i in "${!REPO_LIST[@]}"; do
        printf "  ${CYAN}[ %02d ]${NC} %s\n" "$((i+1))" "${REPO_LIST[$i]}"
    done
    echo -e "${CYAN}=================================================================================${NC}"
    echo ""
    
    read -p "Select corresponding target key identifier: " REPO_CHOICE
    
    if ! [[ "$REPO_CHOICE" =~ ^[0-9]+$ ]] || [ "$REPO_CHOICE" -le 0 ] || [ "$REPO_CHOICE" -gt "${#REPO_LIST[@]}" ]; then
        echo -e "${PINK}[ - ] That selection index doesn't exist in my system, Yotch. Dropping process.${NC}"
        exit 1
    fi
    
    TARGET_REPO="${REPO_LIST[$((REPO_CHOICE-1))]}"
    TARGET_DIR="$DEV_BASE_DIR/$TARGET_REPO"
    
    if [ -d "$TARGET_DIR" ]; then
        echo -e "${RED}[ - ] Target workspace destination folder '$TARGET_DIR' already physical. Operation blocked.${NC}"
        exit 1
    fi
    
    cd "$DEV_BASE_DIR"
    echo -e "${PINK}[ + ] Pulling down '$TARGET_REPO' and unpacking it into your workspace...${NC}"
    AUTH_REPO_URL="https://${GITHUB_USER}:${GITHUB_TOKEN}@github.com/${GITHUB_USER}/${TARGET_REPO}.git"
    
    git clone "$AUTH_REPO_URL"
    
    cd "$TARGET_DIR"
    git config user.name "$GITHUB_USER"
    git config user.email "$GITHUB_EMAIL"
    
    echo -e "${GREEN}[ + ] Down-link operational logic achieved. Your code is waiting for you in $TARGET_DIR.${NC}"
    ;;

  *)
    echo -e "${PINK}[ - ] I don't recognize that instruction code, Yotch. Safely dropping interface execution loops.${NC}"
    exit 1
    ;;
esac