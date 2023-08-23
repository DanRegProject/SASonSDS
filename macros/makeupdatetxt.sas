%macro make_updatetxt(lib, path, date);
  proc sort data=&lib..opdateringsoversigt;
    by skema opdateringstidspunkt;
	*drop lms; /* use the date from lms_opdateringsoversigt */
  run;
/*  proc sort data=&lib..lms_opdater_&LMSproject;
    by skema opdateringstidspunkt;
  run;*/
data &lib..RawUpdateDates (drop= tabel opdateringstidspunkt);
  set &lib..opdateringsoversigt /* &lib..lms_opdater_&LMSproject*/ end=eof;
  by skema ;
  format dato date9.;
*  format upd_date date9.;
*  upd_date=&date;
  file "&path\RawUpdateDates.txt";

  dato = datepart(opdateringstidspunkt);
  if last.skema then /* use last - will get the last update-date */
      put skema @13 " Master data available until " @42 dato;
  if eof then do;
    put "NDR" @13 " Master data available until " @42 "31DEC2012";
    put ;
*    put "LMS population updated %sysfunc(&LMSUntil_1577, worddate.) in project FSEID00001577";
*    put "LMS population updated %sysfunc(&LMSUntil_2177, worddate.) in project FSEID00002177";
*    put "LMS population updated %sysfunc(&LMSUntil_2362, worddate.) in project FSEID00002362";
    put "getDiag, getHosp and getOPR use LPR until 2005, from 2005 onwards LPR2 is used";
    put "getMedi use LMS";
    put "getPOP use CPR3";
	put "The input to the tables will be collected approximately 1,5 month";
    put "before the table is updated";
	put "Last update of tables was done: %sysfunc(&date, worddate.)";
    put "set your ajourdate to this date (or later) if you want the newest data";
  end;
%runquit;
%mend;
