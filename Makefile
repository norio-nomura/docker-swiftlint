IMAGE_NAME?=swiftlint

override DOCKER_FLAGS+=--load

# --no-cache-filter=$(NO_CACHE_FILTER)
override DOCKER_FLAGS+=$(addprefix --no-cache-filter=,$(NO_CACHE_FILTER))

# --platform=$(PLATFORM)
override PLATFORM?=linux/amd64,linux/arm64
override DOCKER_FLAGS+=$(addprefix --platform=,$(PLATFORM))

# --progress=$(PROGRESS)
override DOCKER_FLAGS+=$(addprefix --progress,$(PROGRESS))

# --build-arg=
override DOCKER_FLAGS+=$(foreach v,$(_BUILD_ARGS),$(addprefix --build-arg=$(v)=,$($(v))))
override _BUILD_ARGS=$(sort $(_KNOWN_BUILD_ARG_VARS) $(_BUILD_ARG_VARS_FROM_CLI))
override _KNOWN_BUILD_ARG_VARS=CROSS PREFER_BUILDARCH RUNTIME_IMAGE TARGET_IMAGE USE_SDK
override _BUILD_ARG_VARS_FROM_CLI=$(foreach v,$(filter-out $(_KNOWN_VARS),$(.VARIABLES)),$(if $(filter command line,$(origin $(v))),$(v)))
override _KNOWN_VARS=CONTEXT DOCKER_FLAGS NO_CACHE_FILTER PLATFORM PROGRESS

# --tag=[$(IMAGE_NAME):]$@ --tag=[$(IMAGE_NAME):]$(DOCKER_TAG)
override DOCKER_FLAGS+=$(addprefix --tag=$(addsuffix :,$(IMAGE_NAME)),$(_DOCKER_TAGS))
override _DOCKER_TAGS+=$@

# --cache-to=, --cache-from=
override DOCKER_FLAGS+=$(addsuffix $(_CACHE_FLAGS_COMMON),$(_CACHE_FLAGS))
override _CACHE_FLAGS_COMMON=${HOME}/.cache/docker,type=local,mode=max
override _CACHE_FLAGS=--cache-to=dest= --cache-from=src=

# docker --context $(CONTEXT) buildx build $(DOCKER_FLAGS)
override BUILD=$(strip docker $(addprefix --context ,$(CONTEXT)) buildx build $(sort $(DOCKER_FLAGS)))

.PHONY: all latest cross prefer-buildarch prefer-buildarch-use-sdk use-sdk copier slim

all: latest cross native prefer-buildarch prefer-buildarch-use-sdk use-sdk copier slim

test: ; echo $(addsuffix :,$(IMAGE_NAME))

# use builder
latest: override _DOCKER_TAGS+=latest
latest: prefer-buildarch

cross: override CROSS=1
cross: ; $(BUILD) builder

native: ; $(BUILD) builder

prefer-%: override PREFER_BUILDARCH=1
%-sdk: override USE_SDK=1
prefer-buildarch: ; $(BUILD) builder
prefer-buildarch-use-sdk: ; $(BUILD) builder
use-sdk: ; $(BUILD) builder

# use copier
override COPIER_ARTIFACTS=copier/swiftlint_linux_amd64.tar.gz copier/swiftlint_linux_arm64.tar.gz
copier/swiftlint_linux_%.tar.gz: latest ; docker run --platform linux/$* --rm $(if $(IMAGE_NAME),$(IMAGE_NAME),latest) archive-swiftlint-runtime > $@
copier: $(COPIER_ARTIFACTS) ; $(BUILD) copier

slim: override RUNTIME_IMAGE?=ubuntu
slim: $(COPIER_ARTIFACTS) ; $(BUILD) copier
