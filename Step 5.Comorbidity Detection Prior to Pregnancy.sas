/* Load libraries */
libname org "E:\\H111216\\data";
libname org_6 "E:\\H111216\\data\\data_H111216-6";
libname sub "E:\\H111216\\CJC\\LIN\\01_COVID_GDM\\Data\\Subject";
libname CF_D "E:\\H111216\\CJC\\LIN\\01_COVID_GDM\\Data\\CF_D";
libname GDM "E:\\H111216\\CJC\\LIN\\01_COVID_GDM\\Data\\GDM";

/* Outpatient Diagnoses */
%macro CD(m);
%do y=107 %to 111;
  %let lib = %sysfunc(ifc(&y.<110, org, org_6));
  data CD&y.&m.;
    set &lib..h_nhi_opdte&y.&m._10 (keep=id func_date icd9cm_1 icd9cm_2 icd9cm_3);
    /*DM*/
    if substr(icd9cm_1,1,3) in ("R81") or
       substr(icd9cm_2,1,3) in ("R81") or
       substr(icd9cm_3,1,3) in ("R81") or
       substr(icd9cm_1,1,4) in ("E088","E089","E098","E099","E108","E109","E118","E119","E138","E139") or
       substr(icd9cm_2,1,4) in ("E088","E089","E098","E099","E108","E109","E118","E119","E138","E139") or
       substr(icd9cm_3,1,4) in ("E088","E089","E098","E099","E108","E109","E118","E119","E138","E139") or 
       substr(icd9cm_1,1,5) in ("E0800","E0801","E0810","E0811","E0865","E0869","E0900","E0901","E0910","E0911","E0965","E0969","E1010","E1011","E1065","E1069","E1100","E1101","E1165","E1169","E1300","E1301","E1310","E1311","E1365","E1369") or
       substr(icd9cm_2,1,5) in ("E0800","E0801","E0810","E0811","E0865","E0869","E0900","E0901","E0910","E0911","E0965","E0969","E1010","E1011","E1065","E1069","E1100","E1101","E1165","E1169","E1300","E1301","E1310","E1311","E1365","E1369") or
       substr(icd9cm_3,1,5) in ("E0800","E0801","E0810","E0811","E0865","E0869","E0900","E0901","E0910","E0911","E0965","E0969","E1010","E1011","E1065","E1069","E1100","E1101","E1165","E1169","E1300","E1301","E1310","E1311","E1365","E1369") or 
       substr(icd9cm_1,1,6) in ("E08618","E08620","E08621","E08622","E08628","E08630","E08638","E08641","E08649","E09618","E09620","E09621","E09622","E09628","E09630","E09638","E09641","E09649","E10618","E10620","E10621","E10622","E10628","E10630","E10638","E10641","E10649","E11618","E11620","E11621","E11622","E11628","E11630","E11638","E11641","E11649","E13618","E13620","E13621","E13622","E13628","E13630","E13638","E13641","E13649") or
       substr(icd9cm_2,1,6) in ("E08618","E08620","E08621","E08622","E08628","E08630","E08638","E08641","E08649","E09618","E09620","E09621","E09622","E09628","E09630","E09638","E09641","E09649","E10618","E10620","E10621","E10622","E10628","E10630","E10638","E10641","E10649","E11618","E11620","E11621","E11622","E11628","E11630","E11638","E11641","E11649","E13618","E13620","E13621","E13622","E13628","E13630","E13638","E13641","E13649") or
       substr(icd9cm_3,1,6) in ("E08618","E08620","E08621","E08622","E08628","E08630","E08638","E08641","E08649","E09618","E09620","E09621","E09622","E09628","E09630","E09638","E09641","E09649","E10618","E10620","E10621","E10622","E10628","E10630","E10638","E10641","E10649","E11618","E11620","E11621","E11622","E11628","E11630","E11638","E11641","E11649","E13618","E13620","E13621","E13622","E13628","E13630","E13638","E13641","E13649") then DM=1;
    /*GDM*/
    if substr(icd9cm_1,1,5) in ("Z8632","O2402","O2403","O2412","O2413","O2432","O2433","O2482","O2483","O2492","O2493") or
       substr(icd9cm_2,1,5) in ("Z8632","O2402","O2403","O2412","O2413","O2432","O2433","O2482","O2483","O2492","O2493") or
       substr(icd9cm_3,1,5) in ("Z8632","O2402","O2403","O2412","O2413","O2432","O2433","O2482","O2483","O2492","O2493") or
       substr(icd9cm_1,1,6) in ("O24011","O24012","O24013","O24019","O24111","O24112","O24113","O24119","O24311","O24312","O24313","O24319","O24410","O24414","O24415","O24419","O24420","O24424","O24425","O24429","O24430","O24434","O24435","O24439","O24811","O24812","O24813","O24819","O24911","O24912","O24913","O24919","O99810") or
       substr(icd9cm_2,1,6) in ("O24011","O24012","O24013","O24019","O24111","O24112","O24113","O24119","O24311","O24312","O24313","O24319","O24410","O24414","O24415","O24419","O24420","O24424","O24425","O24429","O24430","O24434","O24435","O24439","O24811","O24812","O24813","O24819","O24911","O24912","O24913","O24919","O99810") or
       substr(icd9cm_3,1,6) in ("O24011","O24012","O24013","O24019","O24111","O24112","O24113","O24119","O24311","O24312","O24313","O24319","O24410","O24414","O24415","O24419","O24420","O24424","O24425","O24429","O24430","O24434","O24435","O24439","O24811","O24812","O24813","O24819","O24911","O24912","O24913","O24919","O99810") then GDM=1;
    /*Obese*/
    if substr(icd9cm_1,1,3) in ("E66") or
       substr(icd9cm_2,1,3) in ("E66") or
       substr(icd9cm_3,1,3) in ("E66") or
       substr(icd9cm_1,1,4) in ("E660","E661","E662","E663","E668","E669","Z683","Z684") or
       substr(icd9cm_2,1,4) in ("E660","E661","E662","E663","E668","E669","Z683","Z684") or
       substr(icd9cm_3,1,4) in ("E660","E661","E662","E663","E668","E669","Z683","Z684") or 
       substr(icd9cm_1,1,5) in ("E6601","E6609","Z6824","Z6825","Z6826","Z6827","Z6828","Z6829","Z6830","Z6831","Z6832","Z6833","Z6834","Z6835","Z6836","Z6837","Z6838","Z6839","Z6841","Z6842","Z6843","Z6844","Z6845") or
       substr(icd9cm_2,1,5) in ("E6601","E6609","Z6824","Z6825","Z6826","Z6827","Z6828","Z6829","Z6830","Z6831","Z6832","Z6833","Z6834","Z6835","Z6836","Z6837","Z6838","Z6839","Z6841","Z6842","Z6843","Z6844","Z6845") or
       substr(icd9cm_3,1,5) in ("E6601","E6609","Z6824","Z6825","Z6826","Z6827","Z6828","Z6829","Z6830","Z6831","Z6832","Z6833","Z6834","Z6835","Z6836","Z6837","Z6838","Z6839","Z6841","Z6842","Z6843","Z6844","Z6845") then Obese = 1;
    /*Polycystic ovarian syndrome*/
    if substr(icd9cm_1,1,4) in ("E282") or
       substr(icd9cm_2,1,4) in ("E282") or
       substr(icd9cm_3,1,4) in ("E282") then POS = 1;
    if DM=1 or GDM=1 or Obese=1 or POS=1 then output;
    drop icd9cm_1 icd9cm_2 icd9cm_3;
  run;
%end;
%mend;
%CD(01); %CD(02); %CD(03); %CD(04); %CD(05); %CD(06); %CD(07); %CD(08); %CD(09); %CD(10); %CD(11); %CD(12);

/* Combine yearly files */
%macro CD2;
%do y=107 %to 111;
  data CD&y.;
    set CD&y.01-CD&y.12;
  run;
%end;
%mend;
%CD2

data CF_D.CD_CF_D;
  set CD107-CD111;
run;

/* Inpatient Diagnoses */
%macro DD;
%do y=107 %to 111;
  %let lib = %sysfunc(ifc(&y.<110, org, org_6));
  data DD&y.;
    set &lib..h_nhi_ipdte&y. (keep=id in_date icd9cm_1-icd9cm_5);
    /*DM*/
    if substr(icd9cm_1,1,3) in ("R81") or
       substr(icd9cm_2,1,3) in ("R81") or
       substr(icd9cm_3,1,3) in ("R81") or
       substr(icd9cm_4,1,3) in ("R81") or
       substr(icd9cm_5,1,3) in ("R81") or
       substr(icd9cm_1,1,4) in ("E088","E089","E098","E099","E108","E109","E118","E119","E138","E139") or
       substr(icd9cm_2,1,4) in ("E088","E089","E098","E099","E108","E109","E118","E119","E138","E139") or
       substr(icd9cm_3,1,4) in ("E088","E089","E098","E099","E108","E109","E118","E119","E138","E139") or 
       substr(icd9cm_4,1,4) in ("E088","E089","E098","E099","E108","E109","E118","E119","E138","E139") or 
       substr(icd9cm_5,1,4) in ("E088","E089","E098","E099","E108","E109","E118","E119","E138","E139") or 
       substr(icd9cm_1,1,5) in ("E0800","E0801","E0810","E0811","E0865","E0869","E0900","E0901","E0910","E0911","E0965","E0969","E1010","E1011","E1065","E1069","E1100","E1101","E1165","E1169","E1300","E1301","E1310","E1311","E1365","E1369") or
       substr(icd9cm_2,1,5) in ("E0800","E0801","E0810","E0811","E0865","E0869","E0900","E0901","E0910","E0911","E0965","E0969","E1010","E1011","E1065","E1069","E1100","E1101","E1165","E1169","E1300","E1301","E1310","E1311","E1365","E1369") or
       substr(icd9cm_3,1,5) in ("E0800","E0801","E0810","E0811","E0865","E0869","E0900","E0901","E0910","E0911","E0965","E0969","E1010","E1011","E1065","E1069","E1100","E1101","E1165","E1169","E1300","E1301","E1310","E1311","E1365","E1369") or
       substr(icd9cm_4,1,5) in ("E0800","E0801","E0810","E0811","E0865","E0869","E0900","E0901","E0910","E0911","E0965","E0969","E1010","E1011","E1065","E1069","E1100","E1101","E1165","E1169","E1300","E1301","E1310","E1311","E1365","E1369") or
       substr(icd9cm_5,1,5) in ("E0800","E0801","E0810","E0811","E0865","E0869","E0900","E0901","E0910","E0911","E0965","E0969","E1010","E1011","E1065","E1069","E1100","E1101","E1165","E1169","E1300","E1301","E1310","E1311","E1365","E1369") or 
       substr(icd9cm_1,1,6) in ("E08618","E08620","E08621","E08622","E08628","E08630","E08638","E08641","E08649","E09618","E09620","E09621","E09622","E09628","E09630","E09638","E09641","E09649","E10618","E10620","E10621","E10622","E10628","E10630","E10638","E10641","E10649","E11618","E11620","E11621","E11622","E11628","E11630","E11638","E11641","E11649","E13618","E13620","E13621","E13622","E13628","E13630","E13638","E13641","E13649") or
       substr(icd9cm_2,1,6) in ("E08618","E08620","E08621","E08622","E08628","E08630","E08638","E08641","E08649","E09618","E09620","E09621","E09622","E09628","E09630","E09638","E09641","E09649","E10618","E10620","E10621","E10622","E10628","E10630","E10638","E10641","E10649","E11618","E11620","E11621","E11622","E11628","E11630","E11638","E11641","E11649","E13618","E13620","E13621","E13622","E13628","E13630","E13638","E13641","E13649") or
       substr(icd9cm_3,1,6) in ("E08618","E08620","E08621","E08622","E08628","E08630","E08638","E08641","E08649","E09618","E09620","E09621","E09622","E09628","E09630","E09638","E09641","E09649","E10618","E10620","E10621","E10622","E10628","E10630","E10638","E10641","E10649","E11618","E11620","E11621","E11622","E11628","E11630","E11638","E11641","E11649","E13618","E13620","E13621","E13622","E13628","E13630","E13638","E13641","E13649") or
       substr(icd9cm_4,1,6) in ("E08618","E08620","E08621","E08622","E08628","E08630","E08638","E08641","E08649","E09618","E09620","E09621","E09622","E09628","E09630","E09638","E09641","E09649","E10618","E10620","E10621","E10622","E10628","E10630","E10638","E10641","E10649","E11618","E11620","E11621","E11622","E11628","E11630","E11638","E11641","E11649","E13618","E13620","E13621","E13622","E13628","E13630","E13638","E13641","E13649") or
       substr(icd9cm_5,1,6) in ("E08618","E08620","E08621","E08622","E08628","E08630","E08638","E08641","E08649","E09618","E09620","E09621","E09622","E09628","E09630","E09638","E09641","E09649","E10618","E10620","E10621","E10622","E10628","E10630","E10638","E10641","E10649","E11618","E11620","E11621","E11622","E11628","E11630","E11638","E11641","E11649","E13618","E13620","E13621","E13622","E13628","E13630","E13638","E13641","E13649") then DM=1;
    /*GDM*/
    if substr(icd9cm_1,1,5) in ("Z8632","O2402","O2403","O2412","O2413","O2432","O2433","O2482","O2483","O2492","O2493") or
       substr(icd9cm_2,1,5) in ("Z8632","O2402","O2403","O2412","O2413","O2432","O2433","O2482","O2483","O2492","O2493") or
       substr(icd9cm_3,1,5) in ("Z8632","O2402","O2403","O2412","O2413","O2432","O2433","O2482","O2483","O2492","O2493") or
       substr(icd9cm_4,1,5) in ("Z8632","O2402","O2403","O2412","O2413","O2432","O2433","O2482","O2483","O2492","O2493") or
       substr(icd9cm_5,1,5) in ("Z8632","O2402","O2403","O2412","O2413","O2432","O2433","O2482","O2483","O2492","O2493") or
       substr(icd9cm_1,1,6) in ("O24011","O24012","O24013","O24019","O24111","O24112","O24113","O24119","O24311","O24312","O24313","O24319","O24410","O24414","O24415","O24419","O24420","O24424","O24425","O24429","O24430","O24434","O24435","O24439","O24811","O24812","O24813","O24819","O24911","O24912","O24913","O24919","O99810") or
       substr(icd9cm_2,1,6) in ("O24011","O24012","O24013","O24019","O24111","O24112","O24113","O24119","O24311","O24312","O24313","O24319","O24410","O24414","O24415","O24419","O24420","O24424","O24425","O24429","O24430","O24434","O24435","O24439","O24811","O24812","O24813","O24819","O24911","O24912","O24913","O24919","O99810") or
       substr(icd9cm_3,1,6) in ("O24011","O24012","O24013","O24019","O24111","O24112","O24113","O24119","O24311","O24312","O24313","O24319","O24410","O24414","O24415","O24419","O24420","O24424","O24425","O24429","O24430","O24434","O24435","O24439","O24811","O24812","O24813","O24819","O24911","O24912","O24913","O24919","O99810") or
       substr(icd9cm_4,1,6) in ("O24011","O24012","O24013","O24019","O24111","O24112","O24113","O24119","O24311","O24312","O24313","O24319","O24410","O24414","O24415","O24419","O24420","O24424","O24425","O24429","O24430","O24434","O24435","O24439","O24811","O24812","O24813","O24819","O24911","O24912","O24913","O24919","O99810") or
       substr(icd9cm_5,1,6) in ("O24011","O24012","O24013","O24019","O24111","O24112","O24113","O24119","O24311","O24312","O24313","O24319","O24410","O24414","O24415","O24419","O24420","O24424","O24425","O24429","O24430","O24434","O24435","O24439","O24811","O24812","O24813","O24819","O24911","O24912","O24913","O24919","O99810") then GDM=1;
    /*Obese*/
    if substr(icd9cm_1,1,3) in ("E66") or
       substr(icd9cm_2,1,3) in ("E66") or
       substr(icd9cm_3,1,3) in ("E66") or
       substr(icd9cm_4,1,3) in ("E66") or
       substr(icd9cm_5,1,3) in ("E66") or
       substr(icd9cm_1,1,4) in ("E660","E661","E662","E663","E668","E669","Z683","Z684") or
       substr(icd9cm_2,1,4) in ("E660","E661","E662","E663","E668","E669","Z683","Z684") or
       substr(icd9cm_3,1,4) in ("E660","E661","E662","E663","E668","E669","Z683","Z684") or 
       substr(icd9cm_4,1,4) in ("E660","E661","E662","E663","E668","E669","Z683","Z684") or 
       substr(icd9cm_5,1,4) in ("E660","E661","E662","E663","E668","E669","Z683","Z684") or 
       substr(icd9cm_1,1,5) in ("E6601","E6609","Z6824","Z6825","Z6826","Z6827","Z6828","Z6829","Z6830","Z6831","Z6832","Z6833","Z6834","Z6835","Z6836","Z6837","Z6838","Z6839","Z6841","Z6842","Z6843","Z6844","Z6845") or
       substr(icd9cm_2,1,5) in ("E6601","E6609","Z6824","Z6825","Z6826","Z6827","Z6828","Z6829","Z6830","Z6831","Z6832","Z6833","Z6834","Z6835","Z6836","Z6837","Z6838","Z6839","Z6841","Z6842","Z6843","Z6844","Z6845") or
       substr(icd9cm_3,1,5) in ("E6601","E6609","Z6824","Z6825","Z6826","Z6827","Z6828","Z6829","Z6830","Z6831","Z6832","Z6833","Z6834","Z6835","Z6836","Z6837","Z6838","Z6839","Z6841","Z6842","Z6843","Z6844","Z6845") or
       substr(icd9cm_4,1,5) in ("E6601","E6609","Z6824","Z6825","Z6826","Z6827","Z6828","Z6829","Z6830","Z6831","Z6832","Z6833","Z6834","Z6835","Z6836","Z6837","Z6838","Z6839","Z6841","Z6842","Z6843","Z6844","Z6845") or
       substr(icd9cm_5,1,5) in ("E6601","E6609","Z6824","Z6825","Z6826","Z6827","Z6828","Z6829","Z6830","Z6831","Z6832","Z6833","Z6834","Z6835","Z6836","Z6837","Z6838","Z6839","Z6841","Z6842","Z6843","Z6844","Z6845") then Obese = 1;
    /*Polycystic ovarian syndrome*/
    if substr(icd9cm_1,1,4) in ("E282") or
       substr(icd9cm_2,1,4) in ("E282") or
       substr(icd9cm_3,1,4) in ("E282") or
       substr(icd9cm_4,1,4) in ("E282") or
       substr(icd9cm_5,1,4) in ("E282") then POS = 1;
    if DM=1 or GDM=1 or Obese=1 or POS=1 then output;
    drop icd9cm_1-icd9cm_5;
  run;
%end;
%mend;
%DD

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
