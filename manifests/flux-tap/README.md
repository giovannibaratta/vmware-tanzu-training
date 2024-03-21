# TAP

## Encrypt TAP values

```sh
sops --encrypt --input-type yaml --mac-only-encrypted --encrypted-regex '^.*([pP]assword|[sS]ecret|serviceAccountToken).*$' tap-values.yaml > tap-values.yaml.encrypted
```