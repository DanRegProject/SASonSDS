/*
  #+NAME          :  %mergeDiag
  #+TYPE          :  SAS
  #+DESCRIPTION   :  Repeatedly calling %reduceDiag for a list of diagnosis and merge on
                     study dataset. Input material to %reduceDiag may be restricted by optional
                     parameters.
                     The macro is called outside a datastep
  #+OUTPUT        :  output dataset from %reduceDiag is merged to basedata
  #+AUTHOR        :  JNK/FLS
  #+CHANGELOG     :  Date        Initials Status
                  :  10-09-15    JNK      ported from DS
                  :
*/

%macro mergeDiag(basedata, inlib, outlib, IndexDate, sets, subset=, postfix=, hosp=, ajour=today());
%put start mergeDiag: %qsysfunc(datetime(),datetime20.3), udtræksdato=&ajour;

%local I nsets var mLPR_i;

%local lprdat;
%let lprdat=%NewDatasetName(lprdattmp); /* temporært datasætnavn så data i work ikke overskrives */
%local lprhosp;
%let lprhosp=%NewDatasetName(lprhosptmp); /* temporært datasætnavn så data i work ikke overskrives */

%let nsets =  %sysfunc(countw(&sets));
%if &nsets gt 2 %then %do; /* reduce list */
  %nonrep(mvar=sets, outvar=newsets);
  %let sets = &newsets;
  %let nsets = %sysfunc(countw(&newsets));
%end;

%do mLPR_i=1 %to &nsets;
  %let var=%sysfunc(compress(%qscan(&sets, &mLPR_i)));
  data &lprdat;
    set &inlib..LPR&var.ALL;
	where &ajour between rec_in and rec_out
	%if %isBlank(%superq(subset))=0 %then and &subset;
	;
  %RunQuit;
  %if %isBlank(%superq(hosp))=0 %then %do; /* dette sikrer at udskrivningsdato fremskrives til endelig udskrivning for indlæggelser; diagnose datoen (IndexDate) ændres ikke */
	proc sql;
	  create table &lprhosp as
	  select a.*, b.hosp_in label="first day at hospital", b.hosp_out label="last day at hospital", b.hospdays label="number of days at hospital"/* jnk added for Mette */
	  from &lprdat a left join &hosp b
	  on a.pnr=b.pnr
	  and (a.indate>=b.hosp_in and a.indate<=b.hosp_out)
	  order by pnr, indate;
    quit;
	data &lprdat;
	 set &lprhosp;
         if pattype in ("0","1") then outdate=hosp_out;
         drop hosp_in hosp_out;
	%runquit;
  %end;
  %reduceDiag(&lprdat, &outlib..LPR&var&postfix&Indexdate, &var&postfix, &IndexDate, basedata=&basedata, ajour=&ajour);
%end;
proc sort data=&basedata;
  by pnr &IndexDate;
run;
data &basedata;
  merge &basedata (in=A)
  %do I=1 %to &nsets;
	%let var=%sysfunc(compress(%qscan(&sets,&I)));
	&outlib..LPR&var&postfix&Indexdate
  %end;
  ;
  by pnr &IndexDate;
  if A;
%RunQuit;
%cleanup(&lprdat);
%if %isBlank(%superq(hosp))=0 %then %do; /* utestet med hosp! */
proc sql;
create table &lprhosp as
    select a.*, b.hosp_in, b.hosp_out, b.hospdays
    from &basedata a left join &hosp b on
    a.pnr=b.pnr
    and &indexDate between b.hosp_in and b.hosp_out
    order by pnr, &indexDate, b.hosp_out;
data &basedata;
    set &lprhosp;
	by pnr &indexDate;
	if last.&indexDate;
  %runquit;
  %cleanup(&lprhosp);
%end;
%mend;
