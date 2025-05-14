/* Load libraries */
libname org "E:\\H111216\\data";
libname org_6 "E:\\H111216\\data\\data_H111216-6";
libname sub "E:\\H111216\\CJC\\LIN\\01_COVID_GDM\\Data\\Subject";

/* Prepare matching index */
data sub6_1;
  set sub.sub5_v5;
  age_int = int(age);
  INDEX = age_int || living_p1;
  drop id;
run;

data sub6_2;
  set sub6_1;
  ID = id_m || birthday;
run;

proc sort data=sub6_2; by ID GDM; run;

data sub6_3;
  set sub6_2;
  by ID;
  if first.ID;
run;

data case ctrl;
  set sub6_3;
  ID = id_m || birthday;
  if GDM = 1 then output case;
  if GDM = 0 then output ctrl;
run;

/* Frequency by INDEX for case and control */
proc freq data=ctrl noprint;
  tables INDEX / list missing out=ctrlcnt(rename=(count=ctrlcnt));
run;
proc freq data=case noprint;
  tables INDEX / list missing out=casecnt(rename=(count=casecnt));
run;

data allcount;
  merge casecnt(in=a) ctrlcnt(in=b);
  by INDEX;
  if casecnt > 0;
  if a and not b then ctrlcnt = 0;
  _nsize_ = min(casecnt, ctrlcnt);
  if _nsize_ > 0;
run;

/* Select eligible cases/controls and perform 1:4 matching */
proc sql;
  create table eligible_controls as
  select * from ctrl
  where INDEX in (select INDEX from allcount);

  create table eligible_cases as
  select * from case
  where INDEX in (select INDEX from allcount);
quit;

proc surveyselect data=eligible_controls sampsize=allcount method=srs seed=499812 out=selected_controls;
  strata INDEX;
run;
proc surveyselect data=eligible_cases sampsize=allcount method=srs seed=499812 out=selected_cases;
  strata INDEX;
run;

data cc;
  set selected_controls(in=a) selected_cases(in=b);
  if a then CCID = 0;
  else if b then CCID = 1;
run;

proc sort data=cc; by INDEX CCID; run;

data cc;
  set cc;
  by INDEX CCID;
  retain ctktr caktr idxid;
  if CCID = 0 then ctktr + 1;
  else if CCID = 1 then caktr + 1;
  if first.INDEX then idxid + 1;
  ida = compress(substr(INDEX,4,6), '*');
  idx = put(idxid, $4.);
  if CCID = 0 then matchx = idx || ida || ctktr;
  else if CCID = 1 then matchx = idx || ida || caktr;
  matchx = compress(matchx, '');
  matchid = input(matchx, 20.);
run;

proc sort data=cc; by matchid CCID; run;

/* Define index date for controls based on paired cases */
proc sql;
  create table tmp_case as
  select a.*, b.matchid
  from case as a
  left join cc as b on a.id = b.id;

  create table cc_final as
  select a.*, b.id as pair_id
  from cc as a
  left join tmp_case as b on a.matchid = b.matchid;
quit;

data cc_all;
  set cc_final;
  death_date = input(d_date, yymmdd10.);
  if death_date ^= . and index_date_match >= death_date then delete;
  format death_date yymmdd10.;
run;

proc sort data=cc_all; by index pair_id CCID; run;

data cc_all;
  set cc_all;
  by index pair_id CCID;
  if first.pair_id then seq = 0;
  seq + 1;
run;

%macro match(size);
proc sql;
  create table sub.sub6_v6_case_ctrl as
  select *
  from cc_all
  where (seq <= &size and pair_id in (select id from cc_all where seq >= (&size + 1) and CCID = 1))
     or (seq >= (&size + 1) and CCID = 1)
  group by pair_id
  order by index, pair_id, CCID;
quit;
%mend match;

%match(1);
%match(4);

proc freq data=sub.sub6_v6_case_ctrl; table CCID; run;
proc sort data=sub.sub6_v6_case_ctrl; by pair_id; run;

/* Matching for Cohort (COVID as exposure) */
data sub6_1;
  set sub.sub5_v5;
  age_int = int(age);
  INDEX = age_int || living_p1;
  drop id;
run;

data sub6_2;
  set sub6_1;
  ID = id_m || birthday;
run;

proc sort data=sub6_2; by ID COVID; run;

data sub6_3;
  set sub6_2;
  by ID;
  if first.ID;
run;

data case ctrl;
  set sub6_3;
  ID = id_m || birthday;
  if COVID = 1 then output case;
  if COVID = 0 then output ctrl;
run;

proc freq data=ctrl noprint;
  tables INDEX / list missing out=ctrlcnt(rename=(count=ctrlcnt));
run;
proc freq data=case noprint;
  tables INDEX / list missing out=casecnt(rename=(count=casecnt));
run;

data allcount;
  merge casecnt(in=a) ctrlcnt(in=b);
  by INDEX;
  if casecnt > 0;
  if a and not b then ctrlcnt = 0;
  _nsize_ = min(casecnt, ctrlcnt);
  if _nsize_ > 0;
run;

proc sql;
  create table eligible_controls as
  select * from ctrl where INDEX in (select INDEX from allcount);

  create table eligible_cases as
  select * from case where INDEX in (select INDEX from allcount);
quit;

proc surveyselect data=eligible_controls sampsize=allcount method=srs seed=499812 out=selected_controls;
  strata INDEX;
run;
proc surveyselect data=eligible_cases sampsize=allcount method=srs seed=499812 out=selected_cases;
  strata INDEX;
run;

data cc;
  set selected_controls(in=a) selected_cases(in=b);
  if a then CCID = 0;
  else if b then CCID = 1;
run;

proc sort data=cc; by INDEX CCID; run;

data cc;
  set cc;
  by INDEX CCID;
  retain ctktr caktr idxid;
  if CCID = 0 then ctktr + 1;
  else if CCID = 1 then caktr + 1;
  if first.INDEX then idxid + 1;
  ida = compress(substr(INDEX,4,6), '*');
  idx = put(idxid, $4.);
  if CCID = 0 then matchx = idx || ida || ctktr;
  else if CCID = 1 then matchx = idx || ida || caktr;
  matchx = compress(matchx, '');
  matchid = input(matchx, 20.);
run;

proc sort data=cc; by matchid CCID; run;

proc sql;
  create table tmp_case as
  select a.*, b.matchid from case as a left join cc as b on a.id = b.id;

  create table cc_final as
  select a.*, b.id as pair_id from cc as a left join tmp_case as b on a.matchid = b.matchid;
quit;

data cc_all;
  set cc_final;
  death_date = input(d_date, yymmdd10.);
  if death_date ^= . and index_date_match >= death_date then delete;
  format death_date yymmdd10.;
run;

proc sort data=cc_all; by index pair_id CCID; run;

data cc_all;
  set cc_all;
  by index pair_id CCID;
  if first.pair_id then seq = 0;
  seq + 1;
run;

%macro match(size);
proc sql;
  create table sub.sub6_v6_cohort as
  select *
  from cc_all
  where (seq <= &size and pair_id in (select id from cc_all where seq >= (&size + 1) and CCID = 1))
     or (seq >= (&size + 1) and CCID = 1)
  group by pair_id
  order by index, pair_id, CCID;
quit;
%mend match;

%match(1);
%match(4);

proc freq data=sub.sub6_v6_cohort; table CCID; run;
proc sort data=sub.sub6_v6_cohort; by pair_id; run;
