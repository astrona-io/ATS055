# Network Observability (ATS055)

Cilium Certified Associate (CCA): Network Observability, worth 10% of the official curriculum. This course belongs to ATP011.

Developed reading explains mechanisms, responsible components, examples and limits. Every section has an introduction, every module closes with a summary, and every section has a capstone lab and a fifteen-question knowledge check. A final domain quiz closes the course. Technical content remains draft. All playgrounds and graded labs are UNTESTED: they passed static checks only.

## Course Outline

| Section / module | Module | Parts |
| --- | --- | --- |
| 010 / 01 | Hubble Components And Flow Records | Hubble Components And Where Flows Come From; Reading A Flow Record And Its Verdict; Identities And Endpoints In A Flow; Hubble Relay Security And TLS |
| 010 / 02 | Hubble Metrics And Flow Buffer Sizing | Enable And Read Hubble Metrics; Size The Flow Buffer; Metric Groups And Label Contexts; Scrape Hubble Metrics With Prometheus |
| 010 / 03 | Hubble Flow Export | Why Export Flows; Static Export Configuration; Filters And Field Masks; Dynamic Export And Rotation |
| 020 / 01 | HTTP Visibility With Layer 7 Policy | How Layer 7 Visibility Works; Write HTTP Rules And Read HTTP Flows; HTTP Rule Matching: Method, Path And Headers; Verify HTTP Visibility And Verdicts |
| 020 / 02 | DNS Visibility And Protocol Limits | How DNS Visibility Works; Write A DNS Rule And Read DNS Flows; FQDN Selectors And Name Patterns; DNS Proxy Behaviour And Limits |
| 020 / 03 | Layer 7 Metrics And Protocol Limits | What The Proxy Can Parse; Encrypted Traffic And TLS; HTTP And DNS Metrics; Proxy Cost And Troubleshooting |
| 030 / 01 | Using The Hubble Command Line | Connect The Hubble CLI And Observe Flows; Filter Flows To Find A Dropped Client; Output Formats And jq; Advanced Flow Filters |
| 030 / 02 | Using The Hubble UI | Hubble UI Components And Access; Read The Service Map And The Flows Table; Namespace Filters And Layer 7 In The UI; Troubleshooting The Hubble UI |
| 030 / 03 | Troubleshooting With Hubble | Start With The Verdict; Policy Verdicts And Who Decided; DNS And Name Problems; Hubble Compared With The Agent Monitor |

## Hands-On Coverage

This course has 9 ungraded playgrounds, 9 module labs and 3 capstone labs. Each lab follows the part it practises.

| Where | Lab |
| --- | --- |
| 010 / 01 | Read Forwarded And Dropped Flows |
| 010 / 02 | Enable Hubble Drop Metrics And Resize The Flow Buffer |
| 010 / 03 | Hubble Flow Export | Why Export Flows; Static Export Configuration; Filters And Field Masks; Dynamic Export And Rotation |
| 010 / 03 | Export Dropped Flows To A File |
| 010 capstone | Observe Dropped Traffic End To End |
| 020 / 01 | Add HTTP Visibility With A Policy |
| 020 / 02 | Make DNS Requests Visible |
| 020 / 03 | Layer 7 Metrics And Protocol Limits | What The Proxy Can Parse; Encrypted Traffic And TLS; HTTP And DNS Metrics; Proxy Cost And Troubleshooting |
| 020 / 03 | Count HTTP Requests With Hubble Metrics |
| 020 capstone | Layer 7 Visibility For HTTP And DNS |
| 030 / 01 | Find The Dropped Client With The Hubble CLI |
| 030 / 02 | Repair The Hubble UI |
| 030 / 03 | Troubleshooting With Hubble | Start With The Verdict; Policy Verdicts And Who Decided; DNS And Name Problems; Hubble Compared With The Agent Monitor |
| 030 / 03 | Diagnose A Dropped Pod With Hubble |
| 030 capstone | Use The Hubble CLI And UI Together |

## Author Review

See [curriculum coverage](CURRICULUM.md), [primary sources](SOURCES.md), [question-bank documentation](ASSESSMENTS.md) and [contribution instructions](CONTRIBUTING.md). No runtime execution is claimed.
