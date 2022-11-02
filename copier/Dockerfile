# runtime image
ARG RUNTIME_IMAGE=swift:focal
FROM ${RUNTIME_IMAGE}
LABEL maintainer "Norio Nomura <norio.nomura@gmail.com>"
COPY swiftlint /usr/bin
RUN chmod +x /usr/bin/swiftlint

# Print Installed SwiftLint Version
RUN swiftlint version
CMD ["swiftlint", "lint"]
