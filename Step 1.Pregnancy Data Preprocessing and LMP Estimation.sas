/* Assign library paths for datasets */
libname org "E:\\H111216\\data"; /* Original dataset path */
libname org_6 "E:\\H111216\\data\\data_H111216-6"; /* Year 110-111 dataset */
libname sub "E:\\H111216\\CJC\\LIN\\01_COVID_GDM\\Data\\Subject"; /* Subject data */
libname BR "E:\\H111216\\CJC\\LIN\\01_COVID_GDM\\Data\\BR"; /* Birth registry data */
libname COVID "E:\\H111216\\CJC\\LIN\\01_COVID_GDM\\Data\\COVID"; /* COVID data */

/* Step1: LMP data processing */
%macro BR;
  /* Load birth data for 109 year */
  data BR109;
    set org.H_BHP_BIRTH109;
    keep ID_M BIRTH_YM_M ROC_M NAT_M TRA_M PRA_M L_D SEX BIRTHDAY WEEK WEIGHT DEL_NO BIRTHWAY MH_1-MH_8 COM_1-COM_8;
  run;

  /* Loop through years 110 to 111 */
  %do a=110 %to 111;
    data BR&a.;
      set org_6.H_BHP_BIRTH&a.;
      keep ID_M BIRTH_YM_M ROC_M NAT_M TRA_M PRA_M L_D SEX BIRTHDAY WEEK WEIGHT DEL_NO BIRTHWAY MH_1-MH_8 COM_1-COM_8;
    run;
  %end;

  /* Combine all birth data */
  data BR.BRall; /* 466219 observations */
    set BR109-BR111;
  run;

  /* Sort by mother ID and birthday */
  proc sort data=BR.BRall;
    by ID_M BIRTHDAY;
  run;
%mend;
%BR

/* Remove records with missing ID_M (n=105) */
data BRpr_1; /* 466114 observations */
  set BR.BRall;
  if ID_M = " " then delete;
run;

/* Identify mothers with multiple children */
proc sql;
  create table multi_child as /* 85398 mothers */
  select *, count(*) as count
  from BRpr_1
  group by ID_M
  having count(*) > 1
  order by ID_M, BIRTHDAY;
quit;

/* Frequency table for delivery number */
proc freq data=multi_child;
  table DEL_NO;
run;

/* Select first record for multiple births per delivery */
data multi_child_1; 
  set multi_child;
  index = ID_M || BIRTHDAY;
run;

proc sort data=multi_child_1;
  by index;
run;

data multi_child_2; /* 76067 records */
  set multi_child_1;
  by index;
  if first.index;
run;

/* Select mothers with more than one delivery during study period */
data BR.mom_pr; /* 42112 mothers */
  set multi_child_2;
  by ID_M;
  if first.ID_M;
run;

/* Remove records with missing BIRTH_YM_M (n=1) */
data BRpr_3; /* 466113 observations */
  set BRpr_1;
  if BIRTH_YM_M = . then delete;
run;

/* Calculate LMP date and age at pregnancy */
data BRpr_4; 
  set BRpr_3;
  BIRTHDAY1 = input(BIRTHDAY, yymmdd10.);
  BIRTH_YM_M1 = input(cats(BIRTH_YM_M, "15"), yymmdd10.);
  index_date = BIRTHDAY1 - (WEEK * 7);
  age = (index_date - BIRTH_YM_M1) / 365.25;
  format index_date yymmdd10.;
  drop BIRTHDAY1 BIRTH_YM_M1;
run;

/* Exclude age < 18 (n=2407) */
data BRpr_5; /* 463706 observations */
  set BRpr_4;
  if age < 18 then delete;
run;

/* Exclude gestational age < 24 weeks (n=4211) */
data BRpr_6; /* 459495 observations */
  set BRpr_5;
  if WEEK < 24 then delete;
run;

/* Final cleaned dataset */
data BR.BRpr; /* 459495 observations */
  set BRpr_6;
run;

/* Regional classification of maternal residence (TRA_M) */
proc sql;
  create table TRA_M as /* 380 unique entries */
  select TRA_M, count(*) as count
  from BR.BRpr
  group by TRA_M
  order by TRA_M;
quit;

data TRA_M_2;
  set TRA_M;
  if substr(TRA_M, 1, 6) = '臺北市' then living_p1 = 1;
  else if substr(TRA_M, 1, 6) = '新北市' then living_p1 = 2;
  else if substr(TRA_M, 1, 6) = '基隆市' then living_p1 = 3;
  else if substr(TRA_M, 1, 6) = '桃園市' then living_p1 = 4;
  else if substr(TRA_M, 1, 6) = '新竹市' then living_p1 = 5;
  else if substr(TRA_M, 1, 6) = '新竹縣' then living_p1 = 6;
  else if substr(TRA_M, 1, 6) = '苗栗縣' then living_p1 = 7;
  else if substr(TRA_M, 1, 6) = '南投縣' then living_p1 = 8;
  else if substr(TRA_M, 1, 6) = '臺中市' then living_p1 = 9;
  else if substr(TRA_M, 1, 6) = '雲林縣' then living_p1 = 10;
  else if substr(TRA_M, 1, 6) = '嘉義市' then living_p1 = 11;
  else if substr(TRA_M, 1, 6) = '嘉義縣' then living_p1 = 12;
  else if substr(TRA_M, 1, 6) = '彰化縣' then living_p1 = 13;
  else if substr(TRA_M, 1, 6) = '臺南市' then living_p1 = 14;
  else if substr(TRA_M, 1, 6) = '高雄市' then living_p1 = 15;
  else if substr(TRA_M, 1, 6) = '屏東縣' then living_p1 = 16;
  else if substr(TRA_M, 1, 6) = '宜蘭縣' then living_p1 = 17;
  else if substr(TRA_M, 1, 6) = '花蓮縣' then living_p1 = 18;
  else if substr(TRA_M, 1, 6) = '臺東縣' then living_p1 = 19;
  else if substr(TRA_M, 1, 6) = '澎湖縣' then living_p1 = 20;
  else if substr(TRA_M, 1, 6) = '金門縣' then living_p1 = 21;
  else if substr(TRA_M, 1, 6) = '連江縣' then living_p1 = 22;
  else if substr(TRA_M, 1, 4) = '外籍' then living_p1 = 23;
run;

proc sort data=TRA_M_2;
  by living_p1;
run;

data TRA_M_3;
  set TRA_M_2;
  retain living_p2 0;
  living_p2 + 1;
  if substr(TRA_M, 1, 4) = '外籍' then living_p2 = 369;
run;

/* Final regional mapping dataset */
data BR.TRA_M; /* 368 local, 12 foreign */
  set TRA_M_3;
run;

/* Merge residence codes back to main dataset */
proc sql;
  create table BR.BRpr2 as /* 459495 observations */
  select a.*, b.living_p1, b.living_p2
  from BR.BRpr as a
  left join BR.TRA_M as b on a.TRA_M = b.TRA_M
  order by ID_M, index_date;
quit;
