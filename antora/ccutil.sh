#!/bin/bash -ex
rm -rf server-admin/server-admin
cp -r build/assembler/server-admin server-admin
rm server-admin/server-admin/20.0/keycloak-server-administration.pdf
sed -i '2 a\
Keycloak Project' server-admin/server-admin/20.0/keycloak-server-administration.adoc
cd server-admin
IMAGENAME='quay.io/ivanhorvath/ccutil:amazing'

if which podman &>/dev/null;
then
    CRT=$(which podman)
else
    CRT=$(which docker)
fi

if ! podman inspect ccutil &>/dev/null;
then
    ${CRT} run --privileged --ulimit host -d -v $(pwd):/docs:rw --name ccutil ${IMAGENAME}
fi

${CRT} exec -w /docs ccutil ccutil compile --format html-single --lang en-US
cd ..
mkdir -p _site/keycloak-antora/server-admin
cp -r server-admin/build/tmp/en-US/html-single _site/keycloak-antora/server-admin
