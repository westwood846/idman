# Referencify

Grounding the truth, one artifact at a time.

This web application lets us build up a reference identity list for our
repositories using similar methods to [Bird et al. in the paper “Mining Email
social networks”](http://macbeth.cs.ucdavis.edu/msr06.pdf). We use their
algorithm with a low word similarity threshold of 0.7, which has shown itself
to be the limit before all artifacts in a repository get merged into the same
identity.

The resulting list of identities has a lot of false positives, which need to be
manually separated, which is easier than finding connections in the first place
according to Bird et al. Due to the low word similarity threshold and the many
ways that the algorithm connects words, there is hopefully no false negatives.


## Usage

* Install `carton` via your package manager.

* Run `carton install`.

* Clone your favorite repository, let's call it `floop`.

* Run `carton exec script/identify path/to/floop`, which will run idman and
  throw the results into `data/floop.json`.

* Run `carton exec script/separate floop` to twiddle the idman results into a
  bunch of separate files into `data/floop/work` and `data/floop/done`.

* Run `carton exec morbo referencify` to run the development server.

* Point your browser at <http://localhost:3000/>.

* Sort the artifacts correctly by dragging them into the boxes. Double-clicking
  shoves an artifact into a new box.

* Once you're done, run `carton exec script/recombine` to reconstruct the
  identity list into the `results` folder.
