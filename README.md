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

On the server, the log can be monitored with

    tail -f ~/home/traefik/log/access.log

# Validation

Check:
- HTML https://validator.w3.org/nu/?doc=https%3A%2F%2Fhotmixes.net
- CSS https://jigsaw.w3.org/css-validator/validator?uri=https%3A%2F%2Fhotmixes.net
- Links https://validator.w3.org/checklink?uri=https%3A%2F%2Fhotmixes.net
- i18n https://validator.w3.org/i18n-checker/check?uri=https%3A%2F%2Fhotmixes.net
- RSS https://validator.w3.org/feed/check.cgi?url=https%3A%2F%2Fhotmixes.net%2Flatest.xml
- unified https://validator.w3.org/unicorn/check?ucn_uri=https%3A%2F%2Fhotmixes.net&ucn_task=conformance
