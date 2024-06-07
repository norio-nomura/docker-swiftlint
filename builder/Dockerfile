# syntax=docker/dockerfile:1

ARG BUILDER_IMAGE=swiftlang/swift:nightly
ARG TARGET_IMAGE=swift:5.10
ARG RUNTIME_IMAGE=${TARGET_IMAGE}
ARG SWIFTLINT_REVISION=0.55.0

####################################################################################################
# --build-arg TARGET_TRIPLE_ARCH
# default: decided by the TARGETARCH
# supports: amd64, x86_64, arm64, aarch64
####################################################################################################
ARG TARGET_TRIPLE_ARCH=${TARGETARCH}
ARG TARGET_TRIPLE_ARCH=${TARGET_TRIPLE_ARCH/*arm64/aarch64}
ARG TARGET_TRIPLE_ARCH=${TARGET_TRIPLE_ARCH/*amd64/x86_64}
ARG TARGET_TRIPLE_ARCH=${TARGET_TRIPLE_ARCH/linux*/}
# input check requires `syntax=docker/dockerfile-upstream:master`
# ARG TARGET_TRIPLE_ARCH=${TARGET_TRIPLE_ARCH:?"Unsupported ARCH detected: $TARGETARCH"}

####################################################################################################
# --build-arg CROSS_TARGETARCHS
# default: not set
# supports: amd64, x86_64, arm64, aarch64
####################################################################################################
ARG CROSS_TARGETARCHS

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
ARG _PARSE_CROSS_TARGETARCHS=${_PARSE_CROSS_TARGETARCHS//${TARGET_TRIPLE_ARCH}/cross}
ARG _CROSS_TRIPLE_ARCH_VARIANT=${TARGET_TRIPLE_ARCH}
ARG _CROSS_TRIPLE_ARCH_VARIANT=${_CROSS_TRIPLE_ARCH_VARIANT/aarch64/arm64}
ARG _CROSS_TRIPLE_ARCH_VARIANT=${_CROSS_TRIPLE_ARCH_VARIANT/x86_64/amd64}
ARG _PARSE_CROSS_TARGETARCHS=${_PARSE_CROSS_TARGETARCHS//${_CROSS_TRIPLE_ARCH_VARIANT}/cross}
ARG _PARSE_CROSS_TARGETARCHS=${_PARSE_CROSS_TARGETARCHS//arm64/}
ARG _PARSE_CROSS_TARGETARCHS=${_PARSE_CROSS_TARGETARCHS//amd64/}
ARG _PARSE_CROSS_TARGETARCHS=${_PARSE_CROSS_TARGETARCHS//aarch64/}
ARG _PARSE_CROSS_TARGETARCHS=${_PARSE_CROSS_TARGETARCHS//x86_64/}
ARG _PARSE_CROSS_TARGETARCHS=${_PARSE_CROSS_TARGETARCHS//,/}
ARG _RESULT_PARSING_CROSS_TARGETARCHS=${_PARSE_CROSS_TARGETARCHS:+cross}

####################################################################################################
# --build-arg CROSS
# If set, build target will be cross-compiled.
# default: decided by the CROSS_TARGETARCHS
####################################################################################################
ARG CROSS=${_RESULT_PARSING_CROSS_TARGETARCHS}
# if `CROSS` is set then `_CROSS_OR_NATIVE` will be "cross", otherwise the variable is the empty string.
ARG _CROSS_OR_NATIVE=${CROSS:+cross}
# if `_CROSS_OR_NATIVE` is set then the variable will be that value. 
# If the variable is not set then the variable will be the "native".
ARG _CROSS_OR_NATIVE=${_CROSS_OR_NATIVE:-native}

####################################################################################################
# --build-arg HOST_TRIPLE_ARCH
# default: decided by the CROSS and TARGETARCH
# supports: amd64, x86_64, arm64, aarch64
####################################################################################################
ARG HOST_TRIPLE_ARCH=${TARGET_TRIPLE_ARCH}${_CROSS_OR_NATIVE}
ARG HOST_TRIPLE_ARCH=${HOST_TRIPLE_ARCH/aarch64cross/x86_64}
ARG HOST_TRIPLE_ARCH=${HOST_TRIPLE_ARCH/aarch64native/aarch64}
ARG HOST_TRIPLE_ARCH=${HOST_TRIPLE_ARCH/x86_64cross/aarch64}
ARG HOST_TRIPLE_ARCH=${HOST_TRIPLE_ARCH/x86_64native/x86_64}

ARG RUNTIME_NAME=${RUNTIME_IMAGE/:/-}
ARG SDK_NAME=${TARGET_TRIPLE_ARCH}-on-${HOST_TRIPLE_ARCH}
ARG TARGET_NAME=${TARGET_IMAGE/:/-}

####################################################################################################
# --build-arg SLEEP
# If set, debugging enabled.
####################################################################################################
ARG SLEEP

ARG _SLEEP_SELECTOR=${SLEEP:+-sleep}

####################################################################################################
# --build-arg DISABLE_BUILD_DIR_CACHE
# If set, disable caching on /SwiftLint/.build directory.
####################################################################################################
ARG DISABLE_BUILD_DIR_CACHE

ARG _BUILD_DIR=${DISABLE_BUILD_DIR_CACHE:+/SwiftLint/.build-disabled}
ARG _BUILD_DIR=${DISABLE_BUILD_DIR_CACHE:-/SwiftLint/.build}

# ARG SWIFT_FLAGS_FOR_DEBUG=${SLEEP:+"-Xswiftc -save-temps"}

####################################################################################################
# Stages for Swift SDKs
####################################################################################################
FROM --platform=linux/arm64 ${TARGET_IMAGE} AS swift-aarch64
RUN rm -f /etc/apt/apt.conf.d/docker-clean; echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/keep-cache
ARG TARGET_NAME
ARG CACHE_ID=${TARGET_NAME}-linux/arm64
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked,id=${CACHE_ID} \
    --mount=type=cache,target=/var/lib/apt,sharing=locked,id=${CACHE_ID} \
    apt-get update && apt-get install -y \
    binutils-aarch64-linux-gnu \
    binutils-x86-64-linux-gnu \
    libcurl4-openssl-dev \
    libxml2-dev
# change the symbolic link from absolute path to relative path for aarch64-linux-gnu-ld.gold
RUN target_lib=/usr/lib/aarch64-linux-gnu/libm.so && \
    test -L $target_lib && ln -sf $(realpath --relative-to=$(dirname $target_lib) $target_lib) $target_lib
COPY <<EOT /SDKSettings.json
{
  "DisplayName": "Swift SDK for Linux (aarch64)",
  "Version": "0.0.1",
  "VersionMap": {},
  "CanonicalName": "aarch64-swift-linux-gnu"
}
EOT

FROM --platform=linux/amd64 ${TARGET_IMAGE} AS swift-x86_64
RUN rm -f /etc/apt/apt.conf.d/docker-clean; echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/keep-cache
ARG TARGET_NAME
ARG CACHE_ID=${TARGET_NAME}-linux/amd64
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked,id=${CACHE_ID} \
    --mount=type=cache,target=/var/lib/apt,sharing=locked,id=${CACHE_ID} \
    apt-get update && apt-get install -y \
    binutils-aarch64-linux-gnu \
    binutils-x86-64-linux-gnu \
    libcurl4-openssl-dev \
    libxml2-dev
# change the symbolic link from absolute path to relative path for x86_64-linux-gnu-ld.gold
RUN target_lib=/usr/lib64/ld-linux-x86-64.so.2 && \
    test -L $target_lib && ln -sf $(realpath --relative-to=$(dirname $target_lib) $target_lib) $target_lib
COPY <<EOT /SDKSettings.json
{
  "DisplayName": "Swift SDK for Linux (x86_64)",
  "Version": "0.0.1",
  "VersionMap": {},
  "CanonicalName": "x86_64-swift-linux-gnu"
}
EOT

####################################################################################################
# Stages for native building
####################################################################################################
# Builder uses other architectures to build SwiftLint
FROM --platform=linux/arm64 ${BUILDER_IMAGE} AS aarch64-on-aarch64-base

FROM --platform=linux/amd64 ${BUILDER_IMAGE} AS x86_64-on-x86_64-base
RUN target_lib=/usr/lib64/ld-linux-x86-64.so.2 && \
    test -L $target_lib && ln -sf $(realpath --relative-to=$(dirname $target_lib) $target_lib) $target_lib

####################################################################################################
# Stages for cross building
####################################################################################################
# Builder uses other architectures to build SwiftLint
FROM --platform=linux/amd64 ${BUILDER_IMAGE} AS aarch64-on-x86_64-base

FROM --platform=linux/arm64 ${BUILDER_IMAGE} AS x86_64-on-aarch64-base

####################################################################################################
# Stages for building SwiftLint
####################################################################################################
# prepare for building SwiftLint
FROM ${SDK_NAME}-base AS prepare-building
ARG SDK_NAME
ENV SDK_NAME=${SDK_NAME}
# Check SwiftLint revision
ARG SWIFTLINT_REVISION
ADD https://github.com/realm/SwiftLint.git#${SWIFTLINT_REVISION} /SwiftLint
WORKDIR /SwiftLint
# Resolve dependencies
ARG _BUILD_DIR
ENV BUILD_DIR=${_BUILD_DIR} DOT_CACHE=/root/.cache
# Quick fix to resolve link error
RUN sed -i 's/^swiftLintPluginDependencies = .*$/swiftLintPluginDependencies = []/' Package.swift
RUN --mount=type=cache,target=${DOT_CACHE},sharing=locked,id=${SDK_NAME} \
    --mount=type=cache,target=${BUILD_DIR},sharing=locked,id=${SDK_NAME} \
    swift package resolve --configuration release
ENV SWIFT_FLAGS="--configuration release --skip-update --static-swift-stdlib --product swiftlint"

FROM prepare-building AS prepare-sdk
# Setup Swift SDK
ARG TARGET_NAME
ENV BUNDLE_PATH=/root/.swiftpm/swift-sdks/${TARGET_NAME}.artifactbundle
ADD swift-sdks.artifactbundle ${BUNDLE_PATH}
ENV SWIFT_FLAGS="${SWIFT_FLAGS} --swift-sdk ${SDK_NAME}"
ARG SLEEP
ENV SLEEP=${SLEEP}

# cross building SwiftLint
FROM prepare-sdk AS cross-builder
RUN --mount=type=cache,target=${DOT_CACHE},sharing=locked,id=${SDK_NAME} \
    --mount=type=cache,target=${BUILD_DIR},sharing=locked,id=${SDK_NAME} \
    --mount=type=bind,target=${BUNDLE_PATH}/aarch64,from=swift-aarch64 \
    --mount=type=bind,target=${BUNDLE_PATH}/x86_64,from=swift-x86_64 \
    swift sdk list|grep "${SDK_NAME}" && \
    swift build ${SWIFT_FLAGS} ${SWIFT_FLAGS_FOR_DEBUG} || [ -n "${SLEEP}" ]

FROM swift-${TARGET_TRIPLE_ARCH} AS runtime

# native building SwiftLint
FROM prepare-sdk AS native-builder
ARG TARGET_TRIPLE_ARCH
RUN --mount=type=cache,target=${DOT_CACHE},sharing=locked,id=${SDK_NAME} \
    --mount=type=cache,target=${BUILD_DIR},sharing=locked,id=${SDK_NAME} \
    --mount=type=bind,target=${BUNDLE_PATH}/${TARGET_TRIPLE_ARCH},from=runtime \
    swift sdk list|grep "${SDK_NAME}" && \
    swift build ${SWIFT_FLAGS} ${SWIFT_FLAGS_FOR_DEBUG} || [ -n "${SLEEP}" ]

FROM ${_CROSS_OR_NATIVE}-builder AS post-build

FROM ${_CROSS_OR_NATIVE}-builder AS post-build-sleep
ARG RUNTIME_NAME TARGETPLATFORM
ARG CACHE_ID=${RUNTIME_NAME}-${TARGETPLATFORM}
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked,id=${CACHE_ID} \
    --mount=type=cache,target=/var/lib/apt,sharing=locked,id=${CACHE_ID} \
    --mount=type=cache,target=${DOT_CACHE},sharing=locked,id=${SDK_NAME} \
    --mount=type=cache,target=${BUILD_DIR},sharing=locked,id=${SDK_NAME} \
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

FROM post-build${_SLEEP_SELECTOR} AS builder
RUN --mount=type=cache,target=${DOT_CACHE},sharing=locked,id=${SDK_NAME} \
    --mount=type=cache,target=${BUILD_DIR},sharing=locked,id=${SDK_NAME} \
    install -v `swift build ${SWIFT_FLAGS} --show-bin-path`/swiftlint /usr/bin

####################################################################################################
# Stages for final image
####################################################################################################

FROM --platform=linux/${TARGET_TRIPLE_ARCH} ${RUNTIME_IMAGE} AS final
LABEL maintainer="Norio Nomura <norio.nomura@gmail.com>"
RUN rm -f /etc/apt/apt.conf.d/docker-clean; echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/keep-cache
ARG RUNTIME_NAME TARGETPLATFORM
ARG CACHE_ID=${RUNTIME_NAME}-${TARGETPLATFORM}
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked,id=${CACHE_ID} \
    --mount=type=cache,target=/var/lib/apt,sharing=locked,id=${CACHE_ID} \
    apt-get update && apt-get install -y \
    libcurl4 \
    libxml2
COPY --from=builder /usr/bin/swiftlint /usr/bin
# Copy Swift runtime libraries if not exists
RUN --mount=type=bind,target=/runtime,from=runtime \
    sourcekit=/usr/lib/libsourcekitdInProc.so && \
        test -f $sourcekit || cp -pv /runtime$sourcekit $(dirname $sourcekit) && \
    swift_host=/usr/lib/swift/host && \
        test -d $swift_host || ( mkdir -p $swift_host && cp -pRv /runtime$swift_host/libSwift*.so $swift_host/ ) && \
    swift_linux=/usr/lib/swift/linux && \
        test -d $swift_linux || ( mkdir -p $swift_linux && cp -pRv /runtime$swift_linux/*.so $swift_linux/ )
COPY --chmod=755 <<"EOT" /usr/local/bin/archive-swiftlint-runtime
#!/bin/bash -eux
tar czO \
    /usr/bin/swiftlint \
    /usr/local/bin/archive-swiftlint-runtime
EOT

RUN cat /proc/1/maps
RUN for s in /proc/1/task/*/status; do cat $s ;done
# Print Installed SwiftLint Version
RUN ["swiftlint", "version"]
RUN echo "_ = 0" | exec swiftlint --use-stdin
CMD ["swiftlint", "lint"]
