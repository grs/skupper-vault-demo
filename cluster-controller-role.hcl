path "secret/data/skupper/foo/*" {
  capabilities = [ "create", "read", "update", "list", "delete" ]
}

path "secret/metadata/skupper/foo/*" {
  capabilities = [ "read", "list" ]
}

path "secret/data/skupper/bar/*" {
  capabilities = [ "create", "read", "update", "list", "delete" ]

}

path "secret/metadata/skupper/bar/*" {
  capabilities = [ "read", "list" ]
}
