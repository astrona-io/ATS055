# Section 020: Enabling Layer 7 Protocol Visibility

Layer 3 and 4 flows show who connected to whom. This section teaches how to see the request itself. Cilium sends the traffic of selected pods through the Envoy proxy in the agent, and the proxy reports HTTP requests and DNS lookups to Hubble. You learn what triggers the redirect, how to write HTTP and DNS rules, what the policy does to the other traffic and which traffic stays hidden.

**Curriculum item covered:** Enabling Layer 7 Protocol Visibility

---

## Learning Outcomes

- Distinguish layer 4 flows from layer 7 flows and name the component that produces each.
- Explain why layer 7 visibility needs a policy and why that policy also enforces.
- Write an HTTP rule with a method and a path, and predict the answer to a request that breaks it.
- Write a DNS rule for UDP and TCP port 53 and read DNS flows.
- Explain the effect of an egress policy on the other traffic of a pod.
- Name traffic that stays hidden, such as HTTPS content.

---

## The Learning Path

### 1. HTTP Visibility With Layer 7 Policy
*   **Module Reader:** **[Module 1: HTTP Visibility With Layer 7 Policy](./module-01/course.md)**
*   **Hands-on Playground:** `sections/section-020/module-01/playground` - kind cluster with Cilium, Hubble and Relay. The policy `probe-ingress` allows `shuttle` to reach port 8080 of the `probe` at layer 4 only.
    ```bash
    astrona run --git ssh://git@github.com/astrona-io/ATS055.git -c sections/section-020/module-01/playground
    ```

### 2. DNS Visibility And Protocol Limits
*   **Module Reader:** **[Module 2: DNS Visibility And Protocol Limits](./module-02/course.md)**
*   **Hands-on Playground:** `sections/section-020/module-02/playground` - the same cluster. No policy selects `shuttle` as a source yet.
    ```bash
    astrona run --git ssh://git@github.com/astrona-io/ATS055.git -c sections/section-020/module-02/playground
    ```

### Capstone
*   **Lab:** `sections/section-020/capstone/labs/lab-01` - layer 7 visibility for HTTP and DNS, with the HTTP metric.

### Knowledge check
*   `sections/section-020/quiz.yaml` - ten questions on this section.

All graded labs are UNTESTED. They passed static checks only.
