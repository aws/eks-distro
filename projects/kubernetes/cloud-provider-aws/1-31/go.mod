module k8s.io/cloud-provider-aws

go 1.24.0

// Cannot be removed until all dependencies use crypto library v0.17.0 or higher
replace golang.org/x/crypto => golang.org/x/crypto v0.17.0
