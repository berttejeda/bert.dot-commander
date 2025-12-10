<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [Overview](#overview)
- [Design](#design)
    - [Features](#features)
- [Script Organization](#script-organization)
    - [Creating Scripts](#creating-scripts)
    - [Scanning Directories](#scanning-directories)
- [Usage Examples](#usage-examples)
- [Configuration](#configuration)
- [Installation](#installation)
    - [Prerequisites](#prerequisites)
    - [ops](#ops)
- [Appendix](#appendix)
    - [Sub-Command Naming Logic](#sub-command-naming-logic)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

<a name="top"></a>
<a name="overview"></a>

# Overview

As systems engineers, we spend much of our time on our command-line terminals
interacting with a myriad of systems in support of the overarching infrastructure.

Our daily tasks can often be repetitive, 
which is why we often find ourselves utilizing 
or creating automation to lessen our keystrokes.

This brings us to a question:

- _What do you get when each member of a team of engineers has an affinity
  for creating their own little scripts to make their lives easier?_<br />
  Hint: It's something messy.
  
The *ops* tool aims to clean up this proclivity for command-line mess in the team setting
by unifying disparate pieces of automation into a single entrypoint, thus 
creating a homogenous command-line experience.

This is accomplished by a simple shell script that automatically discovers executables
organized in directories and creates wrapper scripts with dot-notation naming,
making them easily accessible from anywhere.

The following sections go over this in detail.

<a name="design"></a>
# Design

The *ops* tool is a bash/zsh-compatible shell script that:

- Scans directories recursively for executable files
- Automatically creates wrapper scripts for discovered executables
- Generates aliases for quick access to commands
- Supports namespace organization via configuration or git repository detection
- Creates a unified command index in YAML format

<a name="features"></a>
## Features

  - Commands are executables organized by subfolders in a scanned directory<br />
    (See the Appendix for list of supported executable types)
  - Subfolders are interpreted as namespace components for<br />
    the given scripts/executables contained therein
  - Subcommands follow a dot-notation style of reference, e.g.<br />
    _namespace.folder.subfolder.command_<sup> [1](#sub-command-naming-logic)</sup>
  - Automatic namespace detection from `.ops-command.yaml` or git repository name
  - Automatic wrapper script generation in `${HOME}/ops-command/bin`
  - Automatic alias generation for shell init files (`~/.bashrc`, `~/.zshrc`)
  - Built-in function library automatically sourced during initialization
  - By default, aliases exclude namespace prefix for easier command access

<a name="installation"></a>
# Installation

<a name="prerequisites"></a>
## Prerequisites

You'll need:

- **bash** or **zsh** shell
- **yq** - A YAML processor (for parsing command index)
  - Install via package manager:
    - macOS: `brew install yq`
    - Linux: `apt-get install yq` or `yum install yq`
    - Or download from [https://github.com/mikefarah/yq](https://github.com/mikefarah/yq)

<a name="ops"></a>
## Installing ops

### Quick Install (Recommended)

The easiest way to install ops is using the one-line installer:

```bash
bash < <(curl -s -S -L https://raw.githubusercontent.com/berttejeda/bert.ops-command/master/binscripts/ops-installer)
```

This will:
- Download and install `ops` to `/usr/local/bin`
- Automatically initialize ops
- Update your shell profile files (`.bashrc`, `.zshrc`, or `.profile`)
- Set up the PATH configuration

After installation, reload your shell:
```bash
source ~/.bashrc  # or source ~/.zshrc
```

### Manual Installation

If you prefer to install manually:

1. **Clone or download the repository**:
   ```bash
   git clone https://github.com/berttejeda/bert.ops-command.git
   cd bert.ops-command
   ```

2. **Make the script executable**:
   ```bash
   chmod +x ops
   ```

3. **Add to your PATH** (optional but recommended):
   ```bash
   # Option 1: Symlink to a directory in your PATH
   sudo ln -s $(pwd)/ops /usr/local/bin/ops
   
   # Option 2: Add the directory to your PATH
   # Add this to your ~/.bashrc or ~/.zshrc:
   export PATH="$PATH:/path/to/bert.ops-command"
   ```

4. **Initialize ops**:
   ```bash
   ops ---init
   ```

   This will:
   - Create the ops-command workspace directory at `${HOME}/ops-command`
   - Add initialization blocks to your `~/.bashrc` and `~/.zshrc`
   - Set up the PATH to include `${HOME}/ops-command/bin`
   - Source functions from `${HOME}/ops-command/lib/functions` (if installed)

5. **Reload your shell** or source your init file:
   ```bash
   source ~/.bashrc  # or source ~/.zshrc
   ```

The next section will cover script organization and usage.

[Back to Top](#top)
<a name="script-organization"></a>
# Script Organization

ops works by scanning directories for executable files and creating wrapper scripts
that can be invoked using dot-notation.

<a name="creating-scripts"></a>
## Creating Scripts

Scripts are really easy to create - they are simply executable 
files organized into folders. The folder structure determines the command namespace.

You need only enough proficiency to write a script in bash, zsh, python, powershell, 
or any other language that supports shebangs (e.g., `#!/usr/bin/env bash`).

**Requirements for scripts to be discovered:**

1. The file must be executable (`chmod +x script.sh`)
2. The file must have a shebang on line 1 (e.g., `#!/usr/bin/env bash`)
3. Files in certain directories are automatically excluded (see [Configuration](#configuration) section)

**Example script structure:**

```
~/scripts/
├── git/
│   ├── create-issue-branch.sh
│   └── get-bitbucketfile.ps1
├── k8s/
│   ├── trigger-rolling-update.sh
│   └── get-stats.sh
└── aws/
    └── query.py
```

<a name="scanning-directories"></a>
## Scanning Directories

To make your scripts available via ops, simply scan the directory containing them:

```bash
ops ---scan ~/scripts
```

This will:
- Initialize ops if not already done
- Scan `~/scripts` recursively for executable files
- Create wrapper scripts in `${HOME}/ops-command/bin`
- Generate a command index in YAML format
- Create aliases in your shell init files

After scanning, you can view available commands:

```bash
ops ---help
```

And execute them using dot-notation:

```bash
ops git.create-issue-branch
ops k8s.trigger-rolling-update
ops aws.query
```

[Back to Top](#top)
<a name="usage-examples"></a>
# Usage Examples

## Basic Usage

**Initialize ops:**
```bash
ops ---init
```

**Scan a directory for scripts:**
```bash
ops ---scan ~/my-scripts
```

**View available commands:**
```bash
ops ---help
```

**Update command repositories:**
```bash
ops ---update-command-repos
```

**Check for updates:**
```bash
ops ---update
```

**Execute a command:**
```bash
ops git.create-issue-branch feature/new-feature
```

**Execute a nested command:**
```bash
# For a file at ~/scripts/remote/dev/test.sh
ops remote.dev.test
```

## Namespace Configuration

**Using `.ops-command.yaml`:**

Create a `.ops-command.yaml` file in your scripts directory:

```yaml
commands:
  namespace: 'myproject'
aliases:
  namespace: 'myops'  # Optional: prefix for aliases
```

Then scan the directory:
```bash
ops ---scan ~/scripts
```

**Automatic Git Repository Detection:**

If your scripts directory is a git repository, ops will automatically use
the repository name as the command namespace.

See the [Configuration](#configuration) section for details on alias prefixes and the [Sub-Command Naming Logic](#sub-command-naming-logic) section for complete naming details.

## Command Reference

### Available Flags

- `ops ---init`: Initialize the script's internal config
- `ops ---scan <target_dir>`: Initialize and scan the target directory for executables
- `ops ---help`: Show help message with available commands
- `ops ---version`: Show version information
- `ops ---completion`: Generate and install shell completion scripts
- `ops ---update`: Check for updates and update ops and command repositories
- `ops ---update-command-repos`: Update local command repositories only (without checking for ops updates)

[Back to Top](#top)
<a name="configuration"></a>
# Configuration

## Environment Variables

ops can be configured using the following environment variables:

### `OPSC_WORKSPACE_DIR`

Sets the workspace directory where ops stores its data. Defaults to `${HOME}/ops-command`.

```bash
export OPSC_WORKSPACE_DIR="${HOME}/my-custom-ops-workspace"
```

### `OPSC_EXCLUDE_DIRS`

Configures which directory patterns to exclude during scanning. Defaults to:
- `*/node_modules/*`
- `*/.git/*`
- `*/venv/*`
- `*/lib/*`
- `*/dist/*`

To customize excluded directories:

```bash
export OPSC_EXCLUDE_DIRS=("*/node_modules/*" "*/.git/*" "*/custom_dir/*")
ops ---scan ~/scripts
```

### `OPSC_ALIAS_PREFIX`

Optional prefix for generated aliases. By default, aliases exclude the command namespace prefix for easier access. If `OPSC_ALIAS_PREFIX` is set, it will be added as a prefix to aliases.

**Setting via environment variable:**
```bash
export OPSC_ALIAS_PREFIX="myops"
```

**Setting via `.ops-command.yaml`:**

You can also configure the alias prefix per repository using the `.aliases.namespace` key in `.ops-command.yaml`:

```yaml
aliases:
  namespace: 'myops'  # Sets OPSC_ALIAS_PREFIX for this repository
```

**Priority:**
- Environment variable `OPSC_ALIAS_PREFIX` takes precedence over config file
- If not set via environment variable, the value from `.aliases.namespace` in `.ops-command.yaml` is used
- If neither is set, aliases are created without a prefix

See the [Sub-Command Naming Logic](#sub-command-naming-logic) section for examples of how aliases are generated.

[Back to Top](#top)
<a name="appendix"></a>
# Appendix

<a name="sub-command-naming-logic"></a>
## Sub-Command Naming Logic

As mentioned in the previous sections, commands follow a dot-notation style of reference.

The naming convention works as follows:

**Wrapper Script Names** (used for the actual script files in `${HOME}/ops-command/bin`):

1. **If a command namespace is defined** (via `.commands.namespace` in `.ops-command.yaml` or git repository):
   - Format: `namespace.folder.subfolder.command.sh`
   - Example: `myproject.git.create-issue-branch.sh`

2. **If no command namespace is defined**:
   - Format: `folder.subfolder.command.sh`
   - Example: `git.create-issue-branch.sh`

3. **For nested paths**:
   - A file at `~/scripts/remote/dev/test.sh` becomes:
     - With namespace: `namespace.remote.dev.test.sh`
     - Without namespace: `remote.dev.test.sh`

4. **Files in the root of the scanned directory**:
   - Become `namespace.root.scriptname.sh` (with namespace)
   - Or `root.scriptname.sh` (without namespace)

**Aliases** (created in your shell init files):

Aliases are automatically created in your shell init files (`~/.bashrc`, `~/.zshrc`) after scanning. They exclude the command namespace prefix for easier access:

- Wrapper: `myproject.git.create-issue-branch.sh` → Alias: `git.create-issue-branch`
- Wrapper: `git.create-issue-branch.sh` → Alias: `git.create-issue-branch`

**With alias prefix configured:**

If `OPSC_ALIAS_PREFIX` is set (via environment variable or `.aliases.namespace` in `.ops-command.yaml`):
- Wrapper: `myproject.git.create-issue-branch.sh` → Alias: `myops.git.create-issue-branch` (if prefix is `myops`)
- The alias prefix is added, but the command namespace is still excluded

This allows you to use commands without typing the command namespace, while wrapper scripts remain organized with namespaces. The alias prefix provides an optional way to group aliases from different repositories.

### Supported Executable Types

ops supports any executable file with a shebang, including:

- **Shell scripts**: `#!/usr/bin/env bash`, `#!/usr/bin/env zsh`, `#!/usr/bin/env sh`
- **Python scripts**: `#!/usr/bin/env python`, `#!/usr/bin/env python3`
- **PowerShell scripts**: `#!/usr/bin/env pwsh`
- **Other interpreted languages**: Any executable with a valid shebang

Binary executables without shebangs are skipped during scanning.

### Built-in Functions

ops includes a functions library that is automatically sourced during initialization.
Functions are located in `${HOME}/ops-command/lib/functions` and are sourced automatically
when your shell initializes.

**Available Functions:**

- `secret.set <variable_name>`: Prompts for a secret value and sets it as an environment variable
  ```bash
  secret.set MY_API_KEY
  # Prompts: "Enter in value for the variable 'MY_API_KEY': "
  # Sets MY_API_KEY environment variable
  ```

Additional functions can be added by placing `.sh` files in the `lib/functions` directory.
These will be automatically sourced on the next initialization.

[Back to Top](#top)
