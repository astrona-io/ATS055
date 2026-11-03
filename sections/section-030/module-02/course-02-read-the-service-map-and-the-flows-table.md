# Read The Service Map And The Flows Table

A map is easy to look at and easy to misread. It shows connections that exist in the selected time and namespace, drawn from flows, and it hides everything else. If you read it without knowing what it is built from, you can miss traffic that is present or believe in traffic that is not. This part explains what the UI draws, how to select data and how to turn what you see into a statement you can check on the command line.

## Where the map comes from

The UI does not know your policies or your Services. It asks Relay for flows and builds the map from them. Each box is a workload or an external endpoint that appears in a flow. Each line is a connection between two of them, built from the source and destination of the flows. A line exists because at least one flow was observed for that pair.

A consequence follows. A connection that no one used in the time window has no line, even if the policy allows it. The map is a picture of observed traffic, not of allowed traffic. A missing line means no observed traffic or no flow in the buffer, and it does not mean the connection is forbidden.

## Select a namespace

The UI shows one namespace at a time. A selector at the top of the page lists the namespaces. After you choose one, the map shows the workloads of that namespace and the endpoints that talk to them, which can be in other namespaces.

This matters for the playground. The `rogue` pod runs in `outpost`, and the `probe` runs in `starfleet`. If you select `starfleet`, you see the `probe` and the sources that connect to it, including `shuttle` and the dropped traffic from `rogue`. If you select `outpost`, you see the pods in `outpost` and their targets, including the `probe`. The same edge can therefore appear in both views, with the workload of the other namespace drawn as an outside peer. The namespaces that appear in a map are the selected one and the ones of the connected peers.

Open the UI through a port-forward to the Service, and start with the namespace `starfleet`. The forward must keep running in a terminal:

<!-- astrona:playground:renew -->

```sh
kubectl -n kube-system port-forward service/hubble-ui 12000:80
```

Then browse to `http://127.0.0.1:12000` and select `starfleet`. The map shows a box for the `probe`, and the connections from `shuttle` and from `rogue`.

## Read the connections and their verdicts

The UI marks the state of a connection with the verdicts of the flows behind it. A connection whose flows are forwarded is shown as normal traffic. A connection with dropped flows is marked as a problem. The exact colours and icons depend on the version, so read the legend of your UI instead of relying on a colour that this text names.

In the playground, one edge goes from `outpost/rogue` to `starfleet/probe`. It is the one with dropped flows, because the policy denies that source. The edge from `shuttle` to the `probe` has forwarded flows. To see the edge from `shuttle`, send a request first, because the map needs a flow in the window:

```sh
kubectl -n starfleet exec shuttle -- curl -s -o /dev/null -w "%{http_code}\n" http://probe:8080/get
```

The request prints `200`, and a new line from `shuttle` to the `probe` appears in the map shortly after.

## The flows table

Below the map, the UI shows a table of flows for the selected namespace. Each row is one flow, with the source, the destination, the destination port, the protocol, the verdict and the time. It is the same data that `hubble observe` prints, in table form. The table can be filtered by the same kinds of fields: the verdict, the pod, the protocol and the direction.

To inspect a drop, find the row of the dropped edge: the source `outpost/rogue`, the destination `starfleet/probe`, the destination port `8080` and the verdict dropped. Select the row to see the details of the flow, such as the labels and the reason. Those fields match the flow record you already know.

The table makes a good bridge to the command line. After you find the row, run the same question as a command and confirm it:

```sh
kubectl -n kube-system exec ds/cilium -c cilium-agent -- hubble observe --verdict DROPPED --from-pod outpost/rogue --to-pod starfleet/probe --last 3
```

The lines show the same edge, with the source, the destination, the port and the verdict. The UI is quicker to find the edge, and the command line is better for exact filters and for scripts.

## What the UI does not show

The UI inherits all limits of the flows. Old events are gone once they leave the ring buffer. The UI shows layer 7 details only for traffic that a layer 7 policy sends through the proxy. The UI shows what Relay can reach, so a node that Relay cannot reach is missing.

The UI also does not change anything. It is a read-only view, and the repair of a drop is a policy change that you make with `kubectl`. The map helps you decide which policy to change, and the command line applies and verifies the change.

## From the map to a statement

A good result of a UI session is a short statement that someone else can verify: the dropped edge, written as the source and the destination, and the namespaces that appear in the map. For this playground, the dropped edge is `outpost/rogue` to `starfleet/probe`, and the namespaces in the map are `outpost` and `starfleet`. Anyone can check this statement with the command above.

## Time and freshness

The UI shows recent flows. When you open the page, it asks Relay for the flows that are still in the ring buffers and then follows new flows as they arrive. A connection that was active ten minutes ago can already be gone from the buffer on a busy node, so the map of a quiet cluster looks fuller than the map of a busy one. If you need to know about an older event, the UI cannot help and you must look at metrics or at flows that you exported earlier.

The UI also updates while you watch. A request that you send appears as a new line within a few seconds. If a line does not appear, send the request again and check that you selected the namespace of the source or of the destination. A request between two pods in a namespace that you did not select does not show in the current view.

## Peers outside the namespace

Some boxes in the map are not workloads of the selected namespace. The UI draws endpoints such as the node itself, the cluster DNS and addresses outside the cluster as their own boxes. They appear because the workloads you look at talk to them, and they are part of the flows. A box with an IP address and no name is an endpoint that Cilium could not map to a pod or a Service. Do not read such a box as a fault. It is the same kind of peer that `hubble observe` prints as a plain address with a label such as `host` or `world`.

## Match the map to the policy

The map shows what happened, and the policy says what should happen. A useful habit is to put the two side by side. Read the policy that selects the destination, for example the `probe`, and list the sources it allows. Then look at the map and sort every edge into one of three groups. An edge from an allowed source with forwarded flows is expected. An edge from a source that the policy does not allow, with dropped flows, shows the policy working. An edge from an allowed source with dropped flows is a surprise, and it points to a layer 7 rule, a wrong label or a policy that you did not expect.

Work through the third group with care. A source can be allowed at layer 4 and still show drops, because a layer 7 rule refuses its request. The flows table then shows the protocol and the HTTP fields for those rows. The match of map and policy turns a picture into a list of facts that you can test.

## A worked check

Suppose a colleague says: "The `probe` is not reachable from `outpost`." You can check this claim in three steps without changing anything. First, select `outpost` and find the `rogue` and `drifter` boxes. Second, look at the edge to the `probe`: an edge with dropped flows means the connection was tried and denied, and no edge means that nobody tried in the window. Third, open the flows table and read the verdict and the port of the rows.

If the edge shows drops, the claim is true, but the cause is a policy and not a broken `probe`. The correct next step is to check which policy selects the `probe` and which sources it allows. If no edge exists, the claim is not proven. You ask the client to send a request, or you send one yourself, and look again. The map gives you a way to separate a denied connection from a connection that was never made.

You now know what the UI draws, how to select a namespace, how to find a dropped edge and how to confirm it on the command line. The UI and the command line read the same flows, and you choose between them by the question: a map to find the shape of the traffic, a command to prove one fact.

## Common pitfalls

> [!WARNING]
> The map shows observed traffic, so a missing line does not mean a connection is forbidden. The namespace selector decides which workloads you see, and an edge can show in two namespaces. Do not rely on a colour; read the verdict in the flows table. The UI is read-only, so a repair needs a policy change. An empty map can come from a broken Relay, an empty namespace or a buffer that has already wrapped.
