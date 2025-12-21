# Contributing

Thank you for your interest in contributing to the AWS Static Site plugin!

## Getting Started

### Prerequisites

- AWS CLI v2
- Node.js 18+
- A static site generator (Hugo, Astro, 11ty, etc.)
- Claude Code CLI

### Development Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/yaccp/claude-plugin-aws-static-site
   cd claude-plugin-aws-static-site
   ```

2. Run validation tests:
   ```bash
   ./tests/validate-plugin.sh
   ```

## Making Changes

### Branch Naming

Use descriptive branch names:
- `feat/add-gatsby-support`
- `fix/cloudfront-cache-policy`
- `docs/update-troubleshooting`

### Commit Messages

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
feat: Add Gatsby static site generator support
fix: Resolve CloudFront OAC permission issue
docs: Add Netlify migration guide
chore: Update AWS SDK dependencies
```

### Code Style

- Follow existing patterns in the codebase
- Use Markdown for commands and documentation
- Keep commands self-contained with clear prompts
- Include error handling for AWS operations

## Testing

### Validate Plugin Structure

```bash
./tests/validate-plugin.sh
```

This checks:
- Required files exist
- JSON files are valid
- Commands have correct naming
- Assets are present

### Test Commands Manually

```bash
# Install the plugin locally
claude plugin add .

# Test each command
/yaccp-aws-static-site:doctor
/yaccp-aws-static-site:env
/yaccp-aws-static-site:init
```

### AWS Testing

For AWS-related changes, test in a sandbox account:
1. Configure AWS credentials
2. Run through full deployment cycle
3. Verify S3, CloudFront, ACM, Route53 resources
4. Clean up with `/yaccp-aws-static-site:destroy`

## Adding SSG Support

To add a new static site generator:

1. Update `/yaccp-aws-static-site:init` command:
   - Add to SSG selection options
   - Define default build command
   - Define default output directory

2. Update SKILL.md with new SSG

3. Update README.md:
   - Add to "Static Site Generators" section
   - Update features list

4. Test the full workflow with the new SSG

## Pull Request Process

1. **Create a branch** from `main`
2. **Make your changes** following the guidelines above
3. **Update documentation** if needed:
   - Update CHANGELOG.md
   - Update README.md if adding features
   - Update diagrams if architecture changes
4. **Run validation** to ensure everything works
5. **Submit PR** with a clear description

### PR Template

```markdown
## Summary
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Documentation update
- [ ] Refactoring

## Testing
- [ ] Ran validate-plugin.sh
- [ ] Tested commands locally
- [ ] Tested AWS deployment (if applicable)

## Checklist
- [ ] Updated CHANGELOG.md
- [ ] Updated documentation
- [ ] No breaking changes (or documented)
```

## Updating Diagrams

When modifying architecture:

1. Edit `.mmd` files in `assets/diagrams/`
2. Regenerate SVGs:
   ```bash
   # Using mermaid-cli
   mmdc -i assets/diagrams/architecture.mmd -o assets/diagrams/architecture.svg
   mmdc -i assets/diagrams/workflow.mmd -o assets/diagrams/workflow.svg
   ```
3. Commit both `.mmd` and `.svg` files

## Release Process

Maintainers handle releases:

1. Update version in `.claude-plugin/plugin.json`
2. Update CHANGELOG.md
3. Create git tag: `git tag -a v1.x.x -m "Release v1.x.x"`
4. Push tag: `git push origin v1.x.x`
5. Create GitHub release

## Getting Help

- **Issues**: [GitHub Issues](https://github.com/yaccp/claude-plugin-aws-static-site/issues)
- **Discussions**: [GitHub Discussions](https://github.com/yaccp/claude-plugin-aws-static-site/discussions)

## Code of Conduct

Be respectful and constructive in all interactions. We follow the [Contributor Covenant](https://www.contributor-covenant.org/).
