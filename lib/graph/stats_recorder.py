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
        if commit["author_mail"]:       self.author_mails.add(commit["author_mail"])
        if commit["author_name"]:       self.author_names.add(commit["author_name"])
        if commit["committer_mail"]:    self.committer_mails.add(commit["committer_mail"])
        if commit["committer_name"]:    self.committer_names.add(commit["committer_name"])
        if commit["signer"]:            self.signers.add(commit["signer"])
        if commit["signer_key"]:        self.signer_keys.add()
        self.commits += 1
