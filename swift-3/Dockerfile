FROM norionomura/sourcekit:311
LABEL maintainer "Norio Nomura <norio.nomura@gmail.com>"

ENV SWIFTLINT_REVISION="0.23.1"

# Install SwiftLint
RUN git clone --branch $SWIFTLINT_REVISION https://github.com/realm/SwiftLint.git && \
    cd SwiftLint && \
    swift build --configuration release && \
    mv .build/release/swiftlint /usr/bin && \
    mv .build/release/*.so /usr/lib/swift/linux/x86_64/ && \
    cd .. && \
    rm -rf SwiftLint

# Print Installed SwiftLint Version
RUN swiftlint version
CMD ["swiftlint", "lint"]
