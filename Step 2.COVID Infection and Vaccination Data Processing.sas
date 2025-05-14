/* Load libraries */
libname org "E:\H111216\data";
libname org_6 "E:\H111216\data\data_H111216-6";
libname sub "E:\H111216\CJC\LIN\01_COVID_GDM\Data\Subject";
libname BR "E:\H111216\CJC\LIN\01_COVID_GDM\Data\BR";
libname COVID "E:\H111216\CJC\LIN\01_COVID_GDM\Data\COVID";

/* Vaccine brand frequencies */
proc freq data = org_6.H_CDC_COVID19_1;
table Brand1 Brand2 Brand3 Brand4;
run;

/* Exclude missing ID or first dose is '0' */
data covid1_2; /* 26,048,781 */
  set org_6.H_CDC_COVID19_1;
  if Brand1 = "0" or id = " " then delete;
run;

proc sort data=covid1_2;
  by id;
run;

/* Count number of vaccine doses */
data covid1_3;
  set covid1_2;
  vac_count = 0;
  if Brand1 ^= " " then vac_count + 1;
  if Brand2 ^= " " then vac_count + 1;
  if Brand3 ^= " " then vac_count + 1;
  if Brand4 ^= " " then vac_count + 1;
run;

proc freq data = covid1_3;
table vac_count;
run;

/* Identify duplicate ID cases */
proc sql;
  create table covid.same_id_vac as
  select *, count(*) as count
  from covid1_3
  group by ID
  having count(*) > 1
  order by ID;
quit;

/* Remove ambiguous duplicates (n = 36,389) */
proc sql;
  create table covid1_4 as
  select *
  from covid1_3
  where id not in (select id from covid.same_id_vac)
  order by id;
quit;

/* Process diagnosis records */
data covid2_1;
  set org_6.H_CDC_COVID19_2;
  if Covid_DiagnosedDate ^= " ";
run;

data covid2_2;
  set covid2_1;
  Covid_DiagnosedDate1 = input(Covid_DiagnosedDate, mmddyy10.);
  Covid_ModerateorSevere_Status1 = input(Covid_ModerateorSevere_Status, 10.);
  Covid_DeathStatus1 = input(Covid_DeathStatus, 10.);
  format Covid_DiagnosedDate1 yymmdd10.;
  drop Covid_DiagnosedDate Covid_ModerateorSevere_Status Covid_DeathStatus;
run;

/* Identify repeat infections */
proc sql;
  create table same_id as
  select *, count(*) as count
  from covid2_2
  group by ID
  having count(*) > 1
  order by ID, Covid_DiagnosedDate1;
quit;

/* Filter first moderate/severe case if multiple */
data ModerateorSevere;
  set same_id;
  if Covid_ModerateorSevere_Status1 = 1;
run;

proc sort data=ModerateorSevere;
  by id;
run;

data ModerateorSevere1;
  set ModerateorSevere;
  by id;
  if first.id;
run;

/* Retain first infection per ID */
proc sort data=covid2_2;
  by id Covid_DiagnosedDate1;
run;

data covid2_3;
  set covid2_2;
  by id;
  if first.id;
run;

/* Exclude cases with >5 infections */
proc sql;
  create table covid2_4 as
  select *
  from covid2_3
  where id not in (select id from same_id where count > 5)
  order by id, Covid_DiagnosedDate1;
quit;

/* Merge severe status */
proc sql;
  create table covid2_5 as
  select a.*, b.Covid_ModerateorSevere_Status1 as Covid_ModerateorSevere_Status2
  from covid2_4 as a
  left join ModerateorSevere1 as b on a.id = b.id
  order by id, Covid_DiagnosedDate1;
quit;

data covid2_6;
  set covid2_5;
  if Covid_ModerateorSevere_Status2 = 1 then Covid_ModerateorSevere_Status1 = 1;
  drop Covid_ModerateorSevere_Status2;
run;

/* Merge vaccine and diagnosis data */
proc sql;
  create table covid.covid as
  select *
  from covid1_4 as a left join covid2_6 as b on a.id = b.id
  order by id;
quit;

/* Merge with pregnancy cohort */
proc sql;
  create table sub.sub1 as
  select *
  from BR.BRpr2 as a left join covid.covid as b on a.id_m = b.id
  order by id;
quit;

/* Full macro implementation for claims-based COVID detection including L_COVID and S_COVID */
%macro CD(a);
data CD109&a.;
  set org.h_nhi_opdte109&a._10 (keep=id func_date icd9cm_1 icd9cm_2 icd9cm_3);
  /*COVID*/
  if substr(icd9cm_1,1,3) in ("U10") or
     substr(icd9cm_2,1,3) in ("U10") or
     substr(icd9cm_3,1,3) in ("U10") or
     substr(icd9cm_1,1,4) in ("U071","U072","U099") or
     substr(icd9cm_2,1,4) in ("U071","U072","U099") or
     substr(icd9cm_3,1,4) in ("U071","U072","U099") or
     substr(icd9cm_1,1,5) in ("B9729","J1282","Z8616") or
     substr(icd9cm_2,1,5) in ("B9729","J1282","Z8616") or
     substr(icd9cm_3,1,5) in ("B9729","J1282","Z8616") then COVID=1;
  if COVID=1 then output;
  drop icd9cm_1 icd9cm_2 icd9cm_3;
run;
%do y=110 %to 111;
data CD&y.&a.;
  set org_6.h_nhi_opdte&y.&a._10 (keep=id func_date icd9cm_1 icd9cm_2 icd9cm_3);
  /*COVID*/
  if substr(icd9cm_1,1,3) in ("U10") or
     substr(icd9cm_2,1,3) in ("U10") or
     substr(icd9cm_3,1,3) in ("U10") or
     substr(icd9cm_1,1,4) in ("U071","U072","U099") or
     substr(icd9cm_2,1,4) in ("U071","U072","U099") or
     substr(icd9cm_3,1,4) in ("U071","U072","U099") or
     substr(icd9cm_1,1,5) in ("B9729","J1282","Z8616") or
     substr(icd9cm_2,1,5) in ("B9729","J1282","Z8616") or
     substr(icd9cm_3,1,5) in ("B9729","J1282","Z8616") then COVID=1;
  if COVID=1 then output;
  drop icd9cm_1 icd9cm_2 icd9cm_3;
run;
%end;
%mend;
%CD(01)%CD(02)%CD(03)%CD(04)%CD(05)%CD(06)
%CD(07)%CD(08)%CD(09)%CD(10)%CD(11)%CD(12)

%macro CD2;
%do y=109 %to 111;
data CD&y.;
  set CD&y.01-CD&y.12;
run;
%end;
%mend;
%CD2

data COVID.CD;
  set CD109-CD111;
run;

%macro DD;
data DD109;
  set org.h_nhi_ipdte109 (keep=id in_date icd9cm_1 icd9cm_2 icd9cm_3 icd9cm_4 icd9cm_5);
  /*COVID*/
  if substr(icd9cm_1,1,3) in ("U10") or
     substr(icd9cm_2,1,3) in ("U10") or
     substr(icd9cm_3,1,3) in ("U10") or
     substr(icd9cm_4,1,3) in ("U10") or
     substr(icd9cm_5,1,3) in ("U10") or
     substr(icd9cm_1,1,4) in ("U071","U072","U099") or
     substr(icd9cm_2,1,4) in ("U071","U072","U099") or
     substr(icd9cm_3,1,4) in ("U071","U072","U099") or
     substr(icd9cm_4,1,4) in ("U071","U072","U099") or
     substr(icd9cm_5,1,4) in ("U071","U072","U099") or
     substr(icd9cm_1,1,5) in ("B9729","J1282","Z8616") or
     substr(icd9cm_2,1,5) in ("B9729","J1282","Z8616") or
     substr(icd9cm_3,1,5) in ("B9729","J1282","Z8616") or
     substr(icd9cm_4,1,5) in ("B9729","J1282","Z8616") or
     substr(icd9cm_5,1,5) in ("B9729","J1282","Z8616") then COVID=1;
  if COVID=1 then output;
  drop icd9cm_1 icd9cm_2 icd9cm_3 icd9cm_4 icd9cm_5;
run;
%do y=110 %to 111;
data DD&y.;
  set org_6.h_nhi_ipdte&y. (keep=id in_date icd9cm_1 icd9cm_2 icd9cm_3 icd9cm_4 icd9cm_5);
  /*COVID*/
  if substr(icd9cm_1,1,3) in ("U10") or
     substr(icd9cm_2,1,3) in ("U10") or
     substr(icd9cm_3,1,3) in ("U10") or
     substr(icd9cm_4,1,3) in ("U10") or
     substr(icd9cm_5,1,3) in ("U10") or
     substr(icd9cm_1,1,4) in ("U071","U072","U099") or
     substr(icd9cm_2,1,4) in ("U071","U072","U099") or
     substr(icd9cm_3,1,4) in ("U071","U072","U099") or
     substr(icd9cm_4,1,4) in ("U071","U072","U099") or
     substr(icd9cm_5,1,4) in ("U071","U072","U099") or
     substr(icd9cm_1,1,5) in ("B9729","J1282","Z8616") or
     substr(icd9cm_2,1,5) in ("B9729","J1282","Z8616") or
     substr(icd9cm_3,1,5) in ("B9729","J1282","Z8616") or
     substr(icd9cm_4,1,5) in ("B9729","J1282","Z8616") or
     substr(icd9cm_5,1,5) in ("B9729","J1282","Z8616") then COVID=1;
  if COVID=1 then output;
  drop icd9cm_1 icd9cm_2 icd9cm_3 icd9cm_4 icd9cm_5;
run;
%end;
data COVID.DD;
  set DD109-DD111;
run;
%mend;
%DD

%macro CDDD(y);
/*CD*/
data CD_&y.;
  set COVID.CD;
  where &y.=1;
  rename func_date=&y._date;
  keep ID &y. func_date;
run;

proc sort data=CD_&y.; by ID &y._date; run;

/*DD*/
data DD_&y.;
  set COVID.DD;
  where &y.=1;
  rename in_date=&y._date;
  keep ID &y. in_date;
run;

proc sort data=DD_&y.; by ID &y._date; run;

/*ALL*/
data &y.; set CD_&y. DD_&y.; run;

proc sort data=&y.; by ID &y._date; run;

data &y.;
  set &y.;
  by ID &y._date;
  if first.ID then output;
  keep id &y. &y._date;
run;
%mend;
%CDDD(COVID)

data covid.covid_cddd;
  set covid;
  covid_date1 = input(covid_date, yymmdd10.);
  format covid_date1 yymmdd10.;
  drop covid_date;
run;

/* See macros: %CD, %DD, %CDDD, %CDDD1 (Long COVID), %CDDD2 (Severe COVID) */
%macro CD(a);
data CD109&a.;
  set org.h_nhi_opdte109&a._10 (keep=id func_date icd9cm_1 icd9cm_2 icd9cm_3);
  /*Long COVID*/
  if substr(icd9cm_1,1,4) in ("U099") or
     substr(icd9cm_2,1,4) in ("U099") or
     substr(icd9cm_3,1,4) in ("U099") then L_COVID=1;
  if L_COVID=1 then output;
  drop icd9cm_1 icd9cm_2 icd9cm_3;
run;
%do y=110 %to 111;
data CD&y.&a.;
  set org_6.h_nhi_opdte&y.&a._10 (keep=id func_date icd9cm_1 icd9cm_2 icd9cm_3);
  /*Long COVID*/
  if substr(icd9cm_1,1,4) in ("U099") or
     substr(icd9cm_2,1,4) in ("U099") or
     substr(icd9cm_3,1,4) in ("U099") then L_COVID=1;
  if L_COVID=1 then output;
  drop icd9cm_1 icd9cm_2 icd9cm_3;
run;
%end;
%mend;
%CD(01)%CD(02)%CD(03)%CD(04)%CD(05)%CD(06)
%CD(07)%CD(08)%CD(09)%CD(10)%CD(11)%CD(12)

%macro CD2;
%do y=109 %to 111;
data CD&y.;
  set CD&y.01-CD&y.12;
run;
%end;
%mend;
%CD2

data COVID.CD_L_COVID;
  set CD109-CD111;
run;

%macro DD;
data DD109;
  set org.h_nhi_ipdte109 (keep=id in_date icd9cm_1 icd9cm_2 icd9cm_3 icd9cm_4 icd9cm_5);
  /*Long COVID*/
  if substr(icd9cm_1,1,4) in ("U099") or
     substr(icd9cm_2,1,4) in ("U099") or
     substr(icd9cm_3,1,4) in ("U099") or
     substr(icd9cm_4,1,4) in ("U099") or
     substr(icd9cm_5,1,4) in ("U099") then L_COVID=1;
  /*Sever COVID*/
  if substr(icd9cm_1,1,4) in ("U071") or
     substr(icd9cm_2,1,4) in ("U071") or
     substr(icd9cm_3,1,4) in ("U071") or
     substr(icd9cm_4,1,4) in ("U071") or
     substr(icd9cm_5,1,4) in ("U071") then S_COVID=1;
  if L_COVID=1 or S_COVID then output;
  drop icd9cm_1 icd9cm_2 icd9cm_3 icd9cm_4 icd9cm_5;
run;
%do y=110 %to 111;
data DD&y.;
  set org_6.h_nhi_ipdte&y. (keep=id in_date icd9cm_1 icd9cm_2 icd9cm_3 icd9cm_4 icd9cm_5);
  /*Long COVID*/
  if substr(icd9cm_1,1,4) in ("U099") or
     substr(icd9cm_2,1,4) in ("U099") or
     substr(icd9cm_3,1,4) in ("U099") or
     substr(icd9cm_4,1,4) in ("U099") or
     substr(icd9cm_5,1,4) in ("U099") then L_COVID=1;
  /*Sever COVID*/
  if substr(icd9cm_1,1,4) in ("U071") or
     substr(icd9cm_2,1,4) in ("U071") or
     substr(icd9cm_3,1,4) in ("U071") or
     substr(icd9cm_4,1,4) in ("U071") or
     substr(icd9cm_5,1,4) in ("U071") then S_COVID=1;
  if L_COVID=1 or S_COVID then output;
  drop icd9cm_1 icd9cm_2 icd9cm_3 icd9cm_4 icd9cm_5;
run;
%end;
data COVID.DD_L_COVID;
  set DD109-DD111;
run;
%mend;
%DD

%macro CDDD1(y);
/*CD*/
data CD_&y.;
  set COVID.CD_L_COVID;
  where &y.=1;
  rename func_date=&y._date;
  keep ID &y. func_date;
run;

proc sort data=CD_&y.; by ID &y._date; run;

/*DD*/
data DD_&y.;
  set COVID.DD_L_COVID;
  where &y.=1;
  rename in_date=&y._date;
  keep ID &y. in_date;
run;

proc sort data=DD_&y.; by ID &y._date; run;

/*ALL*/
data &y.; set CD_&y. DD_&y.; run;

proc sort data=&y.; by ID &y._date; run;

data &y.;
  set &y.;
  by ID &y._date;
  if first.ID then output;
  keep id &y. &y._date;
run;
%mend;
%CDDD1(L_COVID)

%macro CDDD2(y);
/*DD*/
data DD_&y.;
  set COVID.DD_L_COVID;
  where &y.=1;
  rename in_date=&y._date;
  keep ID &y. in_date;
run;

proc sort data=DD_&y.; by ID &y._date; run;

/*ALL*/
data &y.;
  set DD_&y.;
run;

proc sort data=&y.; by ID &y._date; run;

data &y.;
  set &y.;
  by ID &y._date;
  if first.ID then output;
  keep id &y. &y._date;
run;
%mend;
%CDDD2(S_COVID)

data covid.L_COVID;
  set L_COVID;
  L_COVID_date1 = input(L_COVID_date, yymmdd10.);
  format L_COVID_date1 yymmdd10.;
  drop L_COVID_date;
run;

data covid.S_COVID;
  set S_COVID;
  S_COVID_date1 = input(S_COVID_date, yymmdd10.);
  format S_COVID_date1 yymmdd10.;
  drop S_COVID_date;
run;

/* Merge Long/Severe COVID diagnosis with cohort */
proc sql;
create table sub2_1 as
  select *
  from sub.sub1 as a left join covid.covid_cddd as b on a.id_m = b.id;

create table sub2_1 as
  select *
  from sub2_1 as a left join covid.L_COVID as b on a.id_m = b.id;

create table sub2_1 as
  select *
  from sub2_1 as a left join covid.S_COVID as b on a.id_m = b.id;
quit;

/* Determine final COVID-related index dates */
data sub2_2;
  set sub2_1;
  if Covid_DiagnosedDate1 ^= . and covid_date1 ^= . then covid_date = min(Covid_DiagnosedDate1, covid_date1);
  else if Covid_DiagnosedDate1 ^= . then covid_date = Covid_DiagnosedDate1;
  else covid_date = covid_date1;

  if Covid_ModerateorSevere_Status1 ^= . and S_COVID_date1 ^= . then S_COVID_date = min(Covid_DiagnosedDate1, S_COVID_date1);
  else if Covid_ModerateorSevere_Status1 ^= . then S_COVID_date = Covid_DiagnosedDate1;
  else S_COVID_date = S_COVID_date1;

  format covid_date yymmdd10. S_COVID_date yymmdd10.;
  drop covid_date1 S_COVID_date1;
run;

data sub2_3;
  set sub2_2;
  covid = (covid_date ^= .);
  S_COVID = (S_COVID_date ^= .);
  L_COVID = (L_COVID_date1 ^= .);
  rename L_COVID_date1 = L_COVID_date;
run;

proc freq data=sub2_3;
  table COVID S_COVID Covid_ModerateorSevere_Status1;
run;

/* Exclude vaccine duplicates again if needed */
proc sql;
create table sub2_4 as
  select *
  from sub2_3
  where id_m not in (select id from covid.same_id_vac)
  order by id_m;
quit;

/* Final COVID-annotated cohort */
data sub.sub2_v3;
  set sub2_4;
run;
