#!/bin/bash
# Snort 3 IBR Analysis - Setup Script
#
# Set up the directory structure and build the Docker image
# USAGE: ./setup.sh

set -e  # Exit on error
echo "=== Snort 3 IBR Analysis - Setup ==="

# Create directory structure
echo "[1/3] Creating directory structure..."
mkdir -p rules pcaps output
echo "Created: rules/, pcaps/ and output/"

# Check for rules tarball (.tar.gz)
echo "[2/3] Checking for rules..."
if [ -f snortrules-snapshot-*.tar.gz ]; then
    RULES_FILE=(snortrules-snapshot-*.tar.gz)
    echo "Extracting: ${RULES_FILE[0]}..."
    tar -xzf "${RULES_FILE[0]}" -C rules --strip-components=1
    touch rules/local.rules

    # Create snort.rules if missing
    if [ ! -f rules/snort.rules ]; then
        echo "# Snort3 rules" > rules/snort.rules
        for f in rules/snort3-*.rules; do
            [ -e "$f" ] && echo "include $(basename "$f")" >> rules/snort.rules
        done
        echo "include local.rules" >> rules/snort.rules
    fi
else
    echo "WARNING: No snortrules-snapshot-*.tar.gz found"
    echo "Download from: https://www.snort.org/downloads"
fi

# Build/pull Docker image
echo ""
#echo "[3/3] Building Docker image..."
echo "[3/3] Pulling Docker image..."
#echo "This may take a while..."
echo ""
docker compose pull

# Verify installation
echo ""
echo "=============================================="
echo "Verifying Snort installation..."
echo "=============================================="
docker compose run --rm snort snort -V

echo ""
echo "=============================================="
echo "Setup complete!"
echo "=============================================="
echo ""
echo "Next steps:"
echo "  1. If rules not extracted, add snortrules-snapshot-*.tar.gz and run ./setup.sh again"
echo "  2. Add PCAP files to pcaps/"
echo "  3. Run analysis with: ./run_analysis.sh"
echo ""
