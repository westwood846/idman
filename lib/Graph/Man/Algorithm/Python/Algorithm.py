class Algorithm(object):

    def __init__(self, *args):
        pass


    def process_artifacts(self, *artifacts):
        return artifacts;


    def should_merge(self, id1, id2):
        for a1 in id1:
            for a2 in id2:
                if self.artifacts_equal(a1, a2):
                    return True
        return False


    def artifacts_equal(self, a1, a2):
        return a1 == a2
