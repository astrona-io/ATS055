# Using The Hubble UI

The Hubble UI draws the traffic of a namespace as a service map: boxes for workloads, lines for the connections between them, and a table of the flows behind the lines. It helps most when you do not yet know the shape of the traffic, or when you must show it to someone who does not use the command line.

This module explains what the UI is made of, how to reach it, what to check when it does not work and how to read the map and the flows table. The UI shows the same flows as the command-line tool, so the verdicts and the limits you already know apply to it too.

The module has four parts. The first two are: **Hubble UI Components And Access** explains the pods and the Service behind the UI, how to open it and how to find out why a Service has no working endpoint. **Read The Service Map And The Flows Table** explains the namespace selector, the map, the flows table and how to match what you see to a policy.

The other two parts are: **Namespace Filters And Layer 7 In The UI** explains what the UI draws and how to narrow it, and **Troubleshooting The Hubble UI** gives an ordered list of checks from the Service to Relay.

## Learning objectives

After this module you can:

- Name the parts of the Hubble UI and the component it reads flows from.
- Enable the UI and open it with a port-forward.
- Diagnose a Service without endpoints: selector, labels and replicas.
- Choose a namespace in the UI and read the service map.
- Find a dropped connection in the map and open its flows.
- Explain which things the UI cannot show.
- Aim the UI at a namespace and read its edges and flows table.
- Troubleshoot a UI that does not load or shows an empty map in a fixed order.

## Before you start

You should know what a Service, an Endpoints object and a label selector are, and you should be able to read flows on the command line.

Your playground is a single-node `kind` cluster with Cilium, Hubble, Hubble Relay and the Hubble UI. The UI is the Deployment and Service `hubble-ui` in `kube-system`, and it reads flows from Relay. The `starfleet` namespace holds the `probe` Deployment and Service on port 8080 and the client pod `shuttle`. The `outpost` namespace holds the client pods `drifter` and `rogue`. The policy `probe-ingress` allows only `shuttle` to reach port 8080 of the `probe`, so the connection from `rogue` is dropped every 5 seconds.

Launch your playground now and keep it running while you read:

<!-- astrona:playground -->
