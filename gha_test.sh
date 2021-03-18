#!/bin/bash

set -e
set -u
docker build -t apacheds-test .
docker run -d --name apacheds-test -p 10389:10389 apacheds-test
sleep 10
echo "Old style"
bin/initialize
bin/group public add
bin/user public add
bin/user public in public
bin/search
yes | bin/clear
echo "New style"
bin/ldapmanager init
bin/ldapmanager user public --password public
bin/ldapmanager group public --member public
bin/ldapmanager get 'uid=public,ou=Users,dc=openmicroscopy,dc=org'
bin/ldapmanager search 'uid=public'
bin/ldapmanager --bind-user uid=public,ou=Users,dc=openmicroscopy,dc=org --bind-pass public search
bin/ldapmanager --bind-user uid=public,ou=Users,dc=openmicroscopy,dc=org --bind-pass public passwd --login public --password first --password second
bin/ldapmanager --bind-user uid=public,ou=Users,dc=openmicroscopy,dc=org --bind-pass first search
bin/ldapmanager --bind-user uid=public,ou=Users,dc=openmicroscopy,dc=org --bind-pass second search
bin/ldapmanager passwd --admin --append --password backdoor
bin/ldapmanager --bind-pass backdoor search
bin/ldapmanager clear
docker rm -f apacheds-test