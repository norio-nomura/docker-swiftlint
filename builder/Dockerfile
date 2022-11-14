# syntax=docker/dockerfile:1
ARG BUILDER_IMAGE=swift:focal
ARG RUNTIME_IMAGE=swift:focal
FROM ${BUILDER_IMAGE} AS builder

RUN --mount=type=cache,target=/var/cache/apt --mount=type=cache,sharing=locked,target=/var/lib/apt \
    apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    libxml2-dev

# Install SwiftLint
RUN git clone https://github.com/realm/SwiftLint.git
WORKDIR /SwiftLint
ARG SWIFTLINT_REVISION=0.49.0
RUN git checkout ${SWIFTLINT_REVISION}
RUN --mount=type=cache,target=/root/.cache --mount=type=cache,target=/SwiftLint/.build \
    <<EOT
#!/bin/bash -eux
    ln -s /usr/lib/swift/_InternalSwiftSyntaxParser .
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
COPY --from=builder /usr/lib/swift/linux/lib_InternalSwiftSyntaxParser.so /usr/lib
COPY --from=builder /usr/lib/swift/linux/libBlocksRuntime.so /usr/lib
COPY --from=builder /usr/lib/swift/linux/libdispatch.so /usr/lib

# Print Installed SwiftLint Version
RUN swiftlint version
RUN echo "_ = 0" | swiftlint --use-stdin
CMD ["swiftlint", "lint"]
