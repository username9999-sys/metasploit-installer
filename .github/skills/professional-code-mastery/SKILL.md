---
name: professional-code-mastery
description: Use at the START of ANY coding task - establishes comprehensive framework for bug-finding, code generation, security analysis, and 100% accuracy guarantee across all languages and 20K+ line codebases. Includes Phases 0-7 with emergency protocols and failure recovery.
license: MIT
version: 2.0.0
created-date: 2024-01-15
last-updated: 2026-07-26
maintainer: GitHub Copilot
tags:
  - bug-finding
  - code-generation
  - security-analysis
  - performance-optimization
  - refactoring
  - testing
  - vulnerability-scanning
keywords:
  - debugging
  - code-mastery
  - security
  - quality-assurance
  - codebase-analysis
allowed-tools:
  - lexical-code-search
  - semantic-code-search
  - get-github-data
  - getfile
  - get-actions-job-logs
---

<SUBAGENT-STOP>
If you were dispatched as a subagent to execute a specific task, ignore this skill.
</SUBAGENT-STOP>

<EXTREMELY-IMPORTANT>
If you think there is even a 1% chance this skill applies to what you are doing, you ABSOLUTELY MUST invoke it.

THIS IS YOUR MASTER SKILL FOR:
- Finding bugs & vulnerabilities (100% accuracy)
- Writing professional code in ANY language
- Analyzing massive codebases (20K+ lines)
- Security & performance optimization
- Module & library development
- Hacking & penetration analysis
- System architecture design
- Enterprise-grade code quality

IF YOUR TASK INVOLVES CODE IN ANY WAY, YOU MUST USE THIS SKILL.

This is not negotiable. You cannot rationalize your way out of this.
</EXTREMELY-IMPORTANT>

---

## The Rule

**Invoke this skill BEFORE any response, analysis, or coding action**

This includes:
- Bug investigation & root cause analysis
- Code review & optimization
- Feature implementation
- Security analysis & hardening
- Performance profiling
- Architecture design
- Multi-source research & solution finding
- Testing & quality assurance
- Vulnerability scanning & exploitation analysis
- Security penetration testing
- Codebase refactoring
- API design & implementation
- Database schema optimization

**Before entering plan mode:** Execute the pre-flight checklist below.

Then announce "Using professional-code-mastery to [purpose]" and follow the framework exactly.

---

## Pre-Flight Checklist

```
BEFORE CODING/DEBUGGING - ALWAYS DO THIS:

□ Task Classification
  └─ Identify task type: bug-fix | feature | refactor | security | performance | review | vulnerability-scan | architecture | optimization

□ Context Gathering
  └─ Language(s) involved: _______________
  └─ Codebase size: small | medium | large (20K+) | massive (100K+)
  └─ Components involved: _______________
  └─ Error message/requirement: _______________
  └─ Stakeholders/Dependencies: _______________

□ Quality Gate Setup
  └─ Set target accuracy: 100% | 99.9% | 99%
  └─ Define success metrics: _______________
  └─ Identify security requirements: Yes | No
  └─ Performance constraints: _______________
  └─ Timeline/SLA: _______________

□ Research Sources Priority
  1. Official documentation
  2. GitHub issues & PRs (same codebase)
  3. Stack Overflow & communities
  4. Package source code
  5. Web search & blogs
  6. Security databases (CVE, NVD, MITRE)
  7. Exploit databases & PoCs
  8. Academic papers & RFCs

□ Risk Assessment
  └─ Potential breaking changes: _______________
  └─ Backward compatibility impacts: _______________
  └─ Security implications: _______________
  └─ Performance impact: _______________

□ Ready to proceed? → Execute skill framework below
```

---

## Skill Priority

When multiple coding tasks apply, process skills sequentially:

- "Fix this bug" → professional-code-mastery (Phase 0 + Phase 3) first, then domain-specific debugging skills
- "Find vulnerabilities" → professional-code-mastery (Phase 0 detection layers) first, then security-specific analysis
- "Write new feature" → professional-code-mastery (Phase 4 + Phase 5) first, then implementation skills
- "Review code quality" → professional-code-mastery (Phase 1 + Phase 6) first, then code review skills
- "Optimize performance" → professional-code-mastery (Phase 6 + Phase 2 research) first, then optimization tools
- "Secure codebase" → professional-code-mastery (Phase 0 security scanning) first, then hardening skills
- "Analyze large codebase" → professional-code-mastery (large codebase navigation) first, then domain exploration
- "Design architecture" → professional-code-mastery (Phase 7 design) first, then architectural tools
- "Refactor code" → professional-code-mastery (Phase 6 quality) first, then refactoring tools

**Critical Rule:** Phase 0 (Bug & Vulnerability Detection) ALWAYS runs first when security or bug-finding is involved.

---

## PHASE 0: BUG & VULNERABILITY DETECTION (100% ACCURACY)

THIS IS THE CRITICAL PHASE FOR FINDING BUGS & VULNERABILITIES
Execute BEFORE all other phases when bug-hunting is the goal

---

### MULTI-LAYER DETECTION STRATEGY

#### LAYER 1: STATIC ANALYSIS (No execution required)
```
Code Pattern Recognition:
├─ [ ] Scan for known vulnerable patterns
├─ [ ] Identify code smells & anti-patterns
├─ [ ] Check for common mistakes by language
├─ [ ] Find unsafe operations
└─ [ ] Detect hardcoded secrets/credentials

Syntax & Type Analysis:
├─ [ ] Type mismatches (null checks, casting)
├─ [ ] Uncaught exceptions
├─ [ ] Resource leaks (file handles, connections)
├─ [ ] Use-after-free patterns
└─ [ ] Memory safety issues

Security Pattern Scanning:
├─ [ ] SQL injection vulnerabilities
├─ [ ] XSS/injection attack vectors
├─ [ ] Authentication/authorization gaps
├─ [ ] Cryptography misuse
├─ [ ] Insecure serialization
└─ [ ] API security issues

Dependency Analysis:
├─ [ ] Known vulnerable dependencies
├─ [ ] Outdated libraries (check CVE databases)
├─ [ ] Supply chain risks
└─ [ ] Transitive dependency issues
```

#### LAYER 2: CONTROL FLOW ANALYSIS
```
Execution Path Mapping:
├─ [ ] Trace all execution paths from entry points
├─ [ ] Identify unreachable code
├─ [ ] Find infinite loops
├─ [ ] Detect deadlock scenarios
└─ [ ] Map state transitions

Logic Error Detection:
├─ [ ] Incorrect conditions (if/switch)
├─ [ ] Off-by-one errors (array indexing)
├─ [ ] Wrong algorithm implementation
├─ [ ] State corruption paths
└─ [ ] Race conditions (concurrent access)

Error Handling Gaps:
├─ [ ] Missing try-catch blocks
├─ [ ] Unhandled error cases
├─ [ ] Silent failures
├─ [ ] Insufficient logging
└─ [ ] Inadequate error recovery
```

#### LAYER 3: DATA FLOW ANALYSIS
```
Source-to-Sink Tracking:
├─ [ ] User input validation (tainted data tracking)
├─ [ ] Data flow from source to database
├─ [ ] Unsafe data transformations
├─ [ ] Implicit type conversions
└─ [ ] Data exposure paths

Variable State Analysis:
├─ [ ] Uninitialized variables
├─ [ ] Variable mutation issues
├─ [ ] Scope violation
├─ [ ] Lifetime issues
└─ [ ] State inconsistency

Concurrency Issues:
├─ [ ] Race conditions on shared data
├─ [ ] Synchronization gaps
├─ [ ] Deadlock potential
├─ [ ] Memory visibility (memory barriers)
└─ [ ] Atomic operation misuse
```

#### LAYER 4: DYNAMIC ANALYSIS (Requires execution/testing)
```
Runtime Behavior Analysis:
├─ [ ] Null pointer dereferences
├─ [ ] Array/buffer overflows
├─ [ ] Stack overflow (recursion depth)
├─ [ ] Integer overflow/underflow
├─ [ ] Floating point precision issues
└─ [ ] Resource exhaustion

Memory Analysis:
├─ [ ] Memory leaks (unreleased allocations)
├─ [ ] Use-after-free (accessing freed memory)
├─ [ ] Double-free (freeing same memory twice)
├─ [ ] Memory corruption (buffer overflow)
├─ [ ] Heap spraying vulnerabilities
└─ [ ] Stack smashing

Performance Profiling:
├─ [ ] Bottleneck identification
├─ [ ] N+1 query problems
├─ [ ] Memory bloat
├─ [ ] CPU hotspots
├─ [ ] I/O inefficiency
└─ [ ] Algorithm inefficiency

Security Testing:
├─ [ ] Authentication bypass attempts
├─ [ ] Authorization escape paths
├─ [ ] Session hijacking possibilities
├─ [ ] CSRF vulnerability confirmation
├─ [ ] XSS injection payload testing
└─ [ ] SQL injection confirmation
```

#### LAYER 5: SECURITY VULNERABILITY SCANNING (OWASP Top 10)
```
Injection Vulnerabilities:
├─ [ ] SQL Injection detection
├─ [ ] NoSQL Injection detection
├─ [ ] OS Command Injection detection
├─ [ ] LDAP Injection detection
├─ [ ] Expression Language (EL) Injection
├─ [ ] Template Injection detection
└─ [ ] XML Injection (XXE) detection

Cross-Site Scripting (XSS):
├─ [ ] Reflected XSS (user input in response)
├─ [ ] Stored XSS (user input in database)
├─ [ ] DOM-based XSS (JavaScript manipulation)
├─ [ ] Content Security Policy (CSP) gaps
└─ [ ] Output encoding missing

Authentication & Session Issues:
├─ [ ] Weak password policies
├─ [ ] Insecure password storage
├─ [ ] Session fixation vulnerabilities
├─ [ ] Insecure session management
├─ [ ] Session timeout issues
├─ [ ] JWT validation gaps
└─ [ ] Multi-factor authentication gaps

Access Control Issues:
├─ [ ] Broken access control (BAC)
├─ [ ] Privilege escalation paths
├─ [ ] Horizontal privilege escalation
├─ [ ] Vertical privilege escalation
├─ [ ] CORS misconfiguration
└─ [ ] Missing authorization checks

Security Misconfiguration:
├─ [ ] Debug mode enabled in production
├─ [ ] Unnecessary services running
├─ [ ] Default credentials not changed
├─ [ ] Insecure HTTP headers missing
├─ [ ] Error messages leaking info
└─ [ ] Outdated software/libraries

Sensitive Data Exposure:
├─ [ ] Data not encrypted at rest
├─ [ ] Data not encrypted in transit (no TLS)
├─ [ ] Sensitive data in logs/error messages
├─ [ ] PII exposure
├─ [ ] API keys/credentials in code
├─ [ ] Cache contains sensitive data
└─ [ ] Backups contain sensitive data

Insecure Deserialization:
├─ [ ] Untrusted data deserialization
├─ [ ] Object injection vulnerabilities
├─ [ ] Remote Code Execution (RCE) via deserialization
└─ [ ] Gadget chain exploitation potential

Using Components with Known Vulnerabilities:
├─ [ ] Outdated dependency versions (CVE check)
├─ [ ] Known vulnerable libraries in use
├─ [ ] Missing security patches
├─ [ ] Transitive dependency vulnerabilities
└─ [ ] License compliance issues

Insufficient Logging & Monitoring:
├─ [ ] Missing security event logging
├─ [ ] Logs not retained long enough
├─ [ ] Insufficient audit trail
├─ [ ] No alerting on suspicious activity
├─ [ ] Logs not protected from tampering
└─ [ ] No centralized log collection
```

#### LAYER 6: ARCHITECTURE & DESIGN FLAWS
```
Design Pattern Violations:
├─ [ ] Incorrect pattern implementation
├─ [ ] Design pattern misuse
├─ [ ] Architectural inconsistency
└─ [ ] Anti-patterns in use

Scalability Issues:
├─ [ ] Single point of failure
├─ [ ] Bottleneck in architecture
├─ [ ] Load balancing gaps
├─ [ ] Database scalability issues
└─ [ ] Cache invalidation problems

Maintainability Issues:
├─ [ ] High coupling between modules
├─ [ ] Low cohesion in classes
├─ [ ] Code duplication
├─ [ ] Circular dependencies
└─ [ ] Tech debt accumulation
```

#### LAYER 7: CONTEXT-SPECIFIC VULNERABILITIES
```
Web Application Vulnerabilities:
├─ [ ] Cross-Site Request Forgery (CSRF)
├─ [ ] Clickjacking vulnerabilities
├─ [ ] MIME type confusion
├─ [ ] Content-Type mismatch exploits
├─ [ ] Open redirect vulnerabilities
└─ [ ] WebSocket security issues

API Security Issues:
├─ [ ] Excessive data exposure in API
├─ [ ] Lack of rate limiting
├─ [ ] Missing API authentication
├─ [ ] Improper API versioning
├─ [ ] API endpoint enumeration possible
└─ [ ] GraphQL introspection enabled

Cloud/Infrastructure Vulnerabilities:
├─ [ ] Exposed AWS credentials
├─ [ ] S3 bucket misconfiguration
├─ [ ] IAM policy too permissive
├─ [ ] Unencrypted EBS volumes
├─ [ ] Unnecessary security group exposure
└─ [ ] Missing VPC network isolation

Cryptography Vulnerabilities:
├─ [ ] Weak encryption algorithms (MD5, SHA1)
├─ [ ] Insufficient key length
├─ [ ] Hardcoded encryption keys
├─ [ ] Weak random number generation
├─ [ ] ECB mode usage (should use CBC, GCM)
├─ [ ] Missing HMAC/authentication
└─ [ ] Improper IV generation
```

#### DETECTION TOOLS

Automated Tools:
- Static Analysis: SonarQube, SonarLint, Checkmarx, Fortify, Bandit (Python), ESLint (JavaScript), Clippy (Rust), SpotBugs (Java), CppCheck (C++), Pylint, Flake8
- Dependency Scanning: npm audit, pip-audit, cargo audit, OWASP Dependency-Check, Snyk, Black Duck, WhiteSource
- Dynamic Analysis: Burp Suite, OWASP ZAP, Valgrind, AddressSanitizer, ThreadSanitizer, AFL, libFuzzer, Frida, DynamoRIO
- Security Scanning: Trivy, Grype, Clair, Aqua Security, Qualys, Rapid7, Tenable

#### BUG SEVERITY CLASSIFICATION
```
CRITICAL (Drop everything, fix immediately):
├─ [ ] Remote Code Execution (RCE) vulnerability
├─ [ ] Privilege escalation to admin
├─ [ ] Complete data breach
├─ [ ] System crash / Denial of Service
├─ [ ] Authentication bypass
├─ [ ] Unencrypted sensitive data exposure
└─ [ ] Scope: Immediate fix required, SLA < 1 hour

HIGH (Fix within 24 hours):
├─ [ ] Significant security vulnerability
├─ [ ] Data exposure (sensitive info)
├─ [ ] Authorization bypass
├─ [ ] Significant performance degradation (>50% slowdown)
├─ [ ] Database corruption possible
├─ [ ] API availability impacted (>10% failures)
└─ Impact: Serious security/business impact, SLA < 24 hours

MEDIUM (Fix within 1 week):
├─ [ ] Minor security issue
├─ [ ] Moderate performance issue (10-50% slowdown)
├─ [ ] Edge case bug
├─ [ ] Incomplete error handling
├─ [ ] Code smell / maintainability issue
└─ Impact: Medium business impact, SLA < 1 week

LOW (Fix in normal sprint):
├─ [ ] Minor code issue
├─ [ ] Documentation missing
├─ [ ] Non-critical optimization
├─ [ ] Code style violation
└─ Impact: Low business impact, SLA < 1 sprint
```

#### 100% ACCURACY BUG-FINDING WORKFLOW
```
STEP 1: COMPREHENSIVE SCANNING
└─ [ ] Run all static analysis tools
└─ [ ] Scan for all vulnerability types
└─ [ ] Check dependency databases (CVE, NPM audit, etc)
└─ [ ] Perform manual code review
└─ [ ] Run automated security tests
└─ [ ] Document each finding with evidence

STEP 2: MANUAL VERIFICATION
└─ [ ] Confirm each finding independently
└─ [ ] Eliminate false positives
└─ [ ] Prioritize by severity & exploitability
└─ [ ] Document each bug with:
       - Location (file, line number)
       - Description (what & why)
       - Proof of concept
       - Impact assessment

STEP 3: ROOT CAUSE ANALYSIS
└─ [ ] Trace bug origin (when introduced)
└─ [ ] Identify contributing factors
└─ [ ] Find similar bugs in codebase
└─ [ ] Determine systemic issues
└─ [ ] Plan preventive measures

STEP 4: SOLUTION DESIGN
└─ [ ] Design secure, minimal fix
└─ [ ] Check for side effects & regressions
└─ [ ] Plan comprehensive testing strategy
└─ [ ] Verify fix won't introduce new bugs
└─ [ ] Document security rationale

STEP 5: FIX IMPLEMENTATION
└─ [ ] Implement fix
└─ [ ] Add comprehensive test cases (unit + integration)
└─ [ ] Run full test suite (must pass 100%)
└─ [ ] Re-run security scans (must pass)
└─ [ ] Verify no regressions

STEP 6: VALIDATION & SIGN-OFF
└─ [ ] Confirm bug is fixed (verify fix works)
└─ [ ] No new bugs introduced
└─ [ ] Security scan passes
└─ [ ] Performance acceptable
└─ [ ] All tests pass (100%)
└─ [ ] Code review complete
└─ [ ] Documentation updated
```

---

## PHASE 1: ISSUE CLASSIFICATION & ANALYSIS

```
SYNTAX ERRORS
├─ Pattern: Parser failed at [location]
├─ Action: Correct syntax immediately
├─ Tools: Linter, compiler, static analysis
└─ Accuracy: 100% (objective)

RUNTIME ERRORS
├─ Pattern: Exception at [line], null reference, type mismatch
├─ Action: Add runtime guards, input validation
├─ Tools: Debugger, stack trace analyzer, profiler
└─ Accuracy: 99%+ (with proper tracing)

LOGIC ERRORS
├─ Pattern: Wrong output, incorrect algorithm, state corruption
├─ Action: Algorithm review, state machine analysis
├─ Tools: Execution tracing, data flow analysis
└─ Accuracy: 95%+ (requires understanding)

SECURITY VULNERABILITIES
├─ Pattern: SQLi, XSS, auth bypass, data exposure
├─ Action: Security hardening, input validation, encryption
├─ Tools: OWASP tools, static analysis, penetration testing
└─ Accuracy: 98%+ (with security knowledge)

PERFORMANCE PROBLEMS
├─ Pattern: Slow response, memory leak, high CPU
├─ Action: Profiling, optimization, caching strategy
├─ Tools: Profiler, memory analyzer, performance benchmarks
└─ Accuracy: 90%+ (depends on instrumentation)

ARCHITECTURAL ISSUES
├─ Pattern: Design pattern violation, scalability problem
├─ Action: Refactoring, design pattern application
├─ Tools: Dependency analysis, architecture visualization
└─ Accuracy: 85%+ (subjective, requires judgment)
```

---

## PHASE 2: MULTI-SOURCE RESEARCH

```
RESEARCH STRATEGY (execute in order):

STEP 1: OFFICIAL SOURCES (High Reliability)
└─ Documentation: Read official docs/API reference
└─ Release notes: Check changelog for known issues
└─ RFC/Standards: Reference language specifications
└─ GitHub: Search official repository issues
└─ Book/Guides: Check authoritative resources

STEP 2: SECURITY SOURCES (Critical for vulnerabilities)
└─ CVE Database: Check Common Vulnerabilities & Exposures (cve.mitre.org)
└─ NVD: National Vulnerability Database
└─ Security Advisories: Vendor-specific security updates
└─ OWASP: Open Web Application Security Project
└─ CWE: Common Weakness Enumeration (cwe.mitre.org)

STEP 3: COMMUNITY SOURCES (Practical experience)
└─ GitHub Issues: Search same codebase for similar issues
└─ GitHub Discussions: Community Q&A
└─ Stack Overflow: Specific error messages
└─ Reddit/Forums: Real-world experience
└─ Blog posts: Documented solutions

STEP 4: SOURCE CODE ANALYSIS
└─ Package repository: npm, PyPI, crates.io, Maven Central
└─ GitHub repository: Browse source code
└─ API reference: Check implementation details
└─ Library documentation: Usage patterns

STEP 5: EXPLOIT/PoC RESEARCH (For vulnerabilities)
└─ Exploit databases: Exploit-DB, PACKETSTORM
└─ GitHub PoC: Search for proof-of-concept code
└─ Security research: Academic papers
└─ Hacking forums: Real-world exploitation techniques

SEARCH PRIORITIES:
1. Official language/framework documentation
2. GitHub issues in the same repository
3. GitHub issues in related repositories
4. Stack Overflow (search by error message)
5. Security databases (CVE, NVD, CWE)
6. Blog posts and tutorials
7. Web search and general resources
```

---

## PHASE 3: CODEBASE NAVIGATION & CONTEXT EXTRACTION

Execute when working with large codebases (20K+ lines)

```
STEP 1: RAPID CODEBASE MAPPING
├─ [ ] Identify project structure
│   ├─ Main entry points (main.py, index.js, main.rs, etc)
│   ├─ Directory layout and organization
│   ├─ Key modules/packages
│   └─ Configuration files
│
├─ [ ] Locate relevant code sections
│   ├─ Use semantic code search for concept matching
│   ├─ Use lexical code search for exact patterns
│   ├─ Identify related files (imports, dependencies)
│   └─ Map data flow through modules
│
└─ [ ] Extract key information
    ├─ Dependencies and versions
    ├─ API endpoints (for web apps)
    ├─ Database schema (if applicable)
    ├─ Environment configuration
    └─ Build/test infrastructure

STEP 2: TARGETED FILE ANALYSIS
├─ [ ] Prioritize files by relevance
│   ├─ Priority 1: Files directly related to issue
│   ├─ Priority 2: Files that call/use issue location
│   ├─ Priority 3: Supporting/utility files
│   └─ Priority 4: Configuration/setup files
│
├─ [ ] Read high-priority files first
│   ├─ Understand function/class signatures
│   ├─ Trace data flows
│   ├─ Identify dependencies
│   └─ Note any TODOs or FIXMEs
│
└─ [ ] Document findings
    ├─ Component relationships
    ├─ Data flows
    ├─ Potential impact areas
    └─ Risk assessment

STEP 3: DEPENDENCY & IMPORT ANALYSIS
├─ [ ] Map import hierarchy
│   ├─ What imports what
│   ├─ Circular dependency detection
│   ├─ External vs internal dependencies
│   └─ Version compatibility
│
├─ [ ] External dependencies
│   ├─ List all external libraries
│   ├─ Check versions (known vulnerabilities?)
│   ├─ Document critical dependencies
│   └─ Identify security-sensitive dependencies
│
└─ [ ] Internal architecture
    ├─ Core modules
    ├─ Utility functions
    ├─ Shared libraries
    └─ Plugin/extension points

STEP 4: PATTERN & CONVENTION IDENTIFICATION
├─ [ ] Code style consistency
│   ├─ Naming conventions
│   ├─ Code structure patterns
│   ├─ Error handling approach
│   └─ Logging patterns
│
├─ [ ] Architectural patterns
│   ├─ Design patterns in use (MVC, MVVM, etc)
│   ├─ API design patterns
│   ├─ Data access patterns
│   └─ Communication patterns
│
└─ [ ] Testing patterns
    ├─ Test structure
    ├─ Mocking/fixture approach
    ├─ Coverage areas
    └─ Test data management
```

---

## PHASE 4: FEATURE IMPLEMENTATION

Execute when implementing new features or significant changes

```
STEP 1: REQUIREMENTS GATHERING & ANALYSIS
├─ [ ] Understand requirements
│   ├─ Functional requirements (what it should do)
│   ├─ Non-functional requirements (performance, security)
│   ├─ Edge cases and constraints
│   ├─ User stories and acceptance criteria
│   └─ Success metrics
│
├─ [ ] Acceptance criteria
│   ├─ Define success (how to verify)
│   ├─ Define failure scenarios
│   ├─ Performance benchmarks
│   └─ Security requirements
│
└─ [ ] Constraint identification
    ├─ Technical constraints
    ├─ Timeline constraints
    ├─ Resource constraints
    ├─ Compatibility requirements
    └─ Scalability requirements

STEP 2: DESIGN & ARCHITECTURE
├─ [ ] High-level design
│   ├─ System architecture
│   ├─ Component design
│   ├─ Data structures
│   ├─ API design (if applicable)
│   └─ Integration points
│
├─ [ ] Security design
│   ├─ Input validation strategy
│   ├─ Authentication/authorization approach
│   ├─ Encryption requirements
│   ├─ Audit logging needs
│   └─ Rate limiting/abuse prevention
│
├─ [ ] Performance considerations
│   ├─ Algorithm selection
│   ├─ Data structure optimization
│   ├─ Caching strategy
│   ├─ Database query optimization
│   └─ Scalability approach
│
└─ [ ] Database design (if applicable)
    ├─ Schema design
    ├─ Indexing strategy
    ├─ Query optimization
    ├─ Migration strategy
    └─ Backup/recovery strategy

STEP 3: IMPLEMENTATION
├─ [ ] Code structure planning
│   ├─ Follow existing patterns & conventions
│   ├─ Maintain code style consistency
│   ├─ Plan class/module organization
│   ├─ Design for testability
│   └─ Plan for documentation
│
├─ [ ] Incremental development
│   ├─ Implement core functionality first
│   ├─ Add error handling
│   ├─ Add logging/monitoring
│   ├─ Add input validation
│   └─ Add edge case handling
│
├─ [ ] Security implementation
│   ├─ Input validation/sanitization
│   ├─ Output encoding
│   ├─ Authentication checks
│   ├─ Authorization checks
│   └─ Security logging
│
└─ [ ] Code quality
    ├─ Code follows style guide
    ├─ No code duplication
    ├─ Proper error handling
    ├─ Adequate logging
    └─ Clear comments for complex logic

STEP 4: TESTING STRATEGY
├─ [ ] Unit tests
│   ├─ Happy path scenarios
│   ├─ Edge cases
│   ├─ Error conditions
│   ├─ Boundary conditions
│   └─ Target: 80%+ coverage
│
├─ [ ] Integration tests
│   ├─ Component integration
│   ├─ API integration
│   ├─ Database integration
│   └─ External service integration
│
├─ [ ] Security testing
│   ├─ Input validation tests
│   ├─ Authentication tests
│   ├─ Authorization tests
│   ├─ Injection attack tests
│   └─ Rate limiting tests
│
└─ [ ] Performance testing
    ├─ Load testing
    ├─ Stress testing
    ├─ Endurance testing
    └─ Spike testing

STEP 5: DOCUMENTATION
├─ [ ] Code documentation
│   ├─ API documentation
│   ├─ Function/method documentation
│   ├─ Complex logic explanation
│   └─ Configuration documentation
│
├─ [ ] User documentation
│   ├─ Feature overview
│   ├─ Usage examples
│   ├─ Configuration guide
│   └─ Troubleshooting guide
│
└─ [ ] Architecture documentation
    ├─ High-level design
    ├─ Data flow diagrams
    ├─ Integration points
    └─ Deployment guide
```

---

## PHASE 5: TESTING & VALIDATION

Comprehensive testing and validation for 100% quality assurance

```
STEP 1: TEST PLANNING
├─ [ ] Test scope
│   ├─ What to test
│   ├─ What NOT to test (and why)
│   ├─ Coverage targets
│   └─ Priority ranking
│
├─ [ ] Test types
│   ├─ Unit tests (individual functions)
│   ├─ Integration tests (component interaction)
│   ├─ System tests (entire system)
│   ├─ Security tests (vulnerability scanning)
│   ├─ Performance tests (load/stress)
│   ├─ Usability tests (user experience)
│   └─ Regression tests (prevent breaking changes)
│
└─ [ ] Test environment setup
    ├─ Test data preparation
    ├─ Mock service setup
    ├─ Database snapshots
    ├─ Environment configuration
    └─ CI/CD pipeline configuration

STEP 2: UNIT TESTING
├─ [ ] Test structure
│   ├─ Arrange (setup test data)
│   ├─ Act (execute function)
│   ├─ Assert (verify results)
│   └─ Cleanup (restore state)
│
├─ [ ] Coverage areas
│   ├─ Happy path (normal operation)
│   ├─ Edge cases (boundary conditions)
│   ├─ Error conditions (exceptions)
│   ├─ State changes (mutable objects)
│   └─ Concurrency (threaded code)
│
├─ [ ] Assertion strategies
│   ├─ Return value verification
│   ├─ State change verification
│   ├─ Side effect verification
│   ├─ Exception verification
│   └─ Performance assertions
│
└─ [ ] Coverage targets
    ├─ Statement coverage: 80%+
    ├─ Branch coverage: 75%+
    ├─ Function coverage: 90%+
    └─ Line coverage: 85%+

STEP 3: INTEGRATION TESTING
├─ [ ] Component integration
│   ├─ Test interactions between modules
│   ├─ Test data passing between components
│   ├─ Test shared resources
│   └─ Test error propagation
│
├─ [ ] API integration
│   ├─ Test API endpoints
│   ├─ Test request/response handling
│   ├─ Test error responses
│   ├─ Test edge cases (large payloads, etc)
│   └─ Test authentication/authorization
│
├─ [ ] Database integration
│   ├─ Test database operations (CRUD)
│   ├─ Test transaction handling
│   ├─ Test query performance
│   ├─ Test data integrity
│   └─ Test rollback scenarios
│
├─ [ ] External service integration
│   ├─ Test API calls to external services
│   ├─ Test error handling (service unavailable)
│   ├─ Test timeout handling
│   ├─ Test retry logic
│   └─ Test fallback mechanisms
│
└─ [ ] End-to-end testing
    ├─ Test complete workflows
    ├─ Test user stories
    ├─ Test data consistency
    ├─ Test system stability
    └─ Test performance under load

STEP 4: SECURITY TESTING
├─ [ ] Input validation testing
│   ├─ SQL injection attempts
│   ├─ Command injection attempts
│   ├─ XSS payload testing
│   ├─ LDAP injection
│   └─ Path traversal attempts
│
├─ [ ] Authentication/Authorization testing
│   ├─ Bypass authentication
│   ├─ Privilege escalation
│   ├─ Session hijacking
│   ├─ Token tampering
│   └─ Permission bypass
│
├─ [ ] Cryptography testing
│   ├─ Weak algorithm detection
│   ├─ Key management
│   ├─ Encryption/decryption correctness
│   ├─ Hash validation
│   └─ Signature verification
│
├─ [ ] Data exposure testing
│   ├─ Sensitive data in logs
│   ├─ Sensitive data in error messages
│   ├─ Cache data exposure
│   ├─ Memory dumps
│   └─ Backup security
│
└─ [ ] API security testing
    ├─ Rate limiting
    ├─ CORS misconfiguration
    ├─ Missing security headers
    ├─ Information disclosure
    └─ Deserialization issues

STEP 5: PERFORMANCE TESTING
├─ [ ] Load testing
│   ├─ Normal load conditions
│   ├─ Expected peak load
│   ├─ Monitor response times
│   ├─ Monitor resource utilization
│   └─ Identify bottlenecks
│
├─ [ ] Stress testing
│   ├─ Exceed normal load limits
│   ├─ Test system breaking point
│   ├─ Verify graceful degradation
│   ├─ Test recovery mechanisms
│   └─ Verify error handling
│
├─ [ ] Endurance testing
│   ├─ Long-running tests (hours/days)
│   ├─ Memory leak detection
│   ├─ Resource leak detection
│   ├─ Connection pool issues
│   └─ Log file growth
│
└─ [ ] Performance benchmarks
    ├─ Response time SLA (< X ms)
    ├─ Throughput SLA (X requests/sec)
    ├─ Resource utilization limits
    ├─ Scalability requirements
    └─ Regression detection

STEP 6: REGRESSION TESTING
├─ [ ] Test existing functionality
│   ├─ Automated regression test suite
│   ├─ Smoke tests (critical paths)
│   ├─ Previously fixed bugs
│   ├─ Known issue areas
│   └─ API backward compatibility
│
├─ [ ] Compatibility testing
│   ├─ Browser compatibility (if web)
│   ├─ OS compatibility
│   ├─ Dependency version compatibility
│   ├─ Database compatibility
│   └─ API version compatibility
│
└─ [ ] Data integrity verification
    ├─ Data consistency
    ├─ Data accuracy
    ├─ Data completeness
    ├─ Data format compliance
    └─ Migration correctness

STEP 7: VALIDATION SIGN-OFF
├─ [ ] Testing metrics
│   ├─ Code coverage (target met?)
│   ├─ Test pass rate (100%?)
│   ├─ Performance benchmarks (met?)
│   ├─ Security scan results (passing?)
│   └─ Critical issues (none?)
│
├─ [ ] Quality gates
│   ├─ All tests pass
│   ├─ Code coverage acceptable
│   ├─ No critical bugs
│   ├─ Security requirements met
│   ├─ Performance requirements met
│   └─ Documentation complete
│
└─ [ ] Sign-off checklist
    ├─ QA approval
    ├─ Security review approval
    ├─ Performance review approval
    ├─ Code review approval
    └─ Ready for release
```

---

## PHASE 6: CODE QUALITY & OPTIMIZATION

Continuous improvement of code quality and performance

```
STEP 1: CODE REVIEW
├─ [ ] Style & readability
│   ├─ Code follows style guide
│   ├─ Naming is clear and consistent
│   ├─ Functions are small (<50 lines)
│   ├─ Comments explain WHY, not WHAT
│   └─ Complexity is manageable (cyclomatic < 10)
│
├─ [ ] Correctness
│   ├─ Logic is correct
│   ├─ Edge cases handled
│   ├─ Error handling adequate
│   ├─ No infinite loops
│   ├─ No resource leaks
│   └─ No race conditions
│
├─ [ ] Security
│   ├─ Input validation present
│   ├─ Output encoding present
│   ├─ No hardcoded secrets
│   ├─ Proper authentication checks
│   ├─ Proper authorization checks
│   ├─ Secure dependencies
│   └─ No known vulnerabilities
│
├─ [ ] Performance
│   ├─ Efficient algorithms
│   ├─ Appropriate data structures
│   ├─ Query optimization (if DB)
│   ├─ Caching properly implemented
│   ├─ No memory waste
│   └─ No unnecessary I/O
│
├─ [ ] Maintainability
│   ├─ Low coupling between modules
│   ├─ High cohesion within modules
│   ├─ Clear interfaces
│   ├─ Testable code
│   ├─ Documentation complete
│   └─ No code duplication
│
└─ [ ] Testing
    ├─ Adequate test coverage
    ├─ Tests are meaningful
    ├─ Tests are maintainable
    ├─ Edge cases tested
    ├─ Error cases tested
    └─ Performance tested

STEP 2: STATIC ANALYSIS
├─ [ ] Run linters
│   ├─ Style violations
│   ├─ Potential bugs
│   ├─ Code smells
│   ├─ Complexity metrics
│   └─ Maintainability index
│
├─ [ ] Run security scanners
│   ├─ Vulnerability detection
│   ├─ Hardcoded secrets
│   ├─ Insecure patterns
│   ├─ Dependency vulnerabilities
│   └─ License compliance
│
├─ [ ] Run complexity analyzers
│   ├─ Cyclomatic complexity
│   ├─ Cognitive complexity
│   ├─ Nesting levels
│   ├─ Function length
│   └─ Class cohesion
│
└─ [ ] Run coverage analyzers
    ├─ Test coverage percentage
    ├─ Coverage gaps
    ├─ Branch coverage
    ├─ Line coverage
    └─ Function coverage

STEP 3: OPTIMIZATION
├─ [ ] Algorithmic optimization
│   ├─ Identify inefficient algorithms
│   ├─ Research better alternatives
│   ├─ Benchmark improvements
│   ├─ Verify correctness
│   └─ Update tests
│
├─ [ ] Database optimization
│   ├─ Query analysis (EXPLAIN PLAN)
│   ├─ Index optimization
│   ├─ Query restructuring
│   ├─ Connection pooling
│   ├─ Caching strategy
│   └─ N+1 query elimination
│
├─ [ ] Memory optimization
│   ├─ Identify memory leaks
│   ├─ Reduce object allocations
│   ├─ Use object pooling
│   ├─ Optimize data structures
│   ├─ Implement lazy loading
│   └─ Memory profiling
│
├─ [ ] CPU optimization
│   ├─ Identify hot spots
│   ├─ Reduce CPU-intensive operations
│   ├─ Parallelize where possible
│   ├─ Use efficient libraries
│   └─ CPU profiling
│
├─ [ ] I/O optimization
│   ├─ Batch I/O operations
│   ├─ Implement buffering
│   ├─ Use asynchronous I/O
│   ├─ Reduce network calls
│   └─ Implement compression
│
└─ [ ] Caching strategy
    ├─ Identify cacheable data
    ├─ Cache invalidation strategy
    ├─ Cache hit rate monitoring
    ├─ Cache memory limits
    └─ Cache key design

STEP 4: REFACTORING
├─ [ ] Code duplication removal
│   ├─ Identify duplicated code
│   ├─ Extract to shared function
│   ├─ Create base class if needed
│   ├─ Update call sites
│   └─ Verify tests pass
│
├─ [ ] Module extraction
│   ├─ Identify cohesive groups
│   ├─ Extract to new module
│   ├─ Define clear interfaces
│   ├─ Update imports
│   └─ Verify tests pass
│
├─ [ ] Design pattern application
│   ├─ Identify pattern-fit opportunities
│   ├─ Apply appropriate pattern
│   ├─ Verify benefits
│   ├─ Document pattern usage
│   └─ Update tests
│
├─ [ ] Simplification
│   ├─ Reduce nesting levels
│   ├─ Simplify conditional logic
│   ├─ Remove unnecessary abstractions
│   ├─ Improve readability
│   └─ Verify tests pass
│
└─ [ ] Deprecation management
    ├─ Mark deprecated APIs
    ├─ Provide migration path
    ├─ Update documentation
    ├─ Plan removal timeline
    └─ Monitor deprecation adoption

STEP 5: CONTINUOUS MONITORING
├─ [ ] Code metrics tracking
│   ├─ Code coverage trends
│   ├─ Complexity trends
│   ├─ Code smell trends
│   ├─ Technical debt tracking
│   └─ Quality gate compliance
│
├─ [ ] Performance monitoring
│   ├─ Response time tracking
│   ├─ Throughput tracking
│   ├─ Resource utilization
│   ├─ Error rate tracking
│   └─ SLA compliance
│
├─ [ ] Security monitoring
│   ├─ Vulnerability scanning
│   ├─ Dependency updates
│   ├─ Security patch tracking
│   ├─ Compliance status
│   └─ Incident response
│
└─ [ ] Quality reporting
    ├─ Metrics dashboard
    ├─ Trend analysis
    ├─ Issue tracking
    ├─ Improvement planning
    └─ Stakeholder reporting
```

---

## PHASE 7: SECURITY HARDENING & ARCHITECTURAL DESIGN

Enterprise-grade security and scalable architecture

```
STEP 1: SECURITY ARCHITECTURE
├─ [ ] Threat modeling
│   ├─ Identify assets
│   ├─ Identify threats
│   ├─ Assess threats (likelihood × impact)
│   ├─ Identify vulnerabilities
│   ├─ Mitigation strategies
│   └─ Residual risk assessment
│
├─ [ ] Security layers
│   ├─ Network security (firewalls, WAF)
│   ├─ Application security (input validation)
│   ├─ Data security (encryption, masking)
│   ├─ Infrastructure security (hardening)
│   ├─ Access control (authentication, authorization)
│   └─ Monitoring & logging (detection)
│
├─ [ ] Defense in depth
│   ├─ Multiple security controls
│   ├─ Redundant protections
│   ├─ Fail-secure defaults
│   ├─ Assume breach mentality
│   └─ Zero-trust architecture
│
└─ [ ] Security by design
    ├─ Security requirements from start
    ├─ Secure design patterns
    ├─ Security testing throughout
    ├─ Security code review
    └─ Continuous security assessment

STEP 2: SCALABILITY & PERFORMANCE ARCHITECTURE
├─ [ ] Horizontal scaling
│   ├─ Stateless application design
│   ├─ Load balancing strategy
│   ├─ Session management
│   ├─ Distributed caching
│   ├─ Database replication
│   └─ Service mesh (if microservices)
│
├─ [ ] Vertical scaling
│   ├─ Resource optimization
│   ├─ Efficient algorithms
│   ├─ Connection pooling
│   ├─ Query optimization
│   ├─ Caching strategy
│   └─ Async processing
│
├─ [ ] Database architecture
│   ├─ Master-slave replication
│   ├─ Sharding strategy
│   ├─ Read replicas
│   ├─ Cache layer (Redis, Memcached)
│   ├─ Query optimization
│   └─ Backup & recovery
│
├─ [ ] API design for scale
│   ├─ Versioning strategy
│   ├─ Rate limiting
│   ├─ Pagination
│   ├─ Filtering/searching
│   ├─ Caching headers
│   └─ Error handling
│
├─ [ ] Monitoring & observability
│   ├─ Metrics collection (Prometheus, StatsD)
│   ├─ Log aggregation (ELK, Datadog)
│   ├─ Distributed tracing (Jaeger, Zipkin)
│   ├─ Health checks
│   ├─ Alerting rules
│   └─ Dashboards
│
└─ [ ] Disaster recovery
    ├─ Backup strategy
    ├─ Recovery time objective (RTO)
    ├─ Recovery point objective (RPO)
    ├─ Failover mechanisms
    ├─ Disaster recovery testing
    └─ Business continuity planning

STEP 3: SECURE ARCHITECTURE PATTERNS
├─ [ ] Authentication architecture
│   ├─ OAuth 2.0 / OpenID Connect
│   ├─ Multi-factor authentication (MFA)
│   ├─ Session management
│   ├─ Token refresh strategy
│   ├─ Credential storage
│   └─ Password policies
│
├─ [ ] Authorization architecture
│   ├─ Role-Based Access Control (RBAC)
│   ├─ Attribute-Based Access Control (ABAC)
│   ├─ Policy-Based Access Control
│   ├─ Resource-level permissions
│   ├─ Permission caching
│   └─ Audit logging
│
├─ [ ] Data protection architecture
│   ├─ Encryption at rest (AES-256)
│   ├─ Encryption in transit (TLS 1.2+)
│   ├─ Data masking/redaction
│   ├─ Database encryption
│   ├─ Key management (HSM, KMS)
│   ├─ Tokenization
│   └─ Data classification
│
├─ [ ] API security architecture
│   ├─ API gateway
│   ├─ Rate limiting
│   ├─ CORS configuration
│   ├─ Request validation
│   ├─ Response filtering
│   ├─ API versioning
│   └─ Documentation security
│
├─ [ ] Microservices security
│   ├─ Service-to-service authentication
│   ├─ Service mesh (Istio, Linkerd)
│   ├─ Network policies
│   ├─ Distributed tracing with security
│   ├─ Secret management (Vault)
│   ├─ Circuit breakers
│   └─ Resilience patterns
│
└─ [ ] Cloud security architecture
    ├─ IAM policies
    ├─ VPC configuration
    ├─ Security groups
    ├─ Network segmentation
    ├─ Secrets management
    ├─ Compliance automation
    └─ Security audit logging

STEP 4: COMPLIANCE & GOVERNANCE
├─ [ ] Compliance requirements
│   ├─ GDPR (if EU data)
│   ├─ CCPA (if California data)
│   ├─ PCI-DSS (if payment cards)
│   ├─ HIPAA (if healthcare data)
│   ├─ SOC 2 (security & availability)
│   ├─ ISO 27001 (information security)
│   └─ Industry-specific standards
│
├─ [ ] Data governance
│   ├─ Data classification
│   ├─ Data retention policies
│   ├─ Data deletion procedures
│   ├─ Data access logging
│   ├─ PII protection
│   ├─ Data audit trails
│   └─ Privacy by design
│
├─ [ ] Change management
│   ├─ Change review process
│   ├─ Rollback procedures
│   ├─ Security impact analysis
│   ├─ Testing requirements
│   ├─ Approval workflows
│   └─ Audit trails
│
├─ [ ] Incident response
│   ├─ Incident plan
│   ├─ Response procedures
│   ├─ Communication plan
│   ├─ Post-incident review
│   ├─ Metrics & reporting
│   └─ Continuous improvement
│
└─ [ ] Vulnerability management
    ├─ Scanning program
    ├─ Remediation priorities
    ├─ Patch management
    ├─ Tracking & reporting
    ├─ Stakeholder notification
    └─ Effectiveness measurement

STEP 5: ARCHITECTURAL REVIEW & DOCUMENTATION
├─ [ ] Architecture documentation
│   ├─ High-level architecture diagram
│   ├─ Component interactions
│   ├─ Data flows
│   ├─ Security controls mapping
│   ├─ Scalability approach
│   ├─ Disaster recovery plan
│   └─ Deployment architecture
│
├─ [ ] Design decision records
│   ├─ Technology choices & rationale
│   ├─ Architecture patterns used
│   ├─ Trade-offs considered
│   ├─ Alternatives rejected & why
│   ├─ Future considerations
│   └─ Implementation notes
│
├─ [ ] Operational procedures
│   ├─ Deployment procedures
│   ├─ Rollback procedures
│   ├─ Monitoring setup
│   ├─ Alert responses
│   ├─ Incident procedures
│   └─ Maintenance windows
│
└─ [ ] Architectural review
    ├─ Security review (by security team)
    ├─ Performance review (by ops team)
    ├─ Scalability review (by architects)
    ├─ Compliance review (by legal/compliance)
    └─ Peer review by senior architects
```

---

## EMERGENCY PROTOCOLS

Execute immediately when critical issues arise

```
CRITICAL BUG / SECURITY VULNERABILITY DETECTED
├─ [ ] IMMEDIATE ACTION (Within 5 minutes)
│   ├─ [ ] Stop all deployments
│   ├─ [ ] Assess severity (CRITICAL/HIGH/MEDIUM/LOW)
│   ├─ [ ] Notify security team (if security issue)
│   ├─ [ ] Notify on-call team
│   ├─ [ ] Create incident ticket
│   ├─ [ ] Assign incident commander
│   └─ [ ] Start incident log
│
├─ [ ] CONTAINMENT (Within 15 minutes)
│   ├─ [ ] Isolate affected systems (if needed)
│   ├─ [ ] Disable dangerous feature (if possible)
│   ├─ [ ] Failover to backup (if applicable)
│   ├─ [ ] Verify isolation/containment
│   ├─ [ ] Monitor for spread
│   └─ [ ] Prepare rollback plan
│
├─ [ ] INVESTIGATION (Within 30 minutes)
│   ├─ [ ] Reproduce bug/issue
│   ├─ [ ] Trace root cause
│   ├─ [ ] Assess blast radius (what's affected)
│   ├─ [ ] Gather evidence/logs
│   ├─ [ ] Document findings
│   ├─ [ ] Identify affected users/data
│   └─ [ ] Estimate fix time
│
├─ [ ] REMEDIATION (ASAP)
│   ├─ [ ] Design emergency fix
│   ├─ [ ] Implement minimal fix
│   ├─ [ ] Test fix locally
│   ├─ [ ] Deploy fix to production
│   ├─ [ ] Verify fix is effective
│   ├─ [ ] Monitor for side effects
│   └─ [ ] Update incident status
│
└─ [ ] POST-INCIDENT (Within 24 hours)
    ├─ [ ] Complete root cause analysis
    ├─ [ ] Identify preventive measures
    ├─ [ ] Create follow-up tickets
    ├─ [ ] Prepare incident report
    ├─ [ ] Conduct blameless postmortem
    ├─ [ ] Notify stakeholders
    └─ [ ] Schedule implementation of preventive measures

PERFORMANCE CRISIS (90%+ resource utilization)
├─ [ ] IMMEDIATE (Within 2 minutes)
│   ├─ [ ] Assess current load
│   ├─ [ ] Check for obvious issues (runaway query, memory leak, etc)
│   ├─ [ ] Enable emergency throttling
│   ├─ [ ] Disable non-critical features
│   ├─ [ ] Scale up resources (if auto-scaling available)
│   └─ [ ] Alert on-call team
│
├─ [ ] DIAGNOSIS (Within 10 minutes)
│   ├─ [ ] Identify resource bottleneck (CPU, Memory, Disk, Network)
│   ├─ [ ] Identify problematic process/query
│   ├─ [ ] Trace recent changes
│   ├─ [ ] Check for DDoS/abuse
│   ├─ [ ] Review logs for errors
│   └─ [ ] Gather metrics/traces
│
├─ [ ] MITIGATION
│   ├─ [ ] Kill runaway process (if safe)
│   ├─ [ ] Kill slow query (if safe)
│   ├─ [ ] Clear cache (if safe)
│   ├─ [ ] Rollback recent changes (if applicable)
│   ├─ [ ] Implement rate limiting
│   ├─ [ ] Block abusive IPs (if DDoS)
│   └─ [ ] Verify recovery
│
└─ [ ] PREVENTION
    ├─ [ ] Implement monitoring/alerts
    ├─ [ ] Add resource limits
    ├─ [ ] Implement auto-scaling
    ├─ [ ] Implement query timeout
    ├─ [ ] Fix root cause
    └─ [ ] Update runbooks

SECURITY BREACH / DATA EXPOSURE DETECTED
├─ [ ] IMMEDIATE (Within 5 minutes)
│   ├─ [ ] Activate incident response plan
│   ├─ [ ] Notify security team & legal
│   ├─ [ ] Assess breach scope (what data, how many users)
│   ├─ [ ] Assess breach severity
│   ├─ [ ] Preserve evidence (logs, access records)
│   ├─ [ ] Revoke compromised credentials
│   ├─ [ ] Block unauthorized access
│   └─ [ ] Implement emergency access controls
│
├─ [ ] CONTAINMENT (Within 30 minutes)
│   ├─ [ ] Isolate affected systems
│   ├─ [ ] Terminate unauthorized sessions
│   ├─ [ ] Disable compromised accounts
│   ├─ [ ] Review audit logs
│   ├─ [ ] Verify attacker removal
│   ├─ [ ] Patch vulnerabilities
│   └─ [ ] Verify containment
│
├─ [ ] INVESTIGATION (Ongoing)
│   ├─ [ ] Gather forensic evidence
│   ├─ [ ] Trace attack vector
│   ├─ [ ] Determine breach timeline
│   ├─ [ ] Identify compromised data/accounts
│   ├─ [ ] Document findings
│   ├─ [ ] Engage external forensics (if needed)
│   └─ [ ] Notify legal/compliance
│
├─ [ ] DISCLOSURE (Within required timeframe)
│   ├─ [ ] Notify affected users (if required by law)
│   ├─ [ ] File regulatory reports (if required)
│   ├─ [ ] Prepare public statement
│   ├─ [ ] Establish hotline for affected users
│   ├─ [ ] Offer credit monitoring (if PII exposed)
│   └─ [ ] Monitor for secondary attacks
│
└─ [ ] REMEDIATION & PREVENTION
    ├─ [ ] Fix security vulnerabilities
    ├─ [ ] Implement security controls
    ├─ [ ] Enhance monitoring & alerting
    ├─ [ ] Review & update security policies
    ├─ [ ] Conduct security training
    ├─ [ ] Perform penetration test
    └─ [ ] Implement long-term solutions
```

---

## FAILURE RECOVERY PROCEDURES

Systematic approach to recovering from failed implementations

```
STEP 1: FAILURE DETECTION
├─ [ ] Recognize failure
│   ├─ Tests failing
│   ├─ Build broken
│   ├─ Deployment failed
│   ├─ Production error
│   ├─ Performance degradation
│   ├─ Security issue
│   └─ Data corruption
│
├─ [ ] Assess severity
│   ├─ CRITICAL: System down, data loss, security breach
│   ├─ HIGH: Major feature broken, significant performance issue
│   ├─ MEDIUM: Feature partially broken, moderate impact
│   ├─ LOW: Minor issue, cosmetic problem
│   └─ Determine SLA for fix
│
└─ [ ] Alert team
    ├─ Notify on-call team
    ├─ Create incident ticket
    ├─ Assign incident commander
    ├─ Start incident communication
    └─ Establish war room (if critical)

STEP 2: IMMEDIATE RESPONSE
├─ [ ] Stabilize (if in production)
│   ├─ Stop bleeding (disable broken feature)
│   ├─ Fallback to previous version (if possible)
│   ├─ Isolate problem area
│   ├─ Verify stability
│   └─ Monitor for side effects
│
├─ [ ] Understand failure
│   ├─ Gather error logs
│   ├─ Reproduce issue locally
│   ├─ Trace stack trace
│   ├─ Identify failure point
│   ├─ Review recent changes
│   └─ Document findings
│
└─ [ ] Initial diagnosis
    ├─ Root cause hypothesis
    ├─ Contributing factors
    ├─ Environmental factors
    ├─ Configuration issues
    └─ Data issues

STEP 3: ROOT CAUSE ANALYSIS
├─ [ ] Investigation
│   ├─ [ ] Review code changes
│   ├─ [ ] Check dependency versions
│   ├─ [ ] Review configuration changes
│   ├─ [ ] Check environment setup
│   ├─ [ ] Review test results
│   ├─ [ ] Trace execution flow
│   └─ [ ] Analyze metrics/logs
│
├─ [ ] Verification
│   ├─ [ ] Confirm hypothesis with evidence
│   ├─ [ ] Rule out alternative causes
│   ├─ [ ] Verify impact scope
│   ├─ [ ] Identify affected users/systems
│   └─ [ ] Estimate time to resolution
│
└─ [ ] Documentation
    ├─ [ ] Document root cause
    ├─ [ ] Document investigation steps
    ├─ [ ] Document failure impact
    ├─ [ ] Save diagnostic artifacts
    └─ [ ] Create postmortem template

STEP 4: RECOVERY OPTIONS
├─ [ ] Option A: Rollback
│   ├─ [ ] Revert to previous known-good version
│   ├─ [ ] Fastest recovery option
│   ├─ [ ] Risk: Data loss if new changes saved data
│   ├─ [ ] Verify rollback successful
│   └─ [ ] Communicate with users
│
├─ [ ] Option B: Quick Fix
│   ├─ [ ] Minimal code change to fix issue
│   ├─ [ ] Faster than full reimplementation
│   ├─ [ ] Risk: Incomplete fix, side effects
│   ├─ [ ] Test fix locally
│   ├─ [ ] Deploy fix
│   └─ [ ] Monitor for issues
│
├─ [ ] Option C: Workaround
│   ├─ [ ] Temporary business process workaround
│   ├─ [ ] Keeps users productive
│   ├─ [ ] Implement permanent fix later
│   ├─ [ ] Risk: User confusion, data inconsistency
│   ├─ [ ] Document workaround clearly
│   └─ [ ] Set deadline for permanent fix
│
└─ [ ] Option D: Major Rework
    ├─ [ ] Complete reimplementation
    ├─ [ ] Longest recovery time
    ├─ [ ] Best long-term solution
    ├─ [ ] Risk: Additional delays
    ├─ [ ] Comprehensive testing
    └─ [ ] Staged rollout

STEP 5: IMPLEMENTATION OF RECOVERY
├─ [ ] Plan the fix
│   ├─ [ ] Design solution
│   ├─ [ ] Identify risks
│   ├─ [ ] Plan testing
│   ├─ [ ] Plan deployment
│   ├─ [ ] Plan rollback
│   └─ [ ] Get approvals
│
├─ [ ] Execute the fix
│   ├─ [ ] Implement solution
│   ├─ [ ] Unit test locally
│   ├─ [ ] Integration testing
│   ├─ [ ] Security review
│   ├─ [ ] Code review
│   └─ [ ] Performance testing
│
├─ [ ] Deploy the fix
│   ├─ [ ] Deploy to staging
│   ├─ [ ] Smoke test
│   ├─ [ ] Deploy to production
│   ├─ [ ] Monitor for issues
│   ├─ [ ] Verify fix effectiveness
│   └─ [ ] Communicate resolution
│
└─ [ ] Validation
    ├─ [ ] Confirm fix resolves issue
    ├─ [ ] No new issues introduced
    ├─ [ ] Performance acceptable
    ├─ [ ] Data integrity verified
    ├─ [ ] User functionality restored
    └─ [ ] SLA met (if applicable)

STEP 6: POST-RECOVERY ACTIONS
├─ [ ] Monitoring
│   ├─ [ ] Enhanced monitoring of fix area
│   ├─ [ ] Alert setup for similar issues
│   ├─ [ ] Metrics tracking
│   ├─ [ ] Performance baseline
│   └─ [ ] Duration: 24-48 hours
│
├─ [ ] Root cause prevention
│   ├─ [ ] Implement preventive measures
│   ├─ [ ] Add automated tests
│   ├─ [ ] Update build/deploy procedures
│   ├─ [ ] Update monitoring/alerting
│   ├─ [ ] Update documentation
│   └─ [ ] Training (if procedural issue)
│
├─ [ ] Postmortem review
│   ├─ [ ] What happened?
│   ├─ [ ] Why did it happen?
│   ├─ [ ] What can we do differently?
│   ├─ [ ] Action items & owners
│   ├─ [ ] Timeline for implementation
│   └─ [ ] Communication to stakeholders
│
└─ [ ] Knowledge sharing
    ├─ [ ] Document incident & resolution
    ├─ [ ] Add to runbook/wiki
    ├─ [ ] Share learnings with team
    ├─ [ ] Update training materials
    ├─ [ ] Create alerts/dashboards
    └─ [ ] Prevent recurrence
```

---

## COMPREHENSIVE WORKFLOW SUMMARY

When using this skill:

1. **ANNOUNCE**: "Using professional-code-mastery to [specific purpose]"
2. **EXECUTE**: Follow the appropriate phase(s) for the task
3. **DOCUMENT**: Record findings and decisions
4. **VERIFY**: Validate solution quality and completeness
5. **REPORT**: Communicate results and next steps

### Phase Selection Guide:
- **Bug fixing**: Phase 0 → Phase 1 → Phase 2 → Phase 3 → Phase 6
- **New features**: Phase 1 → Phase 2 → Phase 4 → Phase 5 → Phase 6
- **Security**: Phase 0 → Phase 2 → Phase 7 → Phase 6
- **Performance**: Phase 0 → Phase 2 → Phase 6 → Phase 7
- **Large codebase analysis**: Phase 3 → Phase 1 → Phase 2
- **Critical incidents**: Emergency Protocols → Failure Recovery Procedures

### Quality Assurance Checklist:
- ✅ All relevant phases completed
- ✅ 100% accuracy verification performed
- ✅ Security requirements met
- ✅ Performance requirements met
- ✅ Tests pass (100%)
- ✅ Documentation complete
- ✅ Code review approved
- ✅ Stakeholders notified

---

**End of professional-code-mastery Skill**
**Version: 2.0.0 | Last Updated: 2026-07-26 | Maintainer: GitHub Copilot**
