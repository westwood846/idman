# coding=utf-8


# removes falsy values from dictionary
def clean_dict(dict1):
    """

    :param dict1:
    :return:
    """
    return {k: v for (k, v) in dict1.iteritems() if v}


#  removes all values from dict for which function does not return true
def filter_values(dict1, function):
    """

    :param dict1:
    :param function:
    :return:
    """
    return {k: v for (k, v) in dict1.iteritems() if function(v)}


# removes all keys from dict for which function does not return true
def filter_keys(dict1, function):
    """

    :param dict1:
    :param function:
    :return:
    """
    return {k: v for (k, v) in dict1.iteritems() if function(k)}


# removes all keys from the dictionary wich contain a certain keyword (in strict mode equality is checked)
def remove_certain_keys(dict1, keyword, strict=False):
    """

    :param dict1:
    :param keyword:
    :param strict:
    :return:
    """
    if strict:
        return filter_keys(dict1, lambda x: not keyword == x)
    else:
        return filter_keys(dict1, lambda x: keyword not in x)


# gets all keys from the dictionary wich contain a certain keyword (in strict mode equality is checked)
def get_certain_keys(dict1, keyword, strict=False):
    """

    :param dict1:
    :param keyword:
    :param strict:
    :return:
    """
    if strict:
        return filter_keys(dict1, lambda x: keyword == x)
    else:
        return filter_keys(dict1, lambda x: keyword in x)


def remove_author(commit):
    """

    :param commit:
    :return:
    """
    return remove_certain_keys(commit, "author")


def remove_committer(commit):
    """

    :param commit:
    :return:
    """
    return remove_certain_keys(commit, "committer")


def remove_signer(commit):
    """

    :param commit:
    :return:
    """
    return remove_certain_keys(commit, "signer")


# removes falsy values from list
def clean_list(l):
    """

    :param l:
    :return:
    """
    return [x for x in l if x]


#  removes all elements from list for which function does not return true
def filter_list(list1, function):
    """

    :param list1:
    :param function:
    :return:
    """
    return [v for v in list1 if function(v)]
