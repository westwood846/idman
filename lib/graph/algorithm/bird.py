# -*- coding: utf-8 -*-

import networkx as nx
from bird_rules import *
from bird_tools import *


originals = {}


def safe_artifact(original, projection):
    if (originals.has_key(projection)):
        originals[projection].add(original)
    else:
        originals[projection] = set([original])


def learn_name(firstname, lastname, artifact_graph):
    """

    :param firstname:
    :param lastname:
    :param artifact_graph:
    """
    name = join_name(firstname, lastname)
    artifact_graph.add_node(name, type="name")

    for node, data in artifact_graph.nodes(data=True):
        if node == name:
            break
        if artifact_graph.has_edge(node, name):
            break

        # Rule 1
        if similar(node, name):
            # print "Rule 1 %s -- %s" % (node, name)
            artifact_graph.add_edge(node, name)
            break

        # Rule 2
        if data["type"] == "name":
            first2, last2 = split_name(node)
            if similar_firstfirst_lastlast(firstname, lastname, first2, last2):
                # print "Rule 2 %s -- %s" % (node, name)
                artifact_graph.add_edge(node, name)
                break

        if data["type"] == "alias":
            # Rule 4
            if alias_contains_first_and_last(node, firstname, lastname):
                # print "Rule 4 %s -- %s" % (node, name)
                artifact_graph.add_edge(node, name)
                break

            # Rule 5
            if alias_contains_first_or_last_and_first_letter(node, firstname, lastname):
                # print "Rule 5 %s -- %s" % (node, name)
                artifact_graph.add_edge(node, name)
                break

def learn_alias(alias, artifact_graph):
    # alias = alias.encode('ascii', 'ignore')
    """

    :param alias:
    :param artifact_graph:
    """
    artifact_graph.add_node(alias, type="alias")

    for node, data in artifact_graph.nodes(data=True):
        if node == alias:
            break
        if artifact_graph.has_edge(node, alias):
            break

        # Rule 3 (or 1, they are identical for mails)
        if similar(node, alias):
            # print "Rule 3 %s -- %s" % (node, alias)
            artifact_graph.add_edge(node, alias)
            break

        if data["type"] == "name":
            # Rule 4
            firstname, lastname = split_name(node)
            if alias_contains_first_and_last(alias, firstname, lastname):
                # print "Rule 4 %s -- %s" % (node, alias)
                artifact_graph.add_edge(node, alias)
                break

            # Rule 5
            if alias_contains_first_or_last_and_first_letter(alias, firstname, lastname):
                # print "Rule 5 %s -- %s" % (node, alias)
                artifact_graph.add_edge(node, alias)
                break

def learn_name_and_mail(artifact_graph, name, mail):
    """

    :param artifact_graph:
    :param name:
    :param mail:
    :return:
    """
    if name:
        normalized_name = normalize_name(name)
        safe_artifact(name, normalized_name)
        firstname, lastname = split_name(normalized_name)

        if not firstname:
            # Bird's algorithm assumes that names are real names.
            # Since git usernames have no such restriction, we need to treat nicknames differently.
            # Treating them as aliases like the email prefixes should yield comparable results.
            learn_alias(lastname, artifact_graph)
            return
        else:
            learn_name(firstname, lastname, artifact_graph)
    if mail:
        mail_prefix = extract_mail_prefix(mail)
        safe_artifact(mail, mail_prefix)
        learn_alias(mail_prefix, artifact_graph)

# noinspection PyUnusedLocal,PyUnusedLocal,PyUnusedLocal,PyUnusedLocal
def learn_commit(artifact_graph, commit, args):
    """

    :param artifact_graph:
    :param commit:
    :param args:
    :return:
    """
    learn_name_and_mail(artifact_graph, commit.get("committer_name", None),
                        commit.get("committer_mail", None))
    learn_name_and_mail(artifact_graph, commit.get("author_name", None), commit.get("author_mail", None))
    return artifact_graph

def duplicate_node(artifact_graph, node, new_node):
    artifact_graph.add_node(new_node)
    for neighbor in artifact_graph[node]:
        artifact_graph.add_edge(neighbor, new_node)

def restore(artifact_graph):
    originals.pop("", None)
    for projection, originals_set in originals.iteritems():
        first_rename = originals_set.pop()
        nx.relabel_nodes(artifact_graph, {projection: first_rename}, False)
        for original in originals_set:
            duplicate_node(artifact_graph, first_rename, original)
