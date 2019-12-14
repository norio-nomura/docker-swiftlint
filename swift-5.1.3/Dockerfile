FROM norionomura/swift:513
LABEL maintainer "Norio Nomura <norio.nomura@gmail.com>"

ENV SWIFTLINT_REVISION="master"

# Install SwiftLint
RUN git clone --branch $SWIFTLINT_REVISION https://github.com/realm/SwiftLint.git && \
    cd SwiftLint && \
    swift build --configuration release --static-swift-stdlib && \
    mv `swift build --configuration release --static-swift-stdlib --show-bin-path`/swiftlint /usr/bin && \
    cd .. && \
    rm -rf SwiftLint

# Print Installed SwiftLint Version
RUN swiftlint version
CMD ["swiftlint", "lint"]
