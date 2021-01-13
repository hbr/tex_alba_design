.PHONY: doc coq sphinx


doc:
	pdflatex main_alba_design.tex


%.vo: %.v
	coqc $<

sphinx:
	make -C sphinx html

coq: unbounded_search.vo hoare_state_monad.vo
