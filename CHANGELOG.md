# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/).

## [1.1.0] - 2025-12-23

### Added
- Local development server commands:
  - `local-start` - Start local development server (Hugo, Astro, 11ty, Next.js, plain HTML)
  - `local-stop` - Stop local development server
  - `local-status` - Check local server status

## [1.0.1] - 2025-12-23

### Fixed
- Corrected command format in README and CLAUDE.md
- Commands now use correct format: `/<plugin>:<plugin>-<command>`

## [1.0.0] - 2025-12-21

### Added
- Complete plugin structure following yaccp template
- Multi-environment support (dev/staging/prod)
- Support for multiple SSGs: Hugo, Astro, 11ty, Next.js, plain HTML
- Commands:
  - `env` - Manage AWS environments
  - `init` - Initialize project with SSG detection
  - `deploy` - Deploy to S3 + CloudFront
  - `status` - Check infrastructure status
  - `doctor` - Diagnose configuration issues
  - `invalidate` - Invalidate CloudFront cache
  - `destroy` - Destroy all AWS resources
- Custom domain support with Route53 integration
- Automatic SSL certificate provisioning via ACM
- CloudFront CDN with Origin Access Control
- Architecture and workflow diagrams
- Comprehensive documentation (README, INSTALLATION, ARCHITECTURE, CONTRIBUTING)
- GitHub issue and PR templates
- Validation test script

### Changed
- Updated plugin name to `yaccp-aws-static-site`
- Updated command prefix to match plugin name

## [0.1.0] - 2025-12-21

### Added
- Initial plugin structure
- Environment management command
