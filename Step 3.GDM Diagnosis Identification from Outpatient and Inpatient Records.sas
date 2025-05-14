/* Load libraries */
libname org "E:\H111216\data";
libname org_6 "E:\H111216\data\data_H111216-6";
libname sub "E:\H111216\CJC\LIN\01_COVID_GDM\Data\Subject";
libname BR "E:\H111216\CJC\LIN\01_COVID_GDM\Data\BR";
libname COVID "E:\H111216\CJC\LIN\01_COVID_GDM\Data\COVID";
libname GDM "E:\H111216\CJC\LIN\01_COVID_GDM\Data\GDM";

/* Load GDM diagnosis from outpatient records */
%macro CD(a);
data CD109&a.;
  set org.h_nhi_opdte109&a._10 (keep=id func_date icd9cm_1 icd9cm_2 icd9cm_3);
  /* GDM ICD codes */
  if substr(icd9cm_1,1,5) in ("Z8632","O2402","O2403","O2412","O2413","O2432","O2433") or
     substr(icd9cm_2,1,5) in ("Z8632","O2402","O2403","O2412","O2413","O2432","O2433") or
     substr(icd9cm_3,1,5) in ("Z8632","O2402","O2403","O2412","O2413","O2432","O2433") then GDM=1;
  if GDM=1 then output;
  drop icd9cm_1 icd9cm_2 icd9cm_3;
run;
%do y=110 %to 111;
data CD&y.&a.;
  set org_6.h_nhi_opdte&y.&a._10 (keep=id func_date icd9cm_1 icd9cm_2 icd9cm_3);
  /* GDM ICD codes */
  if substr(icd9cm_1,1,5) in ("Z8632","O2402","O2403","O2412","O2413","O2432","O2433") or
     substr(icd9cm_2,1,5) in ("Z8632","O2402","O2403","O2412","O2413","O2432","O2433") or
     substr(icd9cm_3,1,5) in ("Z8632","O2402","O2403","O2412","O2413","O2432","O2433") then GDM=1;
  if GDM=1 then output;
  drop icd9cm_1 icd9cm_2 icd9cm_3;
run;
%end;
%mend;
%CD(01)%CD(02)%CD(03)%CD(04)%CD(05)%CD(06)
%CD(07)%CD(08)%CD(09)%CD(10)%CD(11)%CD(12)

/* Combine all outpatient months */
%macro CD2;
%do y=109 %to 111;
data CD&y.;
  set CD&y.01-CD&y.12;
run;
%end;
%mend;
%CD2

data GDM.CD;
  set CD109-CD111;
run;

/* Load GDM diagnosis from inpatient records */
%macro DD;
data DD109;
  set org.h_nhi_ipdte109 (keep=id in_date icd9cm_1-icd9cm_5);
  if substr(icd9cm_1,1,5) in ("Z8632","O2402","O2403","O2412","O2413","O2432","O2433") or
     substr(icd9cm_2,1,5) in ("Z8632","O2402","O2403","O2412","O2413","O2432","O2433") or
     substr(icd9cm_3,1,5) in ("Z8632","O2402","O2403","O2412","O2413","O2432","O2433") or
     substr(icd9cm_4,1,5) in ("Z8632","O2402","O2403","O2412","O2413","O2432","O2433") or
     substr(icd9cm_5,1,5) in ("Z8632","O2402","O2403","O2412","O2413","O2432","O2433") then GDM=1;
  if GDM=1 then output;
  drop icd9cm_1-icd9cm_5;
run;
%do y=110 %to 111;
data DD&y.;
  set org_6.h_nhi_ipdte&y. (keep=id in_date icd9cm_1-icd9cm_5);
  if substr(icd9cm_1,1,5) in ("Z8632","O2402","O2403","O2412","O2413","O2432","O2433") or
     substr(icd9cm_2,1,5) in ("Z8632","O2402","O2403","O2412","O2413","O2432","O2433") or
     substr(icd9cm_3,1,5) in ("Z8632","O2402","O2403","O2412","O2413","O2432","O2433") or
     substr(icd9cm_4,1,5) in ("Z8632","O2402","O2403","O2412","O2413","O2432","O2433") or
     substr(icd9cm_5,1,5) in ("Z8632","O2402","O2403","O2412","O2413","O2432","O2433") then GDM=1;
  if GDM=1 then output;
  drop icd9cm_1-icd9cm_5;
run;
%end;
data GDM.DD;
  set DD109-DD111;
run;
%mend;
%DD

/* Merge outpatient and inpatient GDM records and keep earliest date */
data GDM_ALL;
  set GDM.CD GDM.DD;
run;
proc sort data=GDM_ALL;
  by id func_date in_date;
run;
data GDM_ALL;
  set GDM_ALL;
  gdm_date = coalesce(func_date, in_date);
  format gdm_date yymmdd10.;
  drop func_date in_date;
run;
proc sort data=GDM_ALL;
  by id gdm_date;
run;
data GDM.GDM_ALL;
  set GDM_ALL;
  by id;
  if first.id;
run;

/* Merge GDM diagnosis back to pregnancy cohort */
proc sql;
create table sub3 as
  select a.*, b.gdm_date
  from sub.sub2_v3 as a
  left join GDM.GDM_ALL as b
  on a.id_m = b.id
  order by id_m;
quit;

data sub.sub3;
  set sub3;
  if gdm_date ^= . then gdm = 1;
  else gdm = 0;
run;