# Curriculum Coverage

Exam: Cilium Certified Associate (CCA). Domain: Network Observability (10%).

The [official objectives](https://training.linuxfoundation.org/certification/cilium-certified-associate-cca/) were checked on 2026-10-11. Teaching structure is independently authored and does not add official requirements.

| Section | Official objective | Modules | Capstone | Quiz |
| --- | --- | --- | --- | --- |
| 010 | Understand the Observability Capabilities of Hubble | 2 | Observe Dropped Traffic End To End | sections/section-010/quiz.yaml |
| 020 | Enabling Layer 7 Protocol Visibility | 2 | Layer 7 Visibility For HTTP And DNS | sections/section-020/quiz.yaml |
| 030 | Know How to Use Hubble from the Command Line or the Hubble UI | 2 | Use The Hubble CLI And UI Together | sections/section-030/quiz.yaml |

| Section / module | Module | Parts |
| --- | --- | --- |
| 010 / 01 | Hubble Components And Flow Records | Hubble Components And Where Flows Come From; Reading A Flow Record And Its Verdict |
| 010 / 02 | Hubble Metrics And Flow Buffer Sizing | Enable And Read Hubble Metrics; Size The Flow Buffer |
| 020 / 01 | HTTP Visibility With Layer 7 Policy | How Layer 7 Visibility Works; Write HTTP Rules And Read HTTP Flows |
| 020 / 02 | DNS Visibility And Protocol Limits | How DNS Visibility Works; Write A DNS Rule And Read DNS Flows |
| 030 / 01 | Using The Hubble Command Line | Connect The Hubble CLI And Observe Flows; Filter Flows To Find A Dropped Client |
| 030 / 02 | Using The Hubble UI | Hubble UI Components And Access; Read The Service Map And The Flows Table |

The final domain quiz is sections/final-domain-quiz.yaml. All technical readings remain draft. Live verification is not recorded: no lab or playground has been run.

## Hands-On Coverage

| Where | Lab |
| --- | --- |
| 010 / 01 | Read Forwarded And Dropped Flows |
| 010 / 02 | Enable Hubble Drop Metrics And Resize The Flow Buffer |
| 010 capstone | Observe Dropped Traffic End To End |
| 020 / 01 | Add HTTP Visibility With A Policy |
| 020 / 02 | Make DNS Requests Visible |
| 020 capstone | Layer 7 Visibility For HTTP And DNS |
| 030 / 01 | Find The Dropped Client With The Hubble CLI |
| 030 / 02 | Repair The Hubble UI |
| 030 capstone | Use The Hubble CLI And UI Together |
