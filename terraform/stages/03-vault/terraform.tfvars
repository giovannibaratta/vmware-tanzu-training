vault_address = "https://vault.gkube.it"

enable_oidc_auth = true

oidc_config = {
  client_id = "oidc-auth"
  user_claim = "preferred_username"
  groups_claim = "groups"
  discovery_url = "https://keycloak.gkube.it/realms/tanzu"
  scopes = ["openid", "profile", "groups"]
}

enable_kubernetes_auth = true

kubernetes_auth_config = {
  host = "https://172.16.100.14:6443"
  ca = "-----BEGIN CERTIFICATE-----\nMIIC6jCCAdKgAwIBAgIBADANBgkqhkiG9w0BAQsFADAVMRMwEQYDVQQDEwprdWJl\ncm5ldGVzMB4XDTIzMTExNjE2MTE1MFoXDTMzMTExMzE2MTY1MFowFTETMBEGA1UE\nAxMKa3ViZXJuZXRlczCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBALAN\njFDdWnofWSIwL8DjzJV6zP/LkI8ctH1kzSLND61mRCCrBtINbx6Kao5B7Tyg7Sy+\n7GhGYpe/lVUHWoQJuv7ZVb+pBTcdfxqDGLcjMexyTrwRqXFnyH73ccE0oJWidNYF\n2zODsI+IjoCsqYwubTlPIfMaMNZdmS7u163Wjh3snWZ+7RnjJxkgEaxvhsz5KadM\nRbJsBYxg+6LGYfC4rYq1qHLalwanYW5gWGMw7LUNSzbuFhxARlcTFmu4L1VpMQXM\nv6l7KQpbXeYxwx1PR/XDnOQM4j5M1/fW6/eSpW2Ok5NaQabsBENKwO6etDdyvFAo\nT7hyZhxsFU2Qc8uL24ECAwEAAaNFMEMwDgYDVR0PAQH/BAQDAgKkMBIGA1UdEwEB\n/wQIMAYBAf8CAQAwHQYDVR0OBBYEFKNyVc5U64GaQSV69mWx6kogq3S/MA0GCSqG\nSIb3DQEBCwUAA4IBAQB/e0GPb76B3krspcE1cD2o5KsTWeSouTK4058gS+6vlxer\nLJXMWXiEkXaauOAtjKTN6JK/vA6m1ebT+Nl8jE0g8vH9qUfBZd9HMxZRsSVlY3i8\nQZ1mnu3XH/95ddzLYWcP0fKuWQinUvZvP2L9IGL492toegYOhH0JdTzskA3w5spE\nZRK9s5kL2n7/uWjIIoFdDnfssANw08pdR3rDadlYT9xZ/Uoy+OM7/cyGk+Rw08ht\naHKWnXvpVjRtPLJh9Z7W58SZmy6VINpCI1OhwykRQBeiT1D1gaS1U2mgq9NmgkmT\nP6LvG91h7NtlOEMe1mKQ9dWiVUkmSF58X0rLjBMN\n-----END CERTIFICATE-----"
}