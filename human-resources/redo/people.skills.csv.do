redo-ifchange everyone skills
grep 310 everyone | sort > $2.tmp
join -t, skills $2.tmp
rm $2.tmp
