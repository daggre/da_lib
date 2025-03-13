# Contributing to da_lib

Thank you for considering contributing to da_lib! This document outlines the process for contributing to the project.

## Code of Conduct

By participating in this project, you agree to maintain a respectful and inclusive environment.

## How Can I Contribute?

### Reporting Bugs

- Check if the bug has already been reported in the issues
- Use the bug report template when creating a new issue
- Include detailed steps to reproduce the problem
- Include your RedM and server version

### Suggesting Features

- Check if the feature has already been suggested in the issues
- Use the feature request template when creating a new issue
- Describe the feature in detail and why it would be valuable

### Pull Requests

1. Fork the repository
2. Create a branch for your changes (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Run any applicable tests
5. Commit your changes (`git commit -m 'Add some amazing feature'`)
6. Push to your branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

## Style Guidelines

### Lua Style Guide

- Use 4 spaces for indentation
- Function names should be camelCase
- Local variables should be camelCase
- Constants should be UPPER_SNAKE_CASE
- Use meaningful variable names
- Add comments for complex logic
- Keep functions focused on a single task
- Prefix client-side files with `_cl`
- Prefix server-side files with `_srv`
- Prefix shared files with `_sh`

### Documentation Style Guide

- Use Markdown for all documentation
- Document all public functions with:
  - Brief description
  - Parameters (name, type, description)
  - Return value (type, description)
  - Usage example

## Development Process

### Setting Up Development Environment

1. Clone the repository
2. Install any required dependencies
3. Test the resource in a local RedM server

### Testing

- Test all changes in a local RedM server
- Ensure backward compatibility is maintained
- Test with multiple players for networked functionality

## Extending the Core

When adding new features:

1. Create files in the appropriate `/features/` subdirectory
2. Follow the established naming conventions
3. Update documentation in the `/docs/` directory
4. Update the `fxmanifest.lua` file to include new files

## Release Process

1. The maintainers will review and merge pull requests
2. Version bumps will be determined by the maintainers
3. Releases will be tagged according to semantic versioning

Thank you for contributing to da_lib!