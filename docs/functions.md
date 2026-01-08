# Functions Reference

See `~/.config/zsh/functions/` for complete implementation.

## General Functions

### File Operations
- `e [path]` - Open editor at path (or current directory if no path)
- `t2s <file> [spaces]` - Convert tabs to spaces in file (default: 2 spaces)
- `extract <file>` - Extract any archive format
- `delete_files [pattern]` - Delete files matching pattern (default: *.DS_Store)

### System
- `u` - Update all package managers (apt, brew, npm, fish, pip, etc.)
- `brew-update` - Update Homebrew and packages
- `mkd <dir>` - Make directory and cd into it
- `cype <command>` - Colorized version of `type` command

### File Information
- `hrfs <bytes>` - Convert bytes to human-readable file size
- `gz <file>` - Get gzip information (size and compression ratio)
- `datauri <file>` - Create data URI from file
- `iso <source> <name>` - Create ISO image from mounted volume (macOS)

### Process Management
- `kilp <query> [signal]` - Kill process by name/pattern
- `is_running <process>` - Check if process is running
- `port <number>` - List file activity on given port

### Utilities
- `qt <text>` - Search for text in current directory
- `transfer <file>` - Upload file to transfer.sh
- `ppi [pattern] [size]` - Process phone images (resize with ImageMagick)

### History
- `ghf [command] [number]` - Grep history for top 10 commands

## Git Functions

### Repository Info
- `ginfo` - Print comprehensive repository overview
- `gstats` - Answer statistics for current project
- `gstatsa` - Statistics for all projects in directory

### Branches
- `gbl` - List branches with details
- `gblo [author]` - List branches owned by author
- `gbla` - List current branch for all projects
- `gbs` - Interactive branch switcher
- `gbc <name>` - Create and switch to new branch
- `gbf <name>` - Duplicate current branch with new name
- `gbd` - Delete branch (interactive)
- `gbdl <branch>` - Delete local branch
- `gbdr <branch>` - Delete remote branch
- `gbdm` - Delete merged branches
- `gbr <name>` - Rename current branch
- `gbna` - Number of branches for all projects

### Commits
- `gcb [label]` - Create breakpoint commit
- `gcfi` - Interactive commit fix
- `gcff <file>` - Create fixup commit for file
- `gcfp <sha>` - Create fixup, push, and copy URL
- `gcaa` - Commit all projects in directory
- `gcap` - Commit and push all projects

### Log & History
- `gli` - Interactive log for feature branch
- `gld` - Log details for current branch
- `ghow [commit]` - Show commit details
- `gile <file> <commit>` - Show file details for commit
- `gistory <file>` - View file commit history
- `glameh <file> [lines]` - View file blame history
- `ghurn` - Answer commit churn for files
- `gount` - Total number of commits
- `guthors` - Commit activity by author
- `guthorsa` - Author activity for all projects
- `guthorc [author]` - Author contribution stats

### Stash
- `gash [label]` - Create stash with label
- `gashl` - List stashes
- `gashs [d|t]` - Show/diff stash
- `gashp` - Pop stash
- `gashd` - Drop stash
- `gasha` - Stash count for all projects

### Remote & Sync
- `gup` - Fetch, review, and pull updates
- `gync` - Sync remote changes and delete merged branches
- `gra <url> [name]` - Add remote repository
- `gpua` - Pull for all projects
- `gpa` - Push for all projects
- `gpob` - Push current branch and set upstream
- `gucca` - Upstream commit count for all projects

### Status & Changes
- `gsa` - Status for all projects with changes
- `galla` - Add all changes for all projects
- `gvac` - Verify and clean repository
- `gvaca` - Verify and clean all projects
- `gleana` - Clean uncommitted files for all projects
- `glear` - Clear repository for packaging

### Reset & Cleanup
- `gess [value]` - Reset soft (commits or SHA)
- `gesh [value]` - Reset hard (commits or SHA) **DESTRUCTIVE**
- `gesha [value]` - Reset hard for all projects **DESTRUCTIVE**
- `guke <file>` - Permanently delete file from history **UNRECOVERABLE**

### Tags
- `gtagr <version> <notes> [date]` - Rebuild tag
- `gtagd <tag>` - Delete local and remote tag
- `gtail` - Commits since last tag
- `gtaila` - Commit count since last tag for all projects

### Worktrees
- `gwa <name> <option>` - Add worktree (d=detach, r=remote, l=local)
- `gwd` - Delete current worktree

### Configuration
- `gseta <key> <value>` - Set config value for all projects
- `ggeta <key>` - Get config value for all projects
- `gunseta <key>` - Unset config value for all projects
- `gailsa <email>` - Set email for all projects
- `gail` - Get email for current project
- `gaila` - Get email for all projects

### Time-based Views
- `gince <since> [until] [author]` - Activity since date
- `gday` - Activity since midnight
- `gweek` - Activity since last Monday
- `gmonth` - Activity since 1 month ago
- `gsup` - Standup (activity since yesterday)

## GitHub Functions

- `gh [option]` - GitHub repository browser
  - `o` - Open repository
  - `i` - Open issues
  - `c [hash]` - Open commits (or specific commit)
  - `f <file> [lines]` - Copy file URL
  - `b [c|d|r]` - Branches (c=current, d=diff, r=PR)
  - `t` - Open tags
  - `r [number|l]` - Pull requests (number=specific, l=list)
  - `w` - Open wiki
  - `p` - Open pulse
  - `g` - Open graphs
  - `s` - Open settings
  - `u [hash|l]` - Copy URL (hash=commit, l=last commit)
- `ghpra` - Open PRs for all non-master branches

## Emoji-log Functions

Conventional commits with emoji:
- `gnew "message"` - 📦 NEW
- `gimp "message"` - 👌 IMPROVE
- `gfix "message"` - 🐛 FIX
- `grlz "message"` - 🚀 RELEASE
- `gdoc "message"` - 📖 DOC
- `gtst "message"` - 🤖 TEST
- `gbrk "message"` - ‼️ BREAKING
- `gtype` - Show emoji-log types

## Tool Functions

### Piknik
- `pko <content>` - Copy content to clipboard
- `pkf <file>` - Copy file to clipboard
- `pkfr [dir]` - Send directory as tar archive

### Overmind
- `oms [port]` - Start processes (default port: 2990)
- `omc [process]` - Connect to process (default: web)
- `omr [process]` - Restart process (default: web)

### Asciinema
- `cinr <label>` - Create new recording

### OpenSSL
- `sslc <domain>` - Create SSL certificate

### Curl
- `curli <url>` - Inspect remote file in editor
- `curld <url>` - Curl with diagnostic information

### License Finder
- `licensei <license> <why>` - Include license in global list
- `licensea <library> <why>` - Add library to global list

### Less
- `lessi <file>` - Inspect file interactively
