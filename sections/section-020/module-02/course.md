# DNS Visibility And Protocol Limits

Before a client sends a request to a Service by name, it asks the cluster DNS (Domain Name System) for the address of that name. A failed lookup is a common cause of failed requests, and layer 4 flows show only UDP packets to port 53 with no names. Cilium can show the names that a pod looks up, but only through a policy, and only for the traffic that leaves the pod.

This module explains how DNS visibility works, what policy it needs and what that policy does to the other egress traffic of the pod. It also states the limits of layer 7 visibility: which traffic stays hidden even with a policy.

The module has four parts. The first two are: **How DNS Visibility Works** explains the DNS path in Kubernetes, the DNS proxy and the effect of an egress policy. **Write A DNS Rule And Read DNS Flows** builds the rule, reads the DNS flows and tests the limits.

The other two parts are: **FQDN Selectors And Name Patterns** separates the DNS rule from the `toFQDNs` selector, and **DNS Proxy Behaviour And Limits** explains the FQDN cache, the time to live and what the proxy cannot see.

## Learning objectives

After this module you can:

- Describe the path of a DNS lookup from a pod to the cluster DNS.
- Explain why DNS visibility needs an egress policy and what that policy restricts.
- Write a `CiliumNetworkPolicy` with a `dns` rule for UDP and TCP port 53.
- Read a DNS flow and find the queried name and type.
- Explain why Hubble shows egress DNS and not ingress DNS for a pod.
- Name traffic that stays hidden at layer 7, such as HTTPS.
- Tell a `dns` rule from a `toFQDNs` selector and write a name pattern.
- Explain the FQDN cache and the traffic the DNS proxy cannot see.

## Before you start

You should know how to read a flow and what a `CiliumNetworkPolicy` is. You should also know that a Kubernetes Service has a DNS name of the form `service.namespace`.

Your playground is a single-node `kind` cluster with Cilium, Hubble and Hubble Relay. The `starfleet` namespace holds the `probe` Deployment and Service on port 8080, and the client pod `shuttle`. The `outpost` namespace holds the client pod `drifter`. The policy `probe-ingress` lets `shuttle` reach port 8080 of the `probe`. No policy selects `shuttle` as the source yet, so its egress traffic is unrestricted and Hubble shows no DNS details.

Launch your playground now and keep it running while you read:

<!-- astrona:playground -->
