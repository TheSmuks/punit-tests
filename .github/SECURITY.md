# Security Policy

## Supported Versions

| Version | Supported |
| ------- | --------- |
| >= 1.x  | Yes       |
| < 1.0   | No        |

## Reporting a Vulnerability

If you discover a security vulnerability in PUnit, please report it responsibly:

1. **Do not** open a public issue.
2. Email the maintainer directly via GitHub's private vulnerability reporting feature.
3. Include:
   - Description of the vulnerability
   - Steps to reproduce
   - Affected versions
   - Any potential impact

You can expect:
- Acknowledgment within 48 hours
- An initial assessment within 5 business days
- A fix or mitigation plan communicated after assessment

## Scope

PUnit is a testing framework. Security vulnerabilities in scope include:
- Arbitrary code execution through malicious test files
- Path traversal in test discovery
- Unsafe deserialization of test data

Out of scope:
- Issues in Pike itself (report to the Pike project)
- Issues in dependencies installed separately
- Denial of service through intentionally crafted test suites
