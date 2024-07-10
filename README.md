# docker-swiftlint

*In this document, using **amd64, arm64** for platform architecture for docker, and **x86_64, aarch64** for Swift architecture.*

## `builder` directory
### Build without Swift SDK (no-sdk)

#### Build image for docker host architecture
```bash
docker buildx build --load builder/ -t swiftlint
```

#### Build multi-architecture image (x86_64-no-sdk, aarch64-no-sdk)
```bash
docker buildx build --load builder/ -t swiftlint \
    --platform linux/amd64,linux/arm64
```

### Cross compilation on `BUILDER_IAMGE` using `TARGET_IMAGE` as Swift SDK
Setup `TARGET_IMAGE` as the Swift SDK for the target architecture, and use them from Swift Toolchain in `BUILDER_IMAGE`.

Supported combinations of `TARGET_IMAGE` and `BUILDER_IMAGE` are as follows:
|                | aarch64 builder    | x86_64 builder    |
|----------------|--------------------|-------------------|
| aarch64 target | aarch64-on-aarch64 | aarch64-on-x86_64 |
| x86_64 target  | x86_64-on-aarch64  | x86_64-on-x86_64  |


#### Using `--build-arg USE_SDK=1` for building with Swift SDK
Build arm64 architecture image using Swift SDK (aarch64-on-aarch64)
```bash
docker buildx build --load builder/ -t swiftlint \
    --platform linux/arm64 --build-arg USE_SDK=1
```

#### Using `--build-arg CROSS=1` for cross compilation with Swift SDK
Build arm64 architecture image on amd64 architecture using Swift SDK (aarch64-on-x86_64)
```bash
docker buildx build --load builder/ -t swiftlint \
    --platform linux/arm64 --build-arg CROSS=1
```

#### Using `--build-arg CROSS_TARGETARCHS=...` for cross compiling target architectures with Swift SDK
Build multi-architecture image, native compileed arm64 (aarch64-no-sdk), cross compiled amd64 (x86_64-on-aarch64).  
```bash
docker buildx build --load builder/ -t swiftlint \
    --platform linux/amd64,linux/arm64 --build-arg CROSS_TARGETARCHS=amd64
```
This command minimizes the use of emulation on arm64 host.


## `copier` directory
Expected to use `swiftlint` binary built in `builder` directory.

## Running aarch64 executable generated with Swift on x86_64 Ubuntu (GitHub Hosted Actions Runner) using `qemu-user-static`
There is a known issue where running an aarch64 executable generated with Swift on x86_64 Ubuntu using the default `qemu-user-static` results in a crash.
https://forums.swift.org/t/swift-runtime-unable-to-suspend-thread-when-compiling-in-qemu/67676

This issue can be avoided by using qemu-user-static-7.2 distributed by Debian.  
There are two methods to install it:
- For rootful docker, run `docker run --rm --privileged multiarch/qemu-user-static:7.2.0-1 --reset -p yes`.  
    This method can be used as long as the docker installed on the GitHub Actions Runner is rootful.
- Setup debian sources to apt on host and install it. See [install_qemu_user_static_from_debian](.github/actions/install_qemu_user_static_from_debian/action.yml) as an example.

## Author

Norio Nomura

## License

available under the MIT license. See the LICENSE file for more info.
