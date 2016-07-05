build: paper.tex paper.bib Makefile
	pdflatex paper
	bibtex paper
	pdflatex paper
	pdflatex paper

clean:
	rm -f *~
	rm -f *.aux
	rm -f *.log
	rm -f *.toc
	rm -f *.blg
	rm -f *.bbl
	rm -f paper.ps
	rm -f *.out
	rm -f *.out
	rm -f *.bak
	rm -f *stackdump*

realclean: clean
	rm -f paper.pdf
