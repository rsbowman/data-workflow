#!/usr/bin/env python
import sys, subprocess, json, csv
subprocess.call("redo-ifchange people.json", shell=True)
_, infile, in_noext, tmp_out = sys.argv
with open("people.json", "r") as f:
    reader = json.load(f)
    writer = csv.writer(sys.stdout)
    for row in reader:
        first, last = row["name"].split()
        uname = first[0] + last
        writer.writerow([uname] + row.values())

