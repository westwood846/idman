import itertools
from util import filters

def extract_artifacts(commit):
    artifacts = {
        "author_name": commit['author_name'],
        "author_mail": commit['author_mail'],
        "committer_mail": commit['committer_mail'],
        "committer_name": commit['committer_name'],
        "signer": commit['signer'],
        "signer_key":commit['signer_key']
    }
    return artifacts

def learn_commit(artifact_graph, commit,args):
    artifacts = filters.clean_list(extract_artifacts(commit).values())
    for u, v in itertools.combinations(artifacts, 2):
        if artifact_graph.has_edge(u, v):
            artifact_graph[u][v]["label"] += 1
        else:
            artifact_graph.add_edge(u, v, label=1)
    return artifact_graph
