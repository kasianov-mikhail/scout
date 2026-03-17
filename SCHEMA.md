# CloudKit Schema

The [Schema](Schema) file defines the following CloudKit record types used by Scout:

| Record Type | Purpose |
|---|---|
| `Event` | Log events captured via swift-log |
| `Session` | User session start/end timestamps |
| `Crash` | Crash reports with stack traces |
| `DateIntMatrix` | Integer metric aggregations by date (hours x days grid) |
| `DateDoubleMatrix` | Double metric aggregations by date (hours x days grid) |
| `PeriodMatrix` | Metric aggregations by period (days, weeks, months) |

## Upload

The quickest way to upload the schema is with the included script:
```bash
./upload-schema.sh <your-team-id> <your-container-id>
```

This uses `cktool` (bundled with Xcode) to import the schema into both development and production environments. See [INSTALLATION.md](INSTALLATION.md) for prerequisites and alternative methods.
