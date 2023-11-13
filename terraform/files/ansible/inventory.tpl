[keycloak]
${keycloak_host_ip}

[conjur]
${conjur_host_ip}

%{ if minio_host_ip != "" }
[minio]
${minio_host_ip}
%{ endif }