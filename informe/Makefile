PROJECT= informe
TEX= pdflatex
BUILDTEX= $(TEX) $(PROJECT).tex

.PHONY: informe.pdf
	clean

informe.pdf: informe.tex
	$(BUILDTEX)

clean-all:
	rm -f *.dvi *.log *.bak *.aux *.bbl *.blg *.idx *.ps *.eps *.pdf *.toc *.out *~

clean:
	rm -f *.log *.bak *.aux *.bbl *.blg *.idx *.toc *.out *~
