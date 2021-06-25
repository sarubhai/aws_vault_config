# List key/value secrets mounted under secret/
path "secret/*" {
  capabilities = ["read", "list"]
}

# List secret/
path "secret/" {
  capabilities = ["list"]
}

# List, create, update, and delete key/value secrets mounted under kv/
path "kv/*" {
  capabilities = ["read", "list"]
}

# List kv/
path "kv/" {
  capabilities = ["list"]
}

# Check token capabilities
path "sys/capabilities" {
  capabilities = ["create", "update"]
}

# Check token accessor capabilities
path "sys/capabilities-accessor" {
  capabilities = ["create", "update"]
}

# Check token's own capabilities
path "sys/capabilities-self" {
  capabilities = ["create", "update"]
}
