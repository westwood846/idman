from difflib import SequenceMatcher
import itertools
import networkx as nx
import importlib


def learn_commit(artifact_graph, commit,args):
    min_similarity=args.min_similarity if args.min_similarity != None else 0.9
    metric = args.metric if args.metric else "sequence"
    author_artifacts = [commit["author_name"], commit["author_mail"]]
    learn_artifacts(artifact_graph, author_artifacts,min_similarity,metric)

    committer_artifacts = [commit["committer_name"], commit["committer_mail"]]
    learn_artifacts(artifact_graph, committer_artifacts,min_similarity,metric)

    signer_artifacts = []
    if (commit['signer']):
        signer_artifacts.append(commit['signer'])
    if (commit['signer_key']):
        signer_artifacts.append(commit['signer_key'])
    learn_artifacts(artifact_graph, signer_artifacts,min_similarity,metric)

def learn_artifacts(artifact_graph, commit,min_similarity=0.9,metric="sequence"):
    add_person(artifact_graph, commit)
    learn_person(artifact_graph, commit,min_similarity,metric)


def learn_person(artifact_graph, artifacts,min_similarity=0.9,metric="sequence"):
    metric_calc = importlib.import_module("statistical."+metric)
    for a in artifacts:
        for cluster in nx.connected_components(artifact_graph):#, key=len, reverse=True):#Iterate over clusters largest to smallest
            for n in cluster:
                if metric_calc.calc_similarity(a,n) >= min_similarity and not a == n:
                    if artifact_graph.has_edge(a, n):
                        artifact_graph[a][n]["label"] += 1
                    else:
                        artifact_graph.add_edge(a, n, label=1)
                    break


def add_person(artifact_graph, artifacts):
    for artifact in artifacts:
        artifact_graph.add_node(artifact)

    for u, v in itertools.combinations(artifacts, 2):
        if artifact_graph.has_edge(u, v):
            artifact_graph[u][v]["label"] += 1
        else:
            artifact_graph.add_edge(u, v, label=1)


def calc_similarity(w1, w2):
    return SequenceMatcher(None, w1, w2).ratio()
