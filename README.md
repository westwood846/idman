# idman

Usage: `./idman GIT_REPO_FOLDER [ALGORITHM ARGS...]`.

Will perform the given identity merge `ALGORITHM` (optionally with additional
`ARGS`) on the given `GIT_REPO_FOLDER` and output the author, committer and
signer of every commit in that repository according to the merged identities.
If no `ALGORITHM` is given, the default one is used.


## Requirements

* git (obviously)

* perl (git depends on this, so you probably have it already)

* Python 2

* networkx, a graph library for Python


## Output

See [sample-output.json](sample-output.json) for an example. It's the output
for this here repository.

The idman output will be a JSON object. It contains the following keys:

#### `identities`

An array of identities, each representing an individual contributor. Each
identity is a list of identifiers, such as usernames and e-mail addresses.

#### `commits`

An object representing all commits in the repository, keyed by their hash. Each
individual commit contains the following keys:

##### `author`

##### `committer`

##### `signer`

These values are integers referring to indexes in the `identities` array, or
null if no such association exists. Use these to tell who authored, committed
or signed this particular commit.

##### `author_name`

##### `author_mail`

##### `committer_name`

##### `committer_mail`

##### `signer`

These are the raw names and e-mails from git. Don't use these for
identification, they are raw and the identities aren't merged! Use `author`,
`committer` and `signer` instead.

##### `repo`

The path to the repository's local folder. If you want to run further git
commands on it, you might need to append `/.git` to it.

##### `hash`

The commit's sha-1 hash.

##### `author_date`

The date that the commit was authored as a Unix timestamp. Note that this is a
string of digits, not an integer.

##### `committer_date`

The date that the commit was committed.

##### `subject`

The commit message subject line.

##### `body`

The rest of the commit message.

##### `notes`

The notes attached to the commit. Basically a message in addition to the
regular commit message.

##### `signer_key`

The signature key of who signed the commit.

##### `touched_files`

##### `insertions`

##### `deletions`

The amount of modified files, inserted lines and deleted lines in the commit,
respectively. Renamed files are taken into account properly, so a rename on
its own counts as a single changed file with zero inserted or deleted lines.

See the `--find-renames` and `--find-copies` options in `git log --help` for
details.


## Structure

[idman](idman) is the controller that executes all the pieces in [lib](lib) and
pipes them together properly.

[parseman](lib/parseman) gathers all commit information from git and spews out
a JSON object for each of them on stdout.

[graphman](lib/graph/graphman) does the identity merging from the commit
information it receives from [parseman](lib/parseman). It can pick from various
[identity merging algorithms](lib/graph/algorithm).

[assocman](lib/assocman) receives the results from
[graphman](lib/graph/graphman) and the raw commit information from
[parseman](lib/parseman) and associates the two, producing the final output. If
the algorithm is bad and results in ambiguous associations, assocman will die.


## Algorithms

### occurrence

Connects nodes in the graph if they contain the same identifier.

### default

Like occurrence, but ignores case and strips off `.(none)` at the end of e-mail
addresses, which git seems to randomly attach and remove if the e-mail doesn't
contain a dot.

As the name implies, this is the default algorithm.

### lazy

Does nothing and treats every identifier as its own identity. This is just to
explain how to write algorithms, it's useless otherwise.

### retarded-occurence

Like occurrence but without distinction between committer, author and signer.

### wordsimilarity

Like occurrence but additionally connects nodes if identifiers are similar according to a [statistical metric](lib/graph/statistical).

## Papers

* **A Comparison of Identity Merge Algorithms for Software Repositories** (<https://www.academia.edu/1192857/A_Comparison_of_Identity_Merge_Algorithms_for_Software_Repositories>, <http://www.sciencedirect.com/science/article/pii/S0167642311002048>,<https://www.researchgate.net/profile/Mathieu_Goeminne/publication/228728261_A_Comparison_of_Identity_Merge_Algorithms_for_Software_Repositories/links/02e7e51bed223387c5000000.pdf>)

* **Who’s who in GNOME: using LSA to merge software repository identities** (<https://bvasiles.github.io/papers/era12.pdf>)

* **Maispion: A Tool for Analysing and Visualising Open Source Software Developer Communities** (<http://www.esug.org/data/ESUG2009/IWST/iwst09_submission_11.pdf>)

* **A Comparison of Personal Name Matching: Techniques and Practical Issues** (<http://ieeexplore.ieee.org/xpl/login.jsp?tp=&arnumber=4063641> hoffentlich,<https://www.researchgate.net/profile/Peter_Christen2/publication/215992032_A_comparison_of_personal_name_matching_Techniques_and_practical_issues/links/0912f51156bfb7909d000000.pdf>)

* **Developer identication methods for integrated data from various sources** (<http://2005.msrconf.org/papers/23.pdf>)

* **On the Need of Graph Support for Developer Identification in Software Repositories** (<http://www.kde.cs.uni-kassel.de/conf/lwa10/papers/kdml23.pdf>)

* **Mining Email Social Networks** (<http://macbeth.cs.ucdavis.edu/msr06.pdf>)

* **A Comparison of String Distance Metrics for Name-Matching Tasks** (<http://dc-pubs.dbs.uni-leipzig.de/files/Cohen2003Acomparisonofstringdistance.pdf>)
