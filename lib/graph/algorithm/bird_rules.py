# -*- coding: utf-8 -*-

# noinspection PyUnresolvedReferences
from statistical.levenshtein import levenshtein


def lev_similar(l1, l2, threshold=0.5):
    """

    :param l1:
    :param l2:
    :param threshold:
    :return:
    """
    distance = float(levenshtein(l1, l2))
    max_length = float(max(len(l1), len(l2)))
    return 1 - (distance / max_length) >= threshold


def similar(l1, l2):
    """

    :param l1:
    :param l2:
    :return:
    """
    return lev_similar(l1, l2)


def similar_firstfirst_lastlast(first1, last1, first2, last2):
    """

    :param first1:
    :param last1:
    :param first2:
    :param last2:
    :return:
    """
    return lev_similar(first1, first2) and similar(last1, last2)


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
