# Connect The Hubble CLI And Observe Flows

You have a symptom, such as a request that times out, and you need to see the network side of it within a minute. The Hubble command-line tool can do this, but only if it talks to the right API. A client that talks to one agent shows one node, and a client that talks to Relay shows the cluster. This part explains the two ways to connect, how to check the connection and how to choose the output.

## Two ways to run the tool

The tool is a client. Each time it runs, it connects to a Hubble API and asks for flows. It needs an address, and the address decides the scope of the answer.

The first way runs the tool inside the Cilium agent pod. The agent image contains the `hubble` binary, and it talks to the Unix socket of the Hubble server in the same pod. You need no network setup, only access to the Kubernetes API. The scope is the flows of that node. This is what you use in the playground:

```sh
kubectl -n kube-system exec ds/cilium -c cilium-agent -- hubble status
```

The second way runs the tool on your own machine and connects to Hubble Relay. By default, the tool connects to `localhost:4245`. Relay listens on port 4245 inside its pod, and the Service `hubble-relay` exposes it on port 80. You therefore forward a local port to the Service:

```sh
kubectl -n kube-system port-forward service/hubble-relay 4245:80
```

With the forward running in one terminal, you run `hubble status` and `hubble observe` in another terminal, and the tool reaches Relay at the default address. The Cilium command-line tool has a shortcut for the same forward: `cilium hubble port-forward`. If you use another local port, you give the address with the `--server` option, for example `--server localhost:4246`, or set the environment variable `HUBBLE_SERVER`.

In the second way, the scope is every node that Relay reaches, so flows from several nodes appear in one list. Use it when the pods involved can run on different nodes.

## Check that the API answers

The command `hubble status` tells you whether the API is healthy and how full its buffer is. Run it in the agent pod:

<!-- astrona:playground:renew -->

```sh
kubectl -n kube-system exec ds/cilium -c cilium-agent -- hubble status
```

The lines show the health, the number of flows in the buffer against its capacity and the flow rate. Through Relay, the output has one more line, the connected nodes, as in the documentation example `Connected Nodes: 3/3`. A value such as `2/3` means that Relay cannot reach one node, and the flows of that node are missing from every list you read.

The command `hubble list nodes` prints the nodes that the connected API knows, with their state. Inside the agent pod it lists the local node. Through Relay it lists all nodes:

```sh
kubectl -n kube-system exec ds/cilium -c cilium-agent -- hubble list nodes
```

## Observe and choose the format

The command `hubble observe` prints flows. By default, it prints the most recent flows and stops. The option `--last 20` sets the number, and `--follow` keeps the command running and prints new flows as they arrive. A single run with `--since 2m` prints the flows of the last two minutes.

The default output is a compact line per flow. Three options change the format:

- `-o compact`: one line per flow with the time, the endpoints, the type and the verdict.
- `-o dict`: several lines per flow, one for each field, in a readable block.
- `-o json`: one JSON object per flow with every field, which is the form for scripts and for the `jq` tool.

Try the formats on the same flows. First the compact lines:

```sh
kubectl -n kube-system exec ds/cilium -c cilium-agent -- hubble observe --last 5 -o compact
```

Then the dictionary form, which is easier to read when you need to see all fields of a flow:

```sh
kubectl -n kube-system exec ds/cilium -c cilium-agent -- hubble observe --last 1 -o dict
```

Then JSON. The fields `verdict`, `source` and `destination` that you learned appear as keys:

```sh
kubectl -n kube-system exec ds/cilium -c cilium-agent -- hubble observe --last 1 -o json
```

Choose the compact format to scan, the dictionary format to inspect a single flow and JSON to process the result in a script.

## The first filters

Without filters, the output mixes all traffic of the node, including the internal traffic of Cilium. The filters narrow it. These are the first ones to learn:

- `--namespace` or `-n`: flows where the source or destination is in the namespace.
- `--pod`: flows where the source or destination is the pod, written `namespace/pod`.
- `--from-pod` and `--to-pod`: flows with the pod as source only or destination only.
- `--verdict`: flows with that verdict, such as `FORWARDED` or `DROPPED`.
- `--protocol`: the protocol, such as `tcp`, `udp`, `http` or `dns`.
- `--since`: flows newer than a duration, such as `1m`.

The documentation uses these forms: `hubble observe --pod deathstar --protocol http`, and `hubble observe --pod deathstar --verdict DROPPED`. You can combine filters, and a flow must match all filter types that you give. Within one filter type you can repeat the option to match any of several values.

Read the flows of the namespace `outpost`:

```sh
kubectl -n kube-system exec ds/cilium -c cilium-agent -- hubble observe --namespace outpost --last 10
```

You see the requests of `rogue` to the `probe` with the verdict `DROPPED`. To find all options, `hubble help observe` prints the list for your version, which is the reference to use when an option in this module differs from your version.

## What to keep in mind

The result of a command depends on the scope of the API and on the contents of the buffer. If the list is empty, check three things before you conclude that nothing happened: the time window, the node that the client talks to and the filters. A filter with a wrong pod name does not cause an error; it matches nothing.

You now can connect the tool, check the API and print flows in the right format with the basic filters. The open question is how to use them together to find the cause of a drop and act on it.

## Common pitfalls

> [!WARNING]
> Inside the agent pod you see one node only. A port-forward to Relay must stay running while you use the tool. A wrong pod name matches nothing and gives no error. `--follow` never returns, so use `--last` or `--since` in scripts. The option names can differ between versions; check `hubble help observe` on your system.
