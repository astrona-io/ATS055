# Summary

The ring buffer of the Hubble server holds only the newest flows of one node. The exporter adds a second output: it writes selected flows as lines of JSON to a file in the agent container, and a log collector moves them to long-term storage. The exporter does not send data on its own.

## What you learned

The static exporter is switched on by the file path key in the Cilium ConfigMap, and the agents read it at start. It can use an allow list, a deny list and a field mask. Filters use the same JSON format as the Hubble API: fields in one filter combine with AND, values in a list combine with OR, and several filters combine with OR. A deny filter wins over an allow filter. A field mask reduces the size of each record but removes fields for good.

The dynamic exporter reads a list of exports from the `cilium-flowlog` ConfigMap and applies changes without a restart. Each entry has its own file, filters and mask. Rotation limits the disk use: the exporter renames a full file, keeps a fixed number of backups and removes older ones.

## Key facts

- The export file exists once per node, so a collector must run on every node.
- Filters reduce the number of lines; the mask reduces the size of each line.
- A change of a static export key needs an agent restart; a change of the dynamic list does not.
- The default rotation is 10 megabytes and 5 backups.

<!-- astrona:playground:destroy -->
