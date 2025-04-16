# syntax=docker/dockerfile:1

# runtime image
ARG TARGET_IMAGE=swift
ARG RUNTIME_IMAGE=${TARGET_IMAGE}

# Decide _TARGET_TRIPLE_ARCH from TARGETARCH
ARG _TARGET_TRIPLE_ARCH=${TARGETARCH}
ARG _TARGET_TRIPLE_ARCH=${_TARGET_TRIPLE_ARCH/*arm64/aarch64}
ARG _TARGET_TRIPLE_ARCH=${_TARGET_TRIPLE_ARCH/*amd64/x86_64}
ARG _TARGET_TRIPLE_ARCH=${_TARGET_TRIPLE_ARCH/linux*/}

FROM ${TARGET_IMAGE} AS runtime

FROM ${RUNTIME_IMAGE} AS final
LABEL maintainer="Norio Nomura <norio.nomura@gmail.com>"
RUN rm -f /etc/apt/apt.conf.d/docker-clean; echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/keep-cache
ARG RUNTIME_IMAGE _TARGET_TRIPLE_ARCH
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked,id=apt-${RUNTIME_IMAGE/:/-}-${_TARGET_TRIPLE_ARCH} \
    --mount=type=cache,target=/var/lib/apt,sharing=locked,id=apt-${RUNTIME_IMAGE/:/-}-${_TARGET_TRIPLE_ARCH} \
    apt-get update && apt-get install -y \
    libcurl4 \
    libxml2
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
ARG TARGETARCH
ADD swiftlint_linux_${TARGETARCH}.tar.gz /

# Print Installed SwiftLint Version
RUN ["swiftlint", "version"]
RUN echo "_ = 0" | exec swiftlint --use-stdin
CMD ["swiftlint", "lint"]
