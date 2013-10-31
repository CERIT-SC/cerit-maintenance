# CERIT-SC's maintenance list

[![Build Status](https://travis-ci.org/vholer/maintenance.png)](https://travis-ci.org/vholer/maintenance)

## File format (CSV)

* start datetime (format: `YYYY-MM-DD` or `YYYY-MM-DD HH:MM`)
* end datetime (format: `YYYY-MM-DD` or `YYYY-MM-DD HH:MM` or empty)
* type
 * `maintenance` or `planned-maintenance`
 * `reserved`
* note
* resources (space separated list of FQDNs or cluster names)

### Example

```csv
Start (YYYY-MM-DD),End (YYYY-MM-DD),Type,Note,Resources
2000-01-01,,planned-maintenance,"Y2K blackout",zewura.cerit-sc.cz hda.cerit-sc.cz
```
