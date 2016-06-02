import re

def normalize_name(name):
    # We remove all punctuation, suffixes
    # ("jr"); turn all whitespace into a single space; remove
    # generic terms like "admin", "support", from the name;
    import readers
    import os
    insignificant_words = readers.load_csv_column(".."+os.path.sep+".."+os.path.sep+"data"+os.path.sep+"blacklistmail.csv")
    for term in insignificant_words:
        term_re = re.compile(re.escape(term), re.IGNORECASE)
        name = term_re.sub("", name).strip()
    # The paper does not mention case-sensitivity, but we obviously need to do this case-insensitive
    return name.lower()

def remove_non_alphnum_from_name(name):
    return re.sub("[^\w]+", " ",name).strip()#replaces non-alphanumeric characters with whitespace

def extract_mail_prefix(mail):
    return mail.split("@")[0].lower()

def split_name(name):
    split = name.split() # TODO: Split commas # split without argument splits at whitespace characters
    return " ".join(split[:-1]), split[-1]

def join_name(firstname, lastname):
    return " ".join([firstname, lastname])


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
