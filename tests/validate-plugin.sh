#!/bin/bash

# Validate plugin structure and configuration
# Usage: ./tests/validate-plugin.sh

set -e

PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PLUGIN_NAME="yaccp-aws-static-site"
ERRORS=0
WARNINGS=0

echo "Validating plugin: $PLUGIN_NAME"
echo "================================"
echo ""

# Check required files
check_file() {
    local file="$1"
    local required="$2"
    if [ -f "$PLUGIN_DIR/$file" ]; then
        echo "✓ $file"
        return 0
    else
        if [ "$required" = "required" ]; then
            echo "✗ $file (MISSING - required)"
            ((ERRORS++))
        else
            echo "○ $file (missing - optional)"
            ((WARNINGS++))
        fi
        return 1
    fi
}

# Check required directories
check_dir() {
    local dir="$1"
    if [ -d "$PLUGIN_DIR/$dir" ]; then
        echo "✓ $dir/"
        return 0
    else
        echo "✗ $dir/ (MISSING)"
        ((ERRORS++))
        return 1
    fi
}

echo "Structure"
echo "---------"
check_dir ".claude-plugin"
check_file ".claude-plugin/plugin.json" required
check_file ".claude-plugin/marketplace.json" required
check_dir "commands"
check_dir "skills"
check_file "LICENSE" required
check_file "README.md" required
check_file "CLAUDE.md" required
check_file "CHANGELOG.md" required
check_file ".gitignore" optional
check_file ".editorconfig" optional

echo ""
echo "Commands"
echo "--------"
for cmd in env init deploy status doctor destroy invalidate; do
    check_file "commands/${PLUGIN_NAME}-${cmd}.md" required
done

echo ""
echo "Skills"
echo "------"
check_dir "skills/${PLUGIN_NAME}"
check_file "skills/${PLUGIN_NAME}/SKILL.md" required

echo ""
echo "Documentation"
echo "-------------"
check_file "docs/ARCHITECTURE.md" optional
check_file "docs/CONTRIBUTING.md" optional
check_file "INSTALLATION.md" optional

echo ""
echo "Assets"
echo "------"
check_dir "assets/diagrams"
check_file "assets/diagrams/architecture.mmd" optional
check_file "assets/diagrams/architecture.svg" optional
check_file "assets/diagrams/workflow.mmd" optional
check_file "assets/diagrams/workflow.svg" optional

echo ""
echo "GitHub"
echo "------"
check_dir ".github"
check_file ".github/ISSUE_TEMPLATE/bug_report.md" optional
check_file ".github/ISSUE_TEMPLATE/feature_request.md" optional
check_file ".github/pull_request_template.md" optional

echo ""
echo "JSON Validation"
echo "---------------"

# Validate plugin.json
if [ -f "$PLUGIN_DIR/.claude-plugin/plugin.json" ]; then
    if jq empty "$PLUGIN_DIR/.claude-plugin/plugin.json" 2>/dev/null; then
        NAME=$(jq -r '.name' "$PLUGIN_DIR/.claude-plugin/plugin.json")
        VERSION=$(jq -r '.version' "$PLUGIN_DIR/.claude-plugin/plugin.json")
        echo "✓ plugin.json valid (name: $NAME, version: $VERSION)"

        if [ "$NAME" != "$PLUGIN_NAME" ]; then
            echo "  ⚠ Warning: name should be '$PLUGIN_NAME'"
            ((WARNINGS++))
        fi
    else
        echo "✗ plugin.json invalid JSON"
        ((ERRORS++))
    fi
fi

# Validate marketplace.json
if [ -f "$PLUGIN_DIR/.claude-plugin/marketplace.json" ]; then
    if jq empty "$PLUGIN_DIR/.claude-plugin/marketplace.json" 2>/dev/null; then
        echo "✓ marketplace.json valid"
    else
        echo "✗ marketplace.json invalid JSON"
        ((ERRORS++))
    fi
fi

echo ""
echo "README Sections"
echo "---------------"

if [ -f "$PLUGIN_DIR/README.md" ]; then
    check_section() {
        local section="$1"
        if grep -q "$section" "$PLUGIN_DIR/README.md"; then
            echo "✓ $section"
        else
            echo "○ $section (missing)"
            ((WARNINGS++))
        fi
    }

    check_section "## Features"
    check_section "## Quick Start"
    check_section "## Commands"
    check_section "## Interactive Prompts"
    check_section "## Architecture"
    check_section "## Security"
    check_section "## Cost Estimation"
    check_section "## Troubleshooting"
    check_section "## CI/CD Integration"
fi

echo ""
echo "================================"
echo "Validation Complete"
echo ""
echo "Errors:   $ERRORS"
echo "Warnings: $WARNINGS"

if [ $ERRORS -gt 0 ]; then
    echo ""
    echo "Status: FAILED"
    exit 1
else
    echo ""
    echo "Status: PASSED"
    exit 0
fi
