/* -------------------------------------------------------------------------
   Bundle: cohort variable-derivation block from
   "Step 7.Variable Derivation for Case-Control and Cohort Analyses.sas"
   (the "Cohort: Define derived variables" section, sub7_2 -> sub7_3).

   This is the immortal-time-bias correction at the heart of the repo: for
   each subject it builds a censoring date as the earliest of {GDM diagnosis,
   death, 31DEC2022}, derives survival time from two different index points
   (LMP-based and 24-weeks-gestation-based), and flags whether the GDM event
   actually falls inside that window. Reproduced verbatim below except for
   the LIBNAME/dataset source, which is replaced with a small mock cohort
   shaped like the sub.sub6_v6_cohort table this step reads upstream.
   ------------------------------------------------------------------------- */

/* ---- mock cohort: shaped like sub.sub6_v6_cohort (Step 6 output) ----
   (date fields use the ":" list-input modifier so the informat scans to
   the next blank column, per documented SAS list-input-with-informat
   behavior) */
data sub7_1;
  format birthday yymmdd10. index_date yymmdd10. covid_date yymmdd10.
         gdm_date yymmdd10. d_date yymmdd10.;
  input id_m $ birthday :yymmdd10. index_date :yymmdd10. age week
        NAT_M $ covid covid_date :yymmdd10. Covid_ModerateorSevere_Status1
        vac_count_new living_p1 gdm_date :yymmdd10. d_date :yymmdd10. ccid pair_id;
  datalines;
A001 2021-03-10 2020-08-04 27 26 00 1 2020-09-01 0 1 4 . . 1 101
A002 2021-04-22 2020-09-15 31 28 00 0 . . 0 0 9 2021-01-10 . 0 101
A003 2021-06-01 2020-11-02 22 30 01 1 2020-12-20 1 2 15 . 2021-05-01 1 102
A004 2021-07-18 2020-12-27 35 24 00 0 . . 1 1 4 . . 0 102
A005 2021-09-09 2021-02-15 29 25 00 1 2021-03-01 0 0 9 2021-08-01 . 1 103
A006 2021-10-30 2021-04-05 24 27 00 0 . . 0 3 21 . . 0 103
;
run;

/* ---- verbatim from Step 7 "Cohort: Define derived variables" ---- */
data sub7_2;
  set sub7_1;
  ga_gdm = (GDM_date - index_date) / 7;
  if NAT_M = "00" then NAT = 1; else NAT = 2;

  if covid = 0 then covid_lmp = 0;
  else if covid = 1 and covid_date <= index_date then covid_lmp = 1;
  else if covid = 1 and covid_date > index_date then covid_lmp = 2;

  if Covid_ModerateorSevere_Status1 = . then Covid_ModerateorSevere_Status1 = 0;
  if vac_count_new = . or vac_count_new = 0 then vac_count_new = 0; else vac_count_new = 1;

  if age < 25 then age_g = 1;
  else if 25 <= age < 30 then age_g = 2;
  else if 30 <= age < 35 then age_g = 3;
  else if 35 <= age then age_g = 4;

  if week < 12 then week_g = 1;
  else if 12 <= week < 24 then week_g = 2;
  else if 24 <= week then week_g = 3;

  COVID_GA12 = COVID;
  COVID_GA12_date = COVID_date;
  end_date = index_date + (13 * 7);
  if COVID_date ^= . and COVID_date >= end_date then do;
    COVID_GA12 = 0;
    COVID_GA12_date = .;
  end;
  format COVID_GA12_date yymmdd10.;
  drop end_date;

  if index_date < mdy(04,01,2022) then index_date_220401 = 1;
  else index_date_220401 = 2;
run;

data sub7_3;
  set sub7_2;
  format censor_date yymmdd10. end_date_LMP yymmdd10. end_date_24 yymmdd10. death_date yymmdd10. birth_date yymmdd10.;
  censor_date = '31DEC2022'd;
  birth_date = birthday;

  array dates[2] gdm_date d_date;
  do i = 1 to 2;
    if dates[i] = . then dates[i] = '31DEC2100'd;
  end;
  end_date_LMP = min(of dates[*], censor_date);
  drop i;

  array dates_24[2] gdm_date d_date;
  do j = 1 to 2;
    if dates_24[j] = . then dates_24[j] = '31DEC2100'd;
  end;
  end_date_24 = min(of dates_24[*], censor_date);
  drop j;

  if end_date_LMP >= index_date then time_LMP = end_date_LMP - index_date;
  else time_LMP = 0;

  if end_date_24 >= (index_date + 24*7) then time_24 = end_date_24 - (index_date + 24*7);
  else time_24 = 0;

  if gdm_date ne . and gdm_date = end_date_LMP and gdm_date >= index_date then event_LMP = 1;
  else event_LMP = 0;

  if gdm_date ne . and gdm_date = end_date_24 and gdm_date >= index_date then event_24 = 1;
  else event_24 = 0;

  age_ga24 = ((index_date + 24*7) - (birth_date - (age*365.25))) / 365.25;

  if 23 < ga_gdm <= 28 then ga_gdm_g = 1;
  else if 28 < ga_gdm <= 33 then ga_gdm_g = 2;
  else if 33 < ga_gdm then ga_gdm_g = 3;
  else ga_gdm_g = 0;
run;

proc print data=sub7_3 label;
  var id_m index_date gdm_date d_date censor_date end_date_LMP end_date_24
      time_LMP time_24 event_LMP event_24 ga_gdm_g;
run;
