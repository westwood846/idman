## General

Graphman is the actual Program which joins multiple identities of a developer using a graph-based approach.

## Usage

See

      ./graphman -h

Also commits should be piped into graphman as json-Objects


## Add new feature

### Algorithm

All algorithms are located in the algorithm-folder.
They combine the multiple identities.

They must contain the following function:

    def learn_commit(artifact_graph, commit, args):

* artifact_graph: represents an networkx-graph on which the function works
* commit: is the current commit which identities should be merged into the existing identies if suitable
* args: the command line arguments parsed to graphman

### Similarity Metric

All similarity metrics are located in the statistical-folder

They must contain the function

    def calc_similarity(w1, w2):

with w1,w2 being two words whose similarity is to be computed and the function returns a value between 0.00 and 1.00

## Other

### Util

Everything that can be used by graphman, the algortihms or the similarity-metrics but is not bound to a specific case goes here.