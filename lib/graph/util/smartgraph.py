# coding=utf-8
from networkx import Graph


class SmartGraph(Graph):
    """
    Extension for Networkx Graph to Recognize Derived artifacts
    """

    def __init__(self, data=None, **attr):
        Graph.__init__(self, data, **attr)
        self.commit = dict()
        self.derived_artifacts = set()

    def learn_current_commit(self, commit):
        """
        makes the network learn the current commit
        :param commit: current commit
        """
        self.commit = commit

    def add_node(self, node, attr_dict=None, **attr):
        """
        see networkx.Graph.add_node
        :param node:
        :param attr_dict:
        :param attr:
        """
        if node not in self.commit.values():
            self.derived_artifacts.add(node)
            if attr_dict:
                attr_dict['isDerived'] = True
        Graph.add_node(self, node, attr_dict, **attr)

    def add_path(self, nodes, **attr):
        """
            see networkx.Graph
        """
        super(SmartGraph, self).add_path(nodes, **attr)

    def add_nodes_from(self, nodes, **attr):
        """
            see networkx.Graph
        """
        for n in filter(lambda x: x not in self.commit.values(), nodes):
            self.derived_artifacts.add(n)
        super(SmartGraph, self).add_nodes_from(nodes, **attr)

    def add_star(self, nodes, **attr):
        """
            see networkx.Graph
        """
        super(SmartGraph, self).add_star(nodes, **attr)

    def add_edge(self, u, v, attr_dict=None, **attr):
        """
            see networkx.Graph
        """
        return super(SmartGraph, self).add_edge(u, v, attr_dict, **attr)

    def add_edges_from(self, ebunch, attr_dict=None, **attr):
        """
            see networkx.Graph
        """
        return super(SmartGraph, self).add_edges_from(ebunch, attr_dict, **attr)

    def add_cycle(self, nodes, **attr):
        """
            see networkx.Graph
        """
        super(SmartGraph, self).add_cycle(nodes, **attr)

    def add_weighted_edges_from(self, ebunch, weight='weight', **attr):
        """
            see networkx.Graph
        """
        super(SmartGraph, self).add_weighted_edges_from(ebunch, weight, **attr)


