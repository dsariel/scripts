#!/bin/bash +x


COMPONENT=swift
declare -A CHNG_ID=( ["rhos10"]="Ie402cca4aac3d0e4966b4708d84a5ca685ae32f8" \
                     ["rhos11"]="Ifbbfda6e5c739cde686d35c885942c780bc7e22b" \
                     ["rhos12"]="Ifbbfda6e5c739cde686d35c885942c780bc7e22c" \
                     ["rhos13"]="Ifbbfda6e5c739cde686d35c885942c780bc7e22d" \
                     ["rhos14"]="Ifbbfda6e5c739cde686d35c885942c780bc7e22e")


. ./common_functions

\rm -rf $CHECKOUT_FOLDER
git clone $REPO_URL $CHECKOUT_FOLDER

for i in `seq 13 14` 
do
    echo $i ${CHNG_ID[rhos$i]}
    create_change $i ${CHNG_ID[rhos$i]}
    if [ $i -ne 10 ]; then
       sleep 5m
    fi
done

