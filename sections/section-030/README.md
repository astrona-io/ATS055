# Section 030: Know How to Use Hubble from the Command Line or the Hubble UI

This section teaches the two ways to read flows. The command-line tool is exact and scriptable, and the UI draws a service map. You learn how each connects to Hubble, how to filter flows to find a dropped client, how to repair a Hubble UI Service that has no endpoint and how to read the service map and the flows table.

**Curriculum item covered:** Know How to Use Hubble from the Command Line or the Hubble UI

---

## Learning Outcomes

- Run the Hubble command-line tool inside an agent pod and through Relay and state the scope of each.
- Choose compact, dictionary or JSON output and combine filters.
- Find the source, destination and port of dropped traffic and change a policy narrowly.
- Open the Hubble UI and diagnose a Service without endpoints.
- Read the service map and the flows table and match them to a policy.

---

## The Learning Path

### 1. Using The Hubble Command Line
*   **Module Reader:** **[Module 1: Using The Hubble Command Line](./module-01/course.md)**
*   **Hands-on Playground:** `sections/section-030/module-01/playground` - kind cluster with Cilium, Hubble and Relay. The policy `probe-ingress` and the pod `rogue` produce dropped flows every 5 seconds.
    ```bash
    astrona run --git ssh://git@github.com/astrona-io/ATS055.git -c sections/section-030/module-01/playground
    ```

### 2. Using The Hubble UI
*   **Module Reader:** **[Module 2: Using The Hubble UI](./module-02/course.md)**
*   **Hands-on Playground:** `sections/section-030/module-02/playground` - the same cluster with the Hubble UI enabled.
    ```bash
    astrona run --git ssh://git@github.com/astrona-io/ATS055.git -c sections/section-030/module-02/playground
    ```

### Capstone
*   **Lab:** `sections/section-030/capstone/labs/lab-01` - repair the UI and use the command line and the UI together.

### Knowledge check
*   `sections/section-030/quiz.yaml` - ten questions on this section.

All graded labs are UNTESTED. They passed static checks only.
