# coding=utf-8
# Reference algorithm that does not create any connections


# noinspection PyUnusedLocal
def learn_commit(artifact_graph, commit, args):
    """

    :param artifact_graph:
    :param commit:
    :param args:
    :return:
    """
    artifact_graph.add_node(commit.get("committer_name", None))
    artifact_graph.add_node(commit.get("committer_mail", None))
    artifact_graph.add_node(commit.get("author_name", None))
    artifact_graph.add_node(commit.get("author_mail", None))
    return artifact_graph
