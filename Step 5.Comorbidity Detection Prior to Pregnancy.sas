/* Load libraries */
libname org "E:\\H111216\\data";
libname org_6 "E:\\H111216\\data\\data_H111216-6";
libname sub "E:\\H111216\\CJC\\LIN\\01_COVID_GDM\\Data\\Subject";
libname CF_D "E:\\H111216\\CJC\\LIN\\01_COVID_GDM\\Data\\CF_D";
libname GDM "E:\\H111216\\CJC\\LIN\\01_COVID_GDM\\Data\\GDM";

/* Combine outpatient (CD) and inpatient (DD) diagnosis codes */
/* (Step 5 code simplified: Full macro loops omitted for brevity) */
data CF_D.CD_CF_D;
  set CD107-CD111;
run;

data CF_D.DD_CF_D;
  set DD107-DD111;
run;

/* Extract DM/Obese/POS with valid timing */
%macro CDDD1(x);
  data CD_&x.;
    set CF_D.CD_CF_D;
    where &x. = 1;
    keep ID &x. func_date;
  run;

  proc sort data=CD_&x.; by ID func_date; run;

  data CD_&x.;
    set CD_&x.;
    by ID func_date;
    retain t 0;
    t + 1;
    if first.ID then t = 1;
    &x._date = lag(func_date);
    if t < 3 then &x._date = "";
  run;

  data CD_&x.;
    set CD_&x.;
    func_date1 = input(func_date, yymmdd10.);
    &x._date1 = input(&x._date, yymmdd10.);
    if &x._date = "" then right = "0";
    else if (func_date1 - &x._date1) < 365.25 then right = "1";
    else right = "2";
  run;

  data CD_&x.;
    set CD_&x.;
    where right = "1";
  run;

  data DD_&x.;
    set CF_D.DD_CF_D;
    where &x. = 1;
    rename in_date = &x._date;
    keep ID &x. in_date;
  run;

  data &x.;
    set CD_&x. DD_&x.;
  run;

  proc sort data=&x.; by ID &x._date; run;

  data &x.;
    set &x.;
    by ID &x._date;
    if first.ID then output;
    keep ID &x. &x._date;
  run;
%mend;
%CDDD1(DM)
%CDDD1(Obese)
%CDDD1(POS)

/* GDM only needs earliest record */
%macro CDDD2(x);
  data CD_&x.;
    set CF_D.CD_CF_D;
    where &x. = 1;
    rename func_date = &x._cf_d_date;
    rename &x. = &x._cf_d;
    keep ID &x. func_date;
  run;

  data DD_&x.;
    set CF_D.DD_CF_D;
    where &x. = 1;
    rename in_date = &x._cf_d_date;
    rename &x. = &x._cf_d;
    keep ID &x. in_date;
  run;

  data &x.;
    set CD_&x. DD_&x.;
  run;

  proc sort data=&x.; by ID &x._cf_d_date; run;

  data &x.;
    set &x.;
    by ID &x._cf_d_date;
    if first.ID then output;
    keep ID &x._cf_d &x._cf_d_date;
  run;
%mend;
%CDDD2(GDM)

/* Merge all comorbidities into subject table */
data sub5_1;
  set sub.sub4_v3;
run;

%macro MergeComorb(x);
  proc sql;
    create table sub5_1 as
    select *
    from sub5_1 as a
    left join &x. as b on a.id_m = b.id;
  quit;

  data sub5_1;
    set sub5_1;
    &x._date1 = input(&x._date, yymmdd10.);
    if &x. = . then &x. = 0;
    format &x._date1 yymmdd10.;
    drop &x._date;
  run;

  data sub5_1;
    set sub5_1;
    rename &x._date1 = &x._date;
  run;
%mend;
%MergeComorb(DM)
%MergeComorb(Obese)
%MergeComorb(POS)

proc sql;
  create table sub5_1 as
  select *
  from sub5_1 as a
  left join GDM as b on a.id_m = b.id;
quit;

data sub5_1;
  set sub5_1;
  GDM_cf_d_date1 = input(GDM_cf_d_date, yymmdd10.);
  if GDM_cf_d = . then GDM_cf_d = 0;
  format GDM_cf_d_date1 yymmdd10.;
  drop GDM_cf_d_date;
run;

data sub5_1;
  set sub5_1;
  rename GDM_cf_d_date1 = GDM_cf_d_date;
run;

/* Exclude those with DM or GDM before pregnancy (LMP/index_date) */
data sub5_2;
  set sub5_1;
  if DM_date ^= . and DM_date <= index_date then delete;
  if GDM_cf_d_date ^= . and GDM_cf_d_date <= index_date then delete;
run;

/* Recalculate vaccination doses before 21 gestational weeks */
data sub5_3;
  set sub5_2;
  array vacs{4} InoculationDate1-InoculationDate4;
  array vac_n{4} InoculationDate_n1-InoculationDate_n4;
  do i = 1 to 4;
    vac_n{i} = input(vacs{i}, yymmdd10.);
  end;
  end_date = index_date + (21 * 7);
  vac_count_new = 0;
  do i = 1 to 4;
    if vac_n{i} ^= . and vac_n{i} < end_date then vac_count_new + 1;
  end;
  drop i end_date InoculationDate_n1-InoculationDate_n4;
run;

/* Restrict COVID infections to first 24 weeks of pregnancy */
data sub5_4;
  set sub5_3;
  end_date = index_date + (24 * 7);
  if COVID_date ^= . and end_date < COVID_date then delete;
  if GDM = . then GDM = 0;
  drop end_date;
run;

/* Recode comorbidities based on timing */
data sub5_5;
  set sub5_4;
run;

%macro RecodeComorb(x);
  data sub5_5;
    set sub5_5;
    &x._new = &x.;
    if &x._date ^= . and index_date < &x._date then &x._new = 0;
  run;
%mend;
%RecodeComorb(DM)
%RecodeComorb(Obese)
%RecodeComorb(POS)

/* Final Output */
data sub.sub5_v5;
  set sub5_5;
run;
