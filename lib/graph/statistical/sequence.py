# coding=utf-8
from difflib import SequenceMatcher


def calc_similarity(w1, w2):
    """

    :param w1:
    :param w2:
    :return:
    """
    return SequenceMatcher(w1, w2).ratio()
