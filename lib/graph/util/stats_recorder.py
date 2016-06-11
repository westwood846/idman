class StatsRecorder:
    def __init__(self):
        self.commits = 0
        self.author_mails = set()
        self.author_names = set()
        self.committer_mails = set()
        self.committer_names = set()
        self.signers = set()
        self.signer_keys = set()

    def record_commit(self, commit):
        if commit.get("author_mail", None):       self.author_mails.add(commit["author_mail"])
        if commit.get("author_name", None):       self.author_names.add(commit["author_name"])
        if commit.get("committer_mail", None):    self.committer_mails.add(commit["committer_mail"])
        if commit.get("committer_name", None):    self.committer_names.add(commit["committer_name"])
        if commit.get("signer", None):            self.signers.add(commit["signer"])
        if commit.get("signer_key", None):        self.signer_keys.add(commit["signer_key"])
        self.commits += 1
