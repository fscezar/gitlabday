#!/bin/bash
cat <<EOF >> k8s-manifest.yml
---
apiVersion: apps/v1
kind: Deployment
metadata:
  namespace: default
  name: ${CI_PROJECT_NAME}
  labels:
    app: ${CI_PROJECT_NAME}
spec:
  replicas: 1
  selector:
    matchLabels:
      app: ${CI_PROJECT_NAME}
  template:
    metadata:
      labels:
        app: ${CI_PROJECT_NAME}
    spec:
      containers:
      - name: ${CI_PROJECT_NAME}
        image: registry.gitlab.com/estabilis/gitlab-day/${CI_PROJECT_NAME}:${CI_COMMIT_SHORT_SHA}
        ports:
        - containerPort: ${APP_CONTAINER_PORT}
      imagePullSecrets:
        - name: ${CI_PROJECT_NAME}
---
apiVersion: v1
kind: Service
metadata:
  namespace: default
  name: ${CI_PROJECT_NAME}-svc
  labels:
    app: ${CI_PROJECT_NAME}
spec:
  ports:
  - port: 80
    name: http
    targetPort: ${APP_CONTAINER_PORT}
  - port: 443
    targetPort: ${APP_CONTAINER_PORT}
    name: https
  selector:
    app: ${CI_PROJECT_NAME}
---
apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  namespace: default
  name: ${CI_PROJECT_NAME}-ingress
  annotations:
    kubernetes.io/tls-acme: "true"
    kubernetes.io/ingress.class: "nginx"
    ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
    - host: ${CI_PROJECT_NAME}.estabil.is
      http:
        paths:
          - path: /
            backend:
              serviceName: ${CI_PROJECT_NAME}-svc
              servicePort: 80
---
EOF
