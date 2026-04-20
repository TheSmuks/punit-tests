# Contributing to PUnit

## Development Setup

### Prerequisites
- Pike 8.0.1116+

### Running Tests
`pike -M . run_tests.pike tests/`

## How to Contribute

1. Fork the repository
2. Create a feature branch: `git checkout -b feat/my-feature`
3. Make your changes
4. Run the test suite and ensure all tests pass
5. Commit with conventional commits (see below)
6. Push and open a Pull Request

## Commit Conventions

Follow [Conventional Commits](https://www.conventionalcommits.org/) 1.0.0:

    <type>(<scope>): <description>

Types: feat, fix, docs, refactor, test, chore, ci, perf, style, revert

Scopes: assert, runner, suite, reporter, lifecycle, error

## Pull Request Guidelines

- Keep PRs focused on a single change
- Include tests for new features
- Update documentation (CHANGELOG.md, README.md) as needed
- Ensure CI passes

## Code Review

All PRs require review before merge. Reviewers check for:
- Correctness and edge case handling
- Test coverage
- Documentation accuracy
- Consistent code style
