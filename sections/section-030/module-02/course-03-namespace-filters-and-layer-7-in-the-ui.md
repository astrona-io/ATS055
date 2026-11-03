# Namespace Filters And Layer 7 In The UI

The service map is useful only when it shows the right part of the cluster. This part explains how the UI chooses what to draw, which filters narrow the flows table, and what the UI shows for layer 7 traffic.

## One namespace at a time

The UI shows the flows of one namespace. A selector at the top of the page lists the namespaces that have flows, and you pick one. The map then draws the pods and Services that send or receive flows in that namespace. Traffic that comes from another namespace appears as a node from outside, with the other namespace in its label.

If you choose `starfleet`, the map shows the `probe`, the `shuttle` and the clients from `outpost` that send flows to the `probe`. If you choose `outpost`, the map shows `rogue` and `drifter` and the `probe` they try to reach. The same edge can appear in both maps, because both namespaces take part in it.

## The edges

An edge is an arrow from a source to a destination. A solid line means that flows were forwarded. A red line means that flows were dropped. The UI colours the edge by the verdicts that it saw, and it keeps the data of a recent time window. An edge disappears when no flow of that pair is in the window.

The map shows layer 4 edges by default. When layer 7 flows exist, the UI can show an HTTP view: the edge carries the methods and status codes, and the flows table shows the HTTP columns. An edge for a pod without a layer 7 rule has no HTTP details.

## The flows table

Below the map, the flows table lists the individual flows of the namespace. Each row shows the source, the destination, the destination port, the protocol, the verdict and the time. A click on a row opens all fields of the flow. This is the same record that `hubble observe -o dict` prints.

The filter box above the table accepts filters in a `key:value` style, for example the verdict, the source pod or the protocol. Several filters combine with AND. The filters of the UI are a subset of the command-line filters, so a complex question is easier to answer on the command line.

Use the UI together with the playground. Open it with a port-forward, in one terminal:

<!-- astrona:playground:renew -->

```sh
kubectl -n kube-system port-forward service/hubble-ui 12000:80
```

Open `http://127.0.0.1:12000` in a browser, choose `outpost`, and find the red edge from `rogue` to `probe`. Open the table, filter the verdict to dropped and read the drop reason of one row.

Then confirm the same fact on the command line:

```sh
kubectl -n kube-system exec ds/cilium -c cilium-agent -- hubble observe --from-pod outpost/rogue --verdict DROPPED --last 3
```

The command shows the dropped flows of `rogue`, matching the red edge.

## What the UI does not show

The UI is a recent-view tool, like the ring buffer. It does not show history beyond the time window, and it cannot export what it displays. For long periods, use metrics and the exporter. The UI also shows only what Relay can reach, so a node that Relay cannot reach is missing from the map without a clear error.

You now know how to aim the UI at one namespace and read its edges. When the page does not load or the map is empty, the cause is in the components behind it.

## Common pitfalls

> [!WARNING]
> A map that is empty after you select a namespace usually means that no flows were recorded in the time window, not that the UI is broken. A red edge means that at least one flow was dropped, and it does not say that all traffic failed. Edges from other namespaces appear as outside nodes, which is easy to read as a missing pod. The UI never changes policy.
