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
        self.commit=commit

    def add_node(self, n, attr_dict=None, **attr):
        """
        see networkx.Graph.add_node
        :param n:
        :param attr_dict:
        :param attr:
        """
        if n not in self.commit.values():
            self.derived_artifacts.add(n)
        Graph.add_node(self, n, attr_dict, **attr)

