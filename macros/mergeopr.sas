/*
  #+NAME          :  %mergeOPR
  #+TYPE          :  SAS
  #+DESCRIPTION   :  Repeatedly calling %reducerFO for a list of operations and merge on
                     study dataset.
                     The macro is called outside a datastep
  #+OUTPUT        :  output dataset from %reducerFC is merged to basedata
  #+AUTHOR        :  JNK/FLS
  #+CHANGELOG     :  Date        Initials Status
                  : 29-09-15    JNK      ported from DS
                  :
*/

%macro mergeOPR(basedata, inlib, outlib, IndexDate, sets, ajour=, postfix=);

  %put start mergeOPR: %qsysfunc(datetime(),datetime20.3), udtræksdato=&ajour);

  %local oprdat nsets i var;
  %let oprdat=%NewDatasetName(oprdattmp); /* temporært datasætnavn så data i work ikke overskrives */

  %let tabletypes = opr ube;
  %let ntype = %sysfunc(countw(&tabletypes));
  %let nsets =  %sysfunc(countw(&sets));
  %if &nsets gt 2 %then %do; /* reduce list */
    %nonrep(mvar=sets, outvar=newsets);
    %let sets = &newsets;
    %let nsets = %sysfunc(countw(&newsets));
  %end;

%do j=1 %to &ntype;
  %do i=1 %to &nsets;
    %let var=%sysfunc(compress(%qscan(&sets, &i)));
	%let tabletype = %sysfunc(compress(%qscan(&tabletypes, &j)));

	%let runtype = 0;
	%if %sysfunc(exist(&inlib..&tabletype.&var.all)) eq 1 %then %let runtype = 1;

	%if &runtype eq 1 %then %do;
		proc sql;
			create table &oprdat as
			select a.*, %if %varexist(&inlib..&tabletype.&var.ALL, oprdiag)=0 %then "" as oprdiag,;
                        b.&IndexDate.
			from &inlib..&tabletype.&var.ALL /*(drop=
			%if %varexist(&inlib..&var.ALL, &IndexDate)=1 %then &IndexDate; %else &IndexDate; afterbase )*/ a,
			&basedata b
			where a.pnr=b.pnr and &ajour between rec_in and rec_out
			order by pnr, &IndexDate, oprdate;
			%SqlQuit;

		%reduceOpr(&oprdat, &outlib..&tabletype.&var&postfix&Indexdate, &var&postfix, &IndexDate, ajour=&ajour);
	%end;
  %end;
%end;

  proc sort data=&basedata;
    by pnr &IndexDate;
  run;

  data &basedata;
    merge &basedata (in=A)
	%do j = 1 %to &ntype;
	    %do i=1 %to &nsets;
			%let runtype = 0;
			%let tabletype = %sysfunc(compress(%qscan(&tabletypes,&j)));
			%let var=%sysfunc(compress(%qscan(&sets,&i)));
			%if %sysfunc(exist(&inlib..&tabletype.&var.all)) eq 1 %then %let runtype = 1;

			%if &runtype eq 1 %then %do;
				&outlib..&tabletype.&var&postfix&Indexdate
			%end;
	    %end;
	%end;
    ;
    by pnr &IndexDate;
    if A;
  %RunQuit;
  %cleanup(&oprdat);
%mend;
