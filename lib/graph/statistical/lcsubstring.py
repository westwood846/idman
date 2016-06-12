# coding=utf-8
def calc_similarity(w1, w2):
    """

    :param w1:
    :param w2:
    :return:
    """
    return max([len(longest_common_leading_substring(w1, w2)),
                len(longest_common_trailing_substring(w1, w2))]) / max(
            [len(w1), len(w2)])


##
# this methods are from https://en.wikibooks.org/wiki/Algorithm_Implementation/Strings/Longest_common_leading
# /trailing_substring#Python
# licenced under  CC BY-SA 3.0 (https://creativecommons.org/licenses/by-sa/3.0/)

def longest_common_leading_substring(string1, string2):
    """

    :param string1:
    :param string2:
    :return:
    """
    common = ''
    for s1, s2 in zip(string1, string2):
        if s1 == s2:
            common += s1
    return common


def longest_common_trailing_substring(string1, string2):
    """

    :param string1:
    :param string2:
    :return:
    """
    common = ''
    for s1, s2 in zip(string1[-1::-1], string2[-1::-1]):
        if s1 == s2:
            common += s1
    return common[-1::-1]


##
# this method is from https://en.wikibooks.org/wiki/Algorithm_Implementation/Strings/Longest_common_substring#Python_2
# licenced under  CC BY-SA 3.0 (https://creativecommons.org/licenses/by-sa/3.0/)
# noinspection PyUnusedLocal
def longest_common_substring(s1, s2):
    # noinspection PyUnusedLocal
    """

    :param s1:
    :param s2:
    :return:
    """
    m = [[0] * (1 + len(s2)) for i in xrange(1 + len(s1))]
    longest, x_longest = 0, 0
    for x in xrange(1, 1 + len(s1)):
        for y in xrange(1, 1 + len(s2)):
            if s1[x - 1] == s2[y - 1]:
                m[x][y] = m[x - 1][y - 1] + 1
                if m[x][y] > longest:
                    longest = m[x][y]
                    x_longest = x
            else:
                m[x][y] = 0
    return s1[x_longest - longest: x_longest]
