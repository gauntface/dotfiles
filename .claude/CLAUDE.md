# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

Matt's personal dotfiles and machine-bootstrap scripts. It provisions a fresh
machine (packages, shell, git/GitHub SSH, editor, dock/wallpaper, etc.) and is
designed to run unattended-ish across:

- **macOS** (`Darwin`)
- **Debian / Ubuntu** Linux
- **Fedora** Linux
- **Remote/headless Linux** machines reached over SSH (no X11/Wayland display,
  no GNOME session) — a first-class target, not an afterthought. Anything that
  assumes a display, clipboard tool, or desktop session must degrade
  gracefully on these.

There is no build system, package manager, test suite, or CI here — it's pure
bash. "Testing" a change means syntax-checking and dry-running the affected
function, e.g.:

```bash
bash -n steps/some-step.sh          # syntax check
bash -c 'source libs/logging.sh; source steps/some-step.sh; someFunc args'
```

## Entry points

- **`bootstrap.sh`** — the one-liner curl'd by a brand-new machine (see
  README.md). Downloads a tarball of this repo to `~/Downloads`, unpacks it,
  and execs `install.sh`. Has no access to anything else in the repo at
  runtime other than what's in the tarball.
- **`install.sh`** — the main installer. Sources everything under `libs/` and
  `steps/`, then calls the step functions in a fixed order. This is the file
  that encodes "what happens and in what order" — read it first when tracing
  behavior.
- **`reinstall-check.sh`** — run *before* wiping/reinstalling the OS on an
  existing machine. Checks for uncommitted git work under `~/Projects`, dumps
  the current GNOME terminal profile back into `data/`, and diffs
  installed packages / dock favorites / wallpaper against what's checked in,
  so drift gets caught before it's lost.

## Architecture

**`libs/`** — low-level primitives sourced by both `install.sh` and
`reinstall-check.sh`:

- `logging.sh` — the trickiest file in the repo. `install.sh` redirects all of
  stdout/stderr to a temp log file (`initLogging`), so anything meant for the
  human overrides the builtin `echo` to bounce through `/dev/tty` via
  `enableTTY`/`disableTTY` (save fd 1/2, point them at the tty, restore them).
  **Any new step that needs to show output or read input must use `echo` /
  wrap interactive commands in `enableTTY`/`disableTTY`** — writing straight
  to stdout (`cat`, `printf`, etc.) silently vanishes into the log file
  instead of reaching the terminal. `logTitle`/`logDone`/`logStepDone`/
  `logWarning` are the standard step-lifecycle log calls.
- `error-handling.sh` — global `ERR`/`EXIT` trap that prints the failing
  line/command and points the user at `$ERROR_LOG` before exiting.
- `optional-step.sh` — `optionalStep "description" someFunc` prompts
  yes/no and only runs `someFunc` on yes. Used to gate anything non-essential
  or disruptive (installing Chrome/VSCode/Docker, udev rules, private
  dotfiles).
- `directories.sh` — `setupDirectories` sets the global path variables
  (`PROJECTS_DIR`, `TOOLS_DIR`, `CODE_DIR`, `DOTFILES_DIR`, `DATA_DIR`,
  `PRIV_DOTFILES_DIR`) that every step under `steps/` reads.

**`steps/`** — one file per concern, each defining a function (or small family
of functions) that `install.sh` sources and calls in sequence. Conventions to
follow when adding/editing a step:

- **Idempotent**: check whether the thing already exists/is installed before
  doing anything (e.g. `createGitHubKey` in `setup-github.sh` bails if the key
  file exists; `installOhMyZSH` in `install-zsh.sh` bails if `~/.oh-my-zsh`
  exists).
- **OS-branch on the global `$OS`**, set once by `steps/init-os.sh`
  (`initOSVar`) to `uname -s`, refined on Linux with
  `/etc/os-release`'s `NAME` — e.g. `"Darwin"`, `"Linux - Fedora Linux"`,
  `"Linux - Ubuntu"`. Steps `case` on this, usually matching
  `"Linux - Ubuntu"* | "Linux - Debian"*`, `"Linux - Fedora"*`, and
  `Darwin*)` separately (see `install-deps.sh`, `update.sh`, `setup-github.sh`).
- **Never hard-require a display or desktop session.** Several steps are
  GNOME/desktop-specific by nature (`gnome-terminal.sh`, `setup-gnome-dock.sh`,
  `setup-wallpaper.sh`, `setup-udev.sh`) and only fire on matching OS branches,
  but `install.sh` calls them unconditionally — they aren't wrapped in a
  headless/remote check. `gnome-terminal.sh` shows the right defensive
  pattern (`command -v dconf` guard + `logWarning` + early return instead of
  failing); prefer that pattern over letting a missing display/tool crash the
  whole install via `set -euo pipefail`. `setup-github.sh`'s
  `copyToClipboard` is the reference implementation for "best-effort local
  action, always leave the user a manual fallback": it tries an OSC 52
  terminal escape (works over SSH on supporting terminals) opportunistically,
  then `wl-copy`/`xclip` only if a display and the binary are actually
  present, and otherwise prints the value to the terminal for the user to
  copy by hand.

**`data/`** — the actual dotfile payloads (`zsh`, `git`, `bazel`,
`gnome-terminal`, `gnome-dock`, `udev`, `wallpaper`, `terminal`) that steps
symlink or write into `$HOME`. When a step needs "the checked-in version of
X", it lives here.

**`dependencies/`** — OS package lists consumed by `steps/install-deps.sh`:
`linux-packages.txt` (shared across all Linux), `debian-packages.txt` /
`fedora-packages.txt` (OS-specific additions), `fedora-packages.query.txt`,
and `Brewfile` for macOS. `dependencies/README.md` documents any non-obvious
package (e.g. why `util-linux-user` is needed for `chsh`).

## Private dotfiles

`setup-private-dotfiles.sh` clones a separate `private-dotfiles` repo into
`~/Projects/Tools/private-dotfiles` and execs its own `setup.sh` — that repo
is out-of-tree and not part of this codebase.
