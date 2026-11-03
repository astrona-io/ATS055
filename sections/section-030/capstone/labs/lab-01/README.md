---
estimated_duration: 45m
---

# Lab: Use The Hubble CLI And UI Together

UNTESTED. This lab was written from the Cilium chart and documentation and has not been run. Run `astrona test -c .` before relying on it.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS055.git -c sections/section-030/capstone/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS055.git -c sections/section-030/capstone/labs/lab-01
astrona destroy ats-055-lab-030-cap
```

## Checks

| Script | What it proves |
| --- | --- |
| `validate-ui-has-endpoints.sh` | The hubble-ui Deployment is ready and the Service has a ready endpoint |
| `validate-ui-answers.sh` | The Hubble UI answers an HTTP request through the Service |
| `validate-cli-report-correct.sh` | cli-report names the dropped source, destination, port and verdict |
| `validate-ui-report-correct.sh` | ui-report lists the dropped edge and the namespaces of the map |
| `validate-rogue-forwarded.sh` | Requests from rogue to the probe are now forwarded |
| `validate-drifter-still-denied.sh` | drifter is still refused |
