# Layer 7 Metrics And Protocol Limits

Layer 7 flows show single requests, but an operations team needs rates and error counts over time, and every engineer needs to know what layer 7 visibility cannot show. This module covers both: how the proxy decides what it can parse, why encrypted traffic stays opaque, how to turn HTTP and DNS flows into metrics, and what the proxy costs and how it fails.

The module has four parts. **What The Proxy Can Parse** lists the protocols and the rules that select traffic. **Encrypted Traffic And TLS** explains why HTTPS requests do not appear. **HTTP And DNS Metrics** enables the `httpV2` and `dns` metric groups and reads them. **Proxy Cost And Troubleshooting** explains the cost of the proxy and how to find out why a flow is missing.

## Learning objectives

After this module you can:

- Name the protocols that the Cilium proxy parses and say what happens to other traffic.
- Explain why a request inside TLS has no HTTP flow.
- Enable the `httpV2` and `dns` metric groups and read their counters.
- Choose label contexts that keep the number of series small.
- Explain the cost of the proxy and diagnose a missing layer 7 flow.

## Before you start

You need to know what a layer 7 flow is and how an HTTP rule or a DNS rule makes the proxy parse traffic. You should know how to edit the `cilium-config` ConfigMap and restart the Cilium DaemonSet.

Your playground is a single-node `kind` cluster with Cilium, Hubble and Hubble Relay. The `starfleet` namespace holds the `probe` Deployment and Service on port 8080 and the client pod `shuttle`. The `outpost` namespace holds the client pod `drifter`. The policy `probe-ingress` lets only `shuttle` reach port 8080 and has no HTTP rule yet. Hubble metrics are off.

Launch your playground now and keep it running while you read:

<!-- astrona:playground -->
