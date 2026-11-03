---
estimated_duration: 25m
---

# Lab: Find The Dropped Client With The Hubble CLI

UNTESTED. This lab was written from the Cilium chart and documentation and has not been run. Run `astrona test -c .` before relying on it.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS055.git -c sections/section-030/module-01/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS055.git -c sections/section-030/module-01/labs/lab-01
astrona destroy ats-055-lab-030-01
```

## Checks

| Script | What it proves |
| --- | --- |
| `validate-cli-report-correct.sh` | cli-report names the dropped source, destination, port and verdict |
| `validate-rogue-forwarded.sh` | Requests from rogue to the probe are now forwarded |
| `validate-drifter-still-denied.sh` | drifter is still refused |
