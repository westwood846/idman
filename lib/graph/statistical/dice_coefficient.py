# coding=utf-8
def calc_similarity(w1, w2):
    """

    :param w1:
    :param w2:
    :return:
    """
    return dice_coefficient(w1, w2)


##
# this method is from https://en.wikibooks.org/wiki/Algorithm_Implementation/Strings/Dice%27s_coefficient#Python
# licenced under  CC BY-SA 3.0 (https://creativecommons.org/licenses/by-sa/3.0/)

def dice_coefficient(a, b):
    """

    :param a:
    :param b:
    :return:
    """
    if not len(a) or not len(b):
        return 0.0
    """ quick case for true duplicates """
    if a == b:
        return 1.0
    """ if a != b, and a or b are single chars, then they can't possibly match """
    if len(a) == 1 or len(b) == 1:
        return 0.0

    """ use python list comprehension, preferred over list.append() """
    a_bigram_list = [a[i:i + 2] for i in range(len(a) - 1)]
    b_bigram_list = [b[i:i + 2] for i in range(len(b) - 1)]

    a_bigram_list.sort()
    b_bigram_list.sort()

    # assignments to save function calls
    lena = len(a_bigram_list)
    lenb = len(b_bigram_list)
    # initialize match counters
    matches = i = j = 0
    while i < lena and j < lenb:
        if a_bigram_list[i] == b_bigram_list[j]:
            matches += 2
            i += 1
            j += 1
        elif a_bigram_list[i] < b_bigram_list[j]:
            i += 1
        else:
            j += 1

    score = float(matches) / float(lena + lenb)
    return score
