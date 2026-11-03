# Summary

The Hubble command-line tool is a client of a Hubble API. Where it connects decides what it can see, and the filters decide what it prints.

## What you learned

Run inside a Cilium agent pod, the tool reads the Unix socket of that agent and shows the flows of that node. Run on your own machine, it connects to Hubble Relay, by default at localhost:4245, usually through a port-forward to the Relay Service, and shows the flows of every node that Relay reaches. The status command shows the health of the API and the fill level of the buffer, and through Relay it shows how many nodes are connected. A node count below the total means missing flows.

The observe command prints flows in compact, dictionary or JSON format. Compact is for scanning, dictionary is for inspecting one flow and JSON is for scripts. Filters narrow the list by namespace, pod, source or destination pod, port, protocol, verdict and time. A flow must match every filter type that you give, and a wrong name matches nothing without an error.

A drop investigation starts from the verdict, confirms source, destination and port with narrower filters, compares with forwarded flows to the same destination and reads the labels of the source. The labels are what a policy selector uses, so they decide the change. A source in another namespace needs the namespace label in the selector. After the change, the new flows show the new verdict, and older flows in the buffer still show the old one.

## Key facts

- Agent pod scope is one node; Relay scope is every reachable node.
- `hubble status`, `hubble list nodes` and `hubble observe` are the three base commands.
- `-o compact`, `-o dict` and `-o json` choose the format.
- Filters combine as and across types.
- Change a policy narrowly, and read the timestamps when you check it.

<!-- astrona:playground:destroy -->
