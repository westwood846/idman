#!/usr/bin/env python
# -*- coding: utf-8 -*-

# Connection Criterium: String similarity

import itertools
import networkx as nx
import importlib
from util import filters


def learn_commit(artifact_graph, commit, args):
    """

    :param artifact_graph:
    :param commit:
    :param args:
    """
    min_similarity = args.min_similarity if args.min_similarity is not None else 0.9
    metric = args.metric if args.metric else "sequence"

    learn_artifacts(artifact_graph, [commit["author_name"], commit["author_mail"]], min_similarity,
                    metric)

    learn_artifacts(artifact_graph, [commit["committer_name"], commit["committer_mail"]], min_similarity,
                    metric)

    learn_artifacts(artifact_graph, [commit['signer'], commit['signer_key']], min_similarity, metric)


def learn_artifacts(artifact_graph, commit, min_similarity=0.9, metric="sequence"):
    """

    :param artifact_graph:
    :param commit:
    :param min_similarity:
    :param metric:
    """
    commit = filters.clean_list(commit)
    add_person(artifact_graph, commit)
    learn_person(artifact_graph, commit, min_similarity, metric)


def learn_person(artifact_graph, artifacts, min_similarity=0.9, metric="sequence"):
    """

    :param artifact_graph:
    :param artifacts:
    :param min_similarity:
    :param metric:
    """
    metric_calc = importlib.import_module("statistical." + metric)
    for a in artifacts:
        for cluster in nx.connected_components(artifact_graph):
            for n in cluster:
                if metric_calc.calc_similarity(a, n) >= min_similarity and not a == n:
                    if artifact_graph.has_edge(a, n):
                        artifact_graph[a][n]["label"] += 1
                    else:
                        artifact_graph.add_edge(a, n, label=1)
                    break


def add_person(artifact_graph, artifacts):
    """

    :param artifact_graph:
    :param artifacts:
    """
    for artifact in artifacts:
        artifact_graph.add_node(artifact)

    for u, v in itertools.combinations(artifacts, 2):
        if artifact_graph.has_edge(u, v):
            artifact_graph[u][v]["label"] += 1
        else:
            artifact_graph.add_edge(u, v, label=1)
