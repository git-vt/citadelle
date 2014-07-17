theory Tree_06_03_deep imports  "../../src/OCL_class_diagram_generator" begin
generation_syntax [ deep
                      (generation_semantics [ analysis (*, oid_start 10*) ])
                      skip_export
                      (THEORY Tree_06_03_generated)
                      (IMPORTS ["../../../src/OCL_main", "../../../src/OCL_class_diagram_static"]
                               "../../../src/OCL_class_diagram_generator")
                      SECTION
                      [ in SML module_name M (no_signatures) ]
                      (output_directory "./doc") ]

Class Aazz End
Class Bbyy End
Class Ccxx End
Class Ddww End
Class Eevv End
Class Ffuu End
Class Ggtt < Aazz End
Class Hhss < Aazz End
Class Iirr < Aazz End
Class Jjqq < Aazz End
Class Kkpp < Aazz End
Class Lloo < Aazz End
Class Mmnn < Bbyy End
Class Nnmm < Bbyy End
Class Ooll < Bbyy End
Class Ppkk < Bbyy End
Class Qqjj < Bbyy End
Class Rrii < Bbyy End
Class Sshh < Ccxx End
Class Ttgg < Ccxx End
Class Uuff < Ccxx End
Class Vvee < Ccxx End
Class Wwdd < Ccxx End
Class Xxcc < Ccxx End
Class Yybb < Ddww End
Class Zzaa < Ddww End
Class Baba < Ddww End
Class Bbbb < Ddww End
Class Bcbc < Ddww End
Class Bdbd < Ddww End
Class Bebe < Eevv End
Class Bfbf < Eevv End
Class Bgbg < Eevv End
Class Bhbh < Eevv End
Class Bibi < Eevv End
Class Bjbj < Eevv End
Class Bkbk < Ffuu End
Class Blbl < Ffuu End
Class Bmbm < Ffuu End
Class Bnbn < Ffuu End
Class Bobo < Ffuu End
Class Bpbp < Ffuu End

(* 42 *)

generation_syntax deep flush_all

end
