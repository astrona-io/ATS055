---
estimated_duration: 45m
---

# Lab: Layer 7 Visibility For HTTP And DNS

UNTESTED. This lab was written from the Cilium chart and documentation and has not been run. Run `astrona test -c .` before relying on it.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS055.git -c sections/section-020/capstone/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS055.git -c sections/section-020/capstone/labs/lab-01
astrona destroy ats-055-lab-020-cap
```

## Checks

| Script | What it proves |
| --- | --- |
| `validate-http-rule-present.sh` | The probe policy has an HTTP rule for GET /get from shuttle only |
| `validate-dns-rule-present.sh` | A policy for shuttle has a DNS rule on port 53 and still allows the probe on 8080 |
| `validate-http-behaviour.sh` | GET /get from shuttle returns 200, GET /headers returns 403, drifter is refused |
| `validate-http-flows-visible.sh` | Hubble shows the HTTP request GET /get as forwarded and /headers as dropped |
| `validate-dns-flows-visible.sh` | Hubble shows a DNS query from shuttle for the probe name |
| `validate-http-metric-exposed.sh` | The agent exposes hubble_http_requests_total |
