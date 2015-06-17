#!/usr/bin/env python
import json, subprocess
subprocess.call("redo-ifchange people.json", shell=True)

with open("people.json", "r") as f:
    data = json.load(f)

first_file = open("first_gt_last.txt", "w")
last_file = open("last_gt_first.txt", "w")
for row in data:
    full_name = row["name"]
    fname, lname = full_name.split()
    if len(fname) > len(lname):
        first_file.write(full_name + "\n")
    if len(lname) > len(fname):
        last_file.write(full_name + "\n")
first_file.close()
last_file.close()
