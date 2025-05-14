/* Load libraries */
libname org "E:\\H111216\\data";
libname org_6 "E:\\H111216\\data\\data_H111216-6";
libname sub "E:\\H111216\\CJC\\LIN\\01_COVID_GDM\\Data\\Subject";
libname ID "E:\\H111216\\CJC\\LIN\\01_COVID_GDM\\Data\\ID";

/* Extract income and urban info from insurance enrollment data */
%macro ID(y);
%do a=1 %to 9;
proc sql;
  create table id&y.0&a. as
  select ID, ID_S, ID_BIRTH_Y, ID1_AMT, ID1_CITY, PREM_YM
  from %if &y.=109 %then org; %else org_6;.h_nhi_enrol&y.0&a.
  where id in (select id_m from sub.sub1);
quit;
%end;
%do a=10 %to 12;
proc sql;
  create table id&y.&a. as
  select ID, ID_S, ID_BIRTH_Y, ID1_AMT, ID1_CITY, PREM_YM
  from %if &y.=109 %then org; %else org_6;.h_nhi_enrol&y.&a.
  where id in (select id_m from sub.sub1);
quit;
%end;

data id&y.;
  set id&y.01-id&y.12;
run;

proc sort data=id&y.; by id PREM_YM; run;

data id.id_base&y.;
  set id&y.;
  by id PREM_YM;
  if first.id;
run;
%mend;
%ID(109)
%ID(110)
%ID(111)

/* Combine all years */
data idall;
  set id.id_base109-id.id_base111;
run;
proc sort data=idall; by id PREM_YM; run;
data idpr;
  set idall;
  by id PREM_YM;
  if first.id;
run;

/* Recode income level (updated 20241111) */
data id_base;
  set idpr;
  if ID1_AMT <= 23800 then income = 1;
  else if 23801 <= ID1_AMT <= 27600 then income = 2;
  else if 27601 <= ID1_AMT <= 40100 then income = 3;
  else if 40101 <= ID1_AMT then income = 4;
run;

/* Merge urbanization levels (area code to level) */
proc sql;
create table id_base1_1 as
  select a.*, b.urbanization_level_new as u1
  from id_base as a
  left join id.urbanization as b on a.ID1_CITY = b.area_code_98;

create table id_base1_2 as
  select a.*, b.urbanization_level_new as u2
  from id_base1_1 as a
  left join id.urbanization as b on a.ID1_CITY = b.area_code_99;

create table id_base1_3 as
  select a.*, b.urbanization_level_new as u3
  from id_base1_2 as a
  left join id.urbanization as b on a.ID1_CITY = b.area_code_104;
quit;

data id_base1_4;
  set id_base1_3;
  urbanization_level = u1;
  if urbanization_level = . then urbanization_level = u2;
  if urbanization_level = . then urbanization_level = u3;
run;

proc sort data=id_base1_4; by id PREM_YM; run;
data id_base1_5;
  set id_base1_4;
  by id PREM_YM;
  if first.id;
run;

data id_base1_6;
  set id_base1_5;
  drop ID1_AMT ID1_CITY u1 u2 u3 PREM_YM;
run;

/* Death date extraction */
%macro death;
proc sql;
  create table death109 as
  select id, d_date from org.h_ost_death109
  where id in (select id_m from sub.sub1);

%do a=110 %to 111;
  create table death&a. as
  select id, d_date from org_6.h_ost_death&a.
  where id in (select id_m from sub.sub1);
%end;
quit;

data deathall;
  set death109-death111;
run;
proc sort data=deathall; by id d_date; run;
data deathall2;
  set deathall;
  by id d_date;
  if last.id then output;
run;
%mend;
%death

data id.deathdate;
  set deathall2;
run;

/* Combine income, urbanization, and death info */
proc sql;
create table id.id_base_v2 as
  select *
  from id_base1_6 as a
  left join id.deathdate as b on a.id = b.id;
quit;

/* Merge with main pregnancy cohort */
proc sql;
create table sub4_1 as
  select a.*, b.urbanization_level, b.income, b.d_date, b.id_s
  from sub.sub3_v3 as a
  left join id.id_base_v2 as b on a.id_m = b.id
  order by id_m;
quit;

data sub4_2;
  set sub4_1;
  if urbanization_level = . then urbanization_level = 2;
  if income = . then income = 1;
run;

data sub.sub4_v3;
  set sub4_2;
run;
