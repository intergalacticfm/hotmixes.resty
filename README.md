# Summary

This repository is an OpenResty Docker container which offers a website with a
fancy index for files. The production version is found at https://hotmixes.net
where mainly MP3 files are offered.

# Prerequisists

Install `docker-compose`, e.g. with

    sudo apt-get install docker-compose

# Testing

The local container is build and run with

    docker-compose -f docker-compose-local.yml up --build

The website offered by the local container is at http://localhost:8080

In `docker-compose-local.yml` is a path to the test files. The test files in
this repo are in the directory `testfiles`. Note that in the directory `c` is
a symbolic link to anonther directory and in `d` is a symbolic link to another
MP3 file. Symbolic links are not counted in the total number of files and are
not shown in latest uploads. Be careful not to create recursive loops when using
symbolic links.

When working without test files, the top-level directory for files should
contain subdirectores starting with only lower case `a` until `z` and `0` until
`9`. These subdirectories can be created with

    for i in {0..9}; do mkdir $i; done
    for i in {a..z}; do mkdir $i; done

# Logging

## HTTP service

On the server, the log can be monitored with

    sudo tail -f ~traefik/log/access.log

Create the file `/etc/logrotate.d/traefik` with

    ~traefik/log/*.log {
      daily
      rotate 36
      compress
      delaycompress
      notifempty
      create 644 traefik traefik
      sharedscripts
      postrotate
        docker kill --signal="USR1" traefik
      endscript
    }

## GeoIP

To look up geographical information for an IP address, get a free account at
https://dev.maxmind.com/geoip/geolite2-free-geolocation-data?lang=en via
https://www.maxmind.com/en/geolite2/signup?lang=en and get a free API key via
https://www.maxmind.com/en/accounts/current/license-key?lang=en

See `/root/geoip-api-key` for credentials.

Then install the download and automatic update software with

    sudo apt-get install geoipupdate

Update the AccountID and LicenseKey with

    sudo vi /etc/GeoIP.conf

and remove `GeoLite2-Country` from the line starting with `EditionIDs` Then, run

    sudo geoipupdate

This will download files in `/var/lib/GeoIP/`

## GoAccess

Read https://goaccess.io/download and then install GoAccess with:

    wget -O - https://deb.goaccess.io/gnugpg.key | gpg --dearmor | sudo tee /usr/share/keyrings/goaccess.gpg >/dev/null
    echo "deb [signed-by=/usr/share/keyrings/goaccess.gpg] https://deb.goaccess.io/ $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/goaccess.list
    sudo apt-get update
    sudo apt-get install goaccess

Add to `/etc/crond.d/traefik` the line:

    0 * * * *	root	~hotmixes/hotmices.resty/report-log.sh

and every hour, an updated report is available at
https://hotmixes.net/goaccess/goaccess.html To manually trigger an update, run

    sudo -i hotmixes
    hotmixes.resty/report-log.sh

# Validation

Check:
- HTML https://validator.w3.org/nu/?doc=https%3A%2F%2Fhotmixes.net
- CSS https://jigsaw.w3.org/css-validator/validator?uri=https%3A%2F%2Fhotmixes.net
- Links https://validator.w3.org/checklink?uri=https%3A%2F%2Fhotmixes.net
- i18n https://validator.w3.org/i18n-checker/check?uri=https%3A%2F%2Fhotmixes.net
- RSS https://validator.w3.org/feed/check.cgi?url=https%3A%2F%2Fhotmixes.net%2Flatest.xml
- unified https://validator.w3.org/unicorn/check?ucn_uri=https%3A%2F%2Fhotmixes.net&ucn_task=conformance
