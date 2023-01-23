# Summary

This repository is an OpenResty Docker container which offers a website with a
fancy index for files. The production version is found at https://hotmixes.net
where mainly MP3 files are offered.

# Prerequisists

Install `docker-compose`, e.g. with

    sudo apt-get install docker-compose

Filenames should not have the following characters:
- space ` `
- brackets `(`, `)`, `[`, `]`, `{`, `}`
- slashes `\`, `/`
- interpunction `?`, `!`, `&`, ','
- special characters `#`, `*`, `$`
- at `@`

Use for separators:
- period `.` (to replace a space e.g.)
- plus `+` (to replace an ampersand `&` e.g.)
- `at` (to replace an at `@` e.g.)
- hyphen `-`

Use all caps for artist names.

Symbolic links under `/media/music` are possible and will not influence the
total file count. Reason for doing that is to link from an artist's directory
to a set in a directory of a venue such as the PRC. When working with links, run
the following command from this top-level directory to find possible broken
links:

    find . -xtype l

For finding duplicates, run:

    fdupes -r .


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

Add to `/etc/cron.d/traefik` the line:

    0 * * * *	root	~hotmixes/hotmixes.resty/report-log.sh

and every hour, an updated report is available at
https://hotmixes.net/goaccess/goaccess.html To manually trigger an update, run

    sudo hotmixes.resty/report-log.sh

# Validation

Check:
- HTML https://validator.w3.org/nu/?doc=https%3A%2F%2Fhotmixes.net
- CSS https://jigsaw.w3.org/css-validator/validator?uri=https%3A%2F%2Fhotmixes.net
- Links https://validator.w3.org/checklink?uri=https%3A%2F%2Fhotmixes.net
- i18n https://validator.w3.org/i18n-checker/check?uri=https%3A%2F%2Fhotmixes.net
- RSS https://validator.w3.org/feed/check.cgi?url=https%3A%2F%2Fhotmixes.net%2Flatest.xml
- unified https://validator.w3.org/unicorn/check?ucn_uri=https%3A%2F%2Fhotmixes.net&ucn_task=conformance

# Backup

Backup is done via Synchting. Install it with:

    sudo apt-get install syncthing

See https://docs.syncthing.net/users/autostart.html#linux and configure with:

   cd /etc/systemd/system
   sudo su
   ln -s /lib/systemd/system/syncthing@.service
   systemctl enable syncthing@root.service
   systemctl start syncthing@root.service
   cd ~/.config/syncthing

Edit the file `config.xml` and change this line (note there are two changes):

    <gui enabled="true" tls="false" debugging="false">

into:

    <gui enabled="false" tls="true" debugging="false">

Also add devices manually, as a device and in a folder that is shared. Changes
to this file might need restart of the service with:

    systemctl stop syncthing@root.service
    systemctl start syncthing@root.service

See also https://docs.syncthing.net/users/firewall.html and to get introduced to
the instance on this server, first stop the service, add the lines below to
`config.xml` and start the server again.

    TODO (he paragraph above and test below is work in progress)

Add this Device ID (should not be mentioned here) on the backup machine and
add under Advanced the Address `tcp://ip.v4a.ddr.ess:22000`. (IP should also not be mentoined here.)
