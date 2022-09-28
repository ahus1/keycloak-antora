#!/bin/bash -ex
rm -rf server-admin/server-admin
cp -r build/assembler/server-admin server-admin
rm server-admin/server-admin/20.0/keycloak-server-administration.pdf
sed -i '2 a\
Keycloak Project' server-admin/server-admin/20.0/keycloak-server-administration.adoc

rm -rf guides-operator/guides-operator
cp -r build/assembler/guides-operator guides-operator
rm guides-operator/guides-operator/20.0/guides-keycloak-operator.pdf
sed -i '2 a\
Keycloak Project' guides-operator/guides-operator/20.0/guides-keycloak-operator.adoc
sed -i 's|xref:{page-version}@guides-server::\([^.]*\)|https://ahus1.github.io/keycloak-antora/guides-server/latest/\1|g' guides-operator/guides-operator/20.0/guides-keycloak-operator.adoc

rm -rf guides-server/guides-server
cp -r build/assembler/guides-server guides-server
rm guides-server/guides-server/20.0/guides-keycloak-server.pdf
sed -i '2 a\
Keycloak Project' guides-server/guides-server/20.0/guides-keycloak-server.adoc

IMAGENAME='quay.io/ivanhorvath/ccutil:amazing'

if which podman &>/dev/null;
then
    CRT=$(which podman)
else
    CRT=$(which docker)
fi

if ! ${CRT} inspect ccutil &>/dev/null;
then
    ${CRT} run --privileged --ulimit host -d -v $(pwd):/docs:rw --name ccutil ${IMAGENAME}
fi

${CRT} exec -w /docs/server-admin ccutil ccutil compile --format html-single --lang en-US
${CRT} exec -w /docs/guides-operator ccutil ccutil compile --format html-single --lang en-US
${CRT} exec -w /docs/guides-server ccutil ccutil compile --format html-single --lang en-US

mkdir -p _site/keycloak-antora/server-admin
cp -r server-admin/build/tmp/en-US/html-single _site/keycloak-antora/server-admin

mkdir -p _site/keycloak-antora/guides-operator
cp -r guides-operator/build/tmp/en-US/html-single _site/keycloak-antora/guides-operator

mkdir -p _site/keycloak-antora/guides-server
cp -r guides-server/build/tmp/en-US/html-single _site/keycloak-antora/guides-server
