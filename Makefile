
VERSION=0.1

all: homepage isa2 eisa ExpressionView

.PHONY: homepage isa2 eisa ExpressionView clean

clean: 
	bzr clean-tree --force
	bzr clean-tree --ignored --force

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

isa2/inst/doc/ISA_tutorial.pdf: vignettes/ISA_tutorial.pdf
	cp $< $@

vignettes/ISA_tutorial.pdf: vignettes/ISA_tutorial.tex
	cd vignettes && pdflatex ISA_tutorial.tex && pdflatex ISA_tutorial.tex && \
		pdflatex ISA_tutorial.tex

vignettes/ISA_parallel.tex: $(ISA2FILES) vignettes/ISA_parallel.Rnw
	R CMD build --no-vignettes isa2
	R CMD INSTALL -l /tmp/ isa2_$(VERSION).tar.gz
	cd vignettes && R_LIBS=/tmp/ R CMD Sweave ISA_parallel.Rnw || rm ISA_parallel.tex

isa2/inst/doc/ISA_parallel.vignette: vignettes/ISA_parallel.Rnw
	cp $< $@

isa2/inst/doc/ISA_parallel.pdf: vignettes/ISA_parallel.pdf
	cp $< $@

vignettes/ISA_parallel.pdf: vignettes/ISA_parallel.tex
	cd vignettes && pdflatex ISA_parallel.tex && pdflatex ISA_parallel.tex \
		&& pdflatex ISA_parallel.tex

# eisa

EISAFILES = eisa/DESCRIPTION eisa/NAMESPACE eisa/R/*.R eisa/man/*.Rd \
	eisa/inst/CITATION

EISAVIGNETTES = eisa/inst/doc/EISA_tutorial.vignette eisa/inst/doc/EISA_tutorial.pdf

eisa: eisa_$(VERSION).tar.gz

eisa_$(VERSION).tar.gz:	$(EISAFILES) $(EISAVIGNETTES)
	R CMD build eisa

vignettes/EISA_tutorial.tex: $(EISAFILES) vignettes/EISA_tutorial.Rnw
	R CMD build --no-vignettes isa2
	R CMD build --no-vignettes eisa
	R CMD INSTALL -l /tmp/ isa2_$(VERSION).tar.gz
	R CMD INSTALL -l /tmp/ eisa_$(VERSION).tar.gz
	cd vignettes && R_LIBS=/tmp/ R CMD Sweave EISA_tutorial.Rnw || rm EISA_tutorial.tex

eisa/inst/doc/EISA_tutorial.vignette: vignettes/EISA_tutorial.Rnw
	cp $< $@

eisa/inst/doc/EISA_tutorial.pdf: vignettes/EISA_tutorial.pdf
	cp $< $@

vignettes/EISA_tutorial.pdf: vignettes/EISA_tutorial.tex
	cd vignettes && pdflatex EISA_tutorial.tex && pdflatex EISA_tutorial.tex && \
		pdflatex EISA_tutorial.tex

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

ALIVEPDFFILES=	ExpressionView/src/org/alivepdf/annotations/AnnotationHighlight.as \
		ExpressionView/src/org/alivepdf/annotations/AttachFileStyle.as \
		ExpressionView/src/org/alivepdf/annotations/StampStyle.as \
		ExpressionView/src/org/alivepdf/cells/CellVO.as \
		ExpressionView/src/org/alivepdf/colors/CMYKColor.as \
		ExpressionView/src/org/alivepdf/colors/Color.as \
		ExpressionView/src/org/alivepdf/colors/GrayColor.as \
		ExpressionView/src/org/alivepdf/colors/IColor.as \
		ExpressionView/src/org/alivepdf/colors/RGBColor.as \
		ExpressionView/src/org/alivepdf/data/Grid.as \
		ExpressionView/src/org/alivepdf/data/GridColumn.as \
		ExpressionView/src/org/alivepdf/display/Display.as \
		ExpressionView/src/org/alivepdf/display/PageMode.as \
		ExpressionView/src/org/alivepdf/drawing/Blend.as \
		ExpressionView/src/org/alivepdf/drawing/Caps.as \
		ExpressionView/src/org/alivepdf/drawing/DashedLine.as \
		ExpressionView/src/org/alivepdf/drawing/Joint.as \
		ExpressionView/src/org/alivepdf/drawing/WindingRule.as \
		ExpressionView/src/org/alivepdf/encoding/Base64.as \
		ExpressionView/src/org/alivepdf/encoding/BitString.as \
		ExpressionView/src/org/alivepdf/encoding/IntBlock.as \
		ExpressionView/src/org/alivepdf/encoding/IntList.as \
		ExpressionView/src/org/alivepdf/encoding/JPEGEncoder.as \
		ExpressionView/src/org/alivepdf/encoding/PNGEncoder.as \
		ExpressionView/src/org/alivepdf/events/PageEvent.as \
		ExpressionView/src/org/alivepdf/events/PagingEvent.as \
		ExpressionView/src/org/alivepdf/events/ProcessingEvent.as \
		ExpressionView/src/org/alivepdf/fonts/CoreFonts.as \
		ExpressionView/src/org/alivepdf/fonts/FontFamily.as \
		ExpressionView/src/org/alivepdf/fonts/FontType.as \
		ExpressionView/src/org/alivepdf/fonts/Style.as \
		ExpressionView/src/org/alivepdf/html/HTMLTag.as \
		ExpressionView/src/org/alivepdf/images/GIFImage.as \
		ExpressionView/src/org/alivepdf/images/IImage.as \
		ExpressionView/src/org/alivepdf/images/ImageFormat.as \
		ExpressionView/src/org/alivepdf/images/ImageHeader.as \
		ExpressionView/src/org/alivepdf/images/JPEGImage.as \
		ExpressionView/src/org/alivepdf/images/PDFImage.as \
		ExpressionView/src/org/alivepdf/images/PNGImage.as \
		ExpressionView/src/org/alivepdf/images/ResizeMode.as \
		ExpressionView/src/org/alivepdf/layout/Align.as \
		ExpressionView/src/org/alivepdf/layout/Format.as \
		ExpressionView/src/org/alivepdf/layout/Layout.as \
		ExpressionView/src/org/alivepdf/layout/Orientation.as \
		ExpressionView/src/org/alivepdf/layout/Size.as \
		ExpressionView/src/org/alivepdf/layout/Unit.as \
		ExpressionView/src/org/alivepdf/metrics/FontMetrics.as \
		ExpressionView/src/org/alivepdf/pages/Page.as \
		ExpressionView/src/org/alivepdf/pdf/PDF.as \
		ExpressionView/src/org/alivepdf/saving/Download.as \
		ExpressionView/src/org/alivepdf/saving/Method.as \
		ExpressionView/src/org/alivepdf/tools/sprintf.as \
		ExpressionView/src/org/alivepdf/transitions/Dimension.as \
		ExpressionView/src/org/alivepdf/transitions/MotionDirection.as \
		ExpressionView/src/org/alivepdf/transitions/Transition.as \
		ExpressionView/src/org/alivepdf/transitions/TransitionDirection.as \
		ExpressionView/src/org/alivepdf/viewing/CenterWindow.as \
		ExpressionView/src/org/alivepdf/viewing/Direction.as \
		ExpressionView/src/org/alivepdf/viewing/FitWindow.as \
		ExpressionView/src/org/alivepdf/viewing/MenuBar.as \
		ExpressionView/src/org/alivepdf/viewing/Title.as \
		ExpressionView/src/org/alivepdf/viewing/ToolBar.as \
		ExpressionView/src/org/alivepdf/viewing/WindowUI.as
ALIVEPDFCLASSES = $(subst ExpressionView.src.,,$(subst /,.,$(basename $(ALIVEPDFFILES))))

alivepdf: ExpressionView/libs/alivepdf.swc

ExpressionView/libs/alivepdf.swc: $(ALIVEPDFFILES)
	cd ExpressionView/src/
	compc -source-path ExpressionView/src -include-classes $(ALIVEPDFCLASSES) -output $@

RExpressionView/inst/ExpressionView.swf: $(EVFILES) alivepdf
	cd ExpressionView/src && \
		mxmlc -compiler.library-path+=../libs/AlivePDF.swc \
			-use-network=false ExpressionView.mxml \
			-target-player=10
	cp ExpressionView/src/$(@F) $(@)

ExpressionView_$(VERSION).tar.gz: $(REVFILES) $(REVVIGNETTES)
	R CMD build RExpressionView

vignettes/ExpressionView.tex: $(REVFILES) vignettes/ExpressionView.Rnw
	R CMD build --no-vignettes isa2
	R CMD build --no-vignettes eisa
	R CMD build --no-vignettes RExpressionView
	R CMD INSTALL -l /tmp/ isa2_$(VERSION).tar.gz
	R CMD INSTALL -l /tmp/ eisa_$(VERSION).tar.gz
	R CMD INSTALL -l /tmp/ ExpressionView_$(VERSION).tar.gz
	cd vignettes && R_LIBS=/tmp/ R CMD Sweave ExpressionView.Rnw || rm ExpressionView.tex

RExpressionView/inst/doc/ExpressionView.vignette: vignettes/ExpressionView.Rnw
	cp $< $@

RExpressionView/inst/doc/ExpressionView.pdf: vignettes/ExpressionView.pdf
	cp $< $@

vignettes/ExpressionView.pdf: vignettes/ExpressionView.tex
	cd vignettes && pdflatex ExpressionView.tex && pdflatex ExpressionView.tex && \
		pdflatex ExpressionView.tex
	cp vignettes/ExpressionView.pdf RExpressionView/inst/doc/

############################################
## Homepage

SWEAVE2HTML = htlatex
SWEAVE2HTMLOPTIONS = style,xhtml,graphics-,charset=utf-8 " -cunihtf -utf8" -cvalidate

.PHONY: htmlfiles vignettes

homepage: vignettes htmlfiles

htmlfiles: homepage/*.in
	cd homepage && ./generate.py

vignettes: homepage/ISA_tutorial.html homepage/ISA_tutorial.pdf \
	homepage/ISA_parallel.html homepage/ISA_parallel.pdf \
	homepage/EISA_tutorial.html homepage/EISA_tutorial.pdf \
	homepage/ExpressionView.html homepage/ExpressionView.pdf \
	vignettes/style.cfg

homepage/ISA_tutorial.html: vignettes/ISA_tutorial.tex
	cd vignettes && $(SWEAVE2HTML) ISA_tutorial $(SWEAVE2HTMLOPTIONS)
	cp vignettes/ISA_tutorial.html homepage
	cp vignettes/ISA_tutorial.css homepage
	cp vignettes/ISA_tutorial*.png homepage/
	cp vignettes/graphics/*.png homepage/graphics/

homepage/ISA_tutorial.pdf: vignettes/ISA_tutorial.pdf
	cp $< $@

homepage/ISA_parallel.html: vignettes/ISA_parallel.tex
	cd vignettes && $(SWEAVE2HTML) ISA_parallel $(SWEAVE2HTMLOPTIONS)
	cp vignettes/ISA_parallel.html homepage
	cp vignettes/ISA_parallel.css homepage
#	cp vignettes/ISA_parallel*.png homepage/
	cp vignettes/graphics/*.png homepage/graphics/

homepage/ISA_parallel.pdf: vignettes/ISA_parallel.pdf
	cp $< $@

homepage/EISA_tutorial.html: vignettes/EISA_tutorial.tex
	cd vignettes && $(SWEAVE2HTML) EISA_tutorial $(SWEAVE2HTMLOPTIONS)
	cp vignettes/EISA_tutorial.html homepage
	cp vignettes/EISA_tutorial.css homepage
	cp vignettes/EISA_tutorial*.png homepage/
	cp vignettes/graphics/*.png homepage/graphics/

homepage/EISA_tutorial.pdf: vignettes/EISA_tutorial.pdf
	cp $< $@

homepage/ExpressionView.html: vignettes/ExpressionView.tex
	cd vignettes && $(SWEAVE2HTML) ExpressionView $(SWEAVE2HTMLOPTIONS)
	cp vignettes/ExpressionView.html homepage
	cp vignettes/ExpressionView.css homepage
#	cp vignettes/ExpressionView*.png homepage/
	cp vignettes/graphics/*.png homepage/graphics/

homepage/ExpressionView.pdf: vignettes/ExpressionView.pdf
	cp $< $@
