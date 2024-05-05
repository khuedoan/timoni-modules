.POSIX:
.PHONY: default vet test vendor

default: vet test

vet:
	cd "${module}" && timoni mod vet

test:
	cd "${module}" && timoni build test . --values debug_values.cue

vendor:
	cd "${module}" && timoni mod vendor k8s
