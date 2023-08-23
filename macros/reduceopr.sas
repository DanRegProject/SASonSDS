/*
name:     reduceOpr
          Outputdata from %findingOPR is reduced to a status with only one pnr at a specified time.
          It is packed within findingOPR.sas.
          this macro is called outside a datastep.
indata:   Input dataset name, should be output from %findingOPR. Required.
outdata:  Output dataset name. Required
outcome:  Short textstring to label the outcome, required
IndexDate: Date variable in indata or basedata= or date konstant, defining the date of required disease status. Optional
basedata: Input dataset with required population. Optional.
*/
%macro reduceOpr(indata, outdata, outcome, IndexDate, basedata=, ajour=today());
%put start reduceOpr: %qsysfunc(datetime(), datetime20.3), udtræksdato=&ajour;

%local temp;
%let temp=%NewDatasetName(tempopr);


proc sql;
  create table &temp as
  select a.pnr, a.oprdate, a.indate, a.outdate, a.opr, a.pattype,
  a.oprart, a.oprdiag
  %if &IndexDate ne %then, &IndexDate, (&IndexDate<a.oprdate) as afterbase_local;
  %if &IndexDate = %then , 1 as afterbase_local;
  from &indata a %if &basedata ne %then , &basedata b;
  where
  %if &basedata ne %then a.pnr=b.pnr and;
  &ajour between a.rec_in and a.rec_out
  order by pnr, %if &IndexDate ne %then &IndexDate, ;
  oprdate, indate, outdate, opr desc, oprart;
  delete from &temp where oprdate=.;
  %sqlquit;


  data &outdata ;
    set &temp;
    by pnr %if &IndexDate ne %then &IndexDate; afterbase_local;
    length %if &IndexDate ne %then %do;
      &outcome.FiOprBe&IndexDate
      &outcome.LaOprBe&IndexDate
      &outcome.FiOprDiagBe&IndexDate
      &outcome.LaOprDiagBe&IndexDate
    %end;
    &outcome.OprAf&IndexDate     &outcome.OprDiagAf&IndexDate $8;
    format
    %if &IndexDate ne %then
        &outcome.FiDateBe&IndexDate &outcome.LaDateBe&IndexDate
        &outcome.FiIndateBe&IndexDate &outcome.LaIndateBe&IndexDate
        &outcome.FiOutdateBe&IndexDate &outcome.LaOutdateBe&IndexDate;
        &outcome.DateAf&IndexDate &outcome.InDateAf&IndexDate &outcome.OutDateAf&IndexDate date.;
	format
            &outcome.FiOprBe&IndexDate &outcome.LaOprBe&IndexDate &outcome.OprAf&IndexDate
            &outcome.FiOprDiagBe&IndexDate &outcome.LaOprDiagBe&IndexDate &outcome.OprDiagAf&IndexDate
            &outcome.FiPattypeBe&IndexDate &outcome.LaPattypeBe&IndexDate &outcome.PattypeAf&IndexDate $8.;
	format
      &outcome.EventsAf&IndexDate 4.;
    retain
    %if &IndexDate ne %then
        &outcome.FiDateBe&IndexDate    &outcome.LaDateBe&IndexDate
        &outcome.FiIndateBe&IndexDate  &outcome.LaIndateBe&IndexDate
        &outcome.FiOutdateBe&IndexDate &outcome.LaOutdateBe&IndexDate
        &outcome.FiOprBe&IndexDate     &outcome.LaOprBe&IndexDate
        &outcome.FiOprDiagBe&IndexDate &outcome.LaOprDiagBe&IndexDate
        &outcome.FiPattypeBe&IndexDate &outcome.LaPattypeBe&IndexDate; /* end of %then */
        &outcome.DateAf&IndexDate
        &outcome.IndateAf&IndexDate    &outcome.OutdateAf&IndexDate
        &outcome.OprAf&IndexDate       &outcome.OprDiagAf&IndexDate
        &outcome.PattypeAf&IndexDate   &outcome.EventsAf&IndexDate;


    if %if &IndexDate ne %then first.&IndexDate; %if &IndexDate = %then first.pnr; then do;
    %if &IndexDate ne %then %do;
	  &outcome.FiDateBe&IndexDate    =.;
	  &outcome.LaDateBe&IndexDate    =.;
	  &outcome.FiIndateBe&IndexDate  =.;
	  &outcome.LaIndateBe&IndexDate  =.;
	  &outcome.FiOutdateBe&IndexDate =.;
	  &outcome.LaOutdateBe&IndexDate =.;
	  &outcome.FiOprBe&IndexDate     ="";
	  &outcome.LaOprBe&IndexDate     ="";
          &outcome.FiOprDiagBe&IndexDate ="";
	  &outcome.LaOprDiagBe&IndexDate ="";
	  &outcome.FiPattypeBe&IndexDate ="";
	  &outcome.LaPattypeBe&IndexDate ="";
	%end;
    &outcome.DateAf&IndexDate    =.;
    &outcome.InDateAf&IndexDate  =.;
    &outcome.OutDateAf&IndexDate =.;
    &outcome.PattypeAf&IndexDate ="";
    &outcome.OprAf&IndexDate     ="";
    &outcome.OprDiagAf&IndexDate ="";
    &outcome.EventsAf&IndexDate  =0;
  end;
  %if &IndexDate ne %then %do;
    if first.afterbase_local and afterbase_local=0 then do;
	  &outcome.FiDateBe&IndexDate    = Oprdate;
          &outcome.FiIndateBe&IndexDate  = indate;
          &outcome.FiOutdateBe&IndexDate = outdate;
	  &outcome.FiOprBe&IndexDate     = Opr;
          &outcome.FiOprDiagBe&IndexDate = OprDiag;
	  &outcome.FiPattypeBe&IndexDate = pattype;
	end;
    if last.afterbase_local and afterbase_local=0 then do;
	  &outcome.LaDateBe&IndexDate    = oprdate;
          &outcome.LaIndateBe&IndexDate  = indate;
          &outcome.LaOutdateBe&IndexDate = outdate;
	  &outcome.LaOprBe&IndexDate     = opr;
          &outcome.LaOprDiagBe&IndexDate = oprDiag;
	  &outcome.LaPattypeBe&IndexDate = pattype;
	end;
  %end;
  if first.afterbase_local and afterbase_local=1 then do;
  	&outcome.DateAf&IndexDate    = oprdate;
	&outcome.IndateAf&IndexDate  = indate;
       	&outcome.OutdateAf&IndexDate = outdate;
        &outcome.OprAf&IndexDate     = opr;
        &outcome.OprDiagAf&IndexDate = oprDiag;
	&outcome.PattypeAf&IndexDate = pattype;
  end;
  if afterbase_local=1 then &outcome.EventsAf&IndexDate + 1;
  if %if &IndexDate ne %then last.&IndexDate; %if &IndexDate = %then last.pnr; then output;
  keep pnr
  %if &IndexDate ne %then &IndexDate
      &outcome.FiDateBe&IndexDate     &outcome.LaDateBe&IndexDate
      &outcome.FiIndateBe&IndexDate   &outcome.LaIndateBe&IndexDate
      &outcome.FiOutdateBe&IndexDate  &outcome.LaOutdateBe&IndexDate
      &outcome.FiOprBe&IndexDate      &outcome.LaOprBe&IndexDate
      &outcome.FiOprDiagBe&IndexDate  &outcome.LaOprDiagBe&IndexDate
      &outcome.FiPattypeBe&IndexDate  &outcome.LaPattypeBe&IndexDate;
      &outcome.DateAf&IndexDate       &outcome.OprAf&IndexDate       &outcome.OprDiagAf&IndexDate
      &outcome.IndateAf&IndexDate     &outcome.OutdateAf&IndexDate
      &outcome.PattypeAf&IndexDate    &outcome.EventsAf&IndexDate;
  %if &IndexDate ne %then %do;
    label &outcome.FiOprBe&IndexDate       = "First &outcome code before inclusion event, &IndexDate";
    label &outcome.LaOprBe&IndexDate       = "Last  &outcome code before inclusion event, &IndexDate";
    label &outcome.FiOprDiagBe&IndexDate       = "First diagnose for &outcome code before inclusion event, &IndexDate";
    label &outcome.LaOprDiagBe&IndexDate       = "Last  diagnose for &outcome code before inclusion event, &IndexDate";
    label &outcome.FiDateBe&IndexDate      = "First date for &outcome operation before inclusion event, &IndexDate";
    label &outcome.LaDateBe&IndexDate      = "Last  date for &outcome operation before inclusion event, &IndexDate";
    label &outcome.FiIndateBe&IndexDate      = "First start date for contact of &outcome operation before inclusion event, &IndexDate";
    label &outcome.LaIndateBe&IndexDate      = "Last start date for contact of &outcome operation before inclusion event, &IndexDate";
    label &outcome.FiOutdateBe&IndexDate      = "First discharge date for contact of &outcome operation before inclusion event, &IndexDate";
    label &outcome.LaOutdateBe&IndexDate      = "Last discharge date for contact of &outcome operation before inclusion event, &IndexDate";
    label &outcome.FiPattypeBe&IndexDate   = "First pattype for &outcome operation before inclusion event, &IndexDate";
    label &outcome.LaPattypeBe&IndexDate   = "Last  pattype for &outcome operation before inclusion event, &IndexDate";
  %end;
  label &outcome.OprAf&IndexDate       = "&outcome code after inclusion event, &IndexDate";
  label &outcome.OprDiagAf&IndexDate       = "Diagnose for &outcome code after inclusion event, &IndexDate";
  label &outcome.PattypeAf&IndexDate   = "Pattype after inclusion event, &IndexDate";
  label &outcome.DateAf&IndexDate      = "Date for &outcome operation after inclusion event, &IndexDate";
  label &outcome.InDateAf&IndexDate   = "Start date for contact of &outcome operation after inclusion event, &IndexDate";
  label &outcome.OutDateAf&IndexDate   = "Discharge date for contact of &outcome operation after inclusion event, &IndexDate";
  label &outcome.EventsAf&IndexDate    = "Number of events after inclusion event";
  %if &IndexDate = %then %do;
      rename &outcome.OprAf&IndexDate      = &outcome.Opr;
      rename &outcome.OprDiagAf&IndexDate  = &outcome.OprDiag;
      rename &outcome.DateAf&IndexDate     = &outcome.Date;
      rename &outcome.PattypeAf&IndexDate  = &outcome.Pattype;
      rename &outcome.IndateAf&IndexDate   = &outcome.InDate;
      rename &outcome.OutdateAf&IndexDate  = &outcome.OutDate;
      rename &outcome.EventsAf&IndexDate   = &outcome.Events;
  %end;
%RunQuit;
%cleanup(&temp); /*  ryd op i work */
%mend;





