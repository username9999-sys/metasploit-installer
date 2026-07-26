---
name: professional-code-mastery
description: Use at the START of ANY coding task - establishes comprehensive framework for bug-finding, code generation, security analysis, and 100% accuracy guarantee across all languages and 20K+ line codebases
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

**Before entering plan mode:** Execute the pre-flight checklist below.

Then announce "Using professional-code-mastery to [purpose]" and follow the framework exactly.

---

## Pre-Flight Checklist

```
BEFORE CODING/DEBUGGING - ALWAYS DO THIS:

□ Task Classification
  └─ Identify task type: bug-fix | feature | refactor | security | performance | review | vulnerability-scan

□ Context Gathering
  └─ Language(s) involved: _______________
  └─ Codebase size: small | medium | large (20K+) | massive (100K+)
  └─ Components involved: _______________
  └─ Error message/requirement: _______________

□ Quality Gate Setup
  └─ Set target accuracy: 100% | 99.9% | 99%
  └─ Define success metrics: _______________
  └─ Identify security requirements: Yes | No
  └─ Performance constraints: _______________

□ Research Sources Priority
  1. Official documentation
  2. GitHub issues & PRs (same codebase)
  3. Stack Overflow & communities
  4. Package source code
  5. Web search & blogs
  6. Security databases (CVE, NVD)
  7. Exploit databases & PoCs

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
- Static Analysis: Sonarqube, SonarLint, Checkmarx, Fortify, Bandit (Python), ESLint (JavaScript), Clippy (Rust), SpotBugs (Java), CppCheck (C++)
- Dependency Scanning: npm audit, pip-audit, cargo audit, OWASP Dependency-Check, Snyk, Black Duck
- Dynamic Analysis: Burp Suite, OWASP ZAP, Valgrind, AddressSanitizer, ThreadSanitizer, AFL, libFuzzer, Frida
- Security Scanning: Trivy, Grype, Clair, Aqua Security, Qualys

#### BUG SEVERITY CLASSIFICATION
```
CRITICAL (Drop everything, fix immediately):
├─ [ ] Remote Code Execution (RCE) vulnerability
├─ [ ] Privilege escalation to admin
├─ [ ] Complete data breach
├─ [ ] System crash / Denial of Service
├─ [ ] Authentication bypass
└─ [ ] Unencrypted sensitive data exposure

HIGH (Fix within 24 hours):
├─ [ ] Significant security vulnerability
├─ [ ] Data exposure (sensitive info)
├─ [ ] Authorization bypass
├─ [ ] Significant performance degradation
├─ [ ] Database corruption possible
├─ [ ] API availability impacted
└─ Impact: Serious security/business impact

MEDIUM (Fix within 1 week):
├─ [ ] Minor security issue
├─ [ ] Moderate performance issue
├─ [ ] Edge case bug
├─ [ ] Incomplete error handling
├─ [ ] Code smell / maintainability issue
└─ Impact: Medium business impact

LOW (Fix in normal sprint):
├─ [ ] Minor code issue
├─ [ ] Documentation missing
├─ [ ] Non-critical optimization
├─ [ ] Code style violation
└─ Impact: Low business impact
```

#### 100% ACCURACY BUG-FINDING WORKFLOW
```
STEP 1: COMPREHENSIVE SCANNING
└─ [ ] Run all static analysis tools
└─ [ ] Scan for all vulnerability types
└─ [ ] Check dependency databases
└─ [ ] Perform code review
└─ [ ] Run automated security tests

STEP 2: MANUAL VERIFICATION
└─ [ ] Confirm each finding
└─ [ ] Eliminate false positives
└─ [ ] Prioritize by severity
└─ [ ] Document each bug
└─ [ ] Provide proof of concept (PoC)

STEP 3: ROOT CAUSE ANALYSIS
└─ [ ] Trace bug origin
└─ [ ] Identify contributing factors
└─ [ ] Find similar bugs in codebase
└─ [ ] Determine systemic issues
└─ [ ] Plan preventive measures

STEP 4: SOLUTION DESIGN
└─ [ ] Design secure fix
└─ [ ] Check for side effects
└─ [ ] Plan testing strategy
└─ [ ] Verify fix won't introduce new bugs
└─ [ ] Document security rationale

STEP 5: FIX IMPLEMENTATION
└─ [ ] Implement fix
└─ [ ] Add test cases
└─ [ ] Run full test suite
└─ [ ] Re-run security scans
└─ [ ] Verify no regressions

STEP 6: VALIDATION
└─ [ ] Confirm bug is fixed
└─ [ ] No new bugs introduced
└─ [ ] Security scan passes
└─ [ ] Performance acceptable
└─ [ ] All tests pass
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

STEP 2: SECURITY SOURCES (Critical for vulnerabilities)
└─ CVE Database: Check Common Vulnerabilities & Exposures
└─ NVD (National Vulnerability Database)
└─ OWASP Database: Check OWASP Top 10 & resources
└─ GitHub Security Advisories
└─ Package registry security notices

STEP 3: CODE SOURCES (High Signal)
└─ Stack trace analysis: Extract meaningful clues
└─ GitHub issues: Search "is:issue" + error message
└─ GitHub discussions: Check for same question
└─ GitHub PRs: Look for fixes to similar issues
└─ Source code: Inspect relevant library code

STEP 4: COMMUNITY SOURCES (Medium Signal)
└─ Stack Overflow: Search [tag] + error message
└─ Reddit: Check r/[language], r/programming
└─ Discord/Slack: Community channels
└─ Forums: Technical community forums
└─ Blogs: Technical blog posts

STEP 5: SYNTHESIS & VALIDATION
└─ Cross-reference multiple sources
└─ Prioritize official sources over community
└─ Test proposed solutions
└─ Adapt to your specific context
```

---

## PHASE 3: ROOT CAUSE ANALYSIS (Debugging)

```
STEP 1: REPRODUCE
└─ [ ] Understand exact failure conditions
└─ [ ] Create minimal reproducible case
└─ [ ] Document all inputs & preconditions
└─ [ ] Gather full error output & logs
└─ [ ] Note environment details

STEP 2: HYPOTHESIZE
└─ [ ] List all possible root causes (5-10)
└─ [ ] Prioritize by likelihood
└─ [ ] Research similar issues in codebase
└─ [ ] Check recent code changes
└─ [ ] Verify assumptions

STEP 3: INVESTIGATE
└─ [ ] Add strategic logging
└─ [ ] Use debugger with breakpoints
└─ [ ] Trace execution flow end-to-end
└─ [ ] Monitor variable states at each step
└─ [ ] Profile performance metrics

STEP 4: IDENTIFY ROOT CAUSE
└─ [ ] Which hypothesis is confirmed?
└─ [ ] Is it primary or contributing cause?
└─ [ ] What's the exact failure mechanism?
└─ [ ] Why wasn't this caught earlier?
└─ [ ] Document with evidence

STEP 5: VERIFY ROOT CAUSE
└─ [ ] Trace execution with root cause in mind
└─ [ ] Confirm hypothesis with evidence
└─ [ ] Check for related/similar bugs
└─ [ ] Identify all affected code paths
```

---

## PHASE 4: SOLUTION DESIGN

```
MINIMAL CHANGE PRINCIPLE
└─ Make smallest fix possible
└─ Avoid unnecessary refactoring
└─ Maintain backward compatibility
└─ Consider side effects & dependencies

BEST PRACTICES RESEARCH
└─ Research recommended solutions
└─ Check framework documentation
└─ Review design patterns
└─ Consider industry standards
└─ Learn from similar projects

EDGE CASE PLANNING
└─ What other inputs could break this?
└─ What if resources are constrained?
└─ What if concurrency is involved?
└─ What if scale increases 10x?
└─ What if user input is malicious?

IMPLEMENTATION STRATEGY
└─ [ ] Design solution architecture
└─ [ ] Plan code organization
└─ [ ] Identify test cases needed
└─ [ ] Plan for rollback if needed
└─ [ ] Document design decisions
```

---

## PHASE 5: IMPLEMENTATION (ZERO-DEFECT)

```
CODE GENERATION
└─ [ ] Follow existing code style
└─ [ ] Use proper naming conventions
└─ [ ] Add meaningful comments
└─ [ ] Handle all error cases
└─ [ ] Validate all inputs
└─ [ ] No magic numbers/strings
└─ [ ] Consider performance implications
└─ [ ] Keep functions small & focused

ERROR HANDLING
└─ [ ] Try-catch blocks where appropriate
└─ [ ] Meaningful error messages
└─ [ ] Error logging implemented
└─ [ ] Graceful degradation
└─ [ ] Resource cleanup
└─ [ ] No error message leakage (security)

DOCUMENTATION
└─ [ ] Function/class documentation added
└─ [ ] Complex logic explained
└─ [ ] Usage examples provided
└─ [ ] Edge cases documented
└─ [ ] Breaking changes noted
└─ [ ] Migration guide if needed

TESTING
└─ [ ] Unit tests for new code
└─ [ ] Test normal cases
└─ [ ] Test edge cases
└─ [ ] Test error paths
└─ [ ] Test with various inputs
└─ [ ] Integration tests if needed
└─ [ ] Performance tests if critical
```

---

## PHASE 6: QUALITY ASSURANCE & VERIFICATION

```
STATIC ANALYSIS
└─ [ ] No syntax errors
└─ [ ] No linter warnings
└─ [ ] Type checking passes
└─ [ ] Code style consistent
└─ [ ] Naming conventions followed
└─ [ ] Dead code removed
└─ [ ] TODO comments resolved

FUNCTIONAL TESTING
└─ [ ] Happy path works
└─ [ ] All test cases pass
└─ [ ] Edge cases handled
└─ [ ] Error cases handled
└─ [ ] Integration tests pass
└─ [ ] Regression tests pass
└─ [ ] Performance meets requirements

SECURITY REVIEW
└─ [ ] Input validation implemented
└─ [ ] No SQL injection vulnerabilities
└─ [ ] No XSS vulnerabilities
└─ [ ] Authentication properly enforced
└─ [ ] Authorization correctly implemented
└─ [ ] Sensitive data encrypted
└─ [ ] No hardcoded secrets
└─ [ ] Dependencies updated & secure

PERFORMANCE VERIFICATION
└─ [ ] Response time acceptable
└─ [ ] Memory usage normal
└─ [ ] CPU usage optimized
└─ [ ] Database queries optimized
└─ [ ] No N+1 query problems
└─ [ ] Load testing passed
└─ [ ] Profiler shows no bottlenecks

COMPATIBILITY CHECK
└─ [ ] Backward compatibility verified
└─ [ ] Works on all target environments
└─ [ ] Browser compatibility (if web)
└─ [ ] Version compatibility checked
└─ [ ] Dependency conflicts resolved
```

---

## PHASE 7: DOCUMENTATION & KNOWLEDGE SHARING

```
CODE COMMENTS
└─ Explain "why" not "what"
└─ Document assumptions
└─ Mark workarounds & why they're needed
└─ Note performance-critical sections

COMMIT MESSAGE
└─ Clear summary of change
└─ Why this change was needed
└─ How it fixes the issue
└─ Any side effects or dependencies

DOCUMENTATION UPDATES
└─ API documentation updated
└─ README updated if needed
└─ Runbooks updated if needed
└─ Architecture diagrams updated
└─ CHANGELOG entry added

KNOWLEDGE BASE
└─ Similar issues documented
└─ Solution pattern identified
└─ Lessons learned recorded
└─ Preventive measures documented
└─ Team training material created
```

---

## Language-Specific Bug Hotspots & Vulnerabilities

### Python
```
COMMON BUG PATTERNS:
├─ Mutable default arguments → [CRITICAL] Use None as default
├─ Global variables → [HIGH] Causes state corruption
├─ Type coercion issues → [HIGH] Use type hints + mypy
├─ Generator exhaustion → [MEDIUM] Generators are consumed once
├─ Circular imports → [MEDIUM] Restructure module organization
├─ GIL contention (threading) → [MEDIUM] Use multiprocessing or asyncio
├─ Memory leaks (reference cycles) → [HIGH] Use weakref or gc.collect()
└─ Improper exception handling → [HIGH] Never use bare except

SECURITY VULNERABILITIES:
├─ SQL injection → [CRITICAL] Use parameterized queries (?)
├─ Code injection (eval/exec) → [CRITICAL] Never use on user input
├─ Pickle deserialization RCE → [CRITICAL] Don't pickle untrusted data
├─ Path traversal → [HIGH] Use pathlib, validate paths
├─ Weak cryptography (MD5, old SSL) → [HIGH] Use secrets module
├─ Information disclosure → [HIGH] Catch exceptions, don't expose stack
└─ Insecure temporary files → [MEDIUM] Use tempfile module

TOOLS: Bandit, SonarQube, pytest, mypy, pylint, memory_profiler

EXAMPLE VULNERABILITIES:
1. SQL Injection:
   ❌ cursor.execute("SELECT * FROM users WHERE id=" + user_id)
   ✅ cursor.execute("SELECT * FROM users WHERE id=?", (user_id,))

2. Mutable Default:
   ❌ def append_item(item, list=[])
   ✅ def append_item(item, list=None): if list is None: list = []

3. Code Injection:
   ❌ eval(user_input)
   ✅ ast.literal_eval(user_input) with validation
```

### JavaScript/TypeScript
```
COMMON BUG PATTERNS:
├─ Callback hell / pyramid of doom → [MEDIUM] Use async/await
├─ Unhandled promise rejection → [HIGH] Always add .catch()
├─ this binding in callbacks → [MEDIUM] Use arrow functions or .bind()
├─ Async function timing → [HIGH] Understand microtask queue
├─ Memory leaks in listeners → [HIGH] Always removeEventListener
├─ DOM manipulation inefficiency → [MEDIUM] Batch DOM updates
├─ Race conditions in async → [MEDIUM] Use Promise.all() correctly
└─ Prototype pollution → [CRITICAL] Validate object properties

SECURITY VULNERABILITIES:
├─ DOM-based XSS → [CRITICAL] Never use innerHTML with user input
├─ Prototype pollution → [CRITICAL] Validate nested object assignment
├─ Hardcoded secrets → [CRITICAL] Use environment variables
├─ CORS misconfiguration → [HIGH] Restrict origin properly
├─ Insecure deserialization → [CRITICAL] Don't use eval/Function()
├─ Regex ReDoS → [HIGH] Test regex performance
└─ npm package vulnerabilities → [MEDIUM] Run npm audit regularly

TOOLS: ESLint + security plugins, Snyk, OWASP ZAP, Jest, TypeScript, Chrome DevTools

EXAMPLE VULNERABILITIES:
1. DOM-based XSS:
   ❌ document.getElementById('output').innerHTML = userInput
   ✅ document.getElementById('output').textContent = userInput

2. Unhandled Promise:
   ❌ asyncFunction().then(...)
   ✅ asyncFunction().then(...).catch(err => handle(err))

3. Memory Leak:
   ❌ element.addEventListener('click', handler)
   ✅ element.addEventListener('click', handler); element.removeEventListener('click', handler)
```

### Go
```
COMMON BUG PATTERNS:
├─ Goroutine leaks → [CRITICAL] Always close channels or use context
├─ Deadlocks in channels → [CRITICAL] Understand channel direction
├─ Nil pointer dereferences → [HIGH] Check for nil before dereferencing
├─ Slice bounds overflow → [HIGH] Check len() before indexing
├─ Map concurrent access → [HIGH] Use sync.Map or lock
├─ Defer in loops → [HIGH] Defer executes at function end, not loop end
├─ Interface{} type assertions → [MEDIUM] Check ok before using
└─ Improper error wrapping → [MEDIUM] Use fmt.Errorf("%w", err)

SECURITY VULNERABILITIES:
├─ Hardcoded credentials → [CRITICAL] Use environment variables
├─ SQL injection (concatenated) → [CRITICAL] Use prepared statements
├─ Path traversal → [HIGH] Validate path doesn't escape base
├─ Weak random → [HIGH] Use crypto/rand not math/rand
├─ Unvalidated redirects → [HIGH] Whitelist allowed URLs
├─ Insecure TLS config → [HIGH] Validate certificates
└─ Information disclosure → [HIGH] Don't log sensitive data

TOOLS: go vet, golangci-lint, go-staticcheck, govulncheck

EXAMPLE VULNERABILITIES:
1. Goroutine Leak:
   ❌ go func() { ... }()
   ✅ ctx, cancel := context.WithCancel(...); go func() { ... }(); defer cancel()

2. Defer in Loop:
   ❌ for i := 0; i < 10; i++ { defer file.Close() }
   ✅ for i := 0; i < 10; i++ { func() { defer file.Close(); ... }() }

3. SQL Injection:
   ❌ db.Query("SELECT * FROM users WHERE id=" + userID)
   ✅ db.Query("SELECT * FROM users WHERE id=?", userID)
```

### Rust
```
COMMON BUG PATTERNS:
├─ Borrow checker violations → [CRITICAL] Understand ownership rules
├─ Lifetime issues → [CRITICAL] Use proper lifetime annotations
├─ Panic in production → [HIGH] Use Result<T, E> instead
├─ Unsafe block misuse → [CRITICAL] Unsafe requires invariant proof
├─ Performance regressions → [MEDIUM] Profile with cargo flamegraph
├─ Async runtime issues → [MEDIUM] Use tokio or async-std consistently
└─ String encoding issues → [MEDIUM] Handle UTF-8 properly

SECURITY VULNERABILITIES:
├─ Unsafe code without guards → [CRITICAL] Never assume safety
├─ Integer overflow → [HIGH] Use checked_* operations
├─ Panic causing DoS → [HIGH] Use Result instead of unwrap()
├─ Insecure deserialization → [HIGH] Validate deserialized data
├─ Weak cryptography → [HIGH] Use established crates
├─ TLS issues → [HIGH] Validate certificates properly
└─ Dependency vulnerabilities → [MEDIUM] Run cargo audit

TOOLS: clippy, cargo audit, Miri, cargo-deny, criterion

EXAMPLE VULNERABILITIES:
1. Panic Instead of Error:
   ❌ let num: i32 = user_input.parse().unwrap()
   ✅ let num: i32 = user_input.parse()?

2. Integer Overflow:
   ❌ let result = a + b
   ✅ let result = a.checked_add(b)?

3. Unsafe Without Invariants:
   ❌ unsafe { *(user_ptr as *mut u32) = 0 }
   ✅ // Must ensure: user_ptr is valid, aligned, initialized
```

### Java
```
COMMON BUG PATTERNS:
├─ NullPointerException → [HIGH] Use Optional<T> or null checks
├─ Collections mutation during iteration → [HIGH] Use Iterator
├─ Thread synchronization issues → [CRITICAL] Use synchronized/Lock
├─ Memory leaks (static refs) → [HIGH] Clear static collections
├─ Improper exception handling → [HIGH] Don't catch Exception broadly
├─ Stream API incorrect usage → [MEDIUM] Streams are lazy
├─ ClassCastException → [MEDIUM] Check type before casting
└─ Resource leak → [HIGH] Use try-with-resources

SECURITY VULNERABILITIES:
├─ SQL injection → [CRITICAL] Use PreparedStatement
├─ Insecure deserialization → [CRITICAL] Validate gadget chains
├─ XXE (XML External Entity) → [CRITICAL] Disable external entities
├─ Hardcoded credentials → [CRITICAL] Use environment variables
├─ Path traversal → [HIGH] Validate file paths
├─ Broken authentication → [HIGH] Implement proper auth
├─ Information disclosure → [HIGH] Catch and log properly
└─ Dependency vulnerabilities → [MEDIUM] Check CVEs

TOOLS: SpotBugs, SonarQube, Checkmarx, OWASP Dependency-Check, JUnit

EXAMPLE VULNERABILITIES:
1. SQL Injection:
   ❌ stmt.execute("SELECT * FROM users WHERE id=" + userId)
   ✅ pstmt = conn.prepareStatement("SELECT * FROM users WHERE id=?"); pstmt.setInt(1, userId)

2. Resource Leak:
   ❌ FileInputStream fis = new FileInputStream(file)
   ✅ try (FileInputStream fis = new FileInputStream(file)) { ... }

3. Deserialization RCE:
   ❌ ObjectInputStream ois = new ObjectInputStream(input)
   ✅ Use JSON/Protocol Buffers instead, validate classes
```

### C++
```
COMMON BUG PATTERNS:
├─ Memory leaks (manual new/delete) → [CRITICAL] Use smart pointers
├─ Buffer overflows → [CRITICAL] Check bounds before access
├─ Dangling pointers → [CRITICAL] Initialize/clear pointers
├─ Double deletion → [CRITICAL] Set to nullptr after delete
├─ Iterator invalidation → [HIGH] Don't modify container during iteration
├─ Move semantics issues → [HIGH] Understand move semantics
├─ UB (undefined behavior) → [CRITICAL] Avoid UB entirely
└─ Threading race conditions → [CRITICAL] Use mutexes/atomics

SECURITY VULNERABILITIES:
├─ Stack buffer overflow → [CRITICAL] Use bounds checking
├─ Heap buffer overflow → [CRITICAL] Proper memory allocation
├─ Format string vulnerability → [CRITICAL] Use fmt::format not sprintf
├─ Integer overflow → [HIGH] Check before operations
├─ Use-after-free → [CRITICAL] Proper memory management
├─ Out-of-bounds access → [CRITICAL] Bounds checking
├─ Weak cryptography → [HIGH] Use modern libraries
└─ Code injection → [CRITICAL] Never execute user input

TOOLS: Valgrind, AddressSanitizer, ThreadSanitizer, Clang Static Analyzer, Coverity, CppCheck

EXAMPLE VULNERABILITIES:
1. Buffer Overflow:
   ❌ char buf[10]; strcpy(buf, user_input)
   ✅ char buf[10]; strncpy(buf, user_input, 9); buf[9] = 0

2. Memory Leak:
   ❌ int* ptr = new int(5)
   ✅ std::unique_ptr<int> ptr(new int(5))

3. Dangling Pointer:
   ❌ int* ptr = new int(5); delete ptr; *ptr = 10
   ✅ ptr = nullptr after delete before reuse
```

---

## OWASP Top 10: Vulnerabilities & PoC Examples

### 1. Broken Access Control
```
VULNERABILITY: Application doesn't properly enforce authorization

EXAMPLE PoC:
❌ GET /api/users/2  (User A can view User B's profile by modifying URL)

FIX:
✅ if (currentUser.id != requestedUserId && !currentUser.isAdmin) {
     throw new UnauthorizedException()
   }

TESTING CHECKLIST:
├─ [ ] Try accessing resources with different user IDs
├─ [ ] Test horizontal privilege escalation
├─ [ ] Test vertical privilege escalation
├─ [ ] Verify JWT/session token validation
└─ [ ] Check role-based access control
```

### 2. Cryptographic Failures
```
VULNERABILITY: Sensitive data exposed due to weak encryption

EXAMPLE PoC:
❌ password_hash = md5(password)  // Weak!

FIX:
✅ password_hash = bcrypt.hashpw(password, bcrypt.gensalt(12))

TESTING CHECKLIST:
├─ [ ] Check encryption algorithm (AES-256, not DES)
├─ [ ] Verify data encrypted in transit (TLS 1.2+)
├─ [ ] Check password hashing (bcrypt, argon2, scrypt)
├─ [ ] Verify key management (no hardcoded keys)
└─ [ ] Test data at rest encryption
```

### 3. Injection
```
VULNERABILITY: Untrusted data interpreted as code

EXAMPLE PoC - SQL Injection:
❌ query = "SELECT * FROM users WHERE username='" + username + "'"
   Attacker enters: admin' --

FIX:
✅ preparedStatement = conn.prepareStatement("SELECT * FROM users WHERE username=?")
   preparedStatement.setString(1, username)

EXAMPLE PoC - Command Injection:
❌ cmd = "cat " + filename; Runtime.getRuntime().exec(cmd)
   Attacker enters: test.txt; rm -rf /

FIX:
✅ ProcessBuilder pb = new ProcessBuilder("cat", filename)

TESTING CHECKLIST:
├─ [ ] SQL injection attempts
├─ [ ] NoSQL injection attempts
├─ [ ] Command injection attempts
├─ [ ] LDAP injection attempts
├─ [ ] Template injection attempts
└─ [ ] XML injection (XXE) attempts
```

### 4. Insecure Design
```
VULNERABILITY: Missing security controls at design level

EXAMPLE PoC:
❌ No rate limiting on login attempts (attacker brute forces password)

FIX:
✅ if (failedAttempts > 5) {
     lockoutAccount(5_MINUTES)
   }

TESTING CHECKLIST:
├─ [ ] Threat modeling completed
├─ [ ] Security requirements defined
├─ [ ] Rate limiting implemented
├─ [ ] Account lockout after N failures
├─ [ ] CSRF tokens on state-changing operations
└─ [ ] Principle of least privilege applied
```

### 5. Security Misconfiguration
```
VULNERABILITY: Insecure default settings or incomplete setup

EXAMPLE PoC:
❌ Debug mode enabled in production: <application debug="true">

FIX:
✅ <application debug="${DEBUG:false}">

TESTING CHECKLIST:
├─ [ ] Debug mode disabled
├─ [ ] Default credentials changed
├─ [ ] Unnecessary services disabled
├─ [ ] Security headers set
├─ [ ] Error messages don't leak info
├─ [ ] Outdated software updated
└─ [ ] Security misconfigurations scanned
```

### 6. Vulnerable & Outdated Components
```
VULNERABILITY: Using libraries with known vulnerabilities

EXAMPLE PoC:
❌ Using vulnerable lodash version 4.17.16 (prototype pollution)

FIX:
✅ npm install lodash@4.17.21

TESTING CHECKLIST:
├─ [ ] Run npm audit / pip-audit / cargo audit
├─ [ ] Check CVE databases
├─ [ ] Update all dependencies
├─ [ ] Remove unused dependencies
├�� [ ] Implement automated scanning
└─ [ ] Review dependency licenses
```

### 7. Authentication Failures
```
VULNERABILITY: Weak or broken authentication mechanisms

EXAMPLE PoC:
❌ Session fixation: User logs in, session stays same ID

FIX:
✅ session.regenerate(() => {
     session.userId = userId
   })

TESTING CHECKLIST:
├─ [ ] Session regenerated after login
├─ [ ] Session tokens have expiration
├─ [ ] Passwords properly hashed (bcrypt)
├─ [ ] MFA implemented
├─ [ ] Password reset tokens single-use
└─ [ ] No session fixation vulnerability
```

### 8. Data Integrity Failures
```
VULNERABILITY: Data modified without detection

EXAMPLE PoC:
❌ Unsigned JWT token: token = jwt.encode({"userId": 1}, algorithm="none")

FIX:
✅ token = jwt.encode({"userId": 1}, SECRET_KEY, algorithm="HS256")
   jwt.decode(token, SECRET_KEY, verify=True)

TESTING CHECKLIST:
├─ [ ] All tokens cryptographically signed
├─ [ ] Signatures verified before use
├─ [ ] No "none" algorithm allowed
├─ [ ] Data integrity checksums
└─ [ ] Secure serialization (not eval)
```

### 9. Logging & Monitoring Failures
```
VULNERABILITY: Insufficient logging/monitoring of security events

EXAMPLE PoC:
❌ No logging of failed login attempts (10,000 password guesses undetected)

FIX:
✅ logger.warn("Failed login attempt for user: " + username)
   if (failedAttempts > THRESHOLD) {
     alertSecurityTeam(username)
   }

TESTING CHECKLIST:
├─ [ ] Failed logins logged
├─ [ ] Failed authorization logged
├─ [ ] Data access logged
├─ [ ] Logs retained (6-12 months)
├─ [ ] Logs protected from tampering
├─ [ ] Alerting on suspicious activity
└─ [ ] Centralized log collection
```

### 10. SSRF (Server-Side Request Forgery)
```
VULNERABILITY: Server makes requests to unintended locations

EXAMPLE PoC:
❌ url = request.getParameter("imageUrl")
   image = fetch(url)  // Attacker enters: http://localhost:8080/admin

FIX:
✅ allowedDomains = ["images.example.com", "cdn.example.com"]
   if parsedUrl.domain not in allowedDomains:
     raise ValueError("Invalid domain")

TESTING CHECKLIST:
├─ [ ] Whitelist allowed hosts/domains
├─ [ ] No access to private IPs (127.0.0.1, 10.0.0.0/8)
├─ [ ] No access to cloud metadata (169.254.169.254)
├─ [ ] URL scheme validated (https only?)
├─ [ ] DNS rebinding protection
└─ [ ] Rate limiting on URL fetches
```

---

## CI/CD Pipeline Security Checklist

```
STAGE 1: CODE COMMIT
├─ [ ] Pre-commit hooks enabled
├─ [ ] No secrets in commit (check with git-secrets)
├─ [ ] Signed commits (GPG signature)
├─ [ ] Branch protection rules enforced
└─ [ ] Commit message format validated

STAGE 2: CODE ANALYSIS
├─ [ ] Static analysis runs (SonarQube, Bandit)
├─ [ ] Security scanning runs (Checkmarx, Fortify)
├─ [ ] Linting checks pass
├─ [ ] Type checking passes (TypeScript, mypy)
├─ [ ] Code coverage threshold met (>80%)
├─ [ ] Dependency audit runs (npm audit, pip-audit)
└─ [ ] OWASP scanning complete

STAGE 3: BUILD
├─ [ ] Build succeeds without warnings
├─ [ ] No debug symbols in release builds
├─ [ ] Version info embedded correctly
├─ [ ] Build artifacts signed/verified
├─ [ ] Build logs don't contain secrets
└─ [ ] Container image scanned (Trivy, Grype)

STAGE 4: TESTING
├─ [ ] Unit tests pass (>80% coverage)
├─ [ ] Integration tests pass
├─ [ ] Performance tests pass
├─ [ ] Security tests pass
├─ [ ] Load testing completed
├─ [ ] Compatibility tests pass
└─ [ ] SAST tool report reviewed

STAGE 5: SECURITY SCANNING
├─ [ ] Container image scanning (Trivy)
├─ [ ] Dependency vulnerability scan (Snyk)
├─ [ ] DAST (Dynamic scanning) completed
├─ [ ] Secrets scanning (TruffleHog)
├─ [ ] License compliance check
└─ [ ] Manual security review completed

STAGE 6: DEPLOYMENT
├─ [ ] Only approved commits deployed
├─ [ ] Blue-green deployment configured
├─ [ ] Automated rollback capability ready
├─ [ ] Monitoring/alerting activated
├─ [ ] Deployment to staging first
├─ [ ] Smoke tests pass after deployment
└─ [ ] Post-deployment security check

STAGE 7: POST-DEPLOYMENT
├─ [ ] APM (Application Performance Monitoring) active
├─ [ ] Security logging active
├─ [ ] Alert rules configured
├─ [ ] On-call team notified
├─ [ ] Deployment documented
├─ [ ] Rollback tested if needed
└─ [ ] Security incident response plan active
```

---

## Vulnerability Disclosure Template

```
═══════════════════════════════════════════════════════════════
SECURITY VULNERABILITY REPORT
═══════════════════════════════════════════════════════════════

TITLE: [Concise vulnerability title]
SEVERITY: [ ] CRITICAL [ ] HIGH [ ] MEDIUM [ ] LOW
CVSS SCORE: [e.g., 9.8 (CRITICAL)]
REPORTER: [Name/Organization]
REPORT DATE: [YYYY-MM-DD]

DESCRIPTION:
[Detailed explanation of the vulnerability]

AFFECTED COMPONENT(S):
- Component/Library: [name]
- Version(s): [affected versions]
- File(s): [specific files]

ROOT CAUSE:
[Technical explanation of why vulnerability exists]

IMPACT:
- Security Impact: [what attacker can do]
- Business Impact: [business consequences]
- Affected Users: [how many/who]

PROOF OF CONCEPT:
[Step-by-step reproduction]

CODE SNIPPET:
❌ VULNERABLE CODE: [code]
✅ FIXED CODE: [code]

RECOMMENDED FIX:
[Detailed fix instructions]

TEMPORARY WORKAROUND:
[Steps to reduce risk until patch]

PATCH AVAILABILITY:
- Target Release: [version]
- Release Date: [date]

TESTING:
HOW TO VERIFY FIX: [Steps to verify]
REGRESSION RESULTS: [ ] All tests pass [ ] No new vulnerabilities

TIMELINE:
- [DATE]: Vulnerability discovered
- [DATE]: Vendor notified
- [DATE]: Patch released
- [DATE]: Public disclosure

═══════════════════════════════════════════════════════════════
```

---

## Bug Report Template

```
═══════════════════════════════════════════════════════════════
BUG REPORT
═══════════════════════════════════════════════════════════════

TITLE: [Clear, concise bug title]
SEVERITY: [ ] CRITICAL [ ] HIGH [ ] MEDIUM [ ] LOW
ISSUE ID: [Auto-generated]
REPORTER: [Name]
REPORT DATE: [YYYY-MM-DD]

DESCRIPTION:
[What is the bug? What's the unexpected behavior?]

AFFECTED COMPONENT:
- Module/Feature: [name]
- Version: [version number]
- Environment: [dev/staging/production]

STEPS TO REPRODUCE:
1. [Step 1]
2. [Step 2]
3. [Expected result vs Actual result]

ACTUAL RESULT:
[What happens]

EXPECTED RESULT:
[What should happen]

ERROR MESSAGES:
[Any error messages, stack traces]

ENVIRONMENT:
- OS: [Windows/macOS/Linux]
- Browser: [if applicable]
- Language/Framework versions: [details]
- Dependencies: [list]

ROOT CAUSE:
[Technical explanation]

PROPOSED FIX:
[Suggested solution or code fix]

IMPLEMENTATION EFFORT: [ ] Easy [ ] Medium [ ] Hard

TESTING REQUIRED:
- [ ] Unit tests
- [ ] Integration tests
- [ ] Manual testing
- [ ] Performance testing
- [ ] Regression testing

FIX VERIFICATION:
[How to verify the fix works]

PRIORITY: [ ] P0 (Critical) [ ] P1 (High) [ ] P2 (Medium) [ ] P3 (Low)
ASSIGNED TO: [Team member]
TARGET FIX DATE: [YYYY-MM-DD]
TARGET RELEASE: [version]
LABELS: [bug, critical, security, etc.]

═══════════════════════════════════════════════════════════════
```

---

## Quick Reference Card

```
═══════════════════════════════════════════════════════════════
PROFESSIONAL-CODE-MASTERY QUICK REFERENCE
═══════════════════════════════════════════════════════════════

WHEN TO USE THIS SKILL:
├─ Finding bugs? → USE PHASE 0 FIRST
├─ Writing code? → USE PHASE 4-5
├─ Debugging? → USE PHASE 3
├─ Security issue? → USE PHASE 0
├─ Performance? → USE PHASE 6
└─ Large codebase? → USE LARGE CODEBASE NAVIGATION

ACTIVATION COMMAND:
└─ "Using professional-code-mastery to [specific task]"

7-PHASE FRAMEWORK:
├─ PHASE 0: Bug & Vulnerability Detection (7-layer analysis)
├─ PHASE 1: Issue Classification & Analysis
├─ PHASE 2: Multi-Source Research
├─ PHASE 3: Root Cause Analysis (Debugging)
├─ PHASE 4: Solution Design
├─ PHASE 5: Implementation (Zero-Defect)
├─ PHASE 6: Quality Assurance & Verification
└─ PHASE 7: Documentation & Knowledge Sharing

CRITICAL RULES:
├─ Phase 0 ALWAYS first for bug/security issues
├─ Follow ALL checklist items (no shortcuts)
├─ 100% accuracy target (not 99%)
├─ Research from official sources first
├─ Test all fixes before deployment
└─ Document everything

COMMON MISTAKES:
├─ ❌ Skipping Phase 0 vulnerability scanning
├─ ❌ Not researching before coding
├─ ❌ Rushing implementation without design
├─ ❌ Insufficient testing
├─ ❌ Poor documentation
├─ ❌ Not considering edge cases
└─ ❌ Ignoring security implications

SEVERITY LEVELS:
├─ 🔴 CRITICAL: RCE, privilege escalation, data breach (fix immediately)
├─ 🟠 HIGH: Significant security issue, data exposure (fix in 24h)
├─ 🟡 MEDIUM: Minor security, moderate performance (fix in 1 week)
└─ 🟢 LOW: Code style, minor optimization (normal sprint)

SUCCESS METRICS:
├─ Bugs found: 100% of critical/high severity
├─ False positives: <10%
├─ Test coverage: >80%
├─ Security scan: 0 critical vulnerabilities
└─ Performance regression: <5%

TOOLS BY LANGUAGE:
├─ Python: Bandit, SonarQube, pytest, mypy
├─ JavaScript: ESLint, Snyk, OWASP ZAP, Jest
├─ Go: go vet, golangci-lint, govulncheck
├─ Rust: clippy, cargo audit, Miri
├─ Java: SpotBugs, SonarQube, Checkmarx
└─ C++: Valgrind, AddressSanitizer, Clang Analyzer

ALWAYS REMEMBER:
├─ Quality > Speed
├─ Prevention > Fixing
├─ Security > Features
├─ Documentation > Code
└─ Testing > Assumptions

═══════════════════════════════════════════════════════════════
```

---

## Large Codebase Navigation (20K+ Lines)

```
INDEXING PHASE:
├─ [ ] List all files & directory structure
├─ [ ] Identify entry points (main, init, index)
├─ [ ] Map core modules & their purposes
├─ [ ] Create dependency graph
├─ [ ] Find test files & test strategy
├─ [ ] Identify configuration files
└─ [ ] Document build process

PATTERN RECOGNITION PHASE:
├─ [ ] Identify design patterns used
├─ [ ] Note naming conventions
├─ [ ] Spot anti-patterns & technical debt
├─ [ ] Classify modules by function
├─ [ ] Find similar code patterns
├─ [ ] Identify configuration points
└─ [ ] Document implicit contracts

DEEP DIVE PHASE:
├─ [ ] Trace execution flow (startup to issue)
├─ [ ] Map data transformations
├─ [ ] Identify state management
├─ [ ] Find relevant configuration
├─ [ ] Trace error handling paths
├─ [ ] Identify performance hotspots
└─ [ ] Find security-relevant code

SOLUTION PHASE:
├─ [ ] Research best practices
├─ [ ] Check for existing similar fixes
├─ [ ] Design minimal fix
├─ [ ] Identify all affected code paths
├─ [ ] Plan testing strategy
├─ [ ] Consider backward compatibility
└─ [ ] Document changes
```

---

## Success Metrics

```
ACCURACY METRICS:
├─ Bugs found: 100% of critical/high severity
├─ False positives: <10% of reported issues
├─ Root cause identification: 100%
├─ Code review issues: 0 critical, <3 minor per PR
├─ Test coverage: >80%
├─ Static analysis: 0 high-severity
├─ Security scan results: 0 critical vulnerabilities
└─ Performance regression: <5%

RELIABILITY METRICS:
├─ Uptime: >99.9%
├─ Bug escape rate: <0.1% (critical only)
├─ Mean Time to Recovery: <15 minutes
├─ Customer-reported issues: <0.5 per release
└─ Regression rate: 0%

EFFICIENCY METRICS:
├─ Deployment frequency: Daily or more
├─ Lead time for changes: <1 day
├─ Build time: <10 minutes
├─ Code review time: <24 hours
└─ Time to fix: <2 hours (critical)
```

---

## Quick Activation

When you need to use this skill:

```
1. READ THE PRE-FLIGHT CHECKLIST (above)
   Complete the 4-item task classification

2. ANNOUNCE THE ACTIVATION
   "Using professional-code-mastery to [your specific task]"

3. SELECT THE RELEVANT PHASE(S)
   - Phase 0: Bug & Vulnerability Detection (ALWAYS START HERE FOR BUG-HUNTING)
   - Phase 1: Classification (always)
   - Phase 2: Research (for unknown issues)
   - Phase 3: Debugging (for bugs)
   - Phase 4: Design (for new code)
   - Phase 5: Implementation (for coding)
   - Phase 6: QA (for verification)
   - Phase 7: Documentation (for completion)

4. FOLLOW THE FRAMEWORK EXACTLY
   Execute all checkboxes & steps
   No shortcuts, no exceptions

5. DELIVER ZERO-DEFECT RESULT
   Quality > Speed
   Verification > Assumptions
   Best practices > Quick fixes
```

---

## Red Flags: When to Invoke This Skill

These thoughts mean STOP — you're rationalizing:

| Thought | Reality |
|---------|---------|
| "This is just a simple bug fix" | All bugs deserve systematic analysis |
| "I can figure this out quickly" | Quick fixes often create new bugs |
| "Let me just search GitHub first" | Check this skill BEFORE searching |
| "I'll explore the code myself" | Skills guide exploration efficiently |
| "This doesn't need testing" | Everything needs verification |
| "I remember the solution" | Context changes, skill framework applies always |
| "The error is obvious" | Obvious errors often hide root causes |
| "I can skip the research" | Research prevents wrong fixes |
| "Documentation is not important" | Documentation is part of professionalism |
| "Performance isn't critical" | Every optimization matters at scale |
| "Security can be added later" | Security must be built-in |
| "I know best practices" | Knowing ≠ using the skill consistently |
| "This is not a vulnerability" | Use vulnerability checklist to verify |
| "I don't need security scanning" | Automated tools catch what humans miss |

---

## User Instructions Override

User instructions (CLAUDE.md, AGENTS.md, PROJECT.md, direct requests) take precedence over this skill.

If a user explicitly says "don't use the checklist" or "skip the testing phase", follow their instruction.

Otherwise: **THIS SKILL IS MANDATORY** for all coding, debugging, security, and code review tasks.

---

## Conclusion

This is your **master framework** for:
- ✅ Finding & fixing bugs with 100% accuracy
- ✅ Detecting vulnerabilities & security issues (with PoC examples)
- ✅ Writing professional code in any language (6+ languages covered)
- ✅ Analyzing massive codebases (20K+ lines)
- ✅ Security hardening & penetration analysis
- ✅ Performance optimization
- ✅ CI/CD pipeline security
- ✅ Professional vulnerability & bug reporting
- ✅ Zero-defect delivery guarantee

**Invoke this skill at the START of EVERY coding task. No exceptions.**

---

**Version:** 4.0.0 (Enterprise-Grade Professional Mastery Framework with Deep Security & PoC)  
**Status:** Active & Mandatory  
**Compatibility:** All languages, all codebase sizes  
**Enterprise Ready:** ✅ Production Validated  
**Last Updated:** 2026-07-26
