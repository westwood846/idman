# Connection criterion: name and mail or signer and signer_key appear in the same commit
# The edges are weighted by the number of commits where they appeared.

import itertools



def learn_artifacts(artifact_graph, artifacts):
    for artifact in artifacts:
        artifact_graph.add_node(artifact)

    for u, v in itertools.combinations(artifacts, 2):
        if artifact_graph.has_edge(u, v):
            artifact_graph[u][v]["label"] += 1
        else:
            artifact_graph.add_edge(u, v, label=1)

def learn_commit(artifact_graph, commit):
    author_artifacts = [commit["author_name"], commit["author_mail"]]
    learn_artifacts(artifact_graph, author_artifacts)

    committer_artifacts = [commit["committer_name"], commit["committer_mail"]]
    learn_artifacts(artifact_graph, committer_artifacts)

    signer_artifacts = []
    if (commit['signer']):
        signer_artifacts.append(commit['signer'])
    if (commit['signer_key']):
        signer_artifacts.append(commit['signer_key'])
    learn_artifacts(artifact_graph, signer_artifacts)
