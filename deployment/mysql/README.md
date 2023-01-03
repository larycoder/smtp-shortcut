# MySQL

## Debug

For reading log from mysql on real-time:

```
# Enable general_log to `general_log` table
SET global log_output = 'table';

# Enable log
SET global general_log = 1;

# Query log and decode to utf-8
select a.*, convert(a.argument using utf8) from mysql.general_log a\G;

# Disable log
SET global general_log = 0;
```
