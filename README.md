# minecraft-scripts

A set of personal scripts and edits for managing minecraft instances on an OCI server

## Dependancies

* [restic](https://restic.net/)
* [viral32111/rcon](https://github.com/viral32111/rcon)
* [nicolaschan/minecraft-backup](https://github.com/nicolaschan/minecraft-backup)

## server.properties

Set these to allow rcon (and not spam connected ops)
```properties
rcon.port=25575
broadcast-rcon-to-ops=false
enable-rcon=true
rcon.password=<rcon pwd>
```

## server.sh

Place in the server directory and edit the JAR and RAM settings to suit

## mcctl.sh

Set rcon password to match, and set a restic

### Usage

`mcctl <stop | stop-now | restart | reset-fetchr | reset-chunk | backup | single-backup | prune>`

* `stop`: stop server with a 60s warning and countdown
* `stop-now` : stop server with 10 warning
* `restart`: stop server and allow server.sh to restart it with a 60s warning and countdown
* `reset-fetchr`: Reset the bingo server
  * Clears `~/mc-fetchr` and copy a fresh version from `~/templates/mc-fetchr-template` back, and prompt to rcon `keepInventory`
* `reset-chunk`: Reset the ChunkLock server
  * Clears `~/mc-chunk` and copy a fresh version from `~/templates/mc-chunk-template` back, and prompt to rcon `keepInventory`
* `backup`: Runs a restic backup on active server
  * Uses hardcoded absolute paths for cron compatibility
* `single-backup`: Runs a tar backup on active server
  * Uses hardcoded absolute paths for cron compatibility
* `prune`: Prunes all restic backups in `/home/ubuntu/backups`

## cron

```crontab
# Minecraft backup (hourly)
0 * * * * /home/ubuntu/scripts/mcctl.sh backup >> /var/log/mcctl/mcctl.log 2>&1

# Prune dropped backups (mondays 0030)
30 0 * * 1 /home/ubuntu/scripts/mcctl.sh prune >> /var/log/mcctl/mcctl.log 2>&1

# Restart active server (0430)
30 4 * * * /home/ubuntu/scripts/mcctl.sh restart >> /var/log/mcctl/mcctl.log 2>&1
```

## logrotate

`/etc/logrotate.d/mcctl`

```
/var/log/mcctl/*.log
{
    daily
    missingok
    rotate 7
    compress
    notifempty
}
```