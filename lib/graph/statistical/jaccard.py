# coding=utf-8
from util import names


def calc_similarity(w1, w2):
    """

    :param w1:
    :param w2:
    :return:
    """
    return jaccard(w1, w2)


def jaccard(word1, word2, n=2, prechar=True):
    """

    :param word1:
    :param word2:
    :param n:
    :param prechar:
    :return:
    """
    l1 = set(names.create_n_grams(list(word1), n, prechar))
    l2 = set(names.create_n_grams(list(word2), n, prechar))
    return len(l1.intersection(l2)) / len(l1.union(l2))
