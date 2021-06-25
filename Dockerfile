# Based on https://github.com/linkyard/docker-helm/blob/master/Dockerfile
# and https://github.com/lachie83/k8s-helm/blob/v2.7.2/Dockerfile
FROM alpine:3.8 as build
MAINTAINER A.Davarski

ARG HELM_VERSION=v2.11.0
ARG KUBE_VERSION=v1.12.2

RUN apk add --update --no-cache ca-certificates curl tar gzip && \
    curl -Lo /tmp/kubectl https://storage.googleapis.com/kubernetes-release/release/${KUBE_VERSION}/bin/linux/amd64/kubectl && \
    curl -L http://storage.googleapis.com/kubernetes-helm/helm-${HELM_VERSION}-linux-amd64.tar.gz | tar zxv -C /tmp --strip-components=1 linux-amd64/helm && \
    chmod +x /tmp/kubectl /tmp/helm

# The image we keep
# Ensure docker is present, so it can be used from gitlab too
FROM docker:latest
RUN apk add --update --no-cache git ca-certificates curl
COPY --from=build /tmp/kubectl /tmp/helm /bin/
COPY create-tmp-image-pull-secret create-kubeconfig create-namespace get-gitlab-settings create-release /bin/

# Make sure a basic helm layout is installed so helm just works.
# Users can run `helm repo update` in case anything is needed from the stable/ repo.
RUN helm init --client-only --skip-refresh
CMD ["/bin/helm"]
