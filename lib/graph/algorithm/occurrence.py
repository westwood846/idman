# coding=utf-8
# Connection criterion: name and mail or signer and signer_key appear in the same commit
# The edges are weighted by the number of commits where they appeared.

import itertools
from util import filters


def learn_artifacts(artifact_graph, artifacts):
    """

    :param artifact_graph:
    :param artifacts:
    """
    artifacts = filters.clean_list(artifacts)
    for artifact in artifacts:
        artifact_graph.add_node(artifact)

    for u, v in itertools.combinations(artifacts, 2):
        if artifact_graph.has_edge(u, v):
            artifact_graph[u][v]["label"] += 1
        else:
            artifact_graph.add_edge(u, v, label=1)


# noinspection PyUnusedLocal
def learn_commit(artifact_graph, commit, args):
    """

    :param artifact_graph:
    :param commit:
    :param args:
    """
    author_artifacts = [commit["author_name"], commit["author_mail"]]
    learn_artifacts(artifact_graph, author_artifacts)

    committer_artifacts = [commit["committer_name"], commit["committer_mail"]]
    learn_artifacts(artifact_graph, committer_artifacts)

    signer_artifacts = [commit['signer'], commit['signer_key']]
    learn_artifacts(artifact_graph, signer_artifacts)
