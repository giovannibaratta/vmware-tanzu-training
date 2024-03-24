authenticationType: federated
contourEnvoy:
  serviceType: LoadBalancer

dnsZone: tmc.${domain}
# Do not add trailing /
harborProject: registry.${domain}/tmc-sm

# Map external groups defined in the IDP to the internal group used by TMC
idpGroupRoles:
  admin: tmc:admin
  member: tmc:member

minio:
  password: "${minio_password}"
  username: root

oidc:
  clientID: "${oidc_client_id}"
  clientSecret: "${oidc_client_secret}"
  issuerType: pinniped
  issuerURL: "${oidc_issuer_url}"

clusterIssuer: root-ca

postgres:
  maxConnections: 300
  userPassword: "${postgres_password}"

size: small

# Include all the CAs that must be trusted by the different components of TMC. These CAs will also
# be pushed to clusters created with TMC and injected in the secrets used for the continuous delivery.
trustedCAs:
  root-ca.pem: |-
    ${indent(4, root_ca)}