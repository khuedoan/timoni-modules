.POSIX:
.POSIX: default vet

default: vet test

vet:
	cd "${module}" && timoni mod vet

test:
	cd "${module}" && timoni build test . --values debug_values.cue
