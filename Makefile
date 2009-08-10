
VERSION=0.1

all: homepage isa2 eisa ExpressionView

.PHONY: homepage isa2 eisa ExpressionView

####################################################
## R packages

# isa2

isa2: isa2_$(VERSION).tar.gz

ISA2FILES = isa2/DESCRIPTION isa2/LICENCE isa2/NAMESPACE isa2/R/*.R isa2/man/*.Rd \
	isa2/src/*.c isa2/inst/CITATION 

ISA2VIGNETTES = isa2/inst/doc/ISA_tutorial.vignette \
	isa2/inst/doc/ISA_tutorial.pdf isa2/inst/doc/ISA_parallel.vignette \
	isa2/inst/doc/ISA_parallel.pdf

isa2_$(VERSION).tar.gz: $(ISA2FILES) $(ISA2VIGNETTES)
	R CMD build isa2

vignettes/ISA_tutorial.tex: $(ISA2FILES) vignettes/ISA_tutorial.Rnw
	R CMD build --no-vignettes isa2
	R CMD INSTALL -l /tmp/ isa2_$(VERSION).tar.gz
	cd vignettes && R_LIBS=/tmp/ R CMD Sweave ISA_tutorial.Rnw || rm ISA_tutorial.tex

isa2/inst/doc/ISA_tutorial.vignette: vignettes/ISA_tutorial.Rnw
	cp $< $@

isa2/inst/doc/ISA_tutorial.pdf: vignettes/ISA_tutorial.tex
	cd vignettes && pdflatex ISA_tutorial.tex && pdflatex ISA_tutorial.tex && \
		pdflatex ISA_tutorial.tex
	cp vignettes/ISA_tutorial.pdf isa2/inst/doc/

vignettes/ISA_parallel.tex: $(ISA2FILES) vignettes/ISA_parallel.Rnw
	R CMD build --no-vignettes isa2
	R CMD INSTALL -l /tmp/ isa2_$(VERSION).tar.gz
	cd vignettes && R_LIBS=/tmp/ R CMD Sweave ISA_parallel.Rnw || rm ISA_parallel.tex

isa2/inst/doc/ISA_parallel.vignette: vignettes/ISA_parallel.Rnw
	cp $< $@

isa2/inst/doc/ISA_parallel.pdf: vignettes/ISA_parallel.tex
	cd vignettes && pdflatex ISA_parallel.tex && pdflatex ISA_parallel.tex \
		&& pdflatex ISA_parallel.tex
	cp vignettes/ISA_parallel.pdf isa2/inst/doc/

# eisa

EISAFILES = eisa/DESCRIPTION eisa/NAMESPACE eisa/R/*.R eisa/man/*.Rd \
	eisa/inst/CITATION

EISAVIGNETTES = eisa/inst/doc/EISA_tutorial.vignette eisa/inst/doc/EISA_tutorial.pdf

eisa: eisa_$(VERSION).tar.gz

eisa_$(VERSION).tar.gz:	$(EISAFILES) $(EISAVIGNETTES)
	R CMD build eisa

vignettes/EISA_tutorial.tex: $(EISAFILES) vignettes/EISA_tutorial.Rnw
	R CMD build --no-vignettes eisa
	R CMD INSTALL -l /tmp/ eisa_$(VERSION).tar.gz
	cd vignettes && R_LIBS=/tmp/ R CMD Sweave EISA_tutorial.Rnw || rm EISA_tutorial.tex

eisa/inst/doc/EISA_tutorial.vignette: vignettes/EISA_tutorial.Rnw
	cp $< $@

eisa/inst/doc/EISA_tutorial.pdf: vignettes/EISA_tutorial.tex
	cd vignettes && pdflatex EISA_tutorial.tex && pdflatex EISA_tutorial.tex && \
		pdflatex EISA_tutorial.tex
	cp vignettes/EISA_tutorial.pdf eisa/inst/doc/

# ExpressionView

ExpressionView: ExpressionView_$(VERSION).tar.gz

EVFILES=ExpressionView/src/ch/unil/cbg/ExpressionView/*/*	\
	ExpressionView/src/ExpressionView.mxml

REVFILES=RExpressionView/inst/ExpressionView.swf	\
	RExpressionView/inst/ExpressionView.html		\
	RExpressionView/DESCRIPTION 				\
	RExpressionView/NAMESPACE				\
	RExpressionView/R/*.R RExpressionView/man/*.Rd 		\
	RExpressionView/src/*.h RExpressionView/src/*.cpp 	\
	RExpressionView/inst/CITATION

REVVIGNETTES=RExpressionView/inst/doc/ExpressionView.vignette \
	RExpressionView/inst/doc/ExpressionView.pdf

RExpressionView/inst/ExpressionView.swf: $(EVFILES)
	cd ExpressionView/src && \
		mxmlc -compiler.library-path+=../libs/flexlib.swc,../libs/AlivePDF.swc \
			-use-network=false ExpressionView.mxml
	cp ExpressionView/src/$(@F) $(@)

ExpressionView_$(VERSION).tar.gz: $(REVFILES) $(REVVIGNETTES)
	R CMD build RExpressionView

vignettes/ExpressionView.tex: $(REVFILES) vignettes/ExpressionView.Rnw
	R CMD build --no-vignettes RExpressionView
	R CMD INSTALL -l /tmp/ ExpressionView_$(VERSION).tar.gz
	cd vignettes && R_LIBS=/tmp/ R CMD Sweave ExpressionView.Rnw || rm ExpressionView.tex

RExpressionView/inst/doc/ExpressionView.vignette: vignettes/ExpressionView.Rnw
	cp $< $@

RExpressionView/inst/doc/ExpressionView.pdf: vignettes/ExpressionView.tex
	cd vignettes && pdflatex ExpressionView.tex && pdflatex ExpressionView.tex && \
		pdflatex ExpressionView.tex
	cp vignettes/ExpressionView.pdf RExpressionView/inst/doc/

############################################
## Homepage

.PHONY: htmlfiles vignettes

homepage: vignettes # htmlfiles

htmlfiles: homepage/*.in
	cd homepage && ./generate.py

vignettes: homepage/ISA_tutorial.html homepage/ISA_tutorial.pdf \
	homepage/ISA_parallel.html homepage/ISA_parallel.pdf \
	homepage/EISA_tutorial.html homepage/EISA_tutorial.pdf \
	homepage/ExpressionView.html homepage/ExpressionView.pdf

homepage/ISA_tutorial.html: vignettes/ISA_tutorial.tex
	cd vignettes && sweave2html ISA_tutorial
	cp vignettes/ISA_tutorial.html homepage
	cp vignettes/graphics/*.png homepage/graphics/

homepage/ISA_tutorial.pdf: vignettes/ISA_tutorial.pdf
	cp $< $@

homepage/ISA_parallel.html: vignettes/ISA_parallel.tex
	cd vignettes && sweave2html ISA_parallel
	cp vignettes/ISA_parallel.html homepage
	cp vignettes/graphics/*.png homepage/graphics/

homepage/ISA_parallel.pdf: vignettes/ISA_parallel.pdf
	cp $< $@

homepage/EISA_tutorial.html: vignettes/EISA_tutorial.tex
	cd vignettes && sweave2html EISA_tutorial
	cp vignettes/EISA_tutorial.html homepage
	cp vignettes/graphics/*.png homepage/graphics/

homepage/EISA_tutorial.pdf: vignettes/EISA_tutorial.pdf
	cp $< $@

homepage/ExpressionView.html: vignettes/ExpressionView.tex
	cd vignettes && sweave2html ExpressionView
	cp vignettes/ExpressionView.html homepage
	cp vignettes/graphics/*.png homepage/graphics/

homepage/ExpressionView.pdf: vignettes/ExpressionView.pdf
	cp $< $@



