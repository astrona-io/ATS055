# Summary

Hubble is the observability layer of Cilium. It records network flows: one record for each network event that the Cilium datapath sees on a node. The record is useful because it carries Kubernetes names and labels, not only IP addresses.

## What you learned

The Cilium agent on each node creates and stores the flows. The eBPF programs in the kernel emit events, and the Hubble server inside the agent turns them into flows and keeps the most recent ones in an in-memory ring buffer. When the buffer is full, new flows replace the oldest ones, so Hubble is a recent view and not a permanent log.

Hubble Relay joins the flows of many nodes. It connects to the Hubble server of every node on TCP port 4244 and serves one merged stream on port 4245. The Hubble command-line tool and the Hubble UI read from Relay. The same command-line tool inside the agent pod reads only the flows of that one node. Relay and the UI are optional and have their own switches.

A flow record has a source and a destination with pod names, namespaces, labels and a Cilium identity. It has a protocol and ports, a direction, a flag that marks reply packets, and a verdict. A dropped flow also has a drop reason. A single request creates several flows, one for each event and each direction.

The verdict says what the datapath did with the packet. It does not say what the application did. A forwarded flow does not prove a correct answer, and a dropped flow does not prove a fault, because a policy can drop traffic on purpose.

## Key facts

- The Hubble server runs in the Cilium agent, and the flows live in a fixed-size ring buffer per node.
- Hubble Relay merges the nodes; the command-line tool inside the agent pod does not.
- `hubble status` shows the health and the fill level of the buffer.
- `hubble observe` prints flows and can filter by pod, verdict and direction.
- A missing flow can mean an old event, another node or a filter, and not missing traffic.

<!-- astrona:playground:destroy -->
