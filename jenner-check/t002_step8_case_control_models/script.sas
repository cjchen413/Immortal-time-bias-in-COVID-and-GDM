/* -------------------------------------------------------------------------
   Bundle: "Case-Control: Analysis" block from
   "Step 8.Descriptive and Regression Analyses.sas"
   (Table 1 descriptive statistics + Table 2 conditional-logistic-style
   models, verbatim through the first two PROC LOGISTIC models).

   This is the paper's headline analysis: a matched case-control comparison
   of COVID-19 exposure between GDM cases and non-GDM controls, adjusted for
   age, residence region, obesity, PCOS, nationality, income and vaccination.
   Reproduced verbatim except for the LIBNAME source, which is replaced with
   a small mock analytic cohort shaped like sub.sub7_v6_case_ctrl.
   ------------------------------------------------------------------------- */

/* ---- mock analytic cohort: shaped like sub.sub7_v6_case_ctrl (Step 7 output) ---- */
data sub8_case_ctrl;
  input id_m $ ccid pair_id age ga_gdm COVID living_p1 income NAT
        Obese_new POS_new S_COVID vac_count_new covid_lmp;
  if living_p1 = 22 then living_p1 = 21;
  datalines;
A001 1 101 27 25.4 1 4  1 1 0 0 0 1 1
A002 0 101 26 .    0 4  1 1 0 0 0 0 0
A003 1 102 31 29.1 0 15 4 2 1 0 1 1 0
A004 0 102 30 .    1 15 4 2 0 0 0 1 2
A005 1 103 22 33.8 1 9  1 1 1 1 0 1 1
A006 0 103 23 .    0 9  1 1 0 0 0 0 0
A007 1 104 35 27.0 0 21 3 1 0 0 0 0 0
A008 0 104 34 .    1 21 3 1 0 0 0 1 1
A009 1 105 29 31.5 1 1  2 2 0 0 1 1 2
A010 0 105 28 .    0 1  2 2 0 0 0 0 0
A011 1 106 33 26.8 0 4  3 1 1 0 0 1 0
A012 0 106 32 .    1 4  3 1 0 1 0 0 2
A013 1 107 24 30.2 1 15 1 2 0 0 1 1 1
A014 0 107 25 .    0 15 1 2 1 0 0 1 0
A015 1 108 30 28.6 0 9  2 1 0 1 0 0 0
A016 0 108 29 .    1 9  2 1 1 0 1 1 1
A017 1 109 26 32.4 1 21 4 2 0 0 0 0 2
A018 0 109 27 .    0 21 4 2 0 0 0 1 0
A019 1 110 34 27.9 0 1  3 1 1 0 0 0 0
A020 0 110 33 .    1 1  3 1 0 0 1 1 1
;
run;

/* ---- verbatim from Step 8 "Case-Control: Analysis" (Table 1 + first two Table 2 models) ---- */
proc means data=sub8_case_ctrl mean std median p25 p75 min max maxdec=1;
  var age ga_gdm;
run;

proc means data=sub8_case_ctrl mean std median p25 p75 min max maxdec=1;
  class ccid;
  var age ga_gdm;
run;

proc ttest data=sub8_case_ctrl;
  class ccid;
  var age;
run;

proc freq data=sub8_case_ctrl;
  table COVID*ccid / norow chisq;
run;

proc freq data=sub8_case_ctrl;
  where covid = 1;
  table covid_lmp*ccid / norow chisq;
run;

proc freq data=sub8_case_ctrl;
  table (S_COVID vac_count_new Obese_new POS_new living_p1 income NAT) * ccid / norow chisq;
run;

proc logistic data=sub8_case_ctrl;
  class COVID (ref='0') living_p1 (ref='1');
  model ccid(event='1') = COVID age living_p1;
  id pair_id;
run;

proc logistic data=sub8_case_ctrl;
  class COVID (ref='0') living_p1 (ref='1') Obese_new (ref='0') POS_new (ref='0')
        NAT (ref='1') income (ref='4') S_COVID (ref='0')
        vac_count_new (ref='0');
  model ccid(event='1') = COVID age living_p1 Obese_new POS_new NAT income vac_count_new;
  id pair_id;
run;
