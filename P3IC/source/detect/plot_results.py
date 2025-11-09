#!/usr/bin/env python3
"""
Simple plotting helper for the experiment CSV produced by run_experiments.sh

Usage:
  python3 plot_results.py run_results.csv

Produces:
  - run_summary.csv (means and stddev per thread)
  - time_vs_threads.png (mean time with stddev error bars)
  - speedup_vs_threads.png (speed-up relative to single-thread)

If matplotlib is not installed the script prints installation instructions.
"""
import sys
import csv
from collections import defaultdict
import math

def load_csv(path):
    data = []
    with open(path, newline='') as f:
        reader = csv.DictReader(f)
        for r in reader:
            data.append({ 'threads': int(r['threads']), 'rep': int(r['rep']), 'time_ms': float(r['time_ms']) })
    return data

def summarize(data):
    by_t = defaultdict(list)
    for r in data:
        by_t[r['threads']].append(r['time_ms'])
    rows = []
    for t in sorted(by_t.keys()):
        vals = by_t[t]
        n = len(vals)
        mean = sum(vals)/n
        var = sum((x-mean)**2 for x in vals)/(n-1) if n>1 else 0.0
        std = math.sqrt(var)
        rows.append((t, n, mean, std))
    return rows

def save_summary(rows, out='run_summary.csv'):
    with open(out, 'w', newline='') as f:
        writer = csv.writer(f)
        writer.writerow(['threads','reps','mean_ms','std_ms'])
        for r in rows:
            writer.writerow(r)

def try_plot(rows):
    try:
        import matplotlib.pyplot as plt
    except Exception as e:
        print('matplotlib not available. To install run: pip3 install matplotlib')
        return False

    threads = [r[0] for r in rows]
    means = [r[2] for r in rows]
    stds = [r[3] for r in rows]

    # Time vs threads (error bars)
    plt.figure()
    plt.errorbar(threads, means, yerr=stds, fmt='-o')
    plt.xlabel('Threads')
    plt.ylabel('Time (ms)')
    plt.title('Mean time vs threads')
    plt.grid(True)
    plt.savefig('time_vs_threads.png', dpi=200)
    plt.close()

    # Speedup vs threads
    baseline = means[0]
    speedups = [baseline/m for m in means]
    plt.figure()
    plt.plot(threads, speedups, '-o')
    plt.xlabel('Threads')
    plt.ylabel('Speed-up')
    plt.title('Speed-up vs threads')
    plt.grid(True)
    plt.savefig('speedup_vs_threads.png', dpi=200)
    plt.close()

    print('Plots written: time_vs_threads.png, speedup_vs_threads.png')
    return True

def main():
    if len(sys.argv) < 2:
        print('Usage: python3 plot_results.py run_results.csv')
        sys.exit(1)
    data = load_csv(sys.argv[1])
    rows = summarize(data)
    if not rows:
        print('No data found in', sys.argv[1])
        sys.exit(1)
    save_summary(rows)
    ok = try_plot(rows)
    if not ok:
        print('Summary written to run_summary.csv. Install matplotlib to generate PNGs.')

if __name__ == '__main__':
    main()
