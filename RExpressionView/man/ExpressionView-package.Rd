\docType{package}
\encoding{UTF-8}
\name{ExpressionView-package}
\alias{ExpressionView-package}
\title{The ExpressionView package}
\description{A package designed to interactively explore biclusters
  identified in gene expression data.
}
\section{Introduction}{
  Clustering genes according to their expression profiles is an important
  task in analyzing microarray data. ExpressionView allows the user to 
  explore the biclusters together with the underlying data in an
  interactive environment. The applet requires a browser with Adobe Flash
  player 10 installed.

  The ExpressionView package can treat gene expression data in the form of
  a Bioconductor \code{\link[Biobase]{ExpressionSet}}. It recognizes
  biclusters identified by the Iterative Signature Algorithm (ISA)
  implemented in the \code{\link[eisa]{ISA}} package as well as the
  methods available in the \code{\link[biclust]{biclust}} package.
}
\section{Worflow}{
  The usual workflow consist of three steps:
  \describe{
    \item{Order}{
      To arrange the possibly overlapping biclusters in a visually
      appealing layout, the gene expression data has to be reordered in such
      a way that individual biclusters from contiguous rectangles. The
      optimal order is found by the \code{\link{OrderEV}} function.} 
    \item{Export}{In a second step, the biclusters and all the relevant
      biological information are combined and exported to an ExpressionView
      XML file. This is done by the \code{\link{ExportEV}} function.} 
    \item{Visualize}{
      The Flash applet is started by the \code{\link{LaunchEV}}
      command. Video tutorials describing the various features of the
  applet can be found on the ExpressionView website
  (\url{http://www.unil.ch/cbg/ExpressionView}).
    }
  }
  A tutorial can be found in the accompanying vignette of the package.
}
\section{Biclustering with non-gene expression data}{
  Both, the \code{\link[eisa]{ISA}} and the biclustering methods
  implemented in the \code{\link[biclust]{biclust}} package can treat any
  two-dimensional data, i.e., not necessarily originating from gene
  expression profiling. While the ExpressionView package is optimized for
  gene expression matrices, it is also possible to explore data stemming
  from other sources. For more information, see the description of the
  \code{\link{ExportEV}} function. 
}
\author{Andreas \enc{Lüscher}{Luscher}
  \email{andreas.luescher@a3.epfl.ch}} 
\seealso{\code{\link{OrderEV}}, \code{\link{ExportEV}} and
  \code{\link{LaunchEV}}}
\keyword{cluster}