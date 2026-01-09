# Snort 3 Dockerfile

FROM ubuntu:22.04 AS builder

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Pin versions for reproducibility
ENV SNORT_VERSION=3.10.0.0
ENV LIBDAQ_VERSION=3.0.23

# Install Build Dependencies
RUN apt-get update && apt-get install -y \
    # Required by Snort (from GitHub README)
    cmake \
    build-essential \
    libdumbnet-dev \
    flex \
    libhwloc-dev \
    libluajit-5.1-dev \
    libssl-dev \
    libpcap-dev \
    libpcre2-dev \
    pkg-config \
    zlib1g-dev \
    liblzma-dev \ 
    autoconf \
    automake \
    libtool \
    wget \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build

# Build Libdaq
RUN wget -qO libdaq.tar.gz "https://github.com/snort3/libdaq/archive/refs/tags/v${LIBDAQ_VERSION}.tar.gz" \
    && tar -xzf libdaq.tar.gz \
    && cd libdaq-${LIBDAQ_VERSION} \
    && ./bootstrap \
    && ./configure \
    && make -j$(nproc) \
    && make install \
    && ldconfig

# Build Snort 3
RUN wget -qO snort3.tar.gz "https://github.com/snort3/snort3/archive/refs/tags/${SNORT_VERSION}.tar.gz" \
    && tar -xzf snort3.tar.gz \
    && cd snort3-${SNORT_VERSION} \
    && ./configure_cmake.sh --prefix=/usr/local \
    && cd build \
    && make -j$(nproc) \
    && make install

# Runtime Stage
FROM ubuntu:22.04 AS runtime

ENV DEBIAN_FRONTEND=noninteractive

# Runtime libraries (matching build dependencies)
RUN apt-get update && apt-get install -y --no-install-recommends \
    libpcap0.8 \
    libpcre2-8-0 \
    libdumbnet1 \
    libhwloc15 \
    libluajit-5.1-2 \
    libssl3 \
    zlib1g \
    libnuma1 \
    jq \
    && rm -rf /var/lib/apt/lists/*

# Copy Snort installation
COPY --from=builder /usr/local/bin/snort /usr/local/bin/
COPY --from=builder /usr/local/lib/snort /usr/local/lib/snort
COPY --from=builder /usr/local/lib/libdaq* /usr/local/lib/
COPY --from=builder /usr/local/lib/daq /usr/local/lib/daq
COPY --from=builder /usr/local/etc/snort /usr/local/etc/snort

RUN ldconfig

RUN mkdir -p /rules /pcaps /output
WORKDIR /work

RUN snort -V

CMD ["snort", "--help"]
