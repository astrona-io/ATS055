# HTTP Visibility With Layer 7 Policy

Layer 3 and 4 flows show who connected to whom, on which port, and whether the connection passed. They do not show what the client asked for. Two requests to the same port, `GET /get` and `DELETE /admin`, look the same at layer 4. To see the request itself, Cilium must read the HTTP protocol.

This module shows how Cilium gets that view. Cilium sends the traffic of selected pods through the Envoy proxy that runs inside the Cilium agent, and the proxy reports each HTTP request and response to Hubble. The trigger is a `CiliumNetworkPolicy` with an HTTP rule. The same policy that enables the view also restricts the traffic, so you must understand both effects before you apply it.

The module has four parts. The first two are: **How Layer 7 Visibility Works** explains the layers, the proxy redirect and what it costs. **Write HTTP Rules And Read HTTP Flows** builds an HTTP rule, tests an allowed and a denied request, and reads the HTTP flows and their verdicts.

The other two parts are: **HTTP Rule Matching: Method, Path And Headers** explains each field of an HTTP rule and how the fields combine, and **Verify HTTP Visibility And Verdicts** reads the HTTP flows with the HTTP filters.

## Learning objectives

After this module you can:

- Explain the difference between a layer 4 flow and a layer 7 flow.
- Say which component produces HTTP flows and when it does.
- Write a `CiliumNetworkPolicy` with an HTTP method and path rule.
- Predict what a request that breaks the rule receives.
- Filter Hubble output for HTTP flows and for HTTP drops.
- Explain why encrypted HTTPS traffic does not show HTTP fields.
- Combine method, path and header fields and predict which requests match.
- Find refused requests by status code in Hubble.

## Before you start

You should be able to read a layer 4 flow and know what a `CiliumNetworkPolicy` is. The module defines the HTTP fields it uses.

Your playground is a single-node `kind` cluster with Cilium, Hubble and Hubble Relay. The `starfleet` namespace holds the `probe` Deployment and Service on port 8080 and the client pod `shuttle`. The `outpost` namespace holds the client pod `drifter`. The policy `probe-ingress` in `starfleet` allows only `shuttle` to reach TCP port 8080 of the `probe`. It has no HTTP rule yet, so Hubble shows no HTTP details.

Launch your playground now and keep it running while you read:

<!-- astrona:playground -->
