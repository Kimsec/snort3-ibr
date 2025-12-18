#!/bin/bash
set -e

OUTDIR="output/$(date +%Y%m%d_%H%M%S)"
mkdir -p "$OUTDIR"
echo ""
echo "Processing PCAPs, output will be in: $OUTDIR. This might take a while..."
echo ""
# Run Snort, convert to TSV on the fly
docker compose run --rm snort bash -c '
    snort -c /usr/local/etc/snort/snort.lua \
        -R /usr/local/etc/snort/rules/snort.rules \
        --pcap-dir /pcaps \
        -A alert_json \
        --lua "alert_json = { fields = '\''sid msg class dst_port proto'\'' }" \
        -q | jq -r "[.sid, .msg, .class, .dst_port, .proto] | @tsv"' > "$OUTDIR/alerts.tsv"

# Generate summary from TSV
{
    echo "====== IBR Alert Summary ======"
    echo ""
    echo "=== Alerts by Rule (SID) ==="
    cut -f1,2 "$OUTDIR/alerts.tsv" | sort | uniq -c | sort -rn
    echo ""
    echo "=== Alerts | sorted by Classification ==="
    cut -f3 "$OUTDIR/alerts.tsv" | sort | uniq -c | sort -rn
    echo ""
    echo "=== Alerts | top 50 Destination Port ==="
    cut -f4 "$OUTDIR/alerts.tsv" | sort -n | uniq -c | sort -rn 2>/dev/null | head -50
    echo ""
    echo "=== Alerts | sorted by Protocol ==="
    cut -f5 "$OUTDIR/alerts.tsv" | sort | uniq -c | sort -rn
} | tee "$OUTDIR/summary.txt"
