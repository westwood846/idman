import itertools


def extract_artifacts(commit):
    artifacts = {
        "author_name": commit['author_name'],
        "author_mail": commit['author_mail'],
        "committer_mail": commit['committer_mail'],
        "committer_name": commit['committer_name']
    }
    if (commit['signer'] != ""):
        artifacts["signer"] = commit['signer']
    if (commit['signer_key'] != ""):
        artifacts["signer_key"] = commit['signer_key']
    return artifacts

def learn_commit(artifact_graph, commit):
    artifacts = extract_artifacts(commit).values()
    for u, v in itertools.combinations(artifacts, 2):
        if artifact_graph.has_edge(u, v):
            artifact_graph[u][v]["label"] += 1
        else:
            artifact_graph.add_edge(u, v, label=1)
    return artifact_graph
