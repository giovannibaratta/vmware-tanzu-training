harbor_hostname: ${harbor_hostname}

%{ if harbor_base64_tls_key != null ~}
harbor_base64_tls_key: ${harbor_base64_tls_key}
%{ endif ~}
%{ if harbor_base64_tls_cert != null ~}
harbor_base64_tls_cert: ${harbor_base64_tls_cert}
%{ endif ~}
%{ if harbor_base64_tls_ca_chain != null ~}
harbor_base64_tls_ca_chain: ${harbor_base64_tls_ca_chain}
%{ endif ~}
