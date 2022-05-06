FROM ubuntu:20.04 as builder

## Install build dependencies.
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y cmake clang curl
RUN curl --proto "=https" --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
RUN ${HOME}/.cargo/bin/rustup default nightly
RUN ${HOME}/.cargo/bin/cargo install -f cargo-fuzz

ADD . /repo
WORKDIR /repo

## TODO: ADD YOUR BUILD INSTRUCTIONS HERE.
# RUN ${HOME}/.cargo/bin/cargo build --all
RUN cd fuzz && ${HOME}/.cargo/bin/cargo fuzz build

# Package Stage
FROM ubuntu:20.04


## TODO: Change <Path in Builder Stage>
COPY --from=builder repo/fuzz/target/x86_64-unknown-linux-gnu/release/decode_random /
COPY --from=builder repo/fuzz/target/x86_64-unknown-linux-gnu/release/roundtrip_no_pad /
COPY --from=builder repo/fuzz/target/x86_64-unknown-linux-gnu/release/roundtrip_random_config /
COPY --from=builder repo/fuzz/target/x86_64-unknown-linux-gnu/release/roundtrip /