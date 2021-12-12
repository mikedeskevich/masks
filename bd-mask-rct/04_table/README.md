COVID-19 Face Mask Study - Tables
-----------------------------------------------

* [Introduction](#intro)
* [Table 1](#table-1)
* [Table 2](#table-2)
* [Table 3](#table-3)
* [Table 4](#table-4)
* [Table S1](#table-s1)
* [Table S2](#table-s2)
* [Table S3](#table-s3)
* [Table S4](#table-s4)
* [Table S5](#table-s5)
* [Table S6](#table-s6)
* [Table S7](#table-s7)
* [Table S8](#table-s8)
* [Table S9](#table-s9)
* [Table S10](#table-s10)
* [Table S11](#table-s11)
* [Table S12](#table-s12)
* [Table S13](#table-s13)
* [Table S14](#table-s14)
* [Table S15](#table-s15)
* [Table S16](#table-s16)
* [Table S17](#table-s17)
* [Table S18](#table-s18)
* [Table S19](#table-s19)
* [Table S20](#table-s20)
* [Table S21](#table-s21)
* [Table S22](#table-s22)
* [Table S23](#table-s23)
* [Table S24](#table-s24)
* [Table S25](#table-s25)
* [Table S26](#table-s26)
* [Table S27](#table-s27)
* [Table S28](#table-s28)
* [Table S29](#table-s29)
* [Table S30](#table-s30)

Introduction
------------

The output needed to generate each table in the main text and appendices of the paper is provided below. The file paths are defined in ``02_code\00_preamble``.

For figures, see the ``README`` in ``03_output``. 


Table 1
------------
```
${table_surv}\1a_mask_surv.dta
${table_surv}\2a_soc_dist.dta
```

Table 2
------------
Upper Panel
```
${table_blood_end}\main\3b_symp_sero_pool_no_base.dta
${table_blood_end}\main\4b_symp_sero_mask_no_base.dta
${table_blood_end}\main\summ_stats_symp_sero.dta
```
Lower Panel
```
${table_blood_end}\main\3a_symp_sero_pool.dta
${table_blood_end}\main\4a_symp_sero_mask.dta
```

Table 3
------------
Upper Panel
```
${table_blood_end}\main\7b_symp_pool_no_base.dta
${table_blood_end}\main\8b_symp_mask_no_base.dta
${table_blood_end}\main\summ_stats_symp.dta
```
Lower Panel
```
${table_blood_end}\main\7a_symp_pool.dta
${table_blood_end}\main\8a_symp_mask.dta
```


Table 4
------------
Upper Panel, Column 1
```
${table_blood_end}\main\4a_symp_sero_mask.dta
${table_blood_end}\main\summ_stats_symp_sero.dta
```

Upper Panel, Columns 2-5
```
${table_blood_end}\robustness\age_bin\4a_symp_sero_mask.dta
${table_blood_end}\robustness\age_bin\summ_stats_symp_sero.dta
```

Lower Panel, Column 1
```
${table_blood_end}\simulation\4a_symp_sero_mask.dta
${table_blood_end}\simulation\summ_stats_symp_sero.dta
```


Lower Panel, Columns 2-5
```
${table_blood_end}\simulation\age_bin\4a_symp_sero_mask.dta
${table_blood_end}\simulation\age_bin\summ_stats_symp_sero.dta
```


Table S1
------------
```
${code}\logs\tables1_`date'.log
```


Table S2
------------
```
${code}\logs\tables2_`date'.log
```

Table S3
------------
```
${code}\logs\tables3_`date'.log
```

Table S4
------------
```
${table_com}\1_balance_test_vill.dta
${code}\logs\tables4_`date'.log
```

Table S5
------------
```
${table_surv}\1b_mask_surv_no_base.dta
${table_surv}\2b_soc_dist_no_base.dta
${table_surv}\summ_stats.dta
```

Table S6
------------
```
${table_surv}\3a_n_surv.dta
${table_surv}\3b_n_surv_no_base.dta
${table_surv}\summ_stats.dta
```


Table S7
------------
Top Panel, Left Column
```
${table_blood_end}\main\1b_symp_sero_pool_no_base.dta
${table_blood_end}\main\summ_stats_symp_sero.dta
```
Top Panel, Right Column
```
${table_blood_end}\main\2b_symp_sero_mask_no_base.dta
${table_blood_end}\main\summ_stats_symp_sero.dta
```
Bottom Panel, Left Column
```
${table_blood_end}\main\1a_symp_sero_pool.dta
```
Bottom Panel, Right Column
```
${table_blood_end}\main\2a_symp_sero_mask.dta
```

Table S8
------------
Top Panel, Left Column
```
${table_blood_end}\main\5b_symp_pool_no_base.dta
${table_blood_end}\main\summ_stats_symp.dta
```
Top Panel, Right Column
```
${table_blood_end}\main\6b_symp_mask_no_base.dta
${table_blood_end}\main\summ_stats_symp.dta
```
Bottom Panel, Left Column
```
${table_blood_end}\main\5a_symp_pool.dta
```
Bottom Panel, Right Column
```
${table_blood_end}\main\6a_symp_mask.dta
```

Table S9
------------
Top Panel, Left Column
```
${table_blood_end}\robustness\symp_sero_sample\5b_symp_pool_no_base.dta
${table_blood_end}\robustness\symp_sero_sample\summ_stats_symp.dta
```
Top Panel, Right Column
```
${table_blood_end}\robustness\symp_sero_sample\6b_symp_mask_no_base.dta
${table_blood_end}\robustness\symp_sero_sample\summ_stats_symp.dta
```
Bottom Panel, Left Column
```
${table_blood_end}\robustness\symp_sero_sample\5a_symp_pool.dta
```
Bottom Panel, Right Column
```
${table_blood_end}\robustness\symp_sero_sample\6a_symp_mask.dta
```

Table S10
------------
```
${code}\logs\tables10_`date'.log
```

Table S11
------------
Top Panel
```
${table_surv}\4b_mask_surv_subgroup_no_base.dta
```
Bottom Panel
```
${table_surv}\4a_mask_surv_subgroup.dta
```

Table S12
------------
Upper Panel, Column 1
```
${table_blood_end}\main\1b_symp_sero_pool_no_base.dta
${table_blood_end}\main\summ_stats_symp_sero.dta
```

Upper Panel, Columns 2-7
```
${table_blood_end}\robustness\age_dec\1b_symp_sero_pool_no_base.dta
${table_blood_end}\robustness\age_dec\summ_stats_symp_sero.dta
```
Bottom Panel, Column 1
```
${table_blood_end}\main\1a_symp_sero_pool.dta
```
Bottom Panel, Columns 2-7
```
${table_blood_end}\robustness\age_dec\1a_symp_sero_pool.dta
```

Table S13
------------
Upper Panel, Column 1
```
${table_blood_end}\main\6b_symp_mask_no_base.dta
${table_blood_end}\main\summ_stats_symp.dta
```
Upper Panel, Columns 2-5
```
${table_blood_end}\robustness\age_bin\6b_symp_mask_no_base.dta
${table_blood_end}\robustness\age_bin\summ_stats_symp.dta
```
Bottom Panel, Column 1
```
${table_blood_end}\main\6a_symp_mask.dta
```
Bottom Panel, Columns 2-5
```
${table_blood_end}\robustness\age_bin\6a_symp_mask.dta
```


Table S14
------------
Upper Panel, Column 1
```
${table_blood_end}\main\5b_symp_pool_no_base.dta
${table_blood_end}\main\summ_stats_symp.dta
```
Upper Panel, Columns 2-7
```
${table_blood_end}\robustness\age_dec\5b_symp_pool_no_base.dta
```
Bottom Panel, Column 1
```
${table_blood_end}\main\5a_symp_pool.dta
```
Bottom Panel, Columns 2-7
```
${table_blood_end}\robustness\age_dec\5a_symp_pool.dta
```

Table S15
------------
Upper Panel, Column 1
```
${table_blood_end}\main\8b_symp_mask_no_base.dta
${table_blood_end}\main\summ_stats_symp.dta
```
Upper Panel, Columns 2-5
```
${table_blood_end}\robustness\age_bin\8b_symp_mask_no_base.dta
${table_blood_end}\robustness\age_bin\summ_stats_symp.dta
```
Bottom Panel, Column 1
```
${table_blood_end}\main\8a_symp_mask.dta
```
Bottom Panel, Columns 2-5
```
${table_blood_end}\robustness\age_bin\8a_symp_mask.dta
```

Table S16
------------
```
${table_surv}\6b_vill_cross_rand_no_base.dta
${table_surv}\6a_vill_cross_rand.dta
```

Table S17
------------
```
${table_surv}\7_hh_cross_rand.dta
```

Table S18
------------
```
${table_com}\2_balance_test_ind.dta
${code}\logs\tables18_`date'.log
```

Table S19
------------
```
${table_com}\3_balance_test_ind_add.dta
${code}\logs\tables19_`date'.log
```

Table S20
------------
```
${table_com}\4_balance_test_ind_add_sample_sel.dta
${code}\logs\tables20_`date'.log
```


Table S21
------------
Top Panel, Left Column
```
${table_blood_end}\robustness\add_controls\1a_symp_sero_pool.dta
${table_blood_end}\robustness\add_controls\summ_stats_symp_sero.dta
```

Top Panel, Right Column
```
${table_blood_end}\robustness\add_controls\2a_symp_sero_mask.dta
${table_blood_end}\robustness\add_controls\summ_stats_symp_sero.dta
```
Bottom Panel, Left Column
```
${table_blood_end}\robustness\add_sample_selection\1a_symp_sero_pool.dta
${table_blood_end}\robustness\add_sample_selection\summ_stats_symp_sero.dta
```
Bottom Panel, Right Column
```
${table_blood_end}\robustness\add_sample_selection\2a_symp_sero_mask.dta
${table_blood_end}\robustness\add_sample_selection\summ_stats_symp_sero.dta
```

Table S22
------------
Top Panel
```
${table_surv}\5a_mask_surv_pers_cons_panel.dta
```
Bottom Panel
```
${table_surv}\5b_mask_surv_pers_incons_panel.dta
```

Table S23
------------
Top Panel
```
${table_surv}\8a_mask_surv_by_wave.dta
```
Bottom Panel
```
${table_surv}\9a_soc_dist_by_wave.dta
```

Table S24
------------
Upper Panel, Column 1
```
${table_blood_end}\main\1a_symp_sero_pool.dta
${table_blood_end}\main\summ_stats_symp_sero.dta
```

Upper Panel, Columns 2-5
```
${table_blood_end}\robustness\wave\1a_symp_sero_pool.dta
${table_blood_end}\robustness\wave\summ_stats_symp_sero.dta
```

Lower Panel, Column 1
```
${table_blood_end}\simulation\1a_symp_sero_pool.dta
${table_blood_end}\simulation\summ_stats_symp_sero.dta
```


Lower Panel, Columns 2-5
```
${table_blood_end}\simulation\wave\1a_symp_sero_pool.dta
${table_blood_end}\simulation\wave\summ_stats_symp_sero.dta
```

Table S25
------------
```
${code}\logs\tables25_`date'.log
```

Table S26
------------
Upper Panel, Column 1
```
${table_blood_end}\main\3a_symp_sero_pool.dta
${table_blood_end}\main\summ_stats_symp_sero.dta
```
Upper Panel, Columns 2-5
```
${table_blood_end}\robustness\age_bin\3a_symp_sero_pool.dta
${table_blood_end}\robustness\age_bin\summ_stats_symp_sero.dta
```
Bottom Panel, Column 1
```
${table_blood_end}\simulation\3a_symp_sero_pool.dta
${table_blood_end}\simulation\summ_stats_symp_sero.dta
```
Bottom Panel, Columns 2-5
```
${table_blood_end}\simulation\age_bin\3a_symp_sero_pool.dta
${table_blood_end}\simulation\age_bin\summ_stats_symp_sero.dta
```

Table S27
------------
Upper Panel, Column 1
```
${table_blood_end}\main\3a_symp_sero_pool.dta
${table_blood_end}\main\4a_symp_sero_mask.dta
${table_blood_end}\main\summ_stats_symp_sero.dta
```

Upper Panel, Columns 2-3
```
${table_blood_end}\robustness\sex\3a_symp_sero_pool.dta
${table_blood_end}\robustness\sex\4a_symp_sero_mask.dta
${table_blood_end}\robustness\sex\summ_stats_symp_sero.dta
```

Bottom Panel, Column 1
```
${table_blood_end}\simulation\3a_symp_sero_pool.dta
${table_blood_end}\simulation\4a_symp_sero_mask.dta
${table_blood_end}\simulation\summ_stats_symp_sero.dta
```

Bottom Panel, Columns 2-3
```
${table_blood_end}\simulation\sex\3a_symp_sero_pool.dta
${table_blood_end}\simulation\sex\4a_symp_sero_mask.dta
${table_blood_end}\simulation\sex\summ_stats_symp_sero.dta
```

Table S28
------------
Upper Panel, Column 1
```
${table_blood_end}\main\7b_symp_pool_no_base.dta
${table_blood_end}\main\8b_symp_mask_no_base.dta
${table_blood_end}\main\summ_stats_symp.dta
```
Upper Panel, Columns 2-3
```
${table_blood_end}\robustness\sex\7b_symp_pool_no_base.dta
${table_blood_end}\robustness\sex\8b_symp_mask_no_base.dta
${table_blood_end}\robustness\sex\summ_stats_symp.dta
```
Bottom Panel, Column 1
```
${table_blood_end}\main\7a_symp_pool.dta
${table_blood_end}\main\8a_symp_mask.dta
${table_blood_end}\main\summ_stats_symp.dta
```
Bottom Panel, Columns 2-3
```
${table_blood_end}\robustness\sex\7a_symp_pool.dta
${table_blood_end}\robustness\sex\8a_symp_mask.dta
${table_blood_end}\robustness\sex\summ_stats_symp.dta
```
Table S29
------------
Upper Panel
```
${table_blood_end}\robustness\diff_first_stage\2_symp.dta
```
Bottom Panel
```
${table_blood_end}\robustness\diff_first_stage\1_symp_sero.dta
```

Table S30
------------
Upper Panel
```
${table_blood_end}\robustness\iv\1b_symp_sero_pool_no_base.dta
${table_blood_end}\robustness\iv\2b_symp_pool_no_base.dta
```
Bottom Panel
```
${table_blood_end}\robustness\iv\1a_symp_sero_pool.dta
${table_blood_end}\robustness\iv\2a_symp_pool.dta
```