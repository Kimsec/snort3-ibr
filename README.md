
### Analyzing Internet Background Radiation (IBR) using Snort 3 IDS.

**Project:** Evaluation of Snort as a Mechanism to Categorize Internet Background Radiation  
**Author:** Kim André V. Heggelund  
**Institution:** Noroff University College  
**Period:** 2025/26



## Quick Start

> [!IMPORTANT]
> You need root user privileges to run all the commands described below.
```bash
# 1. Add rules tarball <snortrules-snapshot-31470.tar.gz> (requires free registration)
#    Download from: https://www.snort.org/downloads

# 2. Run setup
chmod +x setup.sh run_analysis.sh
./setup.sh

# 3. Add PCAP files to pcaps/

# 4. Run analysis
./run_analysis.sh
```
## Build Locally (Optional)

By default, the pre-built image from Docker Hub is used. To build locally instead, uncomment the `build` section in `compose.yml`:
```yaml
services:
  snort:
    image: snort3-ibr:3.10.0.0
    build:
      context: .
      dockerfile: Dockerfile
```

Then run:
```bash
docker compose build
```

## Output
generates `output/<timestamp>/summary.txt`:
```
=== IBR Alert Summary ===

=== Alerts by Rule (SID) ===
 666570    29456   PROTOCOL-ICMP Unusual PING detected
 665572    384     PROTOCOL-ICMP PING
   9586    1417    PROTOCOL-SNMP request udp
    ...

=== Alerts by Classification ===
1316824 Misc activity
 666570 Information Leak
  46692 Attempted Information Leak
    ...
```

## Directory Structure
```
snort3-ibr/
├── Dockerfile
├── compose.yml
├── setup.sh
├── run_analysis.sh
├── README.md
├── snortrules-snapshot-31470.tar.gz   (add this)
├── rules/                             (extracted by setup.sh)
├── pcaps/                             (your PCAP files)
└── output/                            (results)
```

## Versions
- **Base Image:** Ubuntu 22.04
- **Snort:** 3.10.0.0
- **Ruleset:** snortrules-snapshot-31470.tar.gz
- **LibDAQ:** 3.0.23


## References
- https://github.com/snort3/snort3
- https://docs.snort.org/start/installation
- https://www.snort.org/downloads
