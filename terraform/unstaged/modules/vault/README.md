# Vault module

## Know issues

### Name clashing

Not all the resources in the module use unique names. The module can not be instantiated more than once.

### Inconsistent plan

When creating a node and a dns entry in the same apply, Terraform fails with the following error during the apply

```
│ Error: Provider produced inconsistent final plan
│ 
│ When expanding the plan for module.vault_cluster.desec_rrset.node["0"] to include new values learned so far during apply, provider
│ "registry.terraform.io/valodim/desec" produced an invalid new value for .records: was null, but now
│ cty.SetVal([]cty.Value{cty.StringVal("172.17.0.16")}).
│ 
│ This is a bug in the provider, which should be reported in the provider's own issue tracker.
```

Workaround: Re-run the apply