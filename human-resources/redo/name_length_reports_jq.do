redo-ifchange people.json
cat people.json | jq -r '.[] | .name | split(" ")
                         | {first: .[0], last: .[1]}
                         | select((.first | length) > (.last | length))
                         | [.first, .last] | join(" ")' > first_gt_last.txt
cat people.json | jq -r '.[] | .name | split(" ")
                         | {first: .[0], last: .[1]}
                         | select((.first | length) < (.last | length))
                         | [.first, .last] | join(" ")' > last_gt_first.txt


