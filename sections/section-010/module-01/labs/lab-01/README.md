---
estimated_duration: 25m
---

# Lab: Read Forwarded And Dropped Flows

UNTESTED. This lab was written from the Cilium chart and documentation and has not been run. Run `astrona test -c .` before relying on it.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS055.git -c sections/section-010/module-01/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS055.git -c sections/section-010/module-01/labs/lab-01
astrona destroy ats-055-lab-010-01
```

## Checks

| Script | What it proves |
| --- | --- |
| `validate-forwarded-flow-exists.sh` | Hubble holds a forwarded flow from shuttle to probe |
| `validate-dropped-flow-exists.sh` | Hubble holds a dropped flow from drifter to probe |
| `validate-report-correct.sh` | The report names the right sources and port |
| `validate-policy-unchanged.sh` | The probe-ingress policy still exists and still allows only shuttle |
