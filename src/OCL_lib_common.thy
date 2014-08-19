(*****************************************************************************
 * Featherweight-OCL --- A Formal Semantics for UML-OCL Version OCL 2.4
 *                       for the OMG Standard.
 *                       http://www.brucker.ch/projects/hol-testgen/
 *
 * OCL_lib_common.thy ---
 * This file is part of HOL-TestGen.
 *
 * Copyright (c) 2013-2014 Universite Paris-Sud, France
 *               2013-2014 IRT SystemX, France
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
(* $Id:$ *)




theory OCL_lib_common
imports  OCL_core
begin

section{* Property Profiles for OCL Operators via Isabelle Locales *}

text{* We use the Isabelle mechanism of a \emph{Locale} to generate the
common lemmas for each type and operator; Locales can be seen as a 
functor that takes a local theory and generates a number of theorems.
In our case, we will instantiate later these locales by the local theory 
of an operator definition and obtain the common rules for strictness, definedness
propagation, context-passingness and constance in a systematic way.
*}

subsection{* mono *}

locale monop_property_profile_scheme =
   fixes f :: "('\<AA>,'\<alpha>::null)val \<Rightarrow> ('\<AA>,'\<beta>::null)val"
   fixes g
   assumes def_scheme: "(f x) \<equiv> \<lambda> \<tau>. if (\<delta> x) \<tau> = true \<tau> then g (x \<tau>) else invalid \<tau>"

locale monop_property_profile2 = monop_property_profile_scheme +
   assumes "\<And> x. x \<noteq> bot \<Longrightarrow> x \<noteq> null \<Longrightarrow> g x \<noteq> bot"
begin
   lemma strict[simp,code_unfold]: " f invalid = invalid"
   by(rule ext, simp add: def_scheme true_def false_def)
 
   lemma null_strict[simp,code_unfold]: " f null = invalid"
   by(rule ext, simp add: def_scheme true_def false_def)

   lemma cp0 : "f X \<tau> = f (\<lambda> _. X \<tau>) \<tau>"
   by(simp add: def_scheme  cp_defined[symmetric])
      
   lemma cp[simp,code_unfold] : " cp P \<Longrightarrow> cp (\<lambda>X. f (P X) )"
   by(rule OCL_core.cpI1[of "f"], intro allI, rule cp0, simp_all)
   
   lemma const[simp,code_unfold] : 
          assumes C1 :"const X"
          shows       "const(f X)"
      proof -
        have const_g : "const (\<lambda>\<tau>. g (X \<tau>))"  by(insert C1, auto simp:const_def, metis)
        show ?thesis   by(simp_all add : def_scheme const_ss C1 const_g)
      qed  
end

locale monop_property_profile0 = monop_property_profile_scheme +
   assumes def_body:  "\<And> x. x \<noteq> bot \<Longrightarrow> x \<noteq> null \<Longrightarrow> g x \<noteq> bot \<and> g x \<noteq> null"

sublocale monop_property_profile0 < monop_property_profile2
by(unfold_locales, simp add: def_scheme, simp add: def_body)

context monop_property_profile0
begin
   lemma def_homo[simp,code_unfold]: "\<delta>(f x) = (\<delta> x)"
   apply(rule ext, rename_tac "\<tau>",subst OCL_core.foundation22[symmetric])
   apply(case_tac "\<not>(\<tau> \<Turnstile> \<delta> x)", simp add:defined_split, elim disjE)
     apply(erule OCL_core.StrongEq_L_subst2_rev, simp,simp)
    apply(erule OCL_core.StrongEq_L_subst2_rev, simp,simp)
   apply(simp)
   apply(rule foundation13[THEN iffD2,THEN OCL_core.StrongEq_L_subst2_rev, where y ="\<delta> x"])
     apply(simp_all add:def_scheme)
   apply(simp add: OclValid_def)
   by(auto simp:foundation13 StrongEq_def false_def true_def defined_def bot_fun_def null_fun_def def_body
           split: split_if_asm)

   lemma def_valid_then_def: "\<upsilon>(f x) = (\<delta>(f x))"
   apply(rule ext, rename_tac "\<tau>",subst OCL_core.foundation22[symmetric])
   apply(case_tac "\<not>(\<tau> \<Turnstile> \<delta> x)", simp add:defined_split, elim disjE)
     apply(erule OCL_core.StrongEq_L_subst2_rev, simp,simp)
    apply(erule OCL_core.StrongEq_L_subst2_rev, simp,simp)
   apply simp
   apply(simp_all add:def_scheme)
   apply(simp add: OclValid_def valid_def, subst cp_StrongEq)
   apply(subst (2) cp_defined, simp, simp add: cp_defined[symmetric])
   by(auto simp:foundation13 StrongEq_def false_def true_def defined_def bot_fun_def null_fun_def def_body
           split: split_if_asm)
end

subsection{* single *}

locale single_infra =
   fixes d:: "('\<AA>,'a::null)val \<Rightarrow> '\<AA> Boolean"
   assumes d_strict[simp,code_unfold]: "d invalid = false"
   assumes d_cp0: "d X \<tau> = d (\<lambda> _. X \<tau>) \<tau>"
   assumes d_const[simp,code_unfold]: "const X \<Longrightarrow> const (d X)"

subsection{* binop *}

definition "bin' f g d\<^sub>x d\<^sub>y X Y =
                       (f X Y = (\<lambda> \<tau>. if (d\<^sub>x X) \<tau> = true \<tau> \<and> (d\<^sub>y Y) \<tau> = true \<tau>
                                      then g X Y \<tau>
                                      else invalid \<tau> ))"
 
definition "bin f g = bin' f (\<lambda>X Y \<tau>. g (X \<tau>) (Y \<tau>))"

lemmas [simp,code_unfold] = bin'_def bin_def

locale binop_infra =
   fixes d\<^sub>x:: "('\<AA>,'a::null)val \<Rightarrow> '\<AA> Boolean"
   fixes d\<^sub>y:: "('\<AA>,'b::null)val \<Rightarrow> '\<AA> Boolean"
   fixes f::"('\<AA>,'a::null)val \<Rightarrow> ('\<AA>,'b::null)val \<Rightarrow> ('\<AA>,'c::null)val"
   fixes g
   assumes d\<^sub>x' : "single_infra d\<^sub>x"
   assumes d\<^sub>y' : "single_infra d\<^sub>y"
   assumes d\<^sub>x_d\<^sub>y_homo[simp,code_unfold]: "cp (f X) \<Longrightarrow> 
                          cp (\<lambda>x. f x Y) \<Longrightarrow> 
                          f X invalid = invalid \<Longrightarrow>
                          f invalid Y = invalid \<Longrightarrow>
                          (\<not> (\<tau> \<Turnstile> d\<^sub>x X) \<or> \<not> (\<tau> \<Turnstile> d\<^sub>y Y)) \<Longrightarrow>
                          \<tau> \<Turnstile> (\<delta> f X Y \<triangleq> (d\<^sub>x X and d\<^sub>y Y))"
   assumes def_scheme''[simplified]: "bin f g d\<^sub>x d\<^sub>y X Y"
   assumes 1: "\<tau> \<Turnstile> d\<^sub>x X \<Longrightarrow> \<tau> \<Turnstile> d\<^sub>y Y \<Longrightarrow> \<tau> \<Turnstile> \<delta> f X Y"
begin
      interpretation d\<^sub>x : single_infra d\<^sub>x by (rule d\<^sub>x')
      interpretation d\<^sub>y : single_infra d\<^sub>y by (rule d\<^sub>y')

      lemma strict1[simp,code_unfold]: " f invalid y = invalid"
      by(rule ext, simp add: def_scheme'' true_def false_def)

      lemma strict2[simp,code_unfold]: " f x invalid = invalid"
      by(rule ext, simp add: def_scheme'' true_def false_def)

      lemma cp0 : "f X Y \<tau> = f (\<lambda> _. X \<tau>) (\<lambda> _. Y \<tau>) \<tau>"
      by(simp add: def_scheme'' d\<^sub>x.d_cp0[symmetric] d\<^sub>y.d_cp0[symmetric] cp_defined[symmetric])
      
      lemma cp[simp,code_unfold] : " cp P \<Longrightarrow> cp Q \<Longrightarrow> cp (\<lambda>X. f (P X) (Q X))"
      by(rule OCL_core.cpI2[of "f"], intro allI, rule cp0, simp_all)

      lemma def_homo[simp,code_unfold]: "\<delta>(f x y) = (d\<^sub>x x and d\<^sub>y y)"
         apply(rule ext, rename_tac "\<tau>",subst OCL_core.foundation22[symmetric])
         apply(case_tac "\<not>(\<tau> \<Turnstile> d\<^sub>x x)", simp)
         apply(case_tac "\<not>(\<tau> \<Turnstile> d\<^sub>y y)", simp)
         apply(simp)
         apply(rule foundation13[THEN iffD2,THEN OCL_core.StrongEq_L_subst2_rev, where y ="d\<^sub>x x"])
           apply(simp_all)
         apply(rule foundation13[THEN iffD2,THEN OCL_core.StrongEq_L_subst2_rev, where y ="d\<^sub>y y"])
           apply(simp_all add: 1 foundation13)
         done

      lemma def_valid_then_def: "\<upsilon>(f x y) = (\<delta>(f x y))" (* [simp,code_unfold] ? *)
         apply(rule ext, rename_tac "\<tau>") 
         apply(simp_all add: valid_def defined_def def_scheme''
                             true_def false_def invalid_def 
                             null_def null_fun_def null_option_def bot_fun_def)
         by (metis "1" OclValid_def def_scheme'' foundation16 true_def)

      lemma defined_args_valid: "(\<tau> \<Turnstile> \<delta> (f x y)) = ((\<tau> \<Turnstile> d\<^sub>x x) \<and> (\<tau> \<Turnstile> d\<^sub>y y))"
         by(simp add: foundation27)

      lemma const[simp,code_unfold] : 
          assumes C1 :"const X" and C2 : "const Y"
          shows       "const(f X Y)"
      proof -
          have const_g : "const (\<lambda>\<tau>. g (X \<tau>) (Y \<tau>))" 
                  by(insert C1 C2, auto simp:const_def, metis)
        show ?thesis
        by(simp_all add : def_scheme'' const_ss C1 C2 const_g)
      qed
end


text{*
In our context, we will use Locales as ``Property Profiles'' for OCL operators;
if an operator @{term "f"} is of profile @{term "binop_infra defined f g"} we know
that it satisfies a number of properties like @{text "strict1"} or @{text "strict2"}
\ie{} @{term "f invalid y = invalid"} and @{term "f null y = invalid"}.
Since some of the more advanced Locales come with 10 - 15 theorems, property profiles
represent a major structuring mechanism for the OCL library.
*}


locale binop_infra1' =
   fixes d\<^sub>y:: "('\<AA>,'b::null)val \<Rightarrow> '\<AA> Boolean"
   fixes f::"('\<AA>,'a::null)val \<Rightarrow> ('\<AA>,'b::null)val \<Rightarrow> ('\<AA>,'c::null)val"
   fixes g
   assumes d\<^sub>y : "single_infra d\<^sub>y"
   assumes d\<^sub>y_homo[simp,code_unfold]: "cp (f X) \<Longrightarrow> 
                          f X invalid = invalid \<Longrightarrow>
                          \<not> \<tau> \<Turnstile> d\<^sub>y Y \<Longrightarrow>
                          \<tau> \<Turnstile> \<delta> f X Y \<triangleq> (\<delta> X and d\<^sub>y Y)"
   assumes def_scheme'[simplified]: "bin f g defined d\<^sub>y X Y"
   assumes def_body':  "\<And> x y \<tau>. x\<noteq>bot \<Longrightarrow> x\<noteq>null \<Longrightarrow> (d\<^sub>y y) \<tau> = true \<tau> \<Longrightarrow> g x (y \<tau>) \<noteq> bot \<and> g x (y \<tau>) \<noteq> null "
begin
      lemma strict3[simp,code_unfold]: " f null y = invalid"
      by(rule ext, simp add: def_scheme' true_def false_def)
end

sublocale binop_infra1' < binop_infra defined
proof - 
      interpret d\<^sub>y : single_infra d\<^sub>y by (rule d\<^sub>y)
 show "binop_infra defined d\<^sub>y f g"
 apply(unfold_locales)
      apply(simp)+
     apply(subst cp_defined, simp)
    apply(rule const_defined, simp)
   apply(simp add:defined_split, elim disjE)
     apply(erule OCL_core.StrongEq_L_subst2_rev, simp, simp)+
   apply(simp)
  apply(simp add: def_scheme')
 apply(simp add: defined_def OclValid_def false_def true_def 
              bot_fun_def null_fun_def def_scheme' split: split_if_asm, rule def_body')
 by(simp add: true_def)+
qed

locale binop_infra1 =
   fixes f::"('\<AA>,'a::null)val \<Rightarrow> ('\<AA>,'b::null)val \<Rightarrow> ('\<AA>,'c::null)val"
   fixes g
   assumes def_scheme[simplified]: "bin f g defined defined X Y"
   assumes def_body:  "\<And> x y. g x y \<noteq> bot \<and> g x y \<noteq> null "
begin
      lemma strict4[simp,code_unfold]: " f x null = invalid"
      by(rule ext, simp add: def_scheme true_def false_def)
end

sublocale binop_infra1 < binop_infra1' defined
 apply(unfold_locales)
      apply(simp)+
     apply(subst cp_defined, simp)+
    apply(rule const_defined, simp)+
   apply(simp add:defined_split, elim disjE)
    apply(erule OCL_core.StrongEq_L_subst2_rev, simp, simp)+
  apply(simp add: def_scheme)
 by(simp add: defined_def OclValid_def false_def true_def 
              bot_fun_def null_fun_def def_scheme def_body)

locale binop_infra2 =
   fixes f::"('\<AA>,'a::null)val \<Rightarrow> ('\<AA>,'b::null)val \<Rightarrow> ('\<AA>,'c::null)val"
   fixes g
   assumes def_scheme[simplified]: "bin f g defined valid X Y"
   assumes def_body:  "\<And> x y. x\<noteq>bot \<Longrightarrow> x\<noteq>null \<Longrightarrow> y\<noteq>bot \<Longrightarrow> g x y \<noteq> bot \<and> g x y \<noteq> null"

sublocale binop_infra2 < binop_infra1' valid
 apply(unfold_locales)
      apply(simp)
     apply(subst cp_valid, simp)
    apply(rule const_valid, simp)
   apply(simp add:foundation18'')
   apply(erule OCL_core.StrongEq_L_subst2_rev, simp, simp)
  apply(simp add: def_scheme)
 by (metis OclValid_def def_body foundation18')
 
locale binop_property_profile3 =
   fixes f :: "('\<AA>,'\<alpha>::null)val \<Rightarrow> ('\<AA>,'\<alpha>::null)val \<Rightarrow> ('\<AA>) Boolean"
   assumes def_scheme[simplified]: "bin' f StrongEq valid valid X Y"

sublocale binop_property_profile3 < binop_infra valid valid f "\<lambda>x y. \<lfloor>\<lfloor>x = y\<rfloor>\<rfloor>"
 apply(unfold_locales)
      apply(simp)
     apply(subst cp_valid, simp)
    apply (simp add: const_valid)
   apply (metis (hide_lams, mono_tags) OclValid_def def_scheme defined5 defined6 defined_and_I foundation1 foundation10' foundation16' foundation18 foundation21 foundation22 foundation9)
  apply(simp add: def_scheme, subst StrongEq_def, simp)
 by (metis OclValid_def def_scheme defined7 foundation16)

context binop_property_profile3
   begin
      lemma idem[simp,code_unfold]: " f null null = true"
      by(rule ext, simp add: def_scheme true_def false_def)

      (* definedness *)
      lemma defargs: "\<tau> \<Turnstile> f x y \<Longrightarrow> (\<tau> \<Turnstile> \<upsilon> x) \<and> (\<tau> \<Turnstile> \<upsilon> y)"
         by(simp add: def_scheme OclValid_def true_def invalid_def valid_def bot_option_def
               split: bool.split_asm HOL.split_if_asm)

      lemma defined_args_valid' : "\<delta> (f x y) = (\<upsilon> x and \<upsilon> y)"
      by(auto intro!: transform2_rev defined_and_I simp:foundation10 defined_args_valid)

      (* logic and algebraic properties *)
      lemma refl_ext[simp,code_unfold] : "(f x x) = (if (\<upsilon> x) then true else invalid endif)"
         by(rule ext, simp add: def_scheme OclIf_def)
      
      lemma sym : "\<tau> \<Turnstile> (f x y) \<Longrightarrow> \<tau> \<Turnstile> (f y x)"  
         apply(case_tac "\<tau> \<Turnstile> \<upsilon> x")
          apply(auto simp: def_scheme OclValid_def)
         by(fold OclValid_def, erule StrongEq_L_sym)

      lemma symmetric : "(f x y) = (f y x)"  
         by(rule ext, rename_tac \<tau>, auto simp: def_scheme StrongEq_sym)
      
      lemma trans : "\<tau> \<Turnstile> (f x y) \<Longrightarrow> \<tau> \<Turnstile> (f y z) \<Longrightarrow> \<tau> \<Turnstile> (f x z)"  
         apply(case_tac "\<tau> \<Turnstile> \<upsilon> x")
          apply(case_tac "\<tau> \<Turnstile> \<upsilon> y")
           apply(auto simp: def_scheme OclValid_def)
         by(fold OclValid_def, auto elim: StrongEq_L_trans)
         
      lemma StrictRefEq_vs_StrongEq: "\<tau> \<Turnstile>(\<upsilon> x) \<Longrightarrow> \<tau> \<Turnstile>(\<upsilon> y) \<Longrightarrow> (\<tau> \<Turnstile> ((f x y) \<triangleq> (x \<triangleq> y)))"
         apply(simp add: def_scheme OclValid_def)
         apply(subst cp_StrongEq[of _ "(x \<triangleq> y)"])
         by simp
         
   end

   
locale binop_property_profile4 =
   fixes f :: "('\<AA>,'\<alpha>::null)val \<Rightarrow> ('\<AA>,'\<beta>::null)val \<Rightarrow> ('\<AA>,'\<gamma>::null)val"
   fixes g
   assumes def_scheme[simplified]: "bin f g valid valid X Y"
   assumes def_body:  "\<And> x y. x\<noteq>bot \<Longrightarrow> y\<noteq>bot \<Longrightarrow> g x y \<noteq> bot \<and> g x y \<noteq> null"

sublocale binop_property_profile4 < binop_infra valid valid
 apply(unfold_locales)
         apply(simp, subst cp_valid, simp, rule const_valid, simp)+
   apply (metis (hide_lams, mono_tags) OclValid_def def_scheme defined5 defined6 defined_and_I foundation1 foundation10' foundation16' foundation18 foundation21 foundation22 foundation9)
  apply(simp add: def_scheme)
 apply(simp add: defined_def OclValid_def false_def true_def 
              bot_fun_def null_fun_def def_scheme split: split_if_asm, rule def_body)
 by (metis OclValid_def foundation18' true_def)+

end
