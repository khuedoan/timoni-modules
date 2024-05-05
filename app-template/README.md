# App Template

A [timoni.sh](http://timoni.sh) module for deploying applications to Kubernetes clusters,
inspired by [bjw's App Template Helm chart](https://bjw-s.github.io/helm-charts/docs/app-template).

## Install

To change the [default configuration](#configuration),
create one or more `values.cue` files and apply them to the instance.

For example, create a file `my-values.cue` with the following content:

```cue
values: {
}
```

And apply the values with:

```shell
timoni -n default apply my-app oci://ghcr.io/khuedoan/timoni-modules/app-template \
--values ./my-values.cue
```

## Uninstall

To uninstall an instance and delete all its Kubernetes resources:

```shell
timoni -n default delete my-app
```

## Configuration

| Key                      | Type                             | Default            | Description                                                                                                                                  |
|--------------------------|----------------------------------|--------------------|----------------------------------------------------------------------------------------------------------------------------------------------|
| `metadata: labels:`      | `{[ string]: string}`            | `{}`               | Common labels for all resources                                                                                                              |
| `metadata: annotations:` | `{[ string]: string}`            | `{}`               | Common annotations for all resources                                                                                                         |
