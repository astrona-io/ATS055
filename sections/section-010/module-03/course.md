# Hubble Flow Export

The flows in the ring buffer disappear when the buffer wraps around. Some teams must keep a record of traffic for audits, for a security analysis or for a tool that searches logs. Hubble can write flows to a file as they happen, and a log collector can then ship the file to long-term storage.

This module shows how the exporter works, how to switch it on, how to choose which flows and which fields it writes, and how the file is rotated. The exporter is a second output of the same Hubble server: it does not change the ring buffer or the metrics.

The module has four parts. **Why Export Flows** explains what the exporter adds to the ring buffer. **Static Export Configuration** sets up the file. **Filters And Field Masks** limits the content. **Dynamic Export And Rotation** covers several export files that change without a restart and the rotation of the files.

## Learning objectives

After this module you can:

- Say why the ring buffer is not enough for audits and what the exporter adds.
- Enable the static exporter and find the file in the agent pod.
- Select flows with an allow list and a deny list.
- Reduce the size of each record with a field mask.
- Explain how dynamic export and file rotation work.

## Before you start

You need to know what a Hubble flow and a verdict are, and how to edit the `cilium-config` ConfigMap and restart the Cilium DaemonSet.

Your playground is a single-node `kind` cluster with Cilium, Hubble and Hubble Relay. The `starfleet` namespace holds the `probe` Service on port 8080 and the client pod `shuttle`. The `outpost` namespace holds the clients `drifter` and `rogue`. The policy `probe-ingress` drops the requests of `drifter` and `rogue`, and `rogue` sends one every 5 seconds. Flow export is off.

Launch your playground now and keep it running while you read:

<!-- astrona:playground -->
