# Name: kubernetes.tf
# Owner: Saurav Mitra
# Description: This terraform config will create Vault Kubernetes Auth Method
# The kubernetes auth method can be used to authenticate with Vault using a Kubernetes Service Account Token. 
# This method of authentication makes it easy to introduce a Vault token into a Kubernetes Pod.

resource "vault_auth_backend" "kubernetes" {
  type     = "kubernetes"
  path     = "kubernetes"
  provider = vault.root
}

resource "vault_kubernetes_auth_backend_config" "kubernetes_config" {
  backend                = vault_auth_backend.kubernetes.path
  kubernetes_host        = "https://10.0.1.200:8443"
  kubernetes_ca_cert     = file(var.kubernetes_ca_cert)
  token_reviewer_jwt     = var.kubernetes_token_reviewer_jwt
  issuer                 = "kubernetes.io/serviceaccount"
  disable_iss_validation = "true"
  provider               = vault.root
}

resource "vault_kubernetes_auth_backend_role" "webapp" {
  backend                          = vault_auth_backend.kubernetes.path
  role_name                        = "webapp"
  bound_service_account_names      = ["vault-auth-sa"]
  bound_service_account_namespaces = ["default"]
  token_policies                   = ["admin"]
  provider                         = vault.root
}



resource "vault_auth_backend" "dev_kubernetes" {
  type       = "kubernetes"
  path       = "kubernetes"
  provider   = vault.dev
  depends_on = [var.dev_namespace]
}

resource "vault_kubernetes_auth_backend_config" "dev_kubernetes_config" {
  backend                = vault_auth_backend.dev_kubernetes.path
  kubernetes_host        = "https://10.0.1.200:8443"
  kubernetes_ca_cert     = file(var.kubernetes_ca_cert)
  token_reviewer_jwt     = var.kubernetes_token_reviewer_jwt
  issuer                 = "kubernetes.io/serviceaccount"
  disable_iss_validation = "true"
  provider               = vault.dev
  depends_on             = [var.dev_namespace]
}

resource "vault_kubernetes_auth_backend_role" "dev_webapp" {
  backend                          = vault_auth_backend.dev_kubernetes.path
  role_name                        = "dev-webapp"
  bound_service_account_names      = ["vault-auth-sa"]
  bound_service_account_namespaces = ["default"]
  token_policies                   = ["kv-read"]
  provider                         = vault.dev
  depends_on                       = [var.dev_namespace]
}


/*
# Kubernetes Setup
kubectl config view

kubectl get serviceaccounts

kubectl create sa vault-auth-sa

kubectl get serviceaccounts/vault-auth-sa -o json

kubectl apply -f - <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: vault-role-tokenreview-binding
  namespace: default
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:auth-delegator
subjects:
- kind: ServiceAccount
  name: vault-auth-sa
  namespace: default
EOF

kubectl get serviceaccounts/vault-auth-sa -o json

export K8S_HOST="https://10.0.1.200:8443"

export VAULT_SA_SECRET_NAME=$(kubectl get sa vault-auth-sa -o jsonpath="{.secrets[0]['name']}")

export SA_JWT_TOKEN=$(kubectl get secret $VAULT_SA_SECRET_NAME -o jsonpath="{.data.token}" | base64 --decode; echo)

export SA_CA_CRT=$(kubectl get secret $VAULT_SA_SECRET_NAME -o jsonpath="{.data['ca\.crt']}" | base64 --decode; echo)

# kubectl delete serviceaccount/vault-auth-sa
*/


/*
# Enable Auth
vault auth enable -namespace=dev -path=kubernetes kubernetes
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X POST $VAULT_ADDR/v1/sys/auth/kubernetes -d '{"type": "kubernetes"}'

# List Auth
vault auth list -namespace=dev
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X GET $VAULT_ADDR/v1/sys/auth

# Configure Kubernetes
vault write -namespace=dev auth/kubernetes/config kubernetes_host="$K8S_HOST" token_reviewer_jwt="$SA_JWT_TOKEN" kubernetes_ca_cert="$SA_CA_CRT"
# In case of isssue with $SA_CA_CRT newline characters preservation in certificate, use the CA file directly
vault write -namespace=dev auth/kubernetes/config kubernetes_host="$K8S_HOST" token_reviewer_jwt="$SA_JWT_TOKEN" kubernetes_ca_cert=@/Users/John/ca.crt
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X POST $VAULT_ADDR/v1/auth/kubernetes/config -d "{\"kubernetes_host\": \"$K8S_HOST\", \"token_reviewer_jwt\": \"$SA_JWT_TOKEN\", \"kubernetes_ca_cert\": \"$SA_CA_CRT\"}"

# Read Kubernetes Config
vault read -namespace=dev auth/kubernetes/config
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X GET $VAULT_ADDR/v1/auth/kubernetes/config

# Create Kubernetes Role
vault write -namespace=dev auth/kubernetes/role/dev-webapp bound_service_account_names=vault-auth-sa bound_service_account_namespaces=default policies=kv-read
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X POST $VAULT_ADDR/v1/auth/kubernetes/role/dev-webapp -d '{"bound_service_account_names": "vault-auth-sa", "bound_service_account_namespaces": "default", "policies": "kv-read"}'

# Read Kubernetes Role
vault read -namespace=dev auth/kubernetes/role/dev-webapp
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X GET $VAULT_ADDR/v1/auth/kubernetes/role/dev-webapp

# List Kubernetes Roles
vault list -namespace=dev auth/kubernetes/role
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X LIST $VAULT_ADDR/v1/auth/kubernetes/role

# Kubernetes Login
vault write auth/kubernetes/login role=demo jwt=$SA_JWT_TOKEN
vault write -namespace=dev auth/kubernetes/login role=dev-webapp jwt=$SA_JWT_TOKEN
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X POST $VAULT_ADDR/v1/auth/kubernetes/login -d "{\"role\": \"dev-webapp\", \"jwt\": \"$SA_JWT_TOKEN\"}""

# Delete Kubernetes Role
vault delete -namespace=dev auth/kubernetes/role/dev-webapp
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X DELETE $VAULT_ADDR/v1/auth/kubernetes/role/dev-webapp

# Disable Auth
vault auth disable -namespace=dev kubernetes
curl -H "X-Vault-Token: $VAULT_TOKEN" -H "X-Vault-Namespace: $VAULT_NAMESPACE" -X DELETE $VAULT_ADDR/v1/sys/auth/kubernetes
*/
