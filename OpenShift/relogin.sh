#!/bin/bash

OCP_SERVER="https://api.ocp.openstack.lab:6443"

KUBEADMIN_PASSWORD_FILE="$HOME/.kube/kubeadmin-password"

if [[ ! -f "$KUBEADMIN_PASSWORD_FILE" ]]; then
    echo "Error: kubeadmin password file not found at $KUBEADMIN_PASSWORD_FILE"
    exit 1
fi

KUBEADMIN_PASSWORD=$(cat "$KUBEADMIN_PASSWORD_FILE")

# Log in to OpenShift using the kubeadmin credentials
oc login -u kubeadmin -p "$KUBEADMIN_PASSWORD" --server="$OCP_SERVER"
if [[ $? -ne 0 ]]; then
    echo "Error: OpenShift login failed."
    exit 1
fi

# Print the token
TOKEN=$(oc whoami --show-token)
if [[ -z "$TOKEN" ]]; then
    echo "Error: Failed to retrieve token."
    exit 1
else
    echo $TOKEN
fi
