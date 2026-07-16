/* -------------------------------------------------------------------------
   Bundle: "Cohort: Analysis" block from
   "Step 8.Descriptive and Regression Analyses.sas"
   (Table S1 descriptive statistics + Table S2 Cox regression, the
   %adjusted1/%adjusted2 macros run against time_LMP/event_LMP).

   This is the repo's immortal-time-bias correction in its final form: two
   Cox proportional-hazards models (PROC PHREG) predicting time-to-GDM from
   COVID exposure, one unadjusted and one covariate-adjusted, run with
   RISKLIMITS to get hazard-ratio confidence intervals. Reproduced verbatim
   -- including the %adjusted1/%adjusted2 macro definitions -- except for
   the LIBNAME source, which is replaced with a small mock cohort shaped
   like sub.sub7_v6_cohort (the survival-time/event fields Step 7 derives).
   ------------------------------------------------------------------------- */

/* ---- mock cohort: shaped like sub.sub7_v6_cohort (Step 7 output) ---- */
data sub8_cohort;
  input id_m $ ccid pair_id age age_ga24 COVID living_p1 income NAT
        Obese_new POS_new S_COVID vac_count_new time_LMP event_LMP;
  if living_p1 = 22 then living_p1 = 21;
  datalines;
B001 1 201 27 27.5 1 4  1 1 0 0 0 1 879   0
B002 0 201 26 26.5 0 4  1 1 0 0 0 0 851   0
B003 1 202 31 31.6 0 15 4 2 1 0 1 1 180  1
B004 0 202 30 30.6 1 15 4 2 0 0 0 1 759   0
B005 1 203 22 22.6 1 9  1 1 1 1 0 1 167  1
B006 0 203 23 23.6 0 9  1 1 0 0 0 0 698   0
B007 1 204 35 35.5 0 21 3 1 0 0 0 0 635   0
B008 0 204 34 34.5 1 21 3 1 0 0 0 1 734   0
B009 1 205 29 29.6 1 1  2 2 0 0 1 1 117   0
B010 0 205 28 28.6 0 1  2 2 0 0 0 0 590   0
B011 1 206 33 33.5 0 4  3 1 1 0 0 1 402   0
B012 0 206 32 32.5 1 4  3 1 0 1 0 0 812   0
B013 1 207 24 24.6 1 15 1 2 0 0 1 1 210  1
B014 0 207 25 25.6 0 15 1 2 1 0 0 1 640   0
B015 1 208 30 30.5 0 9  2 1 0 1 0 0 505   0
B016 0 208 29 29.5 1 9  2 1 1 0 1 1 322   0
;
run;

/* ---- verbatim from Step 8 "Cohort: Analysis" (Table S1 descriptive statistics) ---- */
proc means data=sub8_cohort mean std median p25 p75 min max maxdec=1;
  var age;
run;

proc means data=sub8_cohort mean std median p25 p75 min max maxdec=1;
  class ccid;
  var age;
run;

proc means data=sub8_cohort mean std median p25 p75 min max maxdec=1;
  var age_ga24;
run;

proc means data=sub8_cohort mean std median p25 p75 min max maxdec=1;
  class ccid;
  var age_ga24;
run;

proc ttest data=sub8_cohort;
  class ccid;
  var age;
run;

proc ttest data=sub8_cohort;
  class ccid;
  var age_ga24;
run;

proc freq data=sub8_cohort;
  table (event_LMP S_COVID vac_count_new Obese_new POS_new living_p1 income NAT) * ccid / norow chisq;
run;

/* ---- verbatim from Step 8 "Table S2: Cox Regression" ---- */
%macro adjusted1(time, event);
proc phreg data=sub8_cohort;
  class COVID (ref='0') living_p1 (ref='1');
  model &time.*&event.(0) = COVID age living_p1 / risklimits;
  id pair_id;
run;
%mend;

%macro adjusted2(time, event);
proc phreg data=sub8_cohort;
  class COVID (ref='0') living_p1 (ref='1') Obese_new (ref='0') POS_new (ref='0')
        NAT (ref='1') income (ref='4') S_COVID (ref='0')
        vac_count_new (ref='0');
  model &time.*&event.(0) = COVID age living_p1 Obese_new POS_new NAT income vac_count_new / risklimits;
  id pair_id;
run;
%mend;

%adjusted1(time_LMP, event_LMP)
%adjusted2(time_LMP, event_LMP)
