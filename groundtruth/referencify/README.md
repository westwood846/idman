# Referencify

Grounding the truth, one artifact at a time.


## Usage

* Install `carton` via your package manager.

* Run `carton install`.

* Clone your favorite repository, let's call it `floop`.

* Run `carton exec script/identify path/to/floop`, which will run idman and throw the results into `data/floop.json`.

* Run `carton exec script/separate floop` to twiddle the idman results into a bunch of separate files into `data/floop/work` and `data/floop/done`.

* Run `carton exec morbo referencify` to run the development server.

* Point your browser at <http://localhost:3000/> and enjoy.
