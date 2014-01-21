# CERIT-SC's maintenance list

[![Build Status](https://travis-ci.org/CERIT-SC/cerit-maintenance.png?branch=master)](https://travis-ci.org/CERIT-SC/cerit-maintenance)

## File format (CSV)

* start datetime (format: `YYYY-MM-DD` or `YYYY-MM-DD HH:MM`)
* end datetime (format: `YYYY-MM-DD` or `YYYY-MM-DD HH:MM` or empty)
* type
 * `maintenance` or `scheduled maintenance`
 * `reserved`
* note
* resources (space separated list of FQDNs or cluster names)

### Example

```csv
Start (YYYY-MM-DD),End (YYYY-MM-DD),Type,Note,Resources
2000-01-01,,scheduled maintenance,"Y2K blackout",zewura.cerit-sc.cz hda.cerit-sc.cz
```

## Other

* [Internal document](https://wiki.metacentrum.cz/metawiki/CERIT-SC:Statistika)
  on how data are processed to get availability/reliability metrics.

***

CERIT Scientific Cloud, <support@cerit-sc.cz>
