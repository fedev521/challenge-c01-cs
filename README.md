# Challenge C01 - Cluster States

- [1. Repository Structure](#1-repository-structure)
  - [1.1. Considerations](#11-considerations)
- [2. Alternatives to Deploy an Application](#2-alternatives-to-deploy-an-application)
- [3. How To](#3-how-to)
  - [3.1. Cluster Setup](#31-cluster-setup)
  - [3.2. Add a Cluster](#32-add-a-cluster)
  - [3.3. Add an Application](#33-add-an-application)
  - [3.4. Test the Echo Server](#34-test-the-echo-server)
- [4. Useful Resources](#4-useful-resources)

## 1. Repository Structure

The repository structure is the following:

```
├── apps
│   ├── base
│   ├── production 
│   └── staging
└── clusters
    ├── production
    └── staging
```

The **clusters** directory contains one subdirectory for each cluster and is set
up via `flux bootstrap`. Inside each of subdirectory, the  `apps.yaml` file
defines the Flux Kustomization, which points to the corresponding folder under
`apps/`.

Note: we could and should add an `infra.yaml` manifest and an `infra/` folder to
configure:

- certificates management
- monitoring
- ingress setting
- ...

The structure would be the same as `apps`. We would have to add a dependency to
deploy infrastructure components before the applications the need them.

The **apps** directory contains:

- a `base/` directory containing one folder for each application to be deployed
- one subdirectory for each cluster to define kustomize overlays specific for
  that cluster

Note: [apps/production/kustomization.yaml](apps/production/kustomization.yaml)
contains an example of patch. This single-file approach is hard to maintain if
the number of applications grows. It would be better to use a separate file for
each application.

### 1.1. Considerations

- it is easy to manage a limited number of clusters
- quite a simple structure, easy to navigate
  - clear separation between infrastructure configuration and application
  - clear separation between different applications
  - clear separation between environments
- easy to promote to another environment
- flexibility in the location where to store manifests (see next section)

## 2. Alternatives to Deploy an Application

There are several different ways to deploy an application with this setup:

1. commit manifests under `./apps/base/{application}` (see `apps/base/podinfo`
   for example)
2. commit manifests in another repository, then configure Flux to sync with that
   repository with a GitRepository and a Kustomization (see `apps/base/echo` for
   example)
3. make Flux observe an image repository and update YAML manifests based on the
   latest image found (requires [image controllers](https://fluxcd.io/flux/components/image/))

In this repo, I used plain manifests, but using Helm repositories and charts is
of course an option.

## 3. How To

### 3.1. Cluster Setup

To setup two local clusters (staging and production) with kind and Flux:

```bash
./bootstrap.sh
```

### 3.2. Add a Cluster

Add an element to the list of clusters (Flux bootstrap is idempotent) and run
[bootstrap.sh](./bootstrap.sh). After that, create a folder under `apps/` with a
kustomization.yaml file listing which application you want to deploy.

### 3.3. Add an Application

Add a folder under `apps/base/` and place manifests there. Add an element to the
`resources` list in each of the clusters' kustomization files.

### 3.4. Test the Echo Server

```bash
kubectl port-forward services/echoserver 8888:80
curl localhost:8888
```

## 4. Useful Resources

- [Flux Repository Structure](https://fluxcd.io/flux/guides/repository-structure/)
- [Working with Kustomizations](https://fluxcd.io/flux/components/kustomize/kustomizations/#working-with-kustomizations)
