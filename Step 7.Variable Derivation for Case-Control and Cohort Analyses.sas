/* Load libraries */
libname org "E:\\H111216\\data";
libname org_6 "E:\\H111216\\data\\data_H111216-6";
libname sub "E:\\H111216\\CJC\\LIN\\01_COVID_GDM\\Data\\Subject";

/* Case-Control: Define derived variables */
data sub7_1;
  set sub.sub6_v6_case_ctrl;
run;

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

data sub.sub7_v6_case_ctrl;
  set sub7_2;
run;

/* Cohort: Define derived variables */
data sub7_1;
  set sub.sub6_v6_cohort;
run;

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
  birth_date = input(birthday, yymmdd10.);

  array dates[2] gdm_date death_date;
  do i = 1 to 2;
    if dates[i] = . then dates[i] = '31DEC2100'd;
  end;
  end_date_LMP = min(of dates[*], censor_date);
  drop i;

  array dates_24[2] gdm_date death_date;
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

  BIRTH_YM_M1 = BIRTH_YM_M || "15";
  BIRTH_YM_M1 = input(BIRTH_YM_M1, yymmdd10.);
  age_ga24 = ((index_date + 24*7) - BIRTH_YM_M1) / 365.25;
  drop BIRTH_YM_M1;

  if 23 < ga_gdm <= 28 then ga_gdm_g = 1;
  else if 28 < ga_gdm <= 33 then ga_gdm_g = 2;
  else if 33 < ga_gdm then ga_gdm_g = 3;
  else ga_gdm_g = 0;
run;

data sub.sub7_v6_cohort;
  set sub7_3;
run;
