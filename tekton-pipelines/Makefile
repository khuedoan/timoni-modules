.POSIX:
.PHONY: default update

default: update

update:
	# TODO any better way to do this?
	# Trim the last '---', otherwise we'll get a label reference not found error
	curl https://storage.googleapis.com/tekton-releases/pipeline/previous/v0.59.0/release.yaml \
		| head -n -1 \
		> pipeline.yaml
	cue import \
		--force \
		--outfile templates/pipeline.cue \
		--list \
		--path '"pipeline"' \
		--package templates \
		pipeline.yaml
	rm pipeline.yaml
	curl https://storage.googleapis.com/tekton-releases/triggers/previous/v0.26.2/release.yaml \
		| head -n -1 \
		> triggers.yaml
	cue import \
		--force \
		--outfile templates/triggers.cue \
		--list \
		--path '"triggers"' \
		--package templates \
		triggers.yaml
	rm triggers.yaml
