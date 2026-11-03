# Using The Hubble Command Line

The Hubble command-line tool is the most direct way to ask the network what happened. It prints flows, filters them by pod, port, verdict and time, and shows them in several output formats. During an incident, you use it to answer three questions quickly: which traffic is affected, what Cilium decided, and where the decision was made.

This module teaches the command `hubble observe` and its filters, and the two ways to run the tool: inside a Cilium agent pod, and on your own machine through Hubble Relay. It then applies the tool to a real task: finding the pod whose requests are dropped and deciding what to change.

The module has two parts. **Connect The Hubble CLI And Observe Flows** explains how the tool reaches a Hubble API, the output formats and the first filters. **Filter Flows To Find A Dropped Client** works through a drop investigation with combined filters and ends with a safe policy change.

## Learning objectives

After this module you can:

- Run `hubble` inside the agent pod and through Relay and explain the difference in scope.
- Check the status of the Hubble API with `hubble status` and `hubble list nodes`.
- Choose an output format: compact, JSON or dictionary.
- Filter flows by pod, namespace, port, protocol, verdict, direction and time.
- Find the source and the destination of dropped traffic and the destination port.
- Change a policy to allow one workload without allowing others.

## Before you start

You should know how to read a flow record and its verdict. You should know what a Kubernetes label selector is, because the policy change uses one.

Your playground is a single-node `kind` cluster with Cilium, Hubble and Hubble Relay. The `starfleet` namespace holds the `probe` Deployment and Service on port 8080 and the client pod `shuttle`. The `outpost` namespace holds the client pods `drifter` and `rogue`. The policy `probe-ingress` allows only `shuttle` to reach port 8080 of the `probe`. The `rogue` pod sends a request every 5 seconds, and the policy drops it. The Hubble command-line tool is not installed on your machine, so you run it inside the agent pod.

Launch your playground now and keep it running while you read:

<!-- astrona:playground -->
