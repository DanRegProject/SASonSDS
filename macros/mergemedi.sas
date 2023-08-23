/*
  #+NAME          :  %mergeMedi
  #+TYPE          :  SAS
  #+DESCRIPTION   :  Repeatedly calling %reduceMediStatus for a list of operations and merge on
                     study dataset. Input material to %reduceMediStatus may be restricted by
                     optional parameters.
                     The macro is called outside a datastep
  #+OUTPUT        :  output dataset from %reducerFC is merged to basedata
  #+AUTHOR        :  JNK/FLS
  #+CHANGELOG     :  Date        Initials Status
                  : 29-09-15    JNK      ported from DS
                  :
*/

%macro mergeMedi(basedata, inlib, outlib, IndexDate, sets, ajour=today(), postfix=,subset=);
%put start mergeMedi: %qsysfunc(datetime(),datetime20.3), udtræksdato=&ajour);

%local medidat nsets i var;
%let medidat=%NewDatasetName(medidattmp); /* temporært datasætnavn så data i work ikke overskrives */

%let nsets =  %sysfunc(countw(&sets));
%if &nsets gt 2 %then %do; /* reduce list */
  %nonrep(mvar=sets, outvar=newsets);
  %let sets = &newsets;
  %let nsets = %sysfunc(countw(&newsets));
%end;

%do i=1 %to &nsets;
  %let var=%sysfunc(compress(%qscan(&sets, &i)));

  proc sql;
    create table &medidat as
	select a.*, b.&IndexDate.
	from &inlib..LMDB&var.ALL  a,
      &basedata b
	where a.pnr=b.pnr and &ajour between rec_in and rec_out
        %if "&subset" ne "" %then and &subset;
	order by pnr, &IndexDate, eksd;
	/* klargør til at lave en fra/til liste over atc numre */
	create table test as
	  select &var, count(pnr) as N from &medidat
	  group by &var
	  order by N;
	%RunQuit;
        %let atc = ;
	data _null_;
	  set test end=end;
	  retain fatc;
	  if _N_=1 and end then call symput("atc", substr(&var,1,3));
	  else do;
	  if _N_=1 then fatc=&var;
	  if end then call symput("atc", compress(cat(substr(&var,1,3), "-", substr(fatc,1,3))));
	  end;
    %runquit;

	%prereduceMediStatus(&medidat, &outlib..LMDB&var&postfix&IndexDate, &var&postfix, &atc, &IndexDate, ajour=&ajour);
	%end;
	  proc sort data=&basedata;
	    by pnr &IndexDate;
      run;

	  data &basedata;
	    merge &basedata (in=A)
		%do i=1 %to &nsets;
		%let var=%sysfunc(compress(%qscan(&sets,&i)));
		&outlib..LMDB&var&postfix&Indexdate
		%end;
		;
		by pnr &IndexDate;
		if A;
	%runquit;

  %cleanup(&medidat);

%mend;

