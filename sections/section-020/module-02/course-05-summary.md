# Summary

A DNS lookup is the first step of every request by name, and a failed lookup looks like a network failure. Hubble can show each lookup with its name and type, but only when the traffic goes through the Cilium DNS proxy.

## What you learned

A pod sends its lookups to the cluster DNS, usually CoreDNS pods in `kube-system`, over UDP and TCP port 53. A short name can produce several lookups because of the search domains, and some of them end with a name-not-found answer by design. The kernel programs see only UDP traffic to port 53. The DNS proxy in the agent reads the names.

An egress policy with a `dns` rule sends the DNS traffic of the selected pod through the proxy and records each query and answer as a layer 7 flow. The same policy turns on egress enforcement for the pod, so every other egress that the pod needs must be allowed in the policy, including the connection to the target service. The rule lists both UDP and TCP on port 53. A `matchPattern` of `*` records all names, and a `matchName` or narrower pattern also restricts which names the pod may resolve.

A DNS flow shows the query name, the record type and the verdict. It does not show whether the later connection worked. Layer 7 visibility reads only the protocols the proxy understands and only for the endpoints and ports that a rule selects. HTTPS content stays hidden, and other protocols show only at layer 4.

## Key facts

- The `dns` rule is written under `toPorts`, in `rules.dns`, on an egress rule.
- DNS visibility needs an egress policy on the client pod.
- Any egress policy denies all egress that it does not list.
- `--protocol dns` filters DNS flows; the type `A` is IPv4 and `AAAA` is IPv6.
- An HTTPS request gives a DNS flow and no HTTP flow.

<!-- astrona:playground:destroy -->
