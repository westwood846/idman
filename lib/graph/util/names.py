#!/usr/bin/env python
# -*- coding: utf-8 -*-
import re


def normalize_name(name):
    # We remove all punctuation, suffixes
    # ("jr"); turn all whitespace into a single space; remove
    # generic terms like "admin", "support", from the name;
    """

    :param name:
    :return:
    """
    import readers
    import os
    insignificant_words = readers.load_csv_column(
            ".." + os.path.sep + ".." + os.path.sep + "data" + os.path.sep + "blacklistmail.csv", "name")
    for term in insignificant_words:
        term_re = re.compile(re.escape(term), re.IGNORECASE)
        name = term_re.sub("", name).strip()
    # The paper does not mention case-sensitivity, but we obviously need to do this case-insensitive
    return name.lower()


def remove_non_alphnum_from_name(name):
    """

    :param name:
    :return:
    """
    return re.sub("[^\w]+", " ", name).strip()  # replaces non-alphanumeric characters with whitespace


def extract_mail_prefix(mail):
    """

    :param mail:
    :return:
    """
    return mail.split("@")[0].lower()


def split_name(name):
    """

    :param name:
    :return:
    """
    split = remove_non_alphnum_from_name(name).split()  # split without argument splits at whitespace characters
    return " ".join(split[:-1]), split[-1]


def join_name(firstname, lastname):
    """

    :param firstname:
    :param lastname:
    :return:
    """
    return " ".join([firstname, lastname])


def alias_contains_first_and_last(alias, first, last):
    """

    :param alias:
    :param first:
    :param last:
    :return:
    """
    return len(first) >= 2 and len(last) >= 2 and first in alias and last in alias


def alias_contains_first_or_last_and_first_letter(e, first, last):
    """

    :param e:
    :param first:
    :param last:
    :return:
    """
    length_ok = len(first) >= 2 and len(last) >= 2
    first_partly_in_e = last in e and e.startswith(first[1])
    last_partly_in_e = first in e and e.startswith(last[1])
    return length_ok and (first_partly_in_e or last_partly_in_e)


def learn_name(firstname, lastname, artifact_graph):
    """

    :param firstname:
    :param lastname:
    :param artifact_graph:
    """
    name = join_name(firstname, lastname)
    artifact_graph.add_node(name, type="name")


# noinspection PyUnusedLocal
def create_n_grams(word, length, prechar=False):
    """

    :param word:
    :param length:
    :param prechar:
    :return:
    """
    gramsource = word
    if prechar:
        # noinspection PyUnusedLocal
        tmp = [" " for i in range(length)]
        gramsource = tmp + gramsource + gramsource
    return zip(*[gramsource[i:] for i in range(length)])
