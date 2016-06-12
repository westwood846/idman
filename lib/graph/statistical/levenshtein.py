# coding=utf-8
def calc_similarity(w1, w2):
    """

    :param w1:
    :param w2:
    :return:
    """
    return levenshtein(w1, w2)


##
# this method is from https://en.wikibooks.org/wiki/Algorithm_Implementation/Strings/Levenshtein_distance#Python
# licenced under  CC BY-SA 3.0 (https://creativecommons.org/licenses/by-sa/3.0/)
def levenshtein(seq1, seq2):
    """

    :param seq1:
    :param seq2:
    :return:
    """
    oneago = None
    thisrow = range(1, len(seq2) + 1) + [0]
    for x in xrange(len(seq1)):
        twoago, oneago, thisrow = oneago, thisrow, [0] * len(seq2) + [x + 1]
        for y in xrange(len(seq2)):
            delcost = oneago[y] + 1
            addcost = thisrow[y - 1] + 1
            subcost = oneago[y - 1] + (seq1[x] != seq2[y])
            thisrow[y] = min(delcost, addcost, subcost)
    return thisrow[len(seq2) - 1]
