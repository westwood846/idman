presentation.pdf: presentation.tex $(wildcard img/*)
	pdflatex presentation.tex
	pdflatex presentation.tex

handout:
	perl -i -pe '$$_ = "\\documentclass[slidestop,usenames,dvipsnames,handout]{beamer}\n" if $$. == 1' presentation.tex

final:
	perl -i -pe '$$_ = "\\documentclass[slidestop,usenames,dvipsnames]{beamer}\n" if $$. == 1' presentation.tex

clean:
	rm -f presentation.log presentation.aux presentation.nav \
	      presentation.out presentation.snm presentation.toc \
	      presentation.vrb

realclean: clean
	rm -f presentation.pdf

.PHONY: clean realclean handout final
