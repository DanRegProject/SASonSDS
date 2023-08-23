%let lastyr=%sysfunc(year("&sysdate"d)); /* will use the date / year of the sas-session */

options compress=YES;
*options mprint merror symbolgen mlogic macrogen ;
*options mprint nomerror nosymbolgen nomlogic nomacrogen ;
*options mprint merror mlogic macrogen ;
options mprint merror spool;
%let sqlmax=max;

%include "&macropath/sas/macros/getnewrawdir.sas"; /*add subfolder to raw dir (new in 2023)*/
%get_new_rawdir(&globalprojectpath/InputData);
*libname raw      &newraw access=readonly; 

libname Risklib  "&globalprojectpath/MasterData/RiskTables" access=readonly; /* risk tables: chads, chads2vasc, HASBLED ATRIA */
libname Charlib  "&globalprojectpath/MasterData/Charlson" access=readonly;   /* risk tables: charlson */
libname mcolib  "&globalprojectpath/MasterData/RiskTables";* access=readonly; /* risk tables: chads, chads2vasc, HASBLED ATRIA */


%let globalend    = mdy(12,31,2099);
%let globalstart  = mdy(01,06,2016); /* first datacollection */
%let YearInDays = 365.25;

/* formats */
%include "&macropath/sas/formats/fcollection.sas";

/* helpful macros */
%include "&macropath/sas/macros/nonrep.sas"; /* remove doublets */
%include "&macropath/sas/macros/genEndpoint.sas";
%include "&macropath/sas/macros/array.sas";
%include "&macropath/sas/macros/do_over.sas";
%include "&macropath/sas/macros/numlist.sas";
%include "&macropath/sas/macros/header.sas";
/* generates txt file with used ATC, LPR and OPR codes. To be called from master.sas */
%include "&macropath/sas/macros/create_datalist.sas";
/* make a file for SAS comments */
%include "&macropath/sas/macros/describeSASchoises.sas";
/* macros for calculations of indexes */
%include "&macropath/sas/macros/charlson.sas";
%include "&macropath/sas/macros/multicoscore.sas";
%include "&macropath/sas/macros/riskmacros.sas"; /* HASBLED, CHADS2, CHA2DS2-VASc, ATRIA */
/* TNM cancer stages */
%include "&macropath/sas/macros/cancer_stages.sas";
/* transpose table according to idate  */
%include "&macropath/sas/macros/transpose.sas";
/* Macros for table creation */
%include "&macropath/sas/macros/macroutilities.sas";

%include "&macropath/sas/macros/reduceDiag.sas";
%include "&macropath/sas/macros/reduceMediPeriods.sas";
%include "&macropath/sas/macros/reduceMediStatus.sas";
%include "&macropath/sas/macros/reduceOpr.sas";
%include "&macropath/sas/macros/reduceLab.sas";
%include "&macropath/sas/macros/prereduceMediStatus.sas";
%include "&macropath/sas/macros/reducecanpat.sas";

%include "&macropath/sas/macros/baseDiag.sas";
%include "&macropath/sas/macros/baseOpr.sas";
%include "&macropath/sas/macros/baseMedi.sas";


%include "&macropath/sas/macros/mergeDiag.sas";
%include "&macropath/sas/macros/mergeOpr.sas";
%include "&macropath/sas/macros/mergeMedi.sas";
%include "&macropath/sas/macros/mergePop.sas";
%include "&macropath/sas/macros/mergeCanPat.sas";
%include "&macropath/sas/macros/mergeLab.sas";

%include "&macropath/sas/macros/smoothhosp.sas";
%include "&macropath/sas/macros/qualdiag.sas";

%include "&macropath/sas/macros/getDiag.sas";
%include "&macropath/sas/macros/getMedi.sas";
%include "&macropath/sas/macros/getPOP.sas";
%include "&macropath/sas/macros/getOpr.sas";
%include "&macropath/sas/macros/getHosp.sas";
%include "&macropath/sas/macros/getMFR.sas";
%include "&macropath/sas/macros/getSSR.sas";
%include "&macropath/sas/macros/ExclDiag.sas";
%include "&macropath/sas/macros/checklog.sas";
%include "&macropath/sas/macros/dirlist.sas";
%include "&macropath/sas/macros/nobs.sas";
%include "&macropath/sas/macros/getCanpat.sas";
%include "&macropath/sas/macros/getLab.sas";

%include "&macropath/sas/macros/combinewithold.sas";
%include "&macropath/sas/macros/combinelines.sas";
%include "&macropath/sas/macros/getrawtables.sas";
%include "&macropath/sas/macros/makeupdatetxt.sas";
%include "&macropath/sas/macros/gettablesoverview.sas";
%include "&macropath/sas/macros/TjekMacro.sas";
%include "&macropath/sas/macros/datacheck.sas";
%include "&macropath/sas/macros/getpnrandrecnum.sas";
%include "&macropath/sas/macros/macrolibrary.sas";
/* Adherence */

%include "&macropath/sas/macros/adherencemacros.sas";
/* published diagnosis and drugs  */
%include "&macropath/sas/macros/icd_atcdefines.sas"; /* easy generation of codes for ATC, IDC etc. */
%include "&macropath/sas/ICD_ATC_codes/ATCkoder.sas";
%include "&macropath/sas/ICD_ATC_codes/LPRkoder.sas";
%include "&macropath/sas/ICD_ATC_codes/LPRriskscores.sas";
%include "&macropath/sas/ICD_ATC_codes/OPRkoder.sas";
%include "&macropath/sas/ICD_ATC_codes/UBEkoder.sas";
%include "&macropath/sas/ICD_ATC_codes/ATCriskscores.sas";
%include "&macropath/sas/ICD_ATC_codes/Riskscores.sas";
%include "&macropath/sas/ICD_ATC_codes/DCR codes.sas";
%include "&macropath/sas/ICD_ATC_codes/LPRkoder2020.sas";
%include "&macropath/sas/ICD_ATC_codes/depclass.sas"; /* genereret i populationagregateddata/departmenttype/code */

