# Reference algorithm that does not create any connections



def learn_commit(artifact_graph, commit,args):
    artifact_graph.add_node(commit.get("committer_name",None))
    artifact_graph.add_node(commit.get("committer_mail",None))
    artifact_graph.add_node(commit.get("author_name",None))
    artifact_graph.add_node(commit.get("author_mail",None))
    return artifact_graph
