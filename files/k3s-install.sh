#!/bin/bash

%{ if is_k3s_server }
%{ if k3s_datastore_endpoint != "sqlite" }
curl -o ${k3s_datastore_cafile} https://s3.amazonaws.com/rds-downloads/rds-combined-ca-bundle.pem
%{ endif }
%{ endif }

until (curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION='v${install_k3s_version}' INSTALL_K3S_EXEC='%{ if is_k3s_server }${k3s_tls_san} ${k3s_disable_agent} %{ endif}${k3s_exec}' K3S_TOKEN='${k3s_cluster_secret}' %{ if is_k3s_server }%{ if k3s_datastore_endpoint != "sqlite" }K3S_DATASTORE_CAFILE='${k3s_datastore_cafile}'%{ endif } %{ if k3s_datastore_endpoint != "sqlite" }K3S_DATASTORE_ENDPOINT='${k3s_datastore_endpoint}'%{ endif } %{ endif }%{ if !is_k3s_server } K3S_URL='https://${k3s_url}:6443'%{ endif } sh -); do
  echo 'k3s did not install correctly'
  sleep 2
done

%{ if is_k3s_server }
until kubectl get pods -A | grep 'Running'; do
  echo 'Waiting for k3s startup'
  sleep 5
done
%{ endif }
