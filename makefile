.PHONY: doc coq


doc:
	pdflatex main_alba_design.tex


%.vo: %.v
	coqc $<

coq: unbounded_search.vo
