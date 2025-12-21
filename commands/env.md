# Plugin: Manage Environments

Manage environments and configuration.

## Interactive Flow

### Step 1: Load Config
Read `.claude/yaccp/aws-static-site/config.json`

### Step 2: Select Action
Use AskUserQuestion:
- "List environments"
- "Switch environment"
- "Create new environment"
- "Edit environment"
- "Delete environment"

### Step 3: Execute Action
Handle the selected action accordingly.

### Step 4: Save Config
Update config.json with changes.
