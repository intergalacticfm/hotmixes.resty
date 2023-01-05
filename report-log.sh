#!/bin/bash

LOG=~traefik/log
DST=~hotmixes/hotmixes.resty/goaccess
NAME=Traefik
rm -f /tmp/goaccess
zcat $(find $LOG/ -name "access.log.*.gz" -mtime -35) > /tmp/goaccess
cat $(ls $LOG/access.log*|grep -v gz) >> /tmp/goaccess
goaccess /tmp/goaccess -o $DST/goaccess-$(date +'%Y%m').html --log-format=COMBINED --html-report-title=$NAME --geoip-database=/var/lib/GeoIP/GeoLite2-City.mmdb
rm -f /tmp/goaccess

echo '<!DOCTYPE html>' > $DST/goaccess.html
echo '<html>' >> $DST/goaccess.html
echo '<head><title>GoAccess '$NAME'</title></head>' >> $DST/goaccess.html
echo '<body>' >> $DST/goaccess.html
echo '<h1>GoAccess '$NAME'</h1>' >> $DST/goaccess.html
echo '<p>Updated every hour on the hour. Available monthly reports are:</p>' >> $DST/goaccess.html
echo '<ul>' >> $DST/goaccess.html
for i in $(ls $DST/goaccess-*|sort -r); do
	f=$(basename $i)
	echo '<li><a href="'$f'">'$f'</a></li>' >> $DST/goaccess.html
done
echo '</ul>' >> $DST/goaccess.html
echo '</body>' >> $DST/goaccess.html
echo '</html>' >> $DST/goaccess.html
chown hotmixes.hotmixes $DST/goaccess*.html
