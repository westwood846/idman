from Algorithm import Algorithm
import perl
perl.use('Text::Levenshtein::XS')


class Similarity(Algorithm):

    distance = perl.eval('\&Text::Levenshtein::XS::distance')


    def __init__(self, *args):
        # TODO parse the threshold from args instead
        self.threshold = 0.9


    def artifacts_equal(self, a1, a2):
        nls = 1.0 - float(self.distance(a1, a2)) / max(len(a1), len(a2))
        return nls >= self.threshold
