ARG BUILDER_IMAGE=swift
ARG RUNTIME_IMAGE=swift
FROM ${BUILDER_IMAGE} AS builder

RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    libxml2-dev && \
    rm -r /var/lib/apt/lists/*

# Install SwiftLint
ARG SWIFTLINT_REVISION=master
RUN git clone --branch ${SWIFTLINT_REVISION} https://github.com/realm/SwiftLint.git && \
    cd SwiftLint && \
    swift build --configuration release -Xswiftc -static-stdlib -Xlinker -lCFURLSessionInterface -Xlinker -lCFXMLInterface -Xlinker -lcurl -Xlinker -lxml2 && \
    mv `swift build --configuration release -Xswiftc -static-stdlib --show-bin-path`/swiftlint /usr/bin && \
    cd .. && \
    rm -rf SwiftLint

# runtime image
FROM ${RUNTIME_IMAGE}
LABEL maintainer "Norio Nomura <norio.nomura@gmail.com>"
COPY --from=builder /usr/bin/swiftlint /usr/bin

# Print Installed SwiftLint Version
RUN swiftlint version
CMD ["swiftlint", "lint"]
