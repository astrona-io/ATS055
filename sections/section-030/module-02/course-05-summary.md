# Summary

The Hubble UI is a web view of the same flows that the command-line tool prints. It is optional, it depends on Hubble Relay and it is read-only.

## What you learned

The UI is a Deployment in `kube-system` whose pod serves a web front end and a backend that asks Relay for flows. A Service forwards port 80 to port 8081 of the pod and finds the pod through the label selector `k8s-app: hubble-ui`. Nothing is exposed outside the cluster by default, so you reach the UI through a port-forward to the Service.

A Service without a working endpoint has three common causes. The Deployment can have no replicas, the selector of the Service can fail to match the pod labels, or the pod can be not ready. You check the Endpoints object first, then the replica count, then the selector against the pod labels, then the readiness of the pod. A merge patch on a selector map adds keys, so a wrong key needs a replace operation.

The service map is built from observed flows. A line exists only when a flow for that pair appeared in the window, so a missing line does not mean the connection is forbidden. You select one namespace at a time, and an edge can appear in the views of two namespaces. A connection with dropped flows is marked, and the flows table shows the verdict, the source, the destination and the port. The table and the command line give the same answers, and the command line is the tool for exact filters and scripts.

## Key facts

- The UI reads from Relay, not from the agents.
- The Service `hubble-ui` selects pods with `k8s-app: hubble-ui`.
- An empty Endpoints object means: check replicas, selector and readiness.
- The map shows observed traffic, not allowed traffic.
- The UI cannot change anything.

<!-- astrona:playground:destroy -->
