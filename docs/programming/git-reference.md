# Git Quick Reference

A practical offline reference for Git version control.

---

## Setup and Configuration

```bash
# Identity (required before first commit)
git config --global user.name "Your Name"
git config --global user.email "you@example.com"

# Editor
git config --global core.editor "nano"     # or vim, code --wait

# Line endings
git config --global core.autocrlf input    # Linux/macOS
git config --global core.autocrlf true     # Windows

# Default branch name
git config --global init.defaultBranch main

# Useful settings
git config --global pull.rebase false      # merge on pull (default)
git config --global push.autoSetupRemote true   # auto track remote
git config --global rerere.enabled true    # remember conflict resolutions
git config --global diff.colorMoved zebra  # highlight moved lines

# View all config
git config --list
git config --global --edit                 # open config in editor
```

---

## Repository Basics

```bash
# Initialize new repo
git init
git init my-project              # creates directory and inits

# Clone existing
git clone https://github.com/user/repo.git
git clone git@github.com:user/repo.git       # SSH
git clone --depth 1 <url>                    # shallow clone (latest only, faster)
git clone --branch v2.0 <url>               # specific branch/tag

# Status
git status
git status -s                    # short format
```

---

## Basic Workflow

```bash
# Stage changes
git add file.txt                 # specific file
git add src/                     # directory
git add *.py                     # glob pattern
git add -p                       # interactive patch mode (stage hunks)

# Unstage
git restore --staged file.txt    # unstage (keep changes)
git reset HEAD file.txt          # older syntax, same effect

# Discard changes
git restore file.txt             # discard working tree changes
git checkout -- file.txt         # older syntax

# Commit
git commit -m "Add sensor reading function"
git commit                       # opens editor for message
git commit -am "Quick fix"       # stage tracked files + commit

# Amend last commit (before pushing)
git commit --amend               # change message or add files
git commit --amend --no-edit     # add staged changes, keep message
```

---

## Viewing History

```bash
# Log
git log                          # full log
git log --oneline                # compact (hash + message)
git log --oneline -10            # last 10 commits
git log --oneline --graph --all  # visual branch graph
git log --stat                   # show files changed per commit
git log --patch                  # show actual diffs
git log --author="Name"          # filter by author
git log --since="2024-01-01"     # filter by date
git log --grep="bugfix"          # search commit messages
git log -- path/to/file          # history of specific file
git log --follow -- file.txt     # follow renames

# Diff
git diff                         # unstaged changes
git diff --staged                # staged changes (about to commit)
git diff HEAD                    # all changes vs last commit
git diff main..feature           # between branches
git diff v1.0..v2.0              # between tags
git diff --stat                  # summary (files changed, insertions, deletions)
git diff --name-only             # just filenames

# Show specific commit
git show abc1234                 # show commit details + diff
git show HEAD                    # latest commit
git show HEAD:path/to/file       # file contents at commit

# Blame (who changed each line)
git blame file.txt
git blame -L 10,20 file.txt     # specific line range
```

---

## Branching

```bash
# List branches
git branch                       # local branches
git branch -a                    # local + remote
git branch -v                    # with last commit info

# Create branch
git branch feature-x             # create (don't switch)
git switch -c feature-x          # create and switch (modern)
git checkout -b feature-x        # create and switch (older)

# Switch branches
git switch main                  # modern
git checkout main                # older

# Rename branch
git branch -m old-name new-name
git branch -m new-name           # rename current branch

# Delete branch
git branch -d feature-x          # safe delete (only if merged)
git branch -D feature-x          # force delete

# Delete remote branch
git push origin --delete feature-x
```

---

## Merging

```bash
# Merge feature into main
git switch main
git merge feature-x              # creates merge commit (if needed)
git merge --no-ff feature-x      # always create merge commit
git merge --squash feature-x     # squash all commits into one, then commit

# Abort a merge in progress
git merge --abort
```

### Resolving Merge Conflicts

When Git cannot auto-merge, it marks conflicts in the file:

```
<<<<<<< HEAD
current branch content
=======
incoming branch content
>>>>>>> feature-x
```

Steps:
1. Open conflicted files and edit to resolve (remove markers, keep desired code)
2. `git add resolved-file.txt` (mark as resolved)
3. `git commit` (completes the merge)

```bash
# See conflicted files
git status

# Use a merge tool
git mergetool                    # opens configured merge tool

# Accept one side entirely
git checkout --ours file.txt     # keep current branch version
git checkout --theirs file.txt   # keep incoming branch version
```

---

## Rebasing

Rebase replays commits on top of another branch. Results in a linear history.

```bash
# Rebase feature branch onto latest main
git switch feature-x
git rebase main
# If conflicts: resolve, git add, git rebase --continue
# To abort: git rebase --abort

# Pull with rebase (instead of merge)
git pull --rebase origin main
```

### Interactive Rebase

Clean up commit history before merging:

```bash
git rebase -i HEAD~5             # rewrite last 5 commits
git rebase -i main               # rewrite all commits since main
```

In the editor, change commands for each commit:
- `pick` — keep as-is
- `reword` — change commit message
- `edit` — stop to amend
- `squash` — combine with previous commit (keep message)
- `fixup` — combine with previous (discard message)
- `drop` — remove commit
- Reorder lines to reorder commits

---

## Stash

Temporarily save uncommitted changes:

```bash
git stash                        # stash changes
git stash push -m "WIP: sensor refactor"  # with message
git stash list                   # list stashes
git stash pop                    # apply most recent + remove from stash
git stash apply                  # apply most recent (keep in stash)
git stash apply stash@{2}       # apply specific stash
git stash drop stash@{0}        # delete specific stash
git stash clear                  # delete all stashes
git stash show -p                # show stash diff
git stash push -p                # interactively stash specific hunks
```

---

## Tags

```bash
# List tags
git tag
git tag -l "v1.*"                # filter

# Create tags
git tag v1.0                     # lightweight tag
git tag -a v1.0 -m "Version 1.0 release"  # annotated (recommended)
git tag -a v1.0 abc1234          # tag a specific commit

# Push tags
git push origin v1.0             # push specific tag
git push origin --tags           # push all tags

# Delete tag
git tag -d v1.0                  # local
git push origin --delete v1.0    # remote

# Checkout tag
git checkout v1.0                # detached HEAD at tag
```

---

## Reset

```bash
# Soft reset: move HEAD, keep changes staged
git reset --soft HEAD~1          # undo last commit, changes stay staged

# Mixed reset (default): move HEAD, unstage changes
git reset HEAD~1                 # undo last commit, changes in working tree
git reset HEAD file.txt          # unstage file

# Hard reset: move HEAD, discard all changes
git reset --hard HEAD~1          # undo last commit AND discard changes
git reset --hard origin/main     # match remote exactly (DESTRUCTIVE)
```

---

## Cherry-Pick

Apply specific commits from another branch:

```bash
git cherry-pick abc1234          # apply one commit
git cherry-pick abc1234 def5678  # apply multiple
git cherry-pick abc1234..xyz9999 # apply range
git cherry-pick --no-commit abc1234  # apply without committing

# If conflicts: resolve, git add, git cherry-pick --continue
# To abort: git cherry-pick --abort
```

---

## Remote Management

```bash
# List remotes
git remote -v

# Add remote
git remote add origin https://github.com/user/repo.git
git remote add upstream https://github.com/original/repo.git

# Change remote URL
git remote set-url origin git@github.com:user/repo.git

# Remove remote
git remote remove upstream

# Fetch and push
git fetch origin                 # download changes (don't merge)
git fetch --all                  # from all remotes
git push origin main             # push to remote
git push -u origin feature-x    # push and set upstream tracking
git push --force-with-lease     # safer than --force (checks remote hasn't changed)
```

---

## .gitignore

```gitignore
# Compiled files
*.o
*.pyc
__pycache__/
*.class

# Build output
build/
dist/
*.bin
*.hex
*.elf

# IDE files
.vscode/
.idea/
*.swp
*.swo
*~

# OS files
.DS_Store
Thumbs.db

# Secrets (NEVER commit these)
.env
*.pem
*.key
credentials.json

# Dependencies
node_modules/
venv/

# Patterns
!important.o          # negate: DO track this file
logs/*.log            # only in logs/ directory
**/temp/              # any directory named temp
doc/*.txt             # only in doc/ (not doc/sub/)
doc/**/*.txt          # in doc/ and all subdirectories
```

```bash
# Ignore already-tracked file
git rm --cached file.txt         # stop tracking (keep local file)
echo "file.txt" >> .gitignore

# Global gitignore
git config --global core.excludesFile ~/.gitignore_global
```

---

## Bisect (Find Bug-Introducing Commit)

Binary search through history to find which commit introduced a bug:

```bash
git bisect start
git bisect bad                   # current commit is bad
git bisect good v1.0             # v1.0 was good

# Git checks out a middle commit. Test it, then:
git bisect good                  # if this commit works
git bisect bad                   # if this commit has the bug
# Repeat until Git identifies the first bad commit

git bisect reset                 # return to original HEAD

# Automated bisect with a test script
git bisect start HEAD v1.0
git bisect run ./test.sh         # script exits 0=good, 1=bad
```

---

## Submodules

Include another Git repo inside yours:

```bash
# Add submodule
git submodule add https://github.com/user/lib.git libs/lib

# Clone repo with submodules
git clone --recurse-submodules <url>

# If already cloned without submodules
git submodule update --init --recursive

# Update submodule to latest
cd libs/lib
git pull origin main
cd ../..
git add libs/lib
git commit -m "Update lib submodule"

# Update all submodules
git submodule update --remote --merge
```

---

## Useful Aliases

Add to `~/.gitconfig` under `[alias]`:

```ini
[alias]
    st = status -s
    co = checkout
    sw = switch
    br = branch
    ci = commit
    lg = log --oneline --graph --all --decorate
    last = log -1 HEAD --stat
    unstage = restore --staged
    undo = reset --soft HEAD~1
    amend = commit --amend --no-edit
    aliases = config --get-regexp alias
    branches = branch -a -v
    tags = tag -l
    stashes = stash list
    wip = !git add -A && git commit -m 'WIP'
    whoami = !echo "$(git config user.name) <$(git config user.email)>"
```

---

## SSH Key Setup (GitHub / GitLab)

```bash
# Generate SSH key
ssh-keygen -t ed25519 -C "your@email.com"
# Accept default location (~/.ssh/id_ed25519)
# Set passphrase (optional but recommended)

# Start SSH agent and add key
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

# Copy public key
cat ~/.ssh/id_ed25519.pub
# Paste this into GitHub > Settings > SSH Keys

# Test connection
ssh -T git@github.com

# Use SSH URL for repos
git remote set-url origin git@github.com:user/repo.git
git clone git@github.com:user/repo.git
```

### SSH Config (~/.ssh/config)

```
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519

Host gitlab.com
    HostName gitlab.com
    User git
    IdentityFile ~/.ssh/id_ed25519_gitlab

# Short alias for a server
Host mypi
    HostName 192.168.1.50
    User pi
    IdentityFile ~/.ssh/id_ed25519
```

---

## Common Workflows

### Feature Branch Workflow

```bash
# 1. Start from updated main
git switch main
git pull origin main

# 2. Create feature branch
git switch -c feature/add-sensor-logging

# 3. Work and commit
git add src/sensor.py
git commit -m "Add temperature logging to sensor module"
git add tests/test_sensor.py
git commit -m "Add tests for sensor logging"

# 4. Stay updated with main
git fetch origin
git rebase origin/main            # or: git merge origin/main

# 5. Push feature branch
git push -u origin feature/add-sensor-logging

# 6. Create pull request (on GitHub/GitLab)

# 7. After PR is merged, clean up
git switch main
git pull origin main
git branch -d feature/add-sensor-logging
```

### Fork and Pull Request Workflow

```bash
# 1. Fork on GitHub (web UI)

# 2. Clone your fork
git clone git@github.com:youruser/repo.git
cd repo

# 3. Add upstream remote
git remote add upstream git@github.com:original/repo.git

# 4. Create feature branch
git switch -c fix/typo-in-docs

# 5. Work and commit
git add .
git commit -m "Fix typo in installation docs"

# 6. Push to your fork
git push -u origin fix/typo-in-docs

# 7. Create PR from your fork to upstream (web UI)

# 8. Sync your fork with upstream
git switch main
git fetch upstream
git merge upstream/main
git push origin main
```

### Quick Fixes Workflow

```bash
# Stash current work
git stash push -m "WIP: sensor refactor"

# Switch and fix
git switch main
git switch -c hotfix/null-pointer
# fix the bug...
git commit -am "Fix null pointer in MQTT handler"
git push -u origin hotfix/null-pointer

# Return to work
git switch feature-branch
git stash pop
```
