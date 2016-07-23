# Human Resources Data Workflow Example using Redo

This directory contains the files needed to run a similar demo to the
[drake human-resources demo](https://github.com/Factual/drake/tree/master/demos/human-resources).
Instead of drake, it uses [Redo](https://github.com/apenwarr/redo).

A couple of the `.do` files use python (mainly to munge json and csv); the file
`name_length_reports_jq.do` uses the [jq](http://stedolan.github.io/jq/)
utility. (Probably very inefficiently; it's the first time I've used it!)

This example is not intended to detract from the value of Drake (or Make or Rake
or any other tool that can be used for data workflow), but merely to show that
Redo is a viable option for these sorts of problems.

## Running and so forth

You'll need Redo (link above) and jq if you intend to use
`name_length_reports_jq.do`. You'll need python, too.
