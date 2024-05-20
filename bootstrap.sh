#!/bin/bash

GITHUB_OWNER='fedev521'
GITHUB_REPO='challenge-c01-cs'

for cluster in 'staging' 'production'; do
    kind create cluster --name "$cluster"

    CONTEXT="kind-$cluster"

    [[ -z "$GITHUB_TOKEN" ]] && >&2 echo Missing GITHUB_TOKEN && exit 1
    flux bootstrap github \
        --context="$CONTEXT" \
        --owner="$GITHUB_OWNER" \
        --repository="$GITHUB_REPO" \
        --branch=master \
        --personal \
        --path="clusters/$cluster"
done
