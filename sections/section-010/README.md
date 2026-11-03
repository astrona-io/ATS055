# Section 010: Understand the Observability Capabilities of Hubble

This section teaches what Hubble records and how long it keeps it. A flow is one record of one network event, and Hubble is the part of Cilium that stores and serves those records. You learn which component creates a flow, which component joins the flows of many nodes, how to read a single flow and its verdict, how to count events with metrics and how to size the buffer that holds the flows.

**Curriculum item covered:** Understand the Observability Capabilities of Hubble

---

## Learning Outcomes

- Explain which component creates, stores and serves flows: the Hubble server in the Cilium agent, Hubble Relay, the command-line tool and the UI.
- Distinguish the scope of one agent from the scope of Relay.
- Read the source, destination, direction, verdict and drop reason of a flow.
- Interpret forwarded and dropped verdicts without overclaiming application success.
- Enable Hubble metrics and read the drop counter from the metrics endpoint.
- Size the flow buffer with a valid capacity and explain what a restart removes.
- Explain identities, reserved identities and how a flow gets its names.
- Describe the two Relay connections and which one uses mutual TLS by default.
- Choose metric groups and label contexts, and explain how Prometheus scrapes them.
- Export flows to a file with filters and field masks, and explain rotation.

---

## The Learning Path

### 1. Hubble Components And Flow Records
*   **Module Reader:** **[Module 1: Hubble Components And Flow Records](./module-01/course.md)**
*   **Hands-on Playground:** `sections/section-010/module-01/playground` - kind cluster with Cilium, Hubble and Hubble Relay. Namespaces `starfleet` and `outpost`, the `probe` Service on port 8080, the clients `shuttle`, `drifter` and `rogue`, and the policy `probe-ingress`.
    ```bash
    astrona run --git ssh://git@github.com/astrona-io/ATS055.git -c sections/section-010/module-01/playground
    ```

### 2. Hubble Metrics And Flow Buffer Sizing
*   **Module Reader:** **[Module 2: Hubble Metrics And Flow Buffer Sizing](./module-02/course.md)**
*   **Hands-on Playground:** `sections/section-010/module-02/playground` - the same cluster with Hubble metrics off and the default flow buffer.
    ```bash
    astrona run --git ssh://git@github.com/astrona-io/ATS055.git -c sections/section-010/module-02/playground
    ```

### 3. Hubble Flow Export
*   **Module Reader:** **[Module 3: Hubble Flow Export](./module-03/course.md)**
*   **Hands-on Playground:** `sections/section-010/module-03/playground` - the same cluster. Flow export is off.
    ```bash
    astrona run --git ssh://git@github.com/astrona-io/ATS055.git -c sections/section-010/module-03/playground
    ```

### Capstone
*   **Lab:** `sections/section-010/capstone/labs/lab-01` - observe dropped traffic end to end: metrics, a larger buffer and a report of the drop.

### Knowledge check
*   `sections/section-010/quiz.yaml` - fifteen questions on this section.

All graded labs are UNTESTED. They passed static checks only.
