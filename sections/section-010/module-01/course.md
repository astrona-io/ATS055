# Hubble Components And Flow Records

When a request fails inside a Kubernetes cluster, the first question is what the network did with it. Hubble answers that question. Hubble is the observability layer of Cilium: it records the network flows that Cilium sees and lets you read them. A flow is one record of one network event, for example a packet that was forwarded or a connection that a policy dropped.

This module teaches you which components produce, collect and serve those records, and how to read a single record. You will learn where a flow is created, which component stores it, which component joins the records of many nodes, and what each field and each verdict in a record means.

The module has two parts. **Hubble Components And Where Flows Come From** follows a flow from the Cilium agent on a node to your terminal and shows how Hubble and Hubble Relay are enabled. **Reading A Flow Record And Its Verdict** explains the fields of a flow, the verdict values and what a verdict does and does not prove.

## Learning objectives

After this module you can:

- Name the components of Hubble (the Hubble server in the Cilium agent, Hubble Relay, the Hubble command-line tool and the Hubble UI) and say what each one does.
- Explain where flow records are stored and why the storage is limited.
- Enable Hubble and Hubble Relay and check that they are healthy.
- Read the source, destination, protocol, direction and verdict of a flow record.
- Tell a forwarded flow from a dropped flow and name the drop reason.
- Explain why a forwarded verdict does not prove that an application answered correctly.

## Before you start

You need to know what a pod, a namespace, a Service and a label are, and how to run `kubectl`. You do not need to know Cilium policies yet. The module explains the one policy it uses.

Your playground is a single-node `kind` cluster running Kubernetes 1.35 with Cilium, Hubble and Hubble Relay installed. It contains these objects:

| Namespace | Object | What it is |
| --- | --- | --- |
| `starfleet` | `probe` | A Deployment and Service that answer HTTP requests on port 8080 |
| `starfleet` | `shuttle` | A client pod that sends requests |
| `outpost` | `drifter` | A client pod in another namespace |
| `outpost` | `rogue` | A client pod that sends a request to the `probe` every 5 seconds |
| `starfleet` | policy `probe-ingress` | A `CiliumNetworkPolicy` that lets only `shuttle` reach port 8080 of the `probe` |

The `probe-ingress` policy drops the requests of `drifter` and `rogue`. This gives you both forwarded and dropped flows to read.

Launch your playground now and keep it running while you read:

<!-- astrona:playground -->
