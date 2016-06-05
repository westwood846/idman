from difflib import SequenceMatcher

def calc_similarity(w1, w2):
    return SequenceMatcher(None, w1, w2).quick_ratio()
