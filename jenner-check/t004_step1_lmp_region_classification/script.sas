/* -------------------------------------------------------------------------
   Bundle: LMP-date derivation + Taiwan residence-region classification from
   "Step 1.Pregnancy Data Preprocessing and LMP Estimation.sas"
   (the age/LMP calculation block and the TRA_M -> living_p1/living_p2
   regional-code block, run back to back as the original does).

   This reconstructs last-menstrual-period date and maternal age at
   conception from a delivery record, then maps the mother's Chinese-
   language residence-county string (as recorded in Taiwan's National
   Health Insurance Research Database) to the paper's numeric region code
   via literal substr() comparisons against the 22 special-municipality /
   city / county names, exactly as the original does. Reproduced verbatim
   except for the LIBNAME source (replaced with a small mock birth-registry
   extract shaped like BR.BRall) and the substr() lengths: the original's
   substr(TRA_M,1,6)/substr(TRA_M,1,4) are byte counts (6 bytes = 3 Chinese
   characters, 4 bytes = 2 characters, matching the DBCS Windows SAS session
   this repo was authored under); this bundle runs under Jenner's UTF-8
   session where substr() counts characters, so the equivalent lengths are
   substr(TRA_M,1,3)/substr(TRA_M,1,2). The lookup logic itself -- which
   county maps to which living_p1/living_p2 code -- is untouched.
   ------------------------------------------------------------------------- */

/* ---- mock birth registry: shaped like BR.BRall (Step 1 upstream input) ----
   BIRTH_YM_M is the mother's own birth year-month (YYYYMM), well before the
   delivery date, so age-at-conception comes out positive and plausible. */
data BRpr_3;
  input ID_M $ BIRTHDAY : yymmdd10. BIRTH_YM_M WEEK TRA_M $30.;
  datalines;
M001 2021-06-15 199203 39 臺北市中正區
M002 2021-08-02 198911 38 新北市板橋區
M003 2021-09-20 199507 40 桃園市中壢區
M004 2021-11-05 199001 37 高雄市苓雅區
M005 2022-01-10 199408 41 臺中市西屯區
M006 2022-03-22 200002 26 花蓮縣吉安鄉
;
run;

/* ---- verbatim from Step 1 "Calculate LMP date and age at pregnancy" ----
   (BIRTHDAY is already a SAS date value here, since the mock loader above
   reads it directly with a :yymmdd10. informat rather than the character
   BIRTHDAY the original re-parses via input(); BIRTHDAY1 is therefore
   just BIRTHDAY, dropped straight through instead of re-derived) */
data BRpr_4;
  set BRpr_3;
  BIRTHDAY1 = BIRTHDAY;
  BIRTH_YM_M1 = input(cats(BIRTH_YM_M, "15"), yymmdd10.);
  index_date = BIRTHDAY1 - (WEEK * 7);
  age = (index_date - BIRTH_YM_M1) / 365.25;
  format index_date yymmdd10.;
  drop BIRTHDAY1 BIRTH_YM_M1;
run;

data BRpr_5;
  set BRpr_4;
  if age < 18 then delete;
run;

data BR_pr;
  set BRpr_5;
  if WEEK < 24 then delete;
run;

/* ---- verbatim from Step 1 "Regional classification of maternal residence (TRA_M)" ---- */
proc sql;
  create table TRA_M as
  select TRA_M, count(*) as count
  from BR_pr
  group by TRA_M
  order by TRA_M;
quit;

data TRA_M_2;
  set TRA_M;
  if substr(TRA_M, 1, 3) = '臺北市' then living_p1 = 1;
  else if substr(TRA_M, 1, 3) = '新北市' then living_p1 = 2;
  else if substr(TRA_M, 1, 3) = '基隆市' then living_p1 = 3;
  else if substr(TRA_M, 1, 3) = '桃園市' then living_p1 = 4;
  else if substr(TRA_M, 1, 3) = '新竹市' then living_p1 = 5;
  else if substr(TRA_M, 1, 3) = '新竹縣' then living_p1 = 6;
  else if substr(TRA_M, 1, 3) = '苗栗縣' then living_p1 = 7;
  else if substr(TRA_M, 1, 3) = '南投縣' then living_p1 = 8;
  else if substr(TRA_M, 1, 3) = '臺中市' then living_p1 = 9;
  else if substr(TRA_M, 1, 3) = '雲林縣' then living_p1 = 10;
  else if substr(TRA_M, 1, 3) = '嘉義市' then living_p1 = 11;
  else if substr(TRA_M, 1, 3) = '嘉義縣' then living_p1 = 12;
  else if substr(TRA_M, 1, 3) = '彰化縣' then living_p1 = 13;
  else if substr(TRA_M, 1, 3) = '臺南市' then living_p1 = 14;
  else if substr(TRA_M, 1, 3) = '高雄市' then living_p1 = 15;
  else if substr(TRA_M, 1, 3) = '屏東縣' then living_p1 = 16;
  else if substr(TRA_M, 1, 3) = '宜蘭縣' then living_p1 = 17;
  else if substr(TRA_M, 1, 3) = '花蓮縣' then living_p1 = 18;
  else if substr(TRA_M, 1, 3) = '臺東縣' then living_p1 = 19;
  else if substr(TRA_M, 1, 3) = '澎湖縣' then living_p1 = 20;
  else if substr(TRA_M, 1, 3) = '金門縣' then living_p1 = 21;
  else if substr(TRA_M, 1, 3) = '連江縣' then living_p1 = 22;
  else if substr(TRA_M, 1, 2) = '外籍' then living_p1 = 23;
run;

proc sort data=TRA_M_2;
  by living_p1;
run;

data TRA_M_3;
  set TRA_M_2;
  retain living_p2 0;
  living_p2 + 1;
  if substr(TRA_M, 1, 2) = '外籍' then living_p2 = 369;
run;

proc print data=TRA_M_3 label;
  var TRA_M count living_p1 living_p2;
run;

proc print data=BR_pr label;
  var ID_M index_date age TRA_M;
run;
