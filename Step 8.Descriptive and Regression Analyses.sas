/* Load libraries */
libname org "E:\\H111216\\data";
libname org_6 "E:\\H111216\\data\\data_H111216-6";
libname sub "E:\\H111216\\CJC\\LIN\\01_COVID_GDM\\Data\\Subject";

/* Case-Control: Analysis */
data sub8_case_ctrl;
  set sub.sub7_v6_case_ctrl;
  if living_p1 = 22 then living_p1 = 21;
run;

/* Table 1: Descriptive Statistics */
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

/* Table 2: Logistic Regression Models */
proc logistic data=sub8_case_ctrl;
  class COVID (ref='0') living_p1 (ref='1');
  model ccid(event='1') = COVID age living_p1;
  id pair_id;
run;

proc logistic data=sub8_case_ctrl;
  class COVID (ref='0') living_p1 (ref='1') Obese_new (ref='0') POS_new (ref='0')
        NAT (ref='1') income (ref='4') S_COVID (ref='0')
        Covid_ModerateorSevere_Status1 (ref='0') vac_count_new (ref='0');
  model ccid(event='1') = COVID age living_p1 Obese_new POS_new NAT income vac_count_new;
  id pair_id;
run;

proc logistic data=sub8_case_ctrl;
  class COVID (ref='0') living_p1 (ref='1') Obese_new (ref='0') POS_new (ref='0')
        NAT (ref='1') income (ref='4') S_COVID (ref='0')
        Covid_ModerateorSevere_Status1 (ref='0') vac_count_new (ref='0');
  model ccid(event='1') = COVID age week living_p1 Obese_new POS_new NAT income vac_count_new COVID*vac_count_new;
  id pair_id;
run;

/* Sensitivity Analysis */
data sub8;
  set sub.sub7_v5;
run;

proc freq data=sub8;
  table (COVID_GA12 index_date_220401) * ccid / norow chisq;
run;

proc logistic data=sub8;
  class COVID_GA12 (ref='0') living_p1 (ref='1');
  model ccid(event='1') = COVID_GA12 age week living_p1;
  id pair_id;
run;

proc logistic data=sub8;
  class COVID_GA12 (ref='0') living_p1 (ref='1') Obese_new (ref='0') POS_new (ref='0')
        NAT (ref='1') income (ref='4') vac_count_new (ref='0');
  model ccid(event='1') = COVID_GA12 age week living_p1 Obese_new POS_new NAT income vac_count_new;
  id pair_id;
run;

proc logistic data=sub8;
  where index_date_220401 = 2;
  class COVID (ref='0') living_p1 (ref='1');
  model ccid(event='1') = COVID age week living_p1;
  id pair_id;
run;

proc logistic data=sub8;
  where index_date_220401 = 2;
  class COVID (ref='0') living_p1 (ref='1') Obese_new (ref='0') POS_new (ref='0')
        NAT (ref='1') income (ref='4') vac_count_new (ref='0');
  model ccid(event='1') = COVID age week living_p1 Obese_new POS_new NAT income vac_count_new;
  id pair_id;
run;

/* Cohort: Analysis */
data sub8_cohort;
  set sub.sub7_v6_cohort;
  if living_p1 = 22 then living_p1 = 21;
run;

/* Table S1: Descriptive Statistics */
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

proc freq data=sub8_cohort;
  table (event_24 S_COVID vac_count_new Obese_new POS_new living_p1 income NAT) * ccid / norow chisq;
run;

/* Table S2: Cox Regression */
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
        NAT (ref='1') income (ref='4') S_COVID (ref='0') Covid_ModerateorSevere_Status1 (ref='0')
        vac_count_new (ref='0');
  model &time.*&event.(0) = COVID age living_p1 Obese_new POS_new NAT income vac_count_new / risklimits;
  id pair_id;
run;
%mend;

%adjusted1(time_LMP, event_LMP)
%adjusted2(time_LMP, event_LMP)

%adjusted1(time_24, event_24)
%adjusted2(time_24, event_24)
