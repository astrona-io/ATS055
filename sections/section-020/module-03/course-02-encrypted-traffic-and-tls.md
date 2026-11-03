# Encrypted Traffic And TLS

Most production traffic uses Transport Layer Security (TLS), the protocol that encrypts a connection between a client and a server. Encryption protects the content from everyone on the path, and that includes Cilium. This part explains what Hubble can and cannot show for encrypted traffic, and which options exist.

## What stays visible

For a connection to an HTTPS server, the layers below TLS stay readable. Hubble shows the source, destination, port and verdict as layer 4 flows. If the client looked up the server name through the DNS proxy, a DNS flow also shows the name. The TLS handshake carries the server name in the Server Name Indication (SNI) field, but Hubble flows from the datapath do not decode it.

What is hidden is everything inside the encrypted stream: the HTTP method, the path, the headers, the status code and the body. A policy with an HTTP rule cannot match them either, because the proxy sees only encrypted bytes.

Check this in the playground. The first command sends a request over HTTPS to an outside address, and the second looks for HTTP flows from `shuttle`:

<!-- astrona:playground:renew -->

```sh
kubectl -n starfleet exec shuttle -- curl -s -o /dev/null -m 10 -w "%{http_code}\n" https://httpbin.org/get
kubectl -n kube-system exec ds/cilium -c cilium-agent -- hubble observe --from-pod starfleet/shuttle --protocol http --last 5
```

The first command needs internet access from the cluster and prints a status code. The second command shows no HTTP flow for this request. Run `hubble observe --from-pod starfleet/shuttle --last 10` to see the layer 4 flows to the external address, with the destination `world`.

## Options for HTTPS visibility

There are three ways to get request details for encrypted traffic, and each has a cost.

First, terminate TLS where it is easy to read. If a gateway or an ingress controller terminates TLS and sends plain HTTP to the pods, the traffic between the gateway and the pods is plain, and an HTTP rule works there.

Second, use TLS inspection in Cilium policy. Cilium can terminate and originate TLS in the proxy for selected traffic, using a certificate authority that the clients trust. The policy fields are `terminatingTLS` and `originatingTLS` together with a Kubernetes Secret. The proxy then reads the plain request, applies the HTTP rule and encrypts it again. This gives full visibility, but you must distribute the certificate authority to the clients, and you take on the work of managing keys.

Third, accept the limit. For many services, the layer 4 flows and the DNS names are enough to answer who talks to whom.

## Mutual TLS and encryption between nodes

A different feature, transparent encryption, encrypts pod-to-pod traffic between nodes with WireGuard or IPsec. It is a network feature, not a layer 7 feature, and it does not stop Hubble: the datapath sees the packets before they are encrypted for the wire. Hubble still shows flows for encrypted node traffic, but layer 7 details exist only if the application traffic itself is plain.

You now know why a missing HTTP flow often has a simple reason, and which design choices bring it back. Next, the layer 7 flows that you do have can be turned into counters.

## Common pitfalls

> [!WARNING]
> A missing HTTP flow for an HTTPS address is not a fault. An HTTP rule on a port that carries TLS refuses the connection, because the proxy cannot parse it. TLS inspection needs trusted certificate authority distribution to every client. Node-to-node encryption does not hide flows from Hubble, and it does not add request details either.
