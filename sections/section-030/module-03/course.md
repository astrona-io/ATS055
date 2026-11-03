# Troubleshooting With Hubble

Most Hubble sessions start with a complaint: a request fails, a pod cannot connect, a name does not resolve. The tools are the same each time, but the order in which you use them decides how fast you find the cause. This module teaches a method for network problems in a Cilium cluster and the commands for each step.

The module has four parts. **Start With The Verdict** finds the dropped flows and reads their drop reasons. **Policy Verdicts And Who Decided** shows which policy allowed or denied a flow. **DNS And Name Problems** applies the method to lookups. **Hubble Compared With The Agent Monitor** explains when to use the node-level tools instead.

## Learning objectives

After this module you can:

- Follow a fixed method from a symptom to a cause with Hubble.
- Read the drop reasons that the datapath reports.
- Use policy verdict events to see which direction and rule decided.
- Find DNS failures and tell a refused query from a timeout.
- Choose between `hubble observe` and the agent monitor.

## Before you start

You need to read a flow and its verdict, and to use the filters of `hubble observe`. You should know what a `CiliumNetworkPolicy` is.

Your playground is a single-node `kind` cluster with Cilium, Hubble and Hubble Relay. The `starfleet` namespace holds the `probe` Deployment and Service on port 8080 and the client pod `shuttle`. The `outpost` namespace holds the client pod `drifter` and the pod `rogue`, which sends a request to the `probe` every 5 seconds. The policy `probe-ingress` lets only `shuttle` reach port 8080.

Launch your playground now and keep it running while you read:

<!-- astrona:playground -->
