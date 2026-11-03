# Hubble Metrics And Flow Buffer Sizing

Flow records answer the question of what happened to one request. They do not answer how often something happens or how long the records stay available. Metrics answer the first question, and the size of the flow buffer decides the second. This module shows how to turn on Hubble metrics, read them, and size the buffer that holds the flows.

A metric is a number that a component exposes and that a monitoring system reads at intervals. Hubble can count flows, drops, DNS requests, TCP events and HTTP requests. A counter such as the number of dropped flows is cheap to store for weeks, while the flow records themselves are kept only in memory.

The module has four parts. The first two are: **Enable And Read Hubble Metrics** explains which metrics exist, how the agent exposes them and how to read the drop counter. **Size The Flow Buffer** explains the ring buffer, its allowed sizes, how to change it and what a restart does to the recorded flows.

The other two parts are: **Metric Groups And Label Contexts** lists the groups and the options that shape their labels, and **Scrape Hubble Metrics With Prometheus** shows the Service, the `ServiceMonitor` and the queries.

## Learning objectives

After this module you can:

- Name the Hubble metric groups and the Cilium setting that enables them.
- Read the Hubble metrics endpoint of an agent and find a counter by name.
- Explain why a metric is not a flow record and what each is good for.
- Name the allowed values of the flow buffer capacity and the default.
- Change the buffer capacity and restart the agent so the change takes effect.
- Explain what is lost when the agent restarts.
- Name the metric groups and choose a label context with a stable number of series.
- Explain how Prometheus finds and scrapes the agents.

## Before you start

You need to read a ConfigMap and run `kubectl patch` and `kubectl rollout`. You should know how to read a flow with `hubble observe`.

Your playground is a single-node `kind` cluster with Cilium and Hubble Relay. The Hubble metrics are off at the start. The `starfleet` namespace holds the `probe` Deployment and Service and the `shuttle` pod. The `outpost` namespace holds the `drifter` pod. The `outpost` namespace also holds the `rogue` pod, which sends a request to the `probe` every 5 seconds. The policy `probe-ingress` drops that request, so the playground produces a steady stream of dropped flows to count.

Launch your playground now and keep it running while you read:

<!-- astrona:playground -->
