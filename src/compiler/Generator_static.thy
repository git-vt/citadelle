(******************************************************************************
 * Featherweight-OCL --- A Formal Semantics for UML-OCL Version OCL 2.5
 *                       for the OMG Standard.
 *                       http://www.brucker.ch/projects/hol-testgen/
 *
 * Generator_static.thy ---
 * This file is part of HOL-TestGen.
 *
 * Copyright (c) 2011-2018 Université Paris-Saclay, Univ. Paris-Sud, France
 *               2013-2017 IRT SystemX, France
 *               2011-2015 Achim D. Brucker, Germany
 *               2016-2018 The University of Sheffield, UK
 *               2016-2017 Nanyang Technological University, Singapore
 *               2017-2018 Virginia Tech, USA
 *
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are
 * met:
 *
 *     * Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer.
 *
 *     * Redistributions in binary form must reproduce the above
 *       copyright notice, this list of conditions and the following
 *       disclaimer in the documentation and/or other materials provided
 *       with the distribution.
 *
 *     * Neither the name of the copyright holders nor the names of its
 *       contributors may be used to endorse or promote products derived
 *       from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 ******************************************************************************)

text\<open>We present two solutions for obtaining an Isabelle file.\<close>

section\<open>Static Meta Embedding with Exportation\<close>

theory  Generator_static
imports Printer
begin
ML_file "~~/src/Doc/antiquote_setup.ML"

text \<open>In the ``static'' solution: the user manually generates
the Isabelle file after writing by hand an OCL input to translate.
The input is not written with the syntax of OCL,
but with raw Isabelle constructors.\<close>

subsection\<open>Giving an Input to Translate\<close>

definition "Design =
 (let n = \<lambda>n1 n2. OclTyObj (OclTyCore_pre n1) (case n2 of None \<Rightarrow> [] | Some n2 \<Rightarrow> [[OclTyCore_pre n2]])
    ; mk = \<lambda>n l. ocl_class_raw.make n l [] False in
  [ mk (n \<langle>''Galaxy''\<rangle> None) [(\<langle>''sound''\<rangle>, OclTy_raw \<langle>''unit''\<rangle>), (\<langle>''moving''\<rangle>, OclTy_raw \<langle>''bool''\<rangle>)]
  , mk (n \<langle>''Planet''\<rangle> (Some \<langle>''Galaxy''\<rangle>)) [(\<langle>''weight''\<rangle>, OclTy_raw \<langle>''nat''\<rangle>)]
  , mk (n \<langle>''Person''\<rangle> (Some \<langle>''Planet''\<rangle>)) [(\<langle>''salary''\<rangle>, OclTy_raw \<langle>''int''\<rangle>)] ])"

text \<open>Since we are in a Isabelle session, at this time, it becomes possible to inspect with 
the command @{command value} the result of the translations applied with @{term Design}. 
A suitable environment should nevertheless be provided, 
one can typically experiment this by copying-pasting the following environment
initialized below in @{text main}:\<close>

definition "main =
 (let n = \<lambda>n1. OclTyObj (OclTyCore_pre n1) []
    ; OclMult = \<lambda>m r. ocl_multiplicity.make [m] r [Set] in
  write_file
   (compiler_env_config.extend
     (compiler_env_config_empty True None (oidInit (Oid 0)) Gen_only_design (None, False)
        \<lparr> D_output_disable_thy := False
        , D_output_header_thy := Some (\<langle>''Employee_DesignModel_UMLPart_generated''\<rangle>
                                      ,[\<langle>''../src/OCL_main''\<rangle>]
                                      ,\<langle>''../src/compiler/Generator_dynamic_sequential''\<rangle>) \<rparr>)
     ( L.map (META_class_raw Floor1) Design
       @@@@ [ META_association (ocl_association.make
                                  OclAssTy_association
                                  (OclAssRel [ (n \<langle>''Person''\<rangle>, OclMult (Mult_star, None) None)
                                             , (n \<langle>''Person''\<rangle>, OclMult (Mult_nat 0, Some (Mult_nat 1)) (Some \<langle>''boss''\<rangle>))]))
          , META_flush_all OclFlushAll]
     , None)))"

subsection\<open>Statically Executing the Exportation\<close>

text\<open>
@{verbatim "apply_code_printing ()"} \\
@{verbatim "export_code main"} \\
@{verbatim "  (* in Haskell *)"} \\
@{verbatim "  (* in OCaml module_name M *)"} \\
@{verbatim "  (* in Scala module_name M *)"} \\
@{verbatim "  (* in SML   module_name M *)"}
\<close>

text\<open>After the exportation and executing the exported, we obtain an Isabelle \verb|.thy| file
containing the generated code associated to the above input.\<close>

end
