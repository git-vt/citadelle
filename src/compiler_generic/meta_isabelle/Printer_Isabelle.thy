(*****************************************************************************
 * A Meta-Model for the Isabelle API
 *
 * Copyright (c) 2013-2015 Université Paris-Saclay, Univ Paris Sud, France
 *               2013-2015 IRT SystemX, France
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

section{* Instantiating the Printer for Isabelle *}

theory  Printer_Isabelle
imports Meta_Isabelle
        Printer_Pure
        Printer_SML
begin

context Print
begin

fun of_semi__typ where "of_semi__typ e = (\<lambda>
    Typ_base s \<Rightarrow> To_string s
  | Typ_apply name l \<Rightarrow> sprint2 \<open>%s %s\<close>\<acute> (let s = String_concat \<open>, \<close> (List.map of_semi__typ l) in
                                                 case l of [_] \<Rightarrow> s | _ \<Rightarrow> sprint1 \<open>(%s)\<close>\<acute> s)
                                                (of_semi__typ name)
  | Typ_apply_bin s ty1 ty2 \<Rightarrow> sprint3 \<open>%s %s %s\<close>\<acute> (of_semi__typ ty1) (To_string s) (of_semi__typ ty2)
  | Typ_apply_paren s1 s2 ty \<Rightarrow> sprint3 \<open>%s%s%s\<close>\<acute> (To_string s1) (of_semi__typ ty) (To_string s2)) e"

definition "of_datatype _ = (\<lambda> Datatype n l \<Rightarrow>
  sprint2 \<open>datatype %s = %s\<close>\<acute>
    (To_string n)
    (String_concat \<open>
                        | \<close>
      (L.map
        (\<lambda>(n,l).
         sprint2 \<open>%s %s\<close>\<acute>
           (To_string n)
           (String_concat \<open> \<close> (L.map (\<lambda>x. sprint1 \<open>\"%s\"\<close>\<acute> (of_semi__typ x)) l))) l) ))"

definition "of_type_synonym _ = (\<lambda> Type_synonym n v l \<Rightarrow>
    sprint2 \<open>type_synonym %s = \"%s\"\<close>\<acute> (if v = [] then 
                                           To_string n
                                         else
                                           of_semi__typ (Typ_apply (Typ_base n) (L.map Typ_base v)))
                                        (of_semi__typ l))"

fun of_semi__term where "of_semi__term e = (\<lambda>
    Term_rewrite e1 symb e2 \<Rightarrow> sprint3 \<open>%s %s %s\<close>\<acute> (of_semi__term e1) (To_string symb) (of_semi__term e2)
  | Term_basic l \<Rightarrow> sprint1 \<open>%s\<close>\<acute> (String_concat \<open> \<close> (L.map To_string l))
  | Term_annot e s \<Rightarrow> sprint2 \<open>(%s::%s)\<close>\<acute> (of_semi__term e) (of_semi__typ s)
  | Term_bind symb e1 e2 \<Rightarrow> sprint3 \<open>(%s%s. %s)\<close>\<acute> (To_string symb) (of_semi__term e1) (of_semi__term e2)
  | Term_fun_case e_case l \<Rightarrow> sprint2 \<open>(%s %s)\<close>\<acute>
      (case e_case of None \<Rightarrow> \<open>\<lambda>\<close>
                    | Some e \<Rightarrow> sprint1 \<open>case %s of\<close>\<acute> (of_semi__term e))
      (String_concat \<open>
    | \<close> (List.map (\<lambda> (s1, s2) \<Rightarrow> sprint2 \<open>%s \<Rightarrow> %s\<close>\<acute> (of_semi__term s1) (of_semi__term s2)) l))
  | Term_apply e l \<Rightarrow> sprint2 \<open>%s %s\<close>\<acute> (of_semi__term e) (String_concat \<open> \<close> (List.map (\<lambda> e \<Rightarrow> sprint1 \<open>%s\<close>\<acute> (of_semi__term e)) l))
  | Term_paren p_left p_right e \<Rightarrow> sprint3 \<open>%s%s%s\<close>\<acute> (To_string p_left) (of_semi__term e) (To_string p_right)
  | Term_if_then_else e_if e_then e_else \<Rightarrow> sprint3 \<open>if %s then %s else %s\<close>\<acute> (of_semi__term e_if) (of_semi__term e_then) (of_semi__term e_else)
  | Term_term l pure \<Rightarrow> of_pure_term (L.map To_string l) pure) e"

definition "of_type_notation _ = (\<lambda> Type_notation n e \<Rightarrow>
    sprint2 \<open>type_notation %s (\"%s\")\<close>\<acute> (To_string n) (To_string e))"

definition "of_instantiation _ = (\<lambda> Instantiation n n_def expr \<Rightarrow>
    let name = To_string n in
    sprint4 \<open>instantiation %s :: object
begin
  definition %s_%s_def : \"%s\"
  instance ..
end\<close>\<acute>
      name
      (To_string n_def)
      name
      (of_semi__term expr))"

definition "of_defs _ = (\<lambda> Defs_overloaded n e \<Rightarrow>
    sprint2 \<open>defs(overloaded) %s : \"%s\"\<close>\<acute> (To_string n) (of_semi__term e))"

definition "of_consts _ = (\<lambda> Consts n ty symb \<Rightarrow>
    sprint4 \<open>consts %s :: \"%s\" (\"%s %s\")\<close>\<acute> (To_string n) (of_semi__typ ty) (To_string Consts_value) (To_string symb))"

definition "of_definition _ = (\<lambda>
    Definition e \<Rightarrow> sprint1 \<open>definition \"%s\"\<close>\<acute> (of_semi__term e)
  | Definition_where1 name (abbrev, prio) e \<Rightarrow> sprint4 \<open>definition %s (\"(1%s)\" %d)
  where \"%s\"\<close>\<acute> (To_string name) (of_semi__term abbrev) (To_nat prio) (of_semi__term e)
  | Definition_where2 name abbrev e \<Rightarrow> sprint3 \<open>definition %s (\"%s\")
  where \"%s\"\<close>\<acute> (To_string name) (of_semi__term abbrev) (of_semi__term e))"

definition "(of_semi__thm_attribute_aux_gen :: String.literal \<times> String.literal \<Rightarrow> _ \<Rightarrow> _ \<Rightarrow> _) m lacc s = 
 (let s_base = (\<lambda>s lacc. sprint2 \<open>%s[%s]\<close>\<acute> (To_string s) (String_concat \<open>, \<close> (L.map (\<lambda>(s, x). sprint2 \<open>%s %s\<close>\<acute> s x) lacc))) in
  s_base s (m # lacc))"

definition "of_semi__thm_attribute_aux_gen_where l = 
 (\<open>where\<close>, String_concat \<open> and \<close> (L.map (\<lambda>(var, expr). sprint2 \<open>%s = \"%s\"\<close>\<acute>
                                                            (To_string var)
                                                            (of_semi__term expr)) l))"

definition "of_semi__thm_attribute_aux_gen_of l =
 (\<open>of\<close>, String_concat \<open> \<close> (L.map (\<lambda>expr. sprint1 \<open>\"%s\"\<close>\<acute> (of_semi__term expr)) l))"

(* NOTE all 'let' declarations can be put at the beginning *)
   (*let f_where = (\<lambda>l. (\<open>where\<close>, String_concat \<open> and \<close>
                                        (L.map (\<lambda>(var, expr). sprint2 \<open>%s = \"%s\"\<close>\<acute>
                                                        (To_string var)
                                                        (of_semi__term expr)) l)))
     ; f_of = (\<lambda>l. (\<open>of\<close>, String_concat \<open> \<close>
                                  (L.map (\<lambda>expr. sprint1 \<open>\"%s\"\<close>\<acute>
                                                        (of_semi__term expr)) l)))
     ; f_symmetric = (\<open>symmetric\<close>, \<open>\<close>)
     ; s_base = (\<lambda>s lacc. sprint2 \<open>%s[%s]\<close>\<acute> (To_string s) (String_concat \<open>, \<close> (L.map (\<lambda>(s, x). sprint2 \<open>%s %s\<close>\<acute> s x) lacc))) in
   *)
fun of_semi__thm_attribute_aux where "of_semi__thm_attribute_aux lacc e =
  (\<lambda> Thm_thm s \<Rightarrow> To_string s
   | Thm_thms s \<Rightarrow> To_string s

   | Thm_THEN (Thm_thm s) e2 \<Rightarrow> of_semi__thm_attribute_aux_gen (\<open>THEN\<close>, of_semi__thm_attribute_aux [] e2) lacc s
   | Thm_THEN (Thm_thms s) e2 \<Rightarrow> of_semi__thm_attribute_aux_gen (\<open>THEN\<close>, of_semi__thm_attribute_aux [] e2) lacc s
   | Thm_THEN e1 e2 \<Rightarrow> of_semi__thm_attribute_aux ((\<open>THEN\<close>, of_semi__thm_attribute_aux [] e2) # lacc) e1

   | Thm_simplified (Thm_thm s) e2 \<Rightarrow> of_semi__thm_attribute_aux_gen (\<open>simplified\<close>, of_semi__thm_attribute_aux [] e2) lacc s
   | Thm_simplified (Thm_thms s) e2 \<Rightarrow> of_semi__thm_attribute_aux_gen (\<open>simplified\<close>, of_semi__thm_attribute_aux [] e2) lacc s
   | Thm_simplified e1 e2 \<Rightarrow> of_semi__thm_attribute_aux ((\<open>simplified\<close>, of_semi__thm_attribute_aux [] e2) # lacc) e1

   | Thm_symmetric (Thm_thm s) \<Rightarrow> of_semi__thm_attribute_aux_gen (\<open>symmetric\<close>, \<open>\<close>) lacc s 
   | Thm_symmetric (Thm_thms s) \<Rightarrow> of_semi__thm_attribute_aux_gen (\<open>symmetric\<close>, \<open>\<close>) lacc s
   | Thm_symmetric e1 \<Rightarrow> of_semi__thm_attribute_aux ((\<open>symmetric\<close>, \<open>\<close>) # lacc) e1

   | Thm_where (Thm_thm s) l \<Rightarrow> of_semi__thm_attribute_aux_gen (of_semi__thm_attribute_aux_gen_where l) lacc s
   | Thm_where (Thm_thms s) l \<Rightarrow> of_semi__thm_attribute_aux_gen (of_semi__thm_attribute_aux_gen_where l) lacc s
   | Thm_where e1 l \<Rightarrow> of_semi__thm_attribute_aux (of_semi__thm_attribute_aux_gen_where l # lacc) e1

   | Thm_of (Thm_thm s) l \<Rightarrow> of_semi__thm_attribute_aux_gen (of_semi__thm_attribute_aux_gen_of l) lacc s
   | Thm_of (Thm_thms s) l \<Rightarrow> of_semi__thm_attribute_aux_gen (of_semi__thm_attribute_aux_gen_of l) lacc s
   | Thm_of e1 l \<Rightarrow> of_semi__thm_attribute_aux (of_semi__thm_attribute_aux_gen_of l # lacc) e1

   | Thm_OF (Thm_thm s) e2 \<Rightarrow> of_semi__thm_attribute_aux_gen (\<open>OF\<close>, of_semi__thm_attribute_aux [] e2) lacc s
   | Thm_OF (Thm_thms s) e2 \<Rightarrow> of_semi__thm_attribute_aux_gen (\<open>OF\<close>, of_semi__thm_attribute_aux [] e2) lacc s
   | Thm_OF e1 e2 \<Rightarrow> of_semi__thm_attribute_aux ((\<open>OF\<close>, of_semi__thm_attribute_aux [] e2) # lacc) e1) e"

definition "of_semi__thm_attribute = of_semi__thm_attribute_aux []"

definition "of_semi__thm = (\<lambda> Thms_single thy \<Rightarrow> of_semi__thm_attribute thy
                         | Thms_mult thy \<Rightarrow> of_semi__thm_attribute thy)"

definition "of_semi__thm_attribute_l l = String_concat \<open>
                            \<close> (L.map of_semi__thm_attribute l)"
definition "of_semi__thm_attribute_l1 l = String_concat \<open> \<close> (L.map of_semi__thm_attribute l)"

definition "of_semi__thm_l l = String_concat \<open> \<close> (L.map of_semi__thm l)"

definition "of_lemmas _ = (\<lambda> Lemmas_simp_thm simp s l \<Rightarrow>
    sprint3 \<open>lemmas%s%s = %s\<close>\<acute>
      (if String.is_empty s then \<open>\<close> else sprint1 \<open> %s\<close>\<acute> (To_string s))
      (if simp then \<open>[simp,code_unfold]\<close> else \<open>\<close>)
      (of_semi__thm_attribute_l l)
                                  | Lemmas_simp_thms s l \<Rightarrow>
    sprint2 \<open>lemmas%s [simp,code_unfold] = %s\<close>\<acute>
      (if String.is_empty s then \<open>\<close> else sprint1 \<open> %s\<close>\<acute> (To_string s))
      (String_concat \<open>
                            \<close> (L.map To_string l)))"

definition "(of_semi__attrib_genA :: (semi__thm list \<Rightarrow> String.literal)
   \<Rightarrow> String.literal \<Rightarrow> semi__thm list \<Rightarrow> String.literal) f attr l = (* error reflection: to be merged *)
 (if l = [] then
    \<open>\<close>
  else
    sprint2 \<open> %s: %s\<close>\<acute> attr (f l))"

definition "(of_semi__attrib_genB :: (string list \<Rightarrow> String.literal)
   \<Rightarrow> String.literal \<Rightarrow> string list \<Rightarrow> String.literal) f attr l = (* error reflection: to be merged *)
 (if l = [] then
    \<open>\<close>
  else
    sprint2 \<open> %s: %s\<close>\<acute> attr (f l))"

definition "of_semi__attrib = of_semi__attrib_genA of_semi__thm_l"
definition "of_semi__attrib1 = of_semi__attrib_genB (\<lambda>l. String_concat \<open> \<close> (L.map To_string l))"

fun of_semi__method where "of_semi__method expr = (\<lambda>
    Method_rule o_s \<Rightarrow> sprint1 \<open>rule%s\<close>\<acute> (case o_s of None \<Rightarrow> \<open>\<close>
                                                    | Some s \<Rightarrow> sprint1 \<open> %s\<close>\<acute> (of_semi__thm_attribute s))
  | Method_drule s \<Rightarrow> sprint1 \<open>drule %s\<close>\<acute> (of_semi__thm_attribute s)
  | Method_erule s \<Rightarrow> sprint1 \<open>erule %s\<close>\<acute> (of_semi__thm_attribute s)
  | Method_intro l \<Rightarrow> sprint1 \<open>intro %s\<close>\<acute> (of_semi__thm_attribute_l1 l)
  | Method_elim s \<Rightarrow> sprint1 \<open>elim %s\<close>\<acute> (of_semi__thm_attribute s)
  | Method_subst asm l s =>
      let s_asm = if asm then \<open>(asm) \<close> else \<open>\<close> in
      if L.map String.to_list l = [''0''] then
        sprint2 \<open>subst %s%s\<close>\<acute> s_asm (of_semi__thm_attribute s)
      else
        sprint3 \<open>subst %s(%s) %s\<close>\<acute> s_asm (String_concat \<open> \<close> (L.map To_string l)) (of_semi__thm_attribute s)
  | Method_insert l => sprint1 \<open>insert %s\<close>\<acute> (of_semi__thm_l l)
  | Method_plus t \<Rightarrow> sprint1 \<open>(%s)+\<close>\<acute> (String_concat \<open>, \<close> (List.map of_semi__method t))
  | Method_option t \<Rightarrow> sprint1 \<open>(%s)?\<close>\<acute> (String_concat \<open>, \<close> (List.map of_semi__method t))
  | Method_or t \<Rightarrow> sprint1 \<open>(%s)\<close>\<acute> (String_concat \<open> | \<close> (List.map of_semi__method t))
  | Method_one (Method_simp_only l) \<Rightarrow> sprint1 \<open>simp only: %s\<close>\<acute> (of_semi__thm_l l)
  | Method_one (Method_simp_add_del_split l1 l2 []) \<Rightarrow> sprint2 \<open>simp%s%s\<close>\<acute>
      (of_semi__attrib \<open>add\<close> l1)
      (of_semi__attrib \<open>del\<close> l2)
  | Method_one (Method_simp_add_del_split l1 l2 l3) \<Rightarrow> sprint3 \<open>simp%s%s%s\<close>\<acute>
      (of_semi__attrib \<open>add\<close> l1)
      (of_semi__attrib \<open>del\<close> l2)
      (of_semi__attrib \<open>split\<close> l3)
  | Method_all (Method_simp_only l) \<Rightarrow> sprint1 \<open>simp_all only: %s\<close>\<acute> (of_semi__thm_l l)
  | Method_all (Method_simp_add_del_split l1 l2 []) \<Rightarrow> sprint2 \<open>simp_all%s%s\<close>\<acute>
      (of_semi__attrib \<open>add\<close> l1)
      (of_semi__attrib \<open>del\<close> l2)
  | Method_all (Method_simp_add_del_split l1 l2 l3) \<Rightarrow> sprint3 \<open>simp_all%s%s%s\<close>\<acute>
      (of_semi__attrib \<open>add\<close> l1)
      (of_semi__attrib \<open>del\<close> l2)
      (of_semi__attrib \<open>split\<close> l3)
  | Method_auto_simp_add_split l_simp l_split \<Rightarrow> sprint2 \<open>auto%s%s\<close>\<acute>
      (of_semi__attrib \<open>simp\<close> l_simp)
      (of_semi__attrib1 \<open>split\<close> l_split)
  | Method_rename_tac l \<Rightarrow> sprint1 \<open>rename_tac %s\<close>\<acute> (String_concat \<open> \<close> (L.map To_string l))
  | Method_case_tac e \<Rightarrow> sprint1 \<open>case_tac \"%s\"\<close>\<acute> (of_semi__term e)
  | Method_blast None \<Rightarrow> sprint0 \<open>blast\<close>\<acute>
  | Method_blast (Some n) \<Rightarrow> sprint1 \<open>blast %d\<close>\<acute> (To_nat n)
  | Method_clarify \<Rightarrow> sprint0 \<open>clarify\<close>\<acute>
  | Method_metis l_opt l \<Rightarrow> sprint2 \<open>metis %s%s\<close>\<acute> (if l_opt = [] then \<open>\<close>
                                                   else
                                                     sprint1 \<open>(%s) \<close>\<acute> (String_concat \<open>, \<close> (L.map To_string l_opt))) (of_semi__thm_attribute_l1 l)) expr"

definition "of_semi__command_final = (\<lambda> Command_done \<Rightarrow> \<open>done\<close>
                                   | Command_by l_apply \<Rightarrow> sprint1 \<open>by(%s)\<close>\<acute> (String_concat \<open>, \<close> (L.map of_semi__method l_apply))
                                   | Command_sorry \<Rightarrow> \<open>sorry\<close>)"

definition "of_semi__command_state = (
  \<lambda> Command_apply_end [] \<Rightarrow> \<open>\<close>
  | Command_apply_end l_apply \<Rightarrow> sprint1 \<open>  apply_end(%s)
\<close>\<acute> (String_concat \<open>, \<close> (L.map of_semi__method l_apply)))"

definition' \<open>of_semi__command_proof = (
  let thesis = \<open>?thesis\<close>
    ; scope_thesis_gen = sprint2 \<open>  proof - %s show %s
\<close>\<acute>
    ; scope_thesis = \<lambda>s. scope_thesis_gen s thesis in
  \<lambda> Command_apply [] \<Rightarrow> \<open>\<close>
  | Command_apply l_apply \<Rightarrow> sprint1 \<open>  apply(%s)
\<close>\<acute> (String_concat \<open>, \<close> (L.map of_semi__method l_apply))
  | Command_using l \<Rightarrow> sprint1 \<open>  using %s
\<close>\<acute> (of_semi__thm_l l)
  | Command_unfolding l \<Rightarrow> sprint1 \<open>  unfolding %s
\<close>\<acute> (of_semi__thm_l l)
  | Command_let e_name e_body \<Rightarrow> scope_thesis (sprint2 \<open>let %s = "%s"\<close>\<acute> (of_semi__term e_name) (of_semi__term e_body))
  | Command_have n b e e_last \<Rightarrow> scope_thesis (sprint4 \<open>have %s%s: "%s" %s\<close>\<acute> (To_string n) (if b then \<open>[simp]\<close> else \<open>\<close>) (of_semi__term e) (of_semi__command_final e_last))
  | Command_fix_let l l_let o_show _ \<Rightarrow>
      scope_thesis_gen
        (sprint2 \<open>fix %s%s\<close>\<acute> (String_concat \<open> \<close> (L.map To_string l))
                                     (String_concat
                                       (\<open>
\<close>                                        )
                                       (L.map
                                         (\<lambda>(e_name, e_body).
                                           sprint2 \<open>          let %s = "%s"\<close>\<acute> (of_semi__term e_name) (of_semi__term e_body))
                                         l_let)))
        (case o_show of None \<Rightarrow> thesis
                      | Some l_show \<Rightarrow> sprint1 \<open>"%s"\<close>\<acute> (String_concat \<open> \<Longrightarrow> \<close> (L.map of_semi__term l_show))))\<close>

definition "of_lemma _ =
 (\<lambda> Lemma n l_spec l_apply tactic_last \<Rightarrow>
    sprint4 \<open>lemma %s : \"%s\"
%s%s\<close>\<acute>
      (To_string n)
      (String_concat \<open> \<Longrightarrow> \<close> (L.map of_semi__term l_spec))
      (String_concat \<open>\<close> (L.map (\<lambda> [] \<Rightarrow> \<open>\<close> | l_apply \<Rightarrow> sprint1 \<open>  apply(%s)
\<close>\<acute> (String_concat \<open>, \<close> (L.map of_semi__method l_apply))) l_apply))
      (of_semi__command_final tactic_last)
  | Lemma_assumes n l_spec concl l_apply tactic_last \<Rightarrow>
    sprint5 \<open>lemma %s : %s
%s%s %s\<close>\<acute>
      (To_string n)
      (String_concat \<open>\<close> (L.map (\<lambda>(n, b, e).
          sprint2 \<open>
assumes %s\"%s\"\<close>\<acute>
            (let (n, b) = if b then (sprint1 \<open>%s[simp]\<close>\<acute> (To_string n), False) else (To_string n, String.is_empty n) in
             if b then \<open>\<close> else sprint1 \<open>%s: \<close>\<acute> n)
            (of_semi__term e)) l_spec
       @@@@
       [sprint1 \<open>
shows \"%s\"\<close>\<acute> (of_semi__term concl)]))
      (String_concat \<open>\<close> (L.map of_semi__command_proof l_apply))
      (of_semi__command_final tactic_last)
      (String_concat \<open> \<close>
        (L.map
          (\<lambda>l_apply_e.
            sprint1 \<open>%sqed\<close>\<acute>
              (if l_apply_e = [] then
                 \<open>\<close>
               else
                 sprint1 \<open>
%s \<close>\<acute> (String_concat \<open>\<close> (L.map of_semi__command_state l_apply_e))))
          (List.map_filter
            (\<lambda> Command_let _ _ \<Rightarrow> Some [] | Command_have _ _ _ _ \<Rightarrow> Some [] | Command_fix_let _ _ _ l \<Rightarrow> Some l | _ \<Rightarrow> None)
            (rev l_apply)))))"


definition "of_axiomatization _ = (\<lambda> Axiomatization n e \<Rightarrow> sprint2 \<open>axiomatization where %s:
\"%s\"\<close>\<acute> (To_string n) (of_semi__term e))"

definition "of_section _ = (\<lambda> Section n section_title \<Rightarrow>
    sprint2 \<open>%s{* %s *}\<close>\<acute>
      (sprint1 \<open>%ssection\<close>\<acute> (if n = 0 then \<open>\<close>
                             else if n = 1 then \<open>sub\<close>
                             else \<open>subsub\<close>))
      (To_string section_title))"

definition "of_text _ = (\<lambda> Text s \<Rightarrow> sprint1 \<open>text{* %s *}\<close>\<acute> (To_string s))"

definition "of_ML _ = (\<lambda> SML e \<Rightarrow> sprint1 \<open>ML{* %s *}\<close>\<acute> (of_sexpr e))"

definition "of_thm _ = (\<lambda> Thm thm \<Rightarrow> sprint1 \<open>thm %s\<close>\<acute> (of_semi__thm_attribute_l1 thm))"

definition' \<open>of_interpretation _ = (\<lambda> Interpretation n loc_n loc_param tac \<Rightarrow>
  sprint4 \<open>interpretation %s: %s%s
%s\<close>\<acute> (To_string n)
     (To_string loc_n)
     (String_concat \<open>\<close> (L.map (\<lambda>s. sprint1 \<open> "%s"\<close>\<acute> (of_semi__term s)) loc_param))
     (of_semi__command_final tac))\<close>

definition "of_semi__t ocl =
            (\<lambda> Theory_datatype dataty \<Rightarrow> of_datatype ocl dataty
             | Theory_type_synonym ty_synonym \<Rightarrow> of_type_synonym ocl ty_synonym
             | Theory_type_notation ty_notation \<Rightarrow> of_type_notation ocl ty_notation
             | Theory_instantiation instantiation_class \<Rightarrow> of_instantiation ocl instantiation_class
             | Theory_defs defs_overloaded \<Rightarrow> of_defs ocl defs_overloaded
             | Theory_consts consts_class \<Rightarrow> of_consts ocl consts_class
             | Theory_definition definition_hol \<Rightarrow> of_definition ocl definition_hol
             | Theory_lemmas lemmas_simp \<Rightarrow> of_lemmas ocl lemmas_simp
             | Theory_lemma lemma_by \<Rightarrow> of_lemma ocl lemma_by
             | Theory_axiomatization axiom \<Rightarrow> of_axiomatization ocl axiom
             | Theory_section section_title \<Rightarrow> of_section ocl section_title
             | Theory_text text \<Rightarrow> of_text ocl text
             | Theory_ML ml \<Rightarrow> of_ML ocl ml
             | Theory_thm thm \<Rightarrow> of_thm ocl thm
             | Theory_interpretation thm \<Rightarrow> of_interpretation ocl thm)"

definition "String_concat_map s f l = String_concat s (L.map f l)"

definition' \<open>of_semi__theory ocl =
 (\<lambda> H_thy_simple t \<Rightarrow> of_semi__t ocl t
  | H_thy_locale data l \<Rightarrow> 
      sprint3 \<open>locale %s =
%s
begin
%s
end\<close>\<acute>   (To_string (HolThyLocale_name data))
        (String_concat_map
           \<open>
\<close>
           (\<lambda> (l_fix, o_assum).
                sprint2 \<open>%s%s\<close>\<acute> (String_concat_map \<open>
\<close> (\<lambda>(e, ty). sprint2 \<open>fixes "%s" :: "%s"\<close>\<acute> (of_semi__term e) (of_semi__typ ty)) l_fix)
                                (case o_assum of None \<Rightarrow> \<open>\<close>
                                               | Some (name, e) \<Rightarrow> sprint2 \<open>
assumes %s: "%s"\<close>\<acute> (To_string name) (of_semi__term e)))
           (HolThyLocale_header data))
        (String_concat_map \<open>

\<close> (String_concat_map \<open>

\<close> (of_semi__t ocl)) l))\<close>

end

lemmas [code] =
  (* def *)
  Print.of_datatype_def
  Print.of_type_synonym_def
  Print.of_type_notation_def
  Print.of_instantiation_def
  Print.of_defs_def
  Print.of_consts_def
  Print.of_definition_def
  Print.of_semi__thm_attribute_aux_gen_def
  Print.of_semi__thm_attribute_aux_gen_where_def
  Print.of_semi__thm_attribute_aux_gen_of_def
  Print.of_semi__thm_attribute_def
  Print.of_semi__thm_def
  Print.of_semi__thm_attribute_l_def
  Print.of_semi__thm_attribute_l1_def
  Print.of_semi__thm_l_def
  Print.of_lemmas_def
  Print.of_semi__attrib_genA_def
  Print.of_semi__attrib_genB_def
  Print.of_semi__attrib_def
  Print.of_semi__attrib1_def
  Print.of_semi__command_final_def
  Print.of_semi__command_state_def
  Print.of_semi__command_proof_def
  Print.of_lemma_def
  Print.of_axiomatization_def
  Print.of_section_def
  Print.of_text_def
  Print.of_ML_def
  Print.of_thm_def
  Print.of_interpretation_def
  Print.of_semi__t_def
  Print.String_concat_map_def
  Print.of_semi__theory_def

  (* fun *)
  Print.of_semi__typ.simps
  Print.of_semi__term.simps
  Print.of_semi__thm_attribute_aux.simps
  Print.of_semi__method.simps

end
