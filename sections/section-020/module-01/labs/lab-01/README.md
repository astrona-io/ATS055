---
estimated_duration: 25m
---

# Lab: Add HTTP Visibility With A Policy

UNTESTED. This lab was written from the Cilium chart and documentation and has not been run. Run `astrona test -c .` before relying on it.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS055.git -c sections/section-020/module-01/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS055.git -c sections/section-020/module-01/labs/lab-01
astrona destroy ats-055-lab-020-01
```

## Checks

| Script | What it proves |
| --- | --- |
| `validate-http-rule-present.sh` | The probe policy has an HTTP rule for GET /get from shuttle only |
| `validate-http-behaviour.sh` | GET /get from shuttle returns 200, GET /headers returns 403, drifter is refused |
| `validate-http-flows-visible.sh` | Hubble shows the HTTP request GET /get as forwarded and /headers as dropped |
