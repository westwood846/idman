# Reference algorithm that does not create any connections



def learn_commit(artifact_graph, commit,args):
    artifact_graph.add_node(commit["committer_name"])
    artifact_graph.add_node(commit["committer_mail"])
    artifact_graph.add_node(commit["author_name"])
    artifact_graph.add_node(commit["author_mail"])
    return artifact_graph
