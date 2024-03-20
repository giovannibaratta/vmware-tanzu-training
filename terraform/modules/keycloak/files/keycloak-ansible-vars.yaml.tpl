keycloak_version: "22.0.5"
keycloak_db_password: "${keycloak_db_password}"
keycloak_admin_password: "${keycloak_admin_password}"

%{ if keycloak_base64_tls_key != null ~}
keycloak_base64_tls_key: ${keycloak_base64_tls_key}
%{ endif ~}
%{ if keycloak_base64_tls_cert != null ~}
keycloak_base64_tls_cert: ${keycloak_base64_tls_cert}
%{ endif ~}
%{ if keycloak_base64_tls_ca_chain != null ~}
keycloak_base64_tls_ca_chain: ${keycloak_base64_tls_ca_chain}
%{ endif ~}
