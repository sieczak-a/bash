#!/bin/bash

# USAGE
# chmod +x exportK8sManifests
# ./exportK8sManifest k8s_context

set -e

CONTEXT="$1"

if [[ -z ${CONTEXT} ]]; then
  echo "Usage: $0 KUBE-CONTEXT"
  exit 1
fi

#NAMESPACES=$(kubectl --context ${CONTEXT} get -o json namespaces|jq '.items[].metadata.name'|sed "s/\"//g")

RESOURCES="configmap secret daemonset deployment service hpa statefulset serviceaccount configmap clusterrole rolebinding role"

NAMESPACE="prometheus"

for ns in ${NAMESPACE};do
  for resource in ${RESOURCES};do
    rsrcs=$(kubectl --context ${CONTEXT} -n ${ns} get -o json ${resource}|jq '.items[].metadata.name'|sed "s/\"//g")
    for r in ${rsrcs}
    do
      r2=$(echo $r | sed 's/:/_/g')
      dir="${CONTEXT}/${ns}/${resource}"
      mkdir -p "${dir}"
      kubectl --context ${CONTEXT} -n ${ns} get -o yaml ${resource} ${r} > "${dir}/${r2}.yaml"
    done
  done
done
