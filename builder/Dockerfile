# syntax=docker/dockerfile:1
ARG BUILDER_IMAGE=swift:jammy
ARG RUNTIME_IMAGE=swift:jammy
FROM ${BUILDER_IMAGE} AS builder

RUN rm -f /etc/apt/apt.conf.d/docker-clean; echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/keep-cache
ARG BUILDER_IMAGE
ARG TARGETPLATFORM
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked,id=${BUILDER_IMAGE}-${TARGETPLATFORM} \
    --mount=type=cache,target=/var/lib/apt,sharing=locked,id=${BUILDER_IMAGE}-${TARGETPLATFORM} \
    apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    libxml2-dev

# Install SwiftLint
ARG SWIFTLINT_REVISION=0.54.0
ADD https://github.com/realm/SwiftLint.git#${SWIFTLINT_REVISION} /SwiftLint
WORKDIR /SwiftLint
RUN --mount=type=cache,target=/root/.cache --mount=type=cache,target=/SwiftLint/.build \
    swift package resolve --configuration release
RUN --mount=type=cache,target=/root/.cache --mount=type=cache,target=/SwiftLint/.build \
    <<EOT
#!/bin/bash -eux
    SWIFT_FLAGS="--configuration release --skip-update --static-swift-stdlib"
    swift build ${SWIFT_FLAGS} --product swiftlint
    install -v `swift build ${SWIFT_FLAGS} --show-bin-path`/swiftlint /usr/bin
EOT

# runtime image
FROM ${RUNTIME_IMAGE}
LABEL maintainer "Norio Nomura <norio.nomura@gmail.com>"
RUN rm -f /etc/apt/apt.conf.d/docker-clean; echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/keep-cache
ARG RUNTIME_IMAGE
ARG TARGETPLATFORM
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked,id=${RUNTIME_IMAGE}-${TARGETPLATFORM} \
    --mount=type=cache,target=/var/lib/apt,sharing=locked,id=${RUNTIME_IMAGE}-${TARGETPLATFORM} \
    apt-get update && apt-get install -y \
    libcurl4 \
    libxml2
COPY --from=builder /usr/bin/swiftlint /usr/bin
RUN --mount=type=bind,target=/builder,from=builder \
    <<EOT
#!/bin/bash -eux
    # Copy Swift runtime libraries if not exists
    test -f /usr/lib/libsourcekitdInProc.so || cp -pv /builder/usr/lib/libsourcekitdInProc.so /usr/lib/
    test -d /usr/lib/swift/host || mkdir -p /usr/lib/swift/host && cp -pRv /builder/usr/lib/swift/host/libSwift*.so /usr/lib/swift/host/
    test -d /usr/lib/swift/linux || mkdir -p /usr/lib/swift/linux && cp -pRv /builder/usr/lib/swift/linux/*.so /usr/lib/swift/linux/
EOT
COPY <<"EOT" /usr/local/bin/archive-swiftlint-runtime
#!/bin/bash -eux
tar czO \
    /usr/bin/swiftlint \
    /usr/lib/{libBlocksRuntime,libdispatch,libsourcekitdInProc,libswiftCore}.so \
    /usr/local/bin/archive-swiftlint-runtime
EOT
RUN chmod +x /usr/local/bin/archive-swiftlint-runtime

# Print Installed SwiftLint Version
RUN swiftlint version
RUN echo "_ = 0" | swiftlint --use-stdin
CMD ["swiftlint", "lint"]
