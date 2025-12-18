# Snort 3 Docker Build Documentation

## Purpose

Documentation for building Snort 3 in Docker for IBR (Internet Background Radiation) analysis.

**Author:** Kim André V. Heggelund  
**Institution:** Noroff University College  
**Project:** Evaluation of Snort as a Mechanism to Categorize Internet Background Radiation  
**Date:** 2025/26

---

## Versions

| Component | Version | Source |
|-----------|---------|--------|
| Snort | 3.10.0.0 | https://www.snort.org/downloads |
| LibDAQ | 3.0.23 | https://github.com/snort3/libdaq |
| Base Image | Ubuntu 22.04 | Official Docker Hub |
| Rules | snortrules-snapshot-31470 | https://www.snort.org/downloads |

---

## Build Dependencies

From Snort 3 GitHub README (https://github.com/snort3/snort3):
```bash
apt-get install -y \
    cmake build-essential \
    libdumbnet-dev flex libhwloc-dev \
    libluajit-5.1-dev libssl-dev libpcap-dev \
    libpcre2-dev pkg-config zlib1g-dev liblzma-dev \
    autoconf automake libtool wget ca-certificates
```

## Runtime Dependencies
```bash
apt-get install -y --no-install-recommends \
    libpcap0.8 libpcre2-8-0 libdumbnet1 libhwloc15 \
    libluajit-5.1-2 libssl3 zlib1g libnuma1 jq
```

---

## Build Process

### LibDAQ
```bash
wget https://github.com/snort3/libdaq/archive/refs/tags/v3.0.23.tar.gz
tar -xzf v3.0.23.tar.gz && cd libdaq-3.0.23
./bootstrap && ./configure && make && make install
```

### Snort 3
```bash
wget https://github.com/snort3/snort3/archive/refs/tags/3.10.0.0.tar.gz
tar -xzf 3.10.0.0.tar.gz && cd snort3-3.10.0.0
./configure_cmake.sh --prefix=/usr/local
cd build && make && make install
```

---

## Installation Paths

| Path | Contents |
|------|----------|
| `/usr/local/bin/snort` | Executable |
| `/usr/local/lib/snort/` | Plugins |
| `/usr/local/etc/snort/` | Default config |
| `/usr/local/lib/daq/` | DAQ modules |

---

## Alert Output

Using `alert_json` with custom fields for IBR analysis:
```lua
alert_json = { fields = 'sid msg class dst_port proto' }
```

Output piped through `jq` to TSV for processing of large datasets.

---

## References

1. **Snort 3 GitHub:** https://github.com/snort3/snort3
2. **Snort Installation Guide:** https://docs.snort.org/start/installation
3. **LibDAQ GitHub:** https://github.com/snort3/libdaq
4. **Alert Logging:** https://docs.snort.org/start/alert_logging
5. **Snort Downloads:** https://www.snort.org/downloads

---
