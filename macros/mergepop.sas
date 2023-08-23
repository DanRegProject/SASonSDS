%macro mergePop(Popindata, outdata, basedata, IndexDate, ajour=today());
%local ds;
%let ds=%sysfunc(round(%qsysfunc(datetime()),1));
%if %symexist(YearInDays)=0 %then %do; %local YearInDays; %let YearInDays=365.25; %end;
%put start mergePop: %qsysfunc(datetime(), datetime20.3);
  data work._persons1&ds;
    set &popindata;
*	  if in_date=out_date & in_date>. then delete; /*Deleting lines with in=out dates */
	  where rec_in_person <= &ajour <= rec_out_person AND rec_in_ophold <= &ajour <= rec_out_ophold;
          drop rec_in_person rec_out_person rec_in_ophold rec_out_ophold;
  run;

  %IF %varexist(&Popindata,inper_in_date) %THEN %DO;
       /* THIS CHECK TO IDENTIFY DATA PREPARED ON raw.Cpr3_dansk_ophold_periode_unik */
/* split the join in two parts, first the basic static person information*/
    proc sql;
        create table work._persons2&ds as
            select a.pnr, a.&IndexDate, b.birthdate, b.sex, b.sex_txt, b.deathdate
            from work._persons1&ds b right join &basedata a
            on a.pnr=b.pnr
            order by a.pnr, a.&IndexDate;

    proc sort data=work._persons2&ds noduplicates;
        by pnr &IndexDate;
    run;
    %sqlquit;

    /*  next the relevant migration information relative to the &IndexDate */
    /* this two-step procedure ensures that we can update &basedata with CPR information even in the situation that the CPR variables exists in &basedata. Proc SQL does not allow this out of the box */
    /* data &outdata;
     merge &basedata(in=a) work._persons2;
	 by pnr &IndexDate;
	 if a;
	 run;
*/
	proc sql undo_policy=none;
	create table &outdata as
	select a.*, b.birthdate, b.sex, b.sex_txt, b.deathdate
            from &basedata a left join work._persons2&ds b
            on a.pnr=b.pnr and a.&IndexDate=b.&IndexDate;

        create table work._persons2&ds as
            select a.pnr, a.&IndexDate,  b.statusdate, b.status, b.description,
            b.inper_in_date as pop_in label="Date of emmigration related to last emmigration before studystart, if any",
            b.inper_out_date as pop_out label="Date of emigration, first after studystart"
            from work._persons1&ds b right join &basedata a
            on a.pnr=b.pnr and a.&IndexDate between b.inper_in_date and b.inper_out_date
            order by a.pnr, a.&IndexDate;
/*in later merge it will give problems if there are repeats on IndexDate within pnr, therefore omit repetitions in _person2 */
    proc sort data=work._persons2&ds noduplicates;
        by pnr &IndexDate;
    run;
    %sqlquit;
    /* this two-step procedure ensures that we can update &basedata with CPR information even in the situation that the CPR variables exists in &basedata. Proc SQL does not allow this out of the box */
    data &outdata;
     merge &outdata(in=a) work._persons2&ds;
	 by pnr &IndexDate;
	 if a;
	 format age&IndexDate 8.;
	 if birthdate ne . then age&Indexdate= floor((&indexdate - birthdate)/&YearInDays);; /* only calculate age if birthday exists */
	 run;
   proc datasets nolist;
   delete _persons1&ds _persons2&ds;
   %runquit;
  %END;
  %ELSE %IF %varexist(&Popindata,in_date) %THEN %DO;
/*
  proc sql;
    create table &outlib..personer1 as
	 select *
	from &outlib..persons  where &ajour between rec_in and rec_out;
*/
  data work._persons1;
    set &popindata;
*	  if in_date=out_date & in_date>. then delete; /*Deleting lines with in=out dates */
	  where rec_in_person <= &ajour <= rec_out_person AND rec_in_ophold <= &ajour <= rec_out_ophold;
          drop rec_in rec_out;
  run;

  data work._persons1;
    set  work._persons1;
	by pnr /*rec_in*/ ; /* will use first. statements, suggest to already to a selection with rec_in and rec_out before this step!!! */

    retain  in out native active;
	format native active 4.;
	format in out out_next in_last in_date out_date statusdate date9. ;

	/* make a "lead"= out_next of the emigration date, to be used when arranging periods in DK */
	/* the test for eof1 makes sure the data step runs to the end of all observations, otherwise it would stop at the second last line */
	/* firstobs = 2 sets the program pointer to next line */
	if eof1=0 then
      set work._persons1 (firstobs=2 keep=out_date rename=(out_date=out_next)) end=eof1;
	if last.pnr then out_next=.; /* last lead for each pnr is set to . */

	/* make a "lag"=in_last */
	/* lag1 is a FIFO, not a lookup table for previous line. Store last in_date in every run. ifn ensures the call even if condition is not true */
	/* if not true, indv_last is set to . */
	in_last = ifn (first.pnr=0,lag1(in_date), .);

    /* reset values in first run */
	if first.pnr then do;
	  in = birthdate;
	  out = 0;
	  native = 0;
	  active = 0;

	  /* immigrant, in-date exists but no out-date */
	  if (out_date eq . and in_date ne .) then
        do;
          native = 0;
          in = in_date;/* immigrant case, startdate is in_date and next travel is out_date */
        end;

      /* homegrown, either no dates in in-date and out-date or both is set  */
	  if (out_date ne . and in_date ne .) or (out_date eq . and in_date eq .)
        then native = 1;
		/* in already set to foddato */

      /* no status date, pnr is active dd */
      if statusdate eq . then active = 1;
    end;
	/* end of first.pnr */
    if first.pnr=0 then
    do;
      in=in_date; /* all but first pnr */
	  if native = 1 then in=in_last; /* if native use previous indv_date; */
    end;

    if native = 1 then  out = out_date; /* normal case, pnr born in dk and leaves at some point */
	if native = 0 then  out = out_next; /* pnr moved to DK, period in DK from in-date to out-date in next line */


	/* special cases for last pnr.: in case of dead+travelhistory or alive+native+travelhistory then an extra output line is needed */
	if last.pnr then
    do;
	  if active = 1 then  out = &globalend;  /* If pnr is active then last udv_date is globalend */
	  if active = 0 then  out = statusdate;  /* if pnr is not active, then last udv_date is statusdate */

  	  if (deathdate ne . and out_date ne .) then
        do; /* only one line, dead and has been travelling. Add an extra line */
	      out=out_date;
	      output;  /* first line: birth ->out-date */
	      in=in_date;
	      out=statusdate;
	      output; /* extra line: in-date ->death */
	    end;
	  else if (out_date ne . and native=1 and active=1) then
        do; /* last line, has been travelling, native and active pnr. Add an extra line */
	      out=out_date;
	      output; /* first line: in-date->out-date */
	      in=in_date;
	      out=&globalend;
	      in_last = .; /* just to make it look nice... */
	      output; /* extra line: in-date -> globalend */
	    end;
	  else output; /* default last pnr */
	end;
	else output; /* default all lines but last pnr */

	run;

/* split the join in two parts, first the basic static person information*/
    proc sql;
        create table work._persons2 as
            select a.pnr, a.&IndexDate, b.birthdate, b.sex, b.sex_txt, b.deathdate
            from work._persons1 b right join &basedata a
            on a.pnr=b.pnr
            order by a.pnr, a.&IndexDate;

    proc sort data=work._persons2 noduplicates;
        by pnr &IndexDate;
    run;
    %sqlquit;

    /*  next the relevant migration information relative to the &IndexDate */
    /* this two-step procedure ensures that we can update &basedata with CPR information even in the situation that the CPR variables exists in &basedata. Proc SQL does not allow this out of the box */
    /* data &outdata;
     merge &basedata(in=a) work._persons2;
	 by pnr &IndexDate;
	 if a;
	 run;
*/
	proc sql undo_policy=none;
	create table &outdata as
	select a.*, b.birthdate, b.sex, b.sex_txt, b.deathdate
            from &basedata a left join work._persons2 b
            on a.pnr=b.pnr and a.&IndexDate=b.&IndexDate;

        create table work._persons2 as
            select a.pnr, a.&IndexDate,  b.statusdate, b.status, b.description,
            b.in as pop_in label="Date of emmigration related to last emmigration before studystart, if any",
            b.out as pop_out label="Date of emigration, first after studystart"
            from work._persons1 b right join &basedata a
            on a.pnr=b.pnr and a.&IndexDate between b.in and b.out
            order by a.pnr, a.&IndexDate;
/*in later merge it will give problems if there are repeats on IndexDate within pnr, therefore omit repetitions in _person2 */
    proc sort data=work._persons2 noduplicates;
        by pnr &IndexDate;
    run;
    %sqlquit;
    /* this two-step procedure ensures that we can update &basedata with CPR information even in the situation that the CPR variables exists in &basedata. Proc SQL does not allow this out of the box */
    data &outdata;
     merge &outdata(in=a) work._persons2;
	 by pnr &IndexDate;
	 if a;
	 format age&IndexDate 8.;
	 if birthdate ne . then age&Indexdate= floor((&indexdate - birthdate)/&YearInDays);; /* only calculate age if birthday exists */
	 run;

%macro tagud;
    data &outdata;
     merge &outlib..persontabel (in=a) &indata;
	 by pnr;
	 if a; /* keep only relevant pnr */
	 run;
%mend tagud;
%END;
    %mend;

