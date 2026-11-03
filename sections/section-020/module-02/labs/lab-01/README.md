---
estimated_duration: 25m
---

# Lab: Make DNS Requests Visible

UNTESTED. This lab was written from the Cilium chart and documentation and has not been run. Run `astrona test -c .` before relying on it.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS055.git -c sections/section-020/module-02/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS055.git -c sections/section-020/module-02/labs/lab-01
astrona destroy ats-055-lab-020-02
```

## Checks

| Script | What it proves |
| --- | --- |
| `validate-dns-rule-present.sh` | A policy for shuttle has a DNS rule on port 53 and still allows the probe on 8080 |
| `validate-shuttle-reaches-probe.sh` | shuttle still reaches the probe by name |
| `validate-dns-flows-visible.sh` | Hubble shows a DNS query from shuttle for the probe name |
