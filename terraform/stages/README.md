# Stages

While the stages have been built to be composable (e.g deploy stage 0, then stage 1, ...) they have not been actually tested together and might not actually work well (or not at all due to some requirements on previous stages). Also you might not need all of them (e.g. 02-tmc), the number should give you an hint on order that should be used to apply but does not mean that a previous step is necessary to deploy the resources.

The stages with the same initial number are mutually exclusive, you can only use one between all the stages available.

Stages with a lower number are more close to the infrastructure or core components provided by a provider, while higher numbers are more tied to specific services deployed in the infrastructure.