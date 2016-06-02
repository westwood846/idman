import re
from statistical.levenshtein import levenshtein



def normalize_name(name):
    # We remove all punctuation, suffixes
    # ("jr"); turn all whitespace into a single space; remove
    # generic terms like "admin", "support", from the name;
    prefixes = ["mr.", "mrs.", "miss", "ms.", "prof.", "pr.", "dr.", "ir.", "rev.", "ing.", "jr.", "d.d.s.", "ph.d.", "capt.", "lt."]
    tech_terms = ["administrator", "admin.", "support", "development", "dev.", "developer", "maint.", "maintainer"]
    other_terms = ["i18n", "spam", "bug", "bugs", "root", "mailing", "list", "contact", "project"]
    project_specific_terms = ["elasticsearch", "gdx", "libgdx", "spring", "spring-framework", "django"]
    custom_terms = ["github"]
    insignificant_words = prefixes + tech_terms + project_specific_terms + custom_terms
    for term in insignificant_words:
        term_re = re.compile(re.escape(term), re.IGNORECASE)
        name = term_re.sub("", name).strip()
    return name

def extract_mail_prefix(mail):
    return mail.split("@")[0]

def split_name(name):
    split = name.split(" ") # TODO: Split commas
    return " ".join(split[:-1]), split[-1]

def join_name(firstname, lastname):
    return " ".join([firstname, lastname])

def lev_similar(l1, l2, threshold=0.5):
    distance = float(levenshtein(l1, l2))
    max_length = float(max(len(l1), len(l2)))
    return 1 - (distance / max_length) >= threshold

def similar(l1, l2):
    return lev_similar(l1, l2)

def similar_firstfirst_lastlast(first1, last1, first2, last2):
    return lev_similar(first1, first2) and similar (last1, last2)

def alias_contains_first_and_last(alias, first, last):
    return len(first) >= 2 and len(last) >= 2 and first in alias and last in alias

def alias_contains_first_or_last_and_first_letter(e, first, last):
    length_ok = len(first) >= 2 and len(last) >= 2
    first_partly_in_e = last in e and e.startswith(first[1])
    last_partly_in_e = first in e and e.startswith(last[1])
    return length_ok and (first_partly_in_e or last_partly_in_e)

def learn_name(firstname, lastname, artifact_graph):
    name = join_name(firstname, lastname)
    artifact_graph.add_node(name, type="name")

    for node, data in artifact_graph.nodes(data=True):
        if node == name: break
        if artifact_graph.has_edge(node, name): break

        # Rule 1
        if similar(node, name):
            print "Rule 1 %s -- %s" % (node, name)
            artifact_graph.add_edge(node, name)
            break

        # Rule 2
        if data["type"] == "name":
            first2, last2 = split_name(node)
            if similar_firstfirst_lastlast(firstname, lastname, first2, last2):
                print "Rule 2 %s -- %s" % (node, name)
                artifact_graph.add_edge(node, name)
                break

        if data["type"] == "alias":
            # Rule 4
            if alias_contains_first_and_last(node, firstname, lastname):
                print "Rule 4 %s -- %s" % (node, name)
                artifact_graph.add_edge(node, name)
                break

            # Rule 5
            if alias_contains_first_or_last_and_first_letter(node, firstname, lastname):
                print "Rule 5 %s -- %s" % (node, name)
                artifact_graph.add_edge(node, name)
                break

def learn_alias(alias, artifact_graph):
    alias = alias.encode('ascii', 'ignore')
    artifact_graph.add_node(alias, type="alias")

    for node, data in artifact_graph.nodes(data=True):
        if node == alias: break
        if artifact_graph.has_edge(node, alias): break

        # Rule 3 (or 1, they are identical for mails)
        if similar(node, alias):
            print "Rule 3 %s -- %s" % (node, alias)
            artifact_graph.add_edge(node, alias)
            break

        if data["type"] == "name":
            # Rule 4
            firstname, lastname = split_name(node)
            if alias_contains_first_and_last(alias, firstname, lastname):
                print "Rule 4 %s -- %s" % (node, alias)
                artifact_graph.add_edge(node, alias)
                break

            # Rule 5
            if alias_contains_first_or_last_and_first_letter(alias, firstname, lastname):
                print "Rule 5 %s -- %s" % (node, alias)
                artifact_graph.add_edge(node, alias)
                break

def learn_name_and_mail(artifact_graph, name, mail):
    name = normalize_name(name)
    mail = extract_mail_prefix(mail)
    firstname, lastname = split_name(name)

    if not firstname:
        # Bird's algorithm assumes that names are real names.
        # Since git usernames have no such restriction, we need to treat nicknames differently.
        # Treating them as aliases like the email prefixes should yield comparable results.
        learn_alias(lastname, artifact_graph)
        return
    else:
        learn_name(firstname, lastname, artifact_graph)
    learn_alias(mail, artifact_graph)


def learn_commit(artifact_graph, commit):
    learn_name_and_mail(artifact_graph, commit["committer_name"], commit["committer_mail"])
    learn_name_and_mail(artifact_graph, commit["author_name"], commit["author_mail"])
    return artifact_graph
