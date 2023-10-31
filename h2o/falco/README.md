# Falco

[Additional notes](https://docs.google.com/document/d/1trCecgu9plk4qpWp2Bd_wIQor66r_TVDA7zSWe0_Csg/edit)

## Install Falco
```bash
kubectl create ns falco
kubectl apply -f falco-psp.yaml
helm install falco falcosecurity/falco --namespace falco --version 3.8.4 -f falco-values.yaml
```

## Install Falco sidekick with web UI
[Falco sidekick](https://github.com/falcosecurity/falcosidekick) can be used to forward Falco events to several destinations. The integrated web UI can be used to visualize all the events generated.

```bash
kubectl create ns falcosidekick
kubectl apply -f falcosidekick-psp.yaml
helm install falcosidekick falcosecurity/falcosidekick -n falcosidekick --version 0.7.8 -f falcosidekick-values.yaml
```

## Testing
The event-generator perform actions that will generate Falco events. It can be used to check if Falco is working correctly. The events can be seen in the pod logs or using the web UI.

```bash
kubectl create ns event-generator
kubectl apply -f event-generator-psp.yaml
helm install event-generator falcosecurity/event-generator -n event-generator -f event-generator-values.yaml
```