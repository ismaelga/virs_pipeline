# VIRs pipeline

## Process Vehicle Inspection Reports to infer the state of dimensional tables

We are working with a vehicle fleet inspection agency to populate an analytics dashboard with information about patterns in vehicle inspections amongst their client organizations. Unfortunately, between access controls and resourcing limitations, pulling data directly from a client's vehicle inspection tracking database could take far longer than anyone can afford to wait. However, they already have monthly dumps of vehicle inspection report (VIR) records that contain enough information that we can infer everything we really need to know about both the vehicles being inspected and the client organizations that own those vehicles.

So, we need to process those dumps into a separate, persisted data store that allows us to answer questions about who is getting vehicles and inspections and whether they're passing those inspections.

## Task

The dumps are named `vir_<year><month>.csv` which allows them to be processed in order, and your goal is to create any necessary code or scripts necessary to process all dump files in order, updating and adding data until we have a data store that describes the current state of inspections, vehicles that were inspected, and the organizations that own them.

Once all data has been processed, write a report to disk as a tab-separated values (TSV) file, with headers, named `virs_report.tsv`. This report should give statistics on the three organizations with the highest proportion of vehicles that failed their **_last adjudicated inspection_**.

It contains three columns:

- `org_name`: The names of the organizations as inferred from the VIR files.
- `tot_v`: How many vehicles with inspections exist in those organizations, as aggregated from the three dumps we have.
- `failed_v`: How many vehicles in those organizations are **_currently_** in a failed state.

### Business logic notes

- The inspection failure question is only the first we’ll be asking of the data. There are expected to be more questions, so it's better if the data is structured to make that easy.
- We do not care about and **_do not want to retain past states of the data_** (i.e. we don’t need a time series table)
- A vehicle's or organization's ID will remain the same over time, even if something else about it changes (e.g, an organization changes its name)
- Whenever a vehicle is inspected, an "inspection record" is created. An inspection record is identified by a unique combination of `vehicle_id` and `inspection_date`. It may be adjudicated as passing or failing, or not adjudicated at that time. This means there can either be a value in the `inspection_passed` column, or it can be empty. However, an inspection record can get updated if the inspection is re-adjudicated. When this happens, the `inspection_passed` value may change. A re-adjudicated inspection record would appear in a subsequent VIR (a new dump).
- As `vehicle_id` + `inspection_date` define a unique inspection record, it can be considered a compound primary key for the data store.
- The information in the latest entry pertaining to a vehicle or an organization is authoritative. For example, if the latest inspection record for a particular vehicle indicates that it now belongs to a different organization, we must interpret that as the vehicle having been transferred between organizations. At that point, we no longer care about the results of inspection records for that vehicle when it belonged to another organization.
- Until a new inspection result is indicated, the previous inspection result continues to apply. There can be long delays between when an inspection is conducted, and when a result is updated to passing or failing, so each successive dump is likely to update a few inspection records received in previous dumps.
- In a given inspection record, only `inspection_passed` is ever updated, so changes to vehicles or organizations can only be inferred from subsequent inspection records.

You must supply your code as part of your answer. Use whichever data stores and languages with which you're most comfortable, including domain-specific languages such as SQL. The prime focus of this homework is the data logic and structures. The secondary focus is ingestion and export of data from the data store. The setup of the infrastructure is not a focus beyond creating an environment where we can run your code to test it. Please put instructions for setup in a COMMENTS file (e.g. `COMMENTS.md`).

If your code executes from a Unix-like command line and and/or uses a common DBMS/database programs like Postgres or MySql, you can assume we will be able to manage common setup tasks like database installation and initialization, so you don't need to include code to automate setup beyond creating any structures (tables, dataframes, collections) specifically for the data to be processed. Include complete instructions for the installation and setup of any less common software framework and/or data store necessary for the code to run. Managing security and users or anything else besides processing the data is not part of the homework, so please keep setup simple.

## Notes

The input files are formatted as double-quote quoted CSVs in which literal double-quotes are doubled (i.e. `""`). The delimiter is a pipe (`|`) character. Each file has its own header.

```
vehicle_id|inspection_date|vehicle_org_id|org_name|inspection_period_id|inspection_passed
2811|2020-02-06|1920|Economotor|102|TRUE
4021|2020-02-10|1920|Economotor|102|TRUE
```

Not all columns are needed to generate your `virs_report.tsv`, but they may be needed to answer other questions.

To extract the dumps from `vehicle_inspection_reports.tar.gz` you can run `tar zxvf vehicle_inspection_reports.tar.gz` in most any Unix-like command line.
