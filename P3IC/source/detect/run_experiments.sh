#!/usr/bin/env bash
# Simple experiment runner: runs ./build/detect with different OMP_NUM_THREADS
# Produces CSV: thread,rep,time_ms

set -euo pipefail
cd "$(dirname "$0")"

OUTCSV=run_results.csv
echo "threads,rep,time_ms" > "$OUTCSV"

# Wider sweep: include 8 threads and more repetitions
THREADS=(1 2 4 8)
REPS=5
IMG="build/face_swap_enhanced.png"

for t in "${THREADS[@]}"; do
  export OMP_NUM_THREADS=$t
  for ((r=1;r<=REPS;r++)); do
    echo "Running: threads=$t rep=$r"
    # capture the Total elapsed time line
    out=$(./build/detect "$IMG" 2>&1 | tee /dev/stderr | sed -n 's/.*Total elapsed time: \([0-9]*\)ms.*/\1/p' | tail -n1)
    if [[ -z "$out" ]]; then
      echo "ERROR: could not parse time for threads=$t rep=$r" >&2
      exit 1
    fi
    echo "$t,$r,$out" >> "$OUTCSV"
  done
done

echo "Results written to $OUTCSV"
