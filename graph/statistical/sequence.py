def calc_similarity(w1, w2):
    return SequenceMatcher(None, w1, w2).ratio()
