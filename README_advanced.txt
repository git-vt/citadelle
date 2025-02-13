This directory contains the detailed AFP submission of the
"Featherweight OCL" semantics for OCL as well as our proposal
for Appendix A of the OCL standard.

Beyond the standard mechanism 

(* < *)
<<skipped isar text, not shown in doc >>
(* > *)

The two main targets of this Isabelle project are:
- check everything and generate all documents allowing "sorry"'s, i.e., 
  using Isabelles "quick-and-dirty"-mode:

  isabelle build -c -d . -v -b OCL-dirty

- check everything and generate all documents, ensuring that
   no "sorry"'s are used:

   isabelle build -c -d . -v -b OCL

In your LaTeX text, you can use the following two PlainTeX
environments for selecting in which version your text should
appear:

\isatagafp
  This text will only be visible in the AFP submission, i.e.,
  document.pdf and outline.pdf.
\endisatagafp

\isatagannexa
  This text will only be visible in the Annex A, i.e., annex-a.pdf.
\endisatagannexa


Note that these tags only work within regular Isabelle/Isar "text"
commands if they are complete, i.e.:

  text {* ... \isatagafp ... \endisatagafp ...*}

Only opening or closing such a tag in Isabelle/Isar "text" commands
will not work. For this, you need to use the "text_raw" command:

  text_raw {* \isatagafp *}
  ...
  text_raw {* \endisatagafp *}


For working, these tags rely on the file comment.sty, which
is automatically added by Isabelle during the document generation.
However at the time of writing, the current comment.sty included by
Isabelle (version 3.6) mentions:
  "The opening and closing commands should appear on a line
   of their own. No starting spaces, nothing after it."
In particular, it is not advised to put these tags in a single line:
\isatagafp ... \endisatagafp % wrong
otherwise as side effects some parts occuring after these tags may be
skipped. The recommanded solution is to always write each tag in a
separate line:
\isatagafp
  ...
\endisatagafp


Warning:
=======
Please check twice that you are using \isatagX and \endisatagX
properly, i.e.,
- always pairwise matching
- not separating other envirments.
Not using these PlainTeX environments (which are, generally,
obsolete and discouraged but used by the Isabelle LaTeX setup
anyhow. We only use them to avoid introducing a parallel setup to
the one that we cannot avoid due to design decisions by the
Isabelle maintainer) carefully, will result in LaTeX errors that
are close to not debug-able.


List of Isabelle versions to use depending on revisions:
=========================================================
2018/01/29 revision 13259: Isabelle2016-1 (December 2016)
2016/02/22 revision 12439: Isabelle2016   (February 2016)
2015/06/11 revision 11691: Isabelle2015   (May      2015)
2015/02/02 revision 11283: Isabelle2014   (August   2014)
2013/12/05 revision 10054: Isabelle2013-2 (December 2013)
2013/12/02 revision 10013: Isabelle2013-1 (November 2013)
2013/11/14 revision  9950: Isabelle2013   (February 2013)
2013/05/27 revision  9682: Isabelle2012   (May      2012)
(* 2013/03/27 revision  9616 *)
           revision     ?: Isabelle2011-1 (October  2011)
