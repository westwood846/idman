#!/usr/bin/env python
# -*- coding: utf-8 -*-

# Dependencies: python-networkx

import networkx as nx
from networkx.drawing.nx_agraph import graphviz_layout
import sys
import json
import itertools
import getopt



class SetEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, set):
            return list(obj)
        return json.JSONEncoder.default(self, obj)



G = nx.Graph()

for line in sys.stdin:
    commit = json.loads(line)
    items = [commit['author_name'], commit['author_mail'], commit['committer_mail'], commit['committer_name']]
    items = set(items)
    for item in items:
        G.add_node(item)
    for combination in itertools.combinations(items, 2):
        G.add_edge(combination[0], combination[1])

identities = []
for component in nx.connected_components(G):
    identities.append(component)

if "--dot" in sys.argv:
    print nx.drawing.nx_agraph.to_agraph(G)
elif "--json" in sys.argv:
    print json.dumps(identities, indent=1, cls=SetEncoder)
else:
    print "Useage: graph.py --dot|--json"
