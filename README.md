# Hack Mill
A simple speeds and feeds calculator, specifically for use with [Cheltenham Hackspace](https://www.cheltenhamhackspace.org/)'s CNC milling machine.

## To deploy:
Change the "DEVELOPMENT" flag in `secrets.json` to `false` before deploying.

## To Do:
- [X] Hook up parameter submission to database
- [X] Add parameter filtering to table
- [X] Turn table into custom items
- [X] Add messages on submission
- [X] Factor out secrets
- [X] Add option to remove submitted record
  - [X] Update view on record deleted
- [-] Sanitise SQL queries
- [X] Modularise
- [ ] Show only first 10 matches for records
  - [ ] Allow for more records to be shown
- [X] Sort records by feed rate
- [ ] Add recording for tool usage time
- [X] Add spindle limiting