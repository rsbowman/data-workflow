redo-ifchange people.skills.csv
while read p; do
  echo "$p,$(uuidgen)"
done < people.skills.csv | \
jq --slurp --raw-input --raw-output \
   'split("\n") | map(split(",")) |
    map({"name": .[0],
         "skills": .[1],
         "tel": .[2],
         "uuid": .[3]})'
