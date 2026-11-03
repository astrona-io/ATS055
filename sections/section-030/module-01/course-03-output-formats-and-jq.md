# Output Formats And jq

The default output of `hubble observe` is made for reading. When you want to count, sort or compare flows, or pass them to another tool, you need a format that a program can parse. This part shows the output formats of the Hubble command-line tool and how to process the JSON output with `jq`, a command-line JSON processor.

## The formats

The option `-o` (or `--output`) selects the format. These are the values you need:

- `compact`: one short line per flow, with the time, the source, the destination, the type, the verdict and a few details. This is the best format for reading many flows.
- `dict`: one block of `key: value` lines per flow. It shows the fields in a readable list and is good for studying one flow.
- `table`: aligned columns. It is easy to scan, but long names make the lines wide.
- `json`: one JSON object per line, with the flow under the key `flow`, plus the node name and the time.
- `jsonpb`: JSON in the Protocol Buffers JSON mapping, one object per flow. The field names follow the API definition.

Compare two of them on the same flow. Use `--last 1` so that the output stays short:

<!-- astrona:playground:renew -->

```sh
kubectl -n kube-system exec ds/cilium -c cilium-agent -- hubble observe --from-pod outpost/rogue --last 1 -o compact
kubectl -n kube-system exec ds/cilium -c cilium-agent -- hubble observe --from-pod outpost/rogue --last 1 -o dict
```

The compact line is enough to see that `rogue` sends a request to the `probe` and that the verdict is `DROPPED`. The dict output adds fields such as the identities, the labels and the drop reason.

## Process JSON with jq

Run the command-line tool in the agent pod and pipe the output to `jq` on your own machine. The pipe works because `kubectl exec` writes the standard output of the remote command to your terminal. Do not use the option `-t`, which adds terminal control characters.

This command lists the pairs of source and destination pods of the dropped flows, one pair per line:

```sh
kubectl -n kube-system exec ds/cilium -c cilium-agent -- hubble observe --verdict DROPPED --last 50 -o json | jq -r '.flow | "\(.source.namespace)/\(.source.pod_name) -> \(.destination.namespace)/\(.destination.pod_name)"'
```

The expression `.flow` selects the flow object, and the string in quotes builds one line from four fields. If a field is missing, `jq` prints `null` for it. Dropped flows from a host or from the outside have no pod name.

To count how often each pair appears, add `sort` and `uniq -c`:

```sh
kubectl -n kube-system exec ds/cilium -c cilium-agent -- hubble observe --verdict DROPPED --last 50 -o json | jq -r '.flow | "\(.source.namespace)/\(.source.pod_name) -> \(.destination.namespace)/\(.destination.pod_name)"' | sort | uniq -c
```

The result shows which client produces the most drops. A different question is the reason of the drops. This command prints the distinct drop reasons:

```sh
kubectl -n kube-system exec ds/cilium -c cilium-agent -- hubble observe --verdict DROPPED --last 50 -o json | jq -r '.flow.drop_reason_desc' | sort -u
```

Here `drop_reason_desc` is the text name of the reason, such as `POLICY_DENIED`.

## When to use which

Use `compact` for reading during an investigation. Use `dict` to learn the fields of one flow. Use `json` when you pipe to `jq`, and keep `--last` or `--since` in the command so that the output is bounded. Without a limit, `hubble observe` prints the whole buffer, and with `--follow` it never stops until you press Control-C.

You now can turn flows into lists and counts. The next question is how to choose the flows, so that the output holds only what you ask about.

## Common pitfalls

> [!WARNING]
> Adding `-t` to `kubectl exec` corrupts the JSON for `jq`. The key names in `jq` follow the JSON field names, which use underscores, such as `pod_name`. Fields that do not exist for a flow print as `null`, which is easy to mistake for a real value. Counting the last 50 flows is a sample of the buffer and not a total.
