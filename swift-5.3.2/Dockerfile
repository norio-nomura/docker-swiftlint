ARG IMAGE=swift:5.3.2
FROM ${IMAGE} AS builder
LABEL maintainer "Norio Nomura <norio.nomura@gmail.com>"

RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    libxml2-dev && \
    rm -r /var/lib/apt/lists/*

ENV SWIFTLINT_REVISION="master"

# Install SwiftLint
RUN git clone --branch $SWIFTLINT_REVISION https://github.com/realm/SwiftLint.git && \
    cd SwiftLint && \
    swift build --configuration release -Xswiftc -static-stdlib && \
    mv `swift build --configuration release -Xswiftc -static-stdlib --show-bin-path`/swiftlint /usr/bin && \
    cd .. && \
    rm -rf SwiftLint

# runtime image
FROM ${IMAGE}
COPY --from=builder /usr/bin/swiftlint /usr/bin

# Print Installed SwiftLint Version
RUN swiftlint version
CMD ["swiftlint", "lint"]
