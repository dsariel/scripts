#!/bin/bash +x


COMPONENT=python-swiftclient
declare -A CHNG_ID=( ["rhos10"]="I05b1ad50a430b5227313640827888d3da1d6423f" \
                     ["rhos11"]="I7e87e55918647b6ef4940f7064b590ec0a2a34e1" \
                     ["rhos12"]="I7e87e55918647b6ef4940f7064b590ec0a2a34e2" \
                     ["rhos13"]="I7e87e55918647b6ef4940f7064b590ec0a2a34e3" \
                     ["rhos14"]="I7e87e55918647b6ef4940f7064b590ec0a2a34e4")


. ./common_functions

\rm -rf $CHECKOUT_FOLDER
git clone $REPO_URL $CHECKOUT_FOLDER

for i in `seq 13 14` 
do
    echo $i ${CHNG_ID[rhos$i]}
    create_change $i ${CHNG_ID[rhos$i]}
    sleep 10m
done

