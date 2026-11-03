# Summary

Troubleshooting with Hubble follows a fixed order, which keeps a session short. The first question is whether the network dropped the traffic. A dropped flow gives a pair of pods and a drop reason. An empty drop list shows that the cause is elsewhere, such as the application or a name lookup.

## What you learned

The drop reason names the check that dropped the packet. `POLICY_DENIED` leads to the policies, and the other reasons lead to the datapath or the state of the endpoint. Policy verdict events show the direction, the endpoint and the kind of rule that matched, so a fix can be precise and narrow. After a fix, the same filters show a forwarded verdict, and the pods that must stay refused must still be dropped.

DNS failures look like network failures. Flows to port 53 show whether the query left the pod. Layer 7 DNS flows show the names and the response codes. `NXDOMAIN` means that the name does not exist, `REFUSED` means that a rule or server refused it, and a query without a response means a timeout.

Hubble and the agent monitor use the same events. Hubble adds names, filters and cluster-wide views. The monitor works without Hubble and shows raw events of one node. The endpoint and policy commands show what the agent holds.

## Key facts

- Start with `--verdict DROPPED`, then read the drop reason.
- `--type policy-verdict` shows the direction and the match type of a decision.
- A refused query has a response flow; a timeout has none.
- The agent command is `cilium-dbg` in current releases.

<!-- astrona:playground:destroy -->
