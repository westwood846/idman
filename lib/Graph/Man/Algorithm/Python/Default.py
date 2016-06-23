from Algorithm import Algorithm
import re


class Default(Algorithm):

    rx = re.compile(r'\.?\(none\)$');

    def process_artifacts(self, *artifacts):
        def process(artifact):
            return self.rx.sub(artifact.lower(), '')
        return map(process, artifacts)
