#!/usr/bin/env python
# -*- coding: utf-8 -*-

# Graph based identity algorithm.
#
# Each identity-artifact (e.g. "author_email") is a node.
# If artifacts appear in the metadata of the same commit, they are connected by an edge.
# The connected components of the resulting graph are individual identities.
# The edges are weighted by the number of commits where they appeared.
# Supports json output with (--json) and graphviz output (--dot).
# When outputting for graphviz, the --filter min argument may be used to remove all edges with a weight below min.
#
# Dependencies: python-networkx (apt-get)

import networkx as nx
from networkx.drawing.nx_agraph import graphviz_layout
import sys
import json
import itertools



class SetEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, set):
            return list(obj)
        return json.JSONEncoder.default(self, obj)


G = nx.Graph()

for line in sys.stdin:
    commit = json.loads(line)
    artifacts = [commit['author_name'], commit['author_mail'], commit['committer_mail'], commit['committer_name']]
    artifacts = set(artifacts) # Remove duplicates
    for artifact in artifacts:
        G.add_node(artifact)
    for u, v in itertools.combinations(artifact, 2):
        # Use "label" instead of "weight" to trick dot into drawing it
        if G.has_edge(u, v):
            G[u][v]["label"] += 1
        else:
            G.add_edge(u, v, label=1)

identities = []
for component in nx.connected_components(G):
    identities.append(component)

if "--filter" in sys.argv:
    minimum = int(sys.argv[sys.argv.index("--filter") + 1])
    for u, v, data in G.edges(data=True):
        if data["label"] < minimum:
            G.remove_edge(u, v)

if "--dot" in sys.argv:
    print nx.drawing.nx_agraph.to_agraph(G)
elif "--json" in sys.argv:
    print json.dumps(identities, indent=1, cls=SetEncoder)
else:
    print "Useage: graph.py --dot|--json [--filter min]"
