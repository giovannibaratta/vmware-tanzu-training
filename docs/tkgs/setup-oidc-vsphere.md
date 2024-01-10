# TKGs OIDC

## Retrieve issuer URL

1. Connect to `https://<KEYCLOCK_SERVER>/realms/<REAL_NAME>/.well-known/openid-configuration`

* Registered the provider via ui (don't forget CERT  ) https://docs.vmware.com/en/VMware-vSphere/8.0/vsphere-with-tanzu-tkg/GUID-D0D65502-1442-4FEF-BEEE-D60CD1BC9641.html#GUID-D0D65502-1442-4FEF-BEEE-D60CD1BC9641__GUID-7025A488-69CA-4F60-BBF0-05DA39FB6797

## KB

### Unprocessable Entity: No upstream providers are configured

If you receive the error mentioned in the title when trying to login with the Tanzu CLI, check the logs of the pinniped supervisor. 
```sh
kubectl logs -n vmware-system-pinniped pinniped-supervisor-ff88d7d87-5qc67 | grep -i upstream
```

Several issues might prevents pinniped to use the configured IDP. See a few examples below

IDP is using a certificate that is not configured correctly → Regenerate the certificate or reconfigure the IDP
```sh
... oidc-upstream-observer ... Found x509: certificate is valid for localhost, keycloak, not keycloak.local.lan
```

Pinniped does not trust the certificate of the IDP → Update the provider configuration in vSphere
```sh
\"https://keycloak.local.lan/realms/tanzu/.well-known/openid-configuration\": x509: certificate signed by unknown authority
```

### Unprocessable Entity: email_verified claim in upstream ID token has false value

The user email address must be verified in the IDP

## References

[vSphere APIs](https://developer.vmware.com/apis/vsphere-automation/latest/vcenter/namespace_management/supervisors.identity.providers/)
[Register external provider IDP in vSphere](https://docs.vmware.com/en/VMware-vSphere/8.0/vsphere-with-tanzu-tkg/GUID-D0D65502-1442-4FEF-BEEE-D60CD1BC9641.html#GUID-D0D65502-1442-4FEF-BEEE-D60CD1BC9641__GUID-7025A488-69CA-4F60-BBF0-05DA39FB6797)