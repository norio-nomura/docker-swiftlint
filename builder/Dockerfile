# syntax=docker/dockerfile:1
ARG BUILDER_IMAGE=swift:jammy
ARG RUNTIME_IMAGE=swift:jammy
FROM ${BUILDER_IMAGE} AS builder

RUN --mount=type=cache,target=/var/cache/apt --mount=type=cache,sharing=locked,target=/var/lib/apt \
    apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    libxml2-dev

# Install SwiftLint
ARG SWIFTLINT_REVISION=0.54.0
ADD https://github.com/realm/SwiftLint.git#${SWIFTLINT_REVISION} /SwiftLint
WORKDIR /SwiftLint
RUN --mount=type=cache,target=/root/.cache --mount=type=cache,target=/SwiftLint/.build \
    <<EOT
#!/bin/bash -eux
    SWIFT_FLAGS="$(
        echo --configuration release \
        '-Xswiftc -'{static-stdlib,I.} \
        '-Xlinker -'{l{CFURLSessionInterface,CFXMLInterface,curl,xml2},fuse-ld=lld,L/usr/lib/swift/linux}
    )"
    swift build ${SWIFT_FLAGS} --product swiftlint
    install -v `swift build ${SWIFT_FLAGS} --show-bin-path`/swiftlint /usr/bin
EOT

# runtime image
FROM ${RUNTIME_IMAGE}
LABEL maintainer "Norio Nomura <norio.nomura@gmail.com>"
RUN --mount=type=cache,target=/var/cache/apt --mount=type=cache,sharing=locked,target=/var/lib/apt \
    apt-get update && apt-get install -y \
    libcurl4 \
    libxml2
COPY --from=builder /usr/bin/swiftlint /usr/bin
COPY --from=builder /usr/lib/libsourcekitdInProc.so /usr/lib
COPY --from=builder /usr/lib/swift/linux/libBlocksRuntime.so /usr/lib
COPY --from=builder /usr/lib/swift/linux/libdispatch.so /usr/lib
COPY --from=builder /usr/lib/swift/linux/libswiftCore.so /usr/lib
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
