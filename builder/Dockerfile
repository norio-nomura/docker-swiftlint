# syntax=docker/dockerfile:1

####################################################################################################
# Build Arguments
####################################################################################################

# Suffix for the default image names.
ARG IMAGE_SUFFIX

# The image to use for building SwiftLint by using Swift SDK
ARG BUILDER_IMAGE=swift:6.2${IMAGE_SUFFIX}

# The image to using Swift Toolchain for building SwiftLint
ARG TARGET_IMAGE=swift:6.2${IMAGE_SUFFIX}

# The image to running SwiftLint. If image does not contain Swift runtime libraries,
#              the libraries will be copied from the target image.
ARG RUNTIME_IMAGE=${TARGET_IMAGE}

# The revision of SwiftLint to build.
ARG SWIFTLINT_REVISION=0.63.0

# If set, target will be built on BUILDARCH.
ARG PREFER_BUILDARCH

# supports: amd64, x86_64, arm64, aarch64
ARG CROSS_TARGETARCHS

# If set, build target will be cross-compiled.
# default: decided by the CROSS_TARGETARCHS
ARG CROSS

# If set, build target with verbose output.
ARG VERBOSE

# If set, build target by using Swift SDK.
ARG USE_SDK

# If set, build halt after building SwiftLint for debugging.
ARG SLEEP

# If set, Avoid link error fixed in https://github.com/apple/swift-package-manager/pull/7695
ARG FIX_SWIFTPM_7695

####################################################################################################
# Internal build arguments
####################################################################################################

# Decide _TARGET_TRIPLE_ARCH from TARGETARCH
ARG _TARGET_TRIPLE_ARCH=${TARGETARCH}
ARG _TARGET_TRIPLE_ARCH=${_TARGET_TRIPLE_ARCH/*arm64/aarch64}
ARG _TARGET_TRIPLE_ARCH=${_TARGET_TRIPLE_ARCH/*amd64/x86_64}

ARG _HOST_TRIPLE_ARCH=${BUILDARCH}
ARG _HOST_TRIPLE_ARCH=${_HOST_TRIPLE_ARCH/*arm64/aarch64}
ARG _HOST_TRIPLE_ARCH=${_HOST_TRIPLE_ARCH/*amd64/x86_64}

ARG _PARSE_PREFER_BUILDARCH=${PREFER_BUILDARCH}
ARG _PARSE_PREFER_BUILDARCH=${_PARSE_PREFER_BUILDARCH:+${_HOST_TRIPLE_ARCH}}
ARG _PARSE_PREFER_BUILDARCH=${_PARSE_PREFER_BUILDARCH:-${_TARGET_TRIPLE_ARCH}}
ARG _PARSE_PREFER_BUILDARCH=${_TARGET_TRIPLE_ARCH/${_PARSE_PREFER_BUILDARCH}/}

ARG CROSS_TARGETARCHS=${CROSS_TARGETARCHS:+${CROSS_TARGETARCHS},${_PARSE_PREFER_BUILDARCH}}
ARG CROSS_TARGETARCHS=${CROSS_TARGETARCHS:-${_PARSE_PREFER_BUILDARCH}}

# Parse CROSS_TARGETARCHS
# input check requires `syntax=docker/dockerfile-upstream:master`
# ARG _INPUT_CHECK_CROSS_TARGETARCHS=${CROSS_TARGETARCHS}
# ARG _INPUT_CHECK_CROSS_TARGETARCHS=${_INPUT_CHECK_CROSS_TARGETARCHS//arm64/}
# ARG _INPUT_CHECK_CROSS_TARGETARCHS=${_INPUT_CHECK_CROSS_TARGETARCHS//amd64/}
# ARG _INPUT_CHECK_CROSS_TARGETARCHS=${_INPUT_CHECK_CROSS_TARGETARCHS//aarch64/}
# ARG _INPUT_CHECK_CROSS_TARGETARCHS=${_INPUT_CHECK_CROSS_TARGETARCHS//x86_64/}
# ARG _UNSUPPORTED_CROSS_TARGETARCHS=${_INPUT_CHECK_CROSS_TARGETARCHS}
# ARG _INPUT_CHECK_CROSS_TARGETARCHS=${_INPUT_CHECK_CROSS_TARGETARCHS//,/}
# ARG _INPUT_CHECK_CROSS_TARGETARCHS=${_INPUT_CHECK_CROSS_TARGETARCHS:+UNSUPPORTED}
# ARG _INPUT_CHECK_CROSS_TARGETARCHS=${_INPUT_CHECK_CROSS_TARGETARCHS:-SUPPORTED}
# ARG _INPUT_CHECK_CROSS_TARGETARCHS=${_INPUT_CHECK_CROSS_TARGETARCHS//UNSUPPORTED/}
# ARG _INPUT_CHECK_CROSS_TARGETARCHS=${_INPUT_CHECK_CROSS_TARGETARCHS:?"Unsupported ARCH detected: $_UNSUPPORTED_CROSS_TARGETARCHS"}

ARG _PARSE_CROSS_TARGETARCHS=${CROSS_TARGETARCHS}
ARG _PARSE_CROSS_TARGETARCHS=${_PARSE_CROSS_TARGETARCHS//${_TARGET_TRIPLE_ARCH}/cross-arch}
ARG _CROSS_TRIPLE_ARCH_VARIANT=${_TARGET_TRIPLE_ARCH}
ARG _CROSS_TRIPLE_ARCH_VARIANT=${_CROSS_TRIPLE_ARCH_VARIANT/aarch64/arm64}
ARG _CROSS_TRIPLE_ARCH_VARIANT=${_CROSS_TRIPLE_ARCH_VARIANT/x86_64/amd64}
ARG _PARSE_CROSS_TARGETARCHS=${_PARSE_CROSS_TARGETARCHS//${_CROSS_TRIPLE_ARCH_VARIANT}/cross-arch}
ARG _PARSE_CROSS_TARGETARCHS=${_PARSE_CROSS_TARGETARCHS//arm64/}
ARG _PARSE_CROSS_TARGETARCHS=${_PARSE_CROSS_TARGETARCHS//amd64/}
ARG _PARSE_CROSS_TARGETARCHS=${_PARSE_CROSS_TARGETARCHS//aarch64/}
ARG _PARSE_CROSS_TARGETARCHS=${_PARSE_CROSS_TARGETARCHS//x86_64/}
ARG _PARSE_CROSS_TARGETARCHS=${_PARSE_CROSS_TARGETARCHS//,/}
ARG _RESULT_PARSING_CROSS_TARGETARCHS=${_PARSE_CROSS_TARGETARCHS:+cross-arch}

# Parse CROSS
ARG CROSS=${_RESULT_PARSING_CROSS_TARGETARCHS:+1}
# if `CROSS` is set then `_CROSS_OR_SAME` will be "cross-arch", otherwise the variable is the empty string.
ARG _CROSS_OR_SAME=${CROSS:+cross-arch}
# if `_CROSS_OR_SAME` is set then the variable will be that value. 
# If the variable is not set then the variable will be the "same-arch".
ARG _CROSS_OR_SAME=${_CROSS_OR_SAME:-same-arch}

# Parse USE_SDK
ARG USE_SDK=${CROSS:+1}
ARG _BUILDER_SELECTOR=${USE_SDK:+${_CROSS_OR_SAME}-sdk}
ARG _BUILDER_SELECTOR=${_BUILDER_SELECTOR:-no-sdk}

# Decide _BUILDER_TRIPLE_ARCH from CROSS and TARGETARCH
ARG _BUILDER_TRIPLE_ARCH=${USE_SDK:+${_TARGET_TRIPLE_ARCH}${_CROSS_OR_SAME}}
ARG _BUILDER_TRIPLE_ARCH=${_BUILDER_TRIPLE_ARCH/aarch64cross-arch/x86_64}
ARG _BUILDER_TRIPLE_ARCH=${_BUILDER_TRIPLE_ARCH/aarch64same-arch/aarch64}
ARG _BUILDER_TRIPLE_ARCH=${_BUILDER_TRIPLE_ARCH/x86_64cross-arch/aarch64}
ARG _BUILDER_TRIPLE_ARCH=${_BUILDER_TRIPLE_ARCH/x86_64same-arch/x86_64}

ARG _RUNTIME_NAME=${RUNTIME_IMAGE/:/-}
ARG _SDK_NAME=${USE_SDK:+${_TARGET_TRIPLE_ARCH}-on-${_BUILDER_TRIPLE_ARCH}}
ARG _SDK_NAME=${_SDK_NAME:-${_TARGET_TRIPLE_ARCH}-no-sdk}
ARG _TARGET_NAME=${TARGET_IMAGE/:/-}

ARG _BUILD_CACHE_ID=${USE_SDK:+build-${_SDK_NAME}-${BUILDER_IMAGE/:/-}}
ARG _BUILD_CACHE_ID=${_BUILD_CACHE_ID:-build-${_SDK_NAME}-${_TARGET_NAME}}

ARG _SLEEP_SELECTOR=${SLEEP:+-to-sleep}

####################################################################################################
# Stages for Swift SDKs
####################################################################################################
FROM scratch AS swift-sdk-tools
# Install packages for Swift SDK
COPY --chmod=755 <<'EOT' /install-packages
#!/bin/bash -eux
apt-get update && apt-get install -y \
    binutils-aarch64-linux-gnu \
    binutils-x86-64-linux-gnu \
    libcurl4-openssl-dev \
    libxml2-dev
EOT
# Fix symbolic linked libraries from absolute path to relative path for *-linux-gnu-ld.gold
COPY --chmod=755 <<'EOT' /fix-symlinked-libraries-from-absolute-to-relative
#!/bin/bash -eu
for target_dir in $(readlink -f /lib/*-linux-gnu /lib*); do \
    for target in $(find $target_dir -type l); do \
        [[ ! "$(readlink $target)" =~ ^/ ]] || ln -sfv $(realpath --relative-to=$target_dir $target) $target; \
    done; \
done
EOT
# Create SDKSettings.json
COPY --chmod=755 <<'EOT' /create-sdk-settings-json
#!/bin/bash -eux
arch=$(arch)
cat <<EOF | tee /SDKSettings.json
{
  "DisplayName": "Swift SDK for Linux ($arch)",
  "Version": "0.0.1",
  "VersionMap": {},
  "CanonicalName": "$arch-swift-linux-gnu"
}
EOF
EOT
COPY --chmod=755 <<'EOT' /prepare-sdk-root
#!/bin/bash -eux
dir=$(dirname $0)
$dir/install-packages
$dir/fix-symlinked-libraries-from-absolute-to-relative
$dir/create-sdk-settings-json
EOT

####################################################################################################
# Stages for Swift SDKs
####################################################################################################
FROM --platform=linux/arm64 ${TARGET_IMAGE} AS swift-aarch64
RUN rm -f /etc/apt/apt.conf.d/docker-clean; echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/keep-cache
ARG _TARGET_NAME
ARG APT_CACHE_ID=apt-${_TARGET_NAME}-aarch64
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked,id=${APT_CACHE_ID} \
    --mount=type=cache,target=/var/lib/apt,sharing=locked,id=${APT_CACHE_ID} \
    --mount=type=bind,target=/swift-sdk-tools,from=swift-sdk-tools \
    /swift-sdk-tools/prepare-sdk-root

FROM --platform=linux/amd64 ${TARGET_IMAGE} AS swift-x86_64
RUN rm -f /etc/apt/apt.conf.d/docker-clean; echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/keep-cache
ARG _TARGET_NAME
ARG APT_CACHE_ID=apt-${_TARGET_NAME}-x86_64
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked,id=${APT_CACHE_ID} \
    --mount=type=cache,target=/var/lib/apt,sharing=locked,id=${APT_CACHE_ID} \
    --mount=type=bind,target=/swift-sdk-tools,from=swift-sdk-tools \
    /swift-sdk-tools/prepare-sdk-root

####################################################################################################
# Stages for building target with Swift SDK on same architecture
####################################################################################################
# Builder uses same architectures to build SwiftLint
FROM --platform=linux/arm64 ${BUILDER_IMAGE} AS aarch64-on-aarch64-base
FROM --platform=linux/amd64 ${BUILDER_IMAGE} AS x86_64-on-x86_64-base
# Fix symbolic linked libraries from absolute path to relative path for *-linux-gnu-ld.gold
RUN target_lib=/usr/lib64/ld-linux-x86-64.so.2 && \
    test -L $target_lib && ln -sf $(realpath --relative-to=$(dirname $target_lib) $target_lib) $target_lib

####################################################################################################
# Stages for building target with Swift SDK on other architecture
####################################################################################################
# Builder uses other architectures to build SwiftLint
FROM --platform=linux/amd64 ${BUILDER_IMAGE} AS aarch64-on-x86_64-base
FROM --platform=linux/arm64 ${BUILDER_IMAGE} AS x86_64-on-aarch64-base

####################################################################################################
# Stages for building target with no Swift SDK
####################################################################################################
FROM --platform=linux/arm64 ${TARGET_IMAGE} AS aarch64-no-sdk-base
FROM --platform=linux/amd64 ${TARGET_IMAGE} AS x86_64-no-sdk-base

####################################################################################################
# Prepare source code for building SwiftLint
####################################################################################################
FROM ${_SDK_NAME}-base AS base-preparer
ARG _BUILD_CACHE_ID _BUILDER_SELECTOR _BUILDER_TRIPLE_ARCH _CROSS_OR_SAME _PARSE_CROSS_TARGETARCHS _RESULT_PARSING_CROSS_TARGETARCHS _RUNTIME_NAME _SDK_NAME _SLEEP_SELECTOR _TARGET_NAME _TARGET_TRIPLE_ARCH BUILDER_IMAGE CROSS CROSS_TARGETARCHS IMAGE_SUFFIX RUNTIME_IMAGE SLEEP SWIFTLINT_REVISION TARGET_IMAGE USE_SDK VERBOSE
RUN [ -z "${VERBOSE}"] || cat <<EOT
_BUILD_CACHE_ID: "${_BUILD_CACHE_ID}"
_BUILDER_SELECTOR: "${_BUILDER_SELECTOR}"
_BUILDER_TRIPLE_ARCH: "${_BUILDER_TRIPLE_ARCH}"
_CROSS_OR_SAME: "${_CROSS_OR_SAME}"
_PARSE_CROSS_TARGETARCHS: "${_PARSE_CROSS_TARGETARCHS}"
_RESULT_PARSING_CROSS_TARGETARCHS: "${_RESULT_PARSING_CROSS_TARGETARCHS}"
_RUNTIME_NAME: "${_RUNTIME_NAME}"
_SDK_NAME: "${_SDK_NAME}"
_SLEEP_SELECTOR: "${_SLEEP_SELECTOR}"
_TARGET_NAME: "${_TARGET_NAME}"
_TARGET_TRIPLE_ARCH: "${_TARGET_TRIPLE_ARCH}"
BUILDER_IMAGE: "${BUILDER_IMAGE}"
CROSS_TARGETARCHS: "${CROSS_TARGETARCHS}"
CROSS: "${CROSS}"
IMAGE_SUFFIX: "${IMAGE_SUFFIX}"
RUNTIME_IMAGE: "${RUNTIME_IMAGE}"
SLEEP: "${SLEEP}"
SWIFTLINT_REVISION: "${SWIFTLINT_REVISION}"
TARGET_IMAGE: "${TARGET_IMAGE}"
USE_SDK: "${USE_SDK}"
VERBOSE: "${VERBOSE}"
EOT

# Check out SwiftLint revision
ARG SWIFTLINT_REVISION
ADD --link https://github.com/realm/SwiftLint.git#${SWIFTLINT_REVISION} /SwiftLint
WORKDIR /SwiftLint
# Quick fix to avoid link error
ARG FIX_SWIFTPM_7695
RUN [ -z "$FIX_SWIFTPM_7695" ] || sed -i 's/^swiftLintPluginDependencies = .*$/swiftLintPluginDependencies = []/' Package.swift
# Resolve dependencies
ARG _BUILD_CACHE_ID
ENV _BUILD_CACHE_ID=${_BUILD_CACHE_ID} BUILD_DIR=/SwiftLint/.build DOT_CACHE=/root/.cache
RUN --mount=type=cache,target=${DOT_CACHE},sharing=locked,id=${_BUILD_CACHE_ID} \
    --mount=type=cache,target=${BUILD_DIR},sharing=locked,id=${_BUILD_CACHE_ID} \
    swift package resolve --configuration release
# Set environment variables for later stages
ARG _SDK_NAME _TARGET_NAME _TARGET_TRIPLE_ARCH SLEEP VERBOSE
ENV _SDK_NAME=${_SDK_NAME} _TARGET_NAME=${_TARGET_NAME} _TARGET_TRIPLE_ARCH=${_TARGET_TRIPLE_ARCH} SLEEP=${SLEEP} \
    SWIFT_FLAGS="${VERBOSE:+--verbose} --configuration release --skip-update --static-swift-stdlib --product swiftlint " \
    SWIFT_FLAGS_FOR_DEBUG=${SLEEP:+"-Xswiftc -save-temps"} \
    VERBOSE=${VERBOSE}

####################################################################################################
# Prepare Swift SDK
####################################################################################################
FROM base-preparer AS swift-sdk-preparer
ENV BUNDLE_PATH=/root/.swiftpm/swift-sdks/${_TARGET_NAME}.artifactbundle
ADD --link swift-sdks.artifactbundle ${BUNDLE_PATH}
ENV SWIFT_FLAGS="${SWIFT_FLAGS} --swift-sdk ${_SDK_NAME}"
# Prepare verbose option for Swift SDK
RUN rm -f /etc/apt/apt.conf.d/docker-clean; echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/keep-cache
ARG _BUILDER_TRIPLE_ARCH
ARG APT_CACHE_ID=apt-${_TARGET_NAME}-${_BUILDER_TRIPLE_ARCH}
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked,id=${APT_CACHE_ID} \
    --mount=type=cache,target=/var/lib/apt,sharing=locked,id=${APT_CACHE_ID} \
    [ -n "${VERBOSE}" ] && \
    apt-get update && apt-get install -y \
    jq && \
    for toolset in ${BUNDLE_PATH}/*/toolset.json; do \
        jq 'walk(if type == "object" and has("extraCLIOptions") then .extraCLIOptions += ["-v"] else . end)' $toolset | (sleep 1 && tee $toolset) \
    done || true

####################################################################################################
# Building SwiftLint by using cross-arch Swift SDK
####################################################################################################
FROM swift-sdk-preparer AS cross-arch-sdk-builder
RUN --mount=type=cache,target=${DOT_CACHE},sharing=locked,id=${_BUILD_CACHE_ID} \
    --mount=type=cache,target=${BUILD_DIR},sharing=locked,id=${_BUILD_CACHE_ID} \
    --mount=type=bind,target=${BUNDLE_PATH}/aarch64,from=swift-aarch64 \
    --mount=type=bind,target=${BUNDLE_PATH}/x86_64,from=swift-x86_64 \
    swift sdk list|grep "${_SDK_NAME}" && \
    swift build ${SWIFT_FLAGS} ${SWIFT_FLAGS_FOR_DEBUG} || [ -n "${SLEEP}" ]

FROM swift-${_TARGET_TRIPLE_ARCH} AS runtime

####################################################################################################
# Building SwiftLint by using same-arch Swift SDK
####################################################################################################
FROM swift-sdk-preparer AS same-arch-sdk-builder
RUN --mount=type=cache,target=${DOT_CACHE},sharing=locked,id=${_BUILD_CACHE_ID} \
    --mount=type=cache,target=${BUILD_DIR},sharing=locked,id=${_BUILD_CACHE_ID} \
    --mount=type=bind,target=${BUNDLE_PATH}/${_TARGET_TRIPLE_ARCH},from=runtime \
    swift sdk list|grep "${_SDK_NAME}" && \
    swift build ${SWIFT_FLAGS} ${SWIFT_FLAGS_FOR_DEBUG} || [ -n "${SLEEP}" ]

####################################################################################################
# Building SwiftLint
####################################################################################################
FROM base-preparer AS no-sdk-builder
RUN --mount=type=cache,target=${DOT_CACHE},sharing=locked,id=${_BUILD_CACHE_ID} \
    --mount=type=cache,target=${BUILD_DIR},sharing=locked,id=${_BUILD_CACHE_ID} \
    swift build ${SWIFT_FLAGS} ${SWIFT_FLAGS_FOR_DEBUG} || [ -n "${SLEEP}" ]

####################################################################################################
# Select Builder and Sleep after building SwiftLint
####################################################################################################
FROM ${_BUILDER_SELECTOR}-builder AS builder-selector-to-sleep
RUN rm -f /etc/apt/apt.conf.d/docker-clean; echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/keep-cache
ARG APT_CACHE_ID=apt-${_TARGET_NAME}-${_TARGET_TRIPLE_ARCH}
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked,id=${APT_CACHE_ID} \
    --mount=type=cache,target=/var/lib/apt,sharing=locked,id=${APT_CACHE_ID} \
    --mount=type=cache,target=${DOT_CACHE},sharing=locked,id=${_BUILD_CACHE_ID} \
    --mount=type=cache,target=${BUILD_DIR},sharing=locked,id=${_BUILD_CACHE_ID} \
    --mount=type=bind,target=${BUNDLE_PATH}/aarch64,from=swift-aarch64 \
    --mount=type=bind,target=${BUNDLE_PATH}/x86_64,from=swift-x86_64 \
    pidns=$(readlink /proc/self/ns/pid|sed -E 's/pid:\[([0-9]+)\]/\1/') && \
    cat <<EOT  && sleep 999999
Enter the following command to enter build session:
lima user:
    limactl shell docker bash -c 'sudo nsenter --all --target=\$(lsns|awk "/^$pidns/{print \\\$4}") bash'

Docker for Mac user:
    docker run -it --privileged --pid=host --rm ubuntu bash -c 'nsenter --all --target=\$(lsns|awk "/^$pidns/{print \\\$4}") bash'
EOT

####################################################################################################
# Select Builder
####################################################################################################
FROM ${_BUILDER_SELECTOR}-builder AS builder-selector

####################################################################################################
# Builder for Final Image
####################################################################################################
FROM builder-selector${_SLEEP_SELECTOR} AS builder
RUN --mount=type=cache,target=${DOT_CACHE},sharing=locked,id=${_BUILD_CACHE_ID} \
    --mount=type=cache,target=${BUILD_DIR},sharing=locked,id=${_BUILD_CACHE_ID} \
    install -v `swift build ${SWIFT_FLAGS} --show-bin-path`/swiftlint /usr/bin

####################################################################################################
# Final image
####################################################################################################
FROM --platform=linux/${_TARGET_TRIPLE_ARCH} ${RUNTIME_IMAGE} AS final
LABEL maintainer="Norio Nomura <norio.nomura@gmail.com>"
RUN rm -f /etc/apt/apt.conf.d/docker-clean; echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/keep-cache
ARG _RUNTIME_NAME _TARGET_TRIPLE_ARCH
ARG APT_CACHE_ID=apt-${_RUNTIME_NAME}-${_TARGET_TRIPLE_ARCH}
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked,id=${APT_CACHE_ID} \
    --mount=type=cache,target=/var/lib/apt,sharing=locked,id=${APT_CACHE_ID} \
    apt-get update && apt-get install -y \
    libcurl4 \
    libxml2
COPY --link --from=builder /usr/bin/swiftlint /usr/bin/
# Copy Swift runtime libraries if not exists
RUN --mount=type=bind,target=/runtime,from=runtime <<'EOT'
#!/bin/bash -eu
    sourcekit=/usr/lib/libsourcekitdInProc.so
    test -f "${sourcekit}" && exit # assume that the libraries exist
    dependencies_txt=$(realpath $(ldd "/runtime${sourcekit}" | awk '/=>/ && $3~/\/lib\/swift/{print $3}'))
    dependencies=()
    while read -r line; do dependencies+=("$line"); done <<< "${dependencies_txt}"
    for dependency in "${dependencies[@]}"; do
        dirname=$(dirname "${dependency}")
        test -d "${dirname#/runtime}" || mkdir -p "${dirname#/runtime}"
        cp -pv "${dependency}" "${dirname#/runtime}"
    done
    cp -pv /runtime$sourcekit $(dirname $sourcekit)
EOT
COPY --chmod=755 <<'EOT' /usr/local/bin/swiftlint
#!/bin/bash
swiftlint=/usr/bin/swiftlint
is_container() { [[ -f /.dockerenv ]]; }
is_docker() { [[ "$(</run/systemd/container)" == "docker" ]] &>/dev/null; }
is_qemu() {
    # Use awk instead of grep because grep may crashes with QEMU interpreter
    awk 'BEGIN{s=1}/qemu-(aarch64|x86_64)-static/{s=0}END{exit s}' /proc/1/maps &>/dev/null
}

if is_qemu; then
    is_container || is_docker && IGNORE_ERROR_ON_QEMU=${IGNORE_ERROR_ON_QEMU:-true}
    if [[ -n "$IGNORE_ERROR_ON_QEMU" ]]; then
        echo "Executing swiftlint with enabling timeout, because swiftlint may crashes or hangs when running with QEMU interpreter" >&2
        timeout --preserve-status --foreground --kill-after=310 300 $swiftlint "$@" || true
    else
        exec $swiftlint "$@"
    fi
else
    exec $swiftlint "$@"
fi
EOT
COPY --chmod=755 <<"EOT" /usr/local/bin/archive-swiftlint-runtime
#!/bin/bash -eux
tar czO -C / \
    usr/bin/swiftlint \
    usr/local/bin/swiftlint \
    usr/local/bin/archive-swiftlint-runtime
EOT

# Print Installed SwiftLint Version
RUN ["swiftlint", "version"]
RUN echo "_ = 0" | exec swiftlint --use-stdin
CMD ["swiftlint", "lint"]
