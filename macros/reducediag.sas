%macro reduceDiag(indata, outdata, outcome, IndexDate, basedata=, ajour=today());
/*
tager indexet lavet af FindingDiag og reducerer til en række pr pnr
inddata:  input datasæt
outdata:  retur datasæt
outcome:  prefix for variable
IndexDate: postfix for variable
basedata: optional datasæt at tage IndexDate fra
*/
%local temp;
%put start reduceDiag: %qsysfunc(datetime(), datetime20.3), udtræksdato=&ajour;

%let temp=%NewDatasetName(temp);


proc sql;
  create table &temp as
  select a.* %if &IndexDate ne %then, &IndexDate, (&IndexDate<a.indate) as afterbase_local;
  %if &IndexDate = %then , 1 as afterbase_local;
  from &indata a %if &basedata ne %then , &basedata b;
  where
  %if &basedata ne %then a.pnr=b.pnr and;
  &ajour between a.rec_in and a.rec_out
  order by a.pnr, %if &IndexDate ne %then &IndexDate, ;
  a.indate, a.outdate, a.diagnose desc, a.diagtype;
  %sqlquit;

  data &outdata ; set &temp;
  by pnr %if &IndexDate ne %then &IndexDate; afterbase_local;
  length %if &IndexDate ne %then
  &outcome.FiDiagBe&IndexDate
  &outcome.LaDiagBe&IndexDate
  ;
  &outcome.DiagAf&IndexDate $6;
  retain
  %if &IndexDate ne %then
  &outcome.FiDateBe&IndexDate     &outcome.LaDateBe&IndexDate
  &outcome.FiOutDateBe&IndexDate  &outcome.LaOutDateBe&IndexDate
  &outcome.FiDiagBe&IndexDate     &outcome.LaDiagBe&IndexDate
  &outcome.FiDiagtypeBe&IndexDate &outcome.LaDiagtypeBe&IndexDate
  &outcome.FiPattypeBe&IndexDate  &outcome.LaPattypeBe&IndexDate;
  &outcome.DateAf&IndexDate       &outcome.OutDateAf&IndexDate
  &outcome.DiagAf&IndexDate       &outcome.PattypeAf&IndexDate
  &outcome.DiagtypeAf&IndexDate   &outcome.EventsAf&IndexDate;
  /* specify formats to avoid warnings */
  format
    %if &IndexDate ne %then
      &outcome.FiDiagtypeBe&IndexDate &outcome.LaDiagtypeBe&IndexDate;
     &outcome.DiagtypeAf&IndexDate   $1.0; /* char */
  format
    %if &IndexDate ne %then
      &outcome.FiPattypeBe&IndexDate  &outcome.LaPattypeBe&IndexDate ;
    &outcome.PattypeAf&IndexDate
    &outcome.EventsAf&IndexDate  1.0; /* num */
  format
  %if &IndexDate ne %then &outcome.FiDateBe&IndexDate     &outcome.LaDateBe&IndexDate
                          &outcome.FiOutDateBe&IndexDate  &outcome.LaOutDateBe&IndexDate;
                          &outcome.DateAf&IndexDate       &outcome.OutDateAf&IndexDate date.;

  if %if &IndexDate ne %then first.&IndexDate; %if &IndexDate = %then first.pnr; then do;
    %if &IndexDate ne %then %do;
	  &outcome.FiDateBe&IndexDate     =.;
	  &outcome.LaDateBe&IndexDate     =.;
	  &outcome.FiOutDateBe&IndexDate  =.;
	  &outcome.LaOutDateBe&IndexDate  =.;
	  &outcome.FiDiagBe&IndexDate     ="";
	  &outcome.FiDiagtypeBe&IndexDate ="";
	  &outcome.LaDiagBe&IndexDate     ="";
	  &outcome.LaDiagTypeBe&IndexDate ="";
	  &outcome.FiPattypeBe&IndexDate  =.;
	  &outcome.LaPattypeBe&IndexDate  =.;
	%end;
    &outcome.DateAf&IndexDate    =.;
	&outcome.OutDateAf&IndexDate =.;
	&outcome.PattypeAf&IndexDate =.;
	&outcome.DiagtypeAf&IndexDate="";
	&outcome.DiagAf&IndexDate    ="";
	&outcome.EventsAf&IndexDate  =0;
  end;
  %if &IndexDate ne %then %do;
    if first.afterbase_local and afterbase_local=0 then do;
	  &outcome.FiDateBe&IndexDate     = indate;
      &outcome.FiOutDateBe&IndexDate  = outdate;
	  &outcome.FiDiagBe&IndexDate     = diagnose;
	  &outcome.FiDiagtypeBe&IndexDate = diagtype;
	  &outcome.FiPattypeBe&IndexDate  = input(pattype, 1.);
	end;
    if last.afterbase_local and afterbase_local=0 then do;
	  &outcome.LaDateBe&IndexDate     = indate;
      &outcome.LaOutDateBe&IndexDate  = outdate;
	  &outcome.LaDiagBe&IndexDate     = diagnose;
	  &outcome.LaDiagtypeBe&IndexDate = diagtype;
	  &outcome.LaPattypeBe&IndexDate  = input(pattype, 1.);
	end;
  %end;
  if first.afterbase_local and afterbase_local=1 then do;
  	&outcome.DateAf&IndexDate     = indate;
	&outcome.DiagAf&IndexDate     = diagnose;
	&outcome.OutDateAf&IndexDate  = outdate;
	&outcome.DiagtypeAf&IndexDate = diagtype;
	&outcome.PattypeAf&IndexDate  = input(pattype, 1.);
  end;
  if afterbase_local=1 then &outcome.EventsAf&IndexDate + 1;
  if %if &IndexDate ne %then last.&IndexDate; %if &IndexDate = %then last.pnr; then output;
  keep pnr
  %if &IndexDate ne %then &IndexDate
    &outcome.FiDateBe&IndexDate     &outcome.LaDateBe&IndexDate
    &outcome.FiOutDateBe&IndexDate  &outcome.LaOutDateBe&IndexDate
    &outcome.FiDiagBe&IndexDate     &outcome.LaDiagBe&IndexDate
	&outcome.FiDiagtypeBe&IndexDate &outcome.LaDiagTypeBe&IndexDate
	&outcome.FiPattypeBe&IndexDate  &outcome.LaPattypeBe&IndexDate;
	&outcome.DateAf&IndexDate       &outcome.DiagAf&IndexDate
	&outcome.OutDateAf&IndexDate    &outcome.DiagtypeAf&IndexDate
	&outcome.PattypeAf&IndexDate    &outcome.EventsAf&IndexDate;
  %if &IndexDate ne %then %do;
    label &outcome.FiDateBe&IndexDate     = "First date for &outcome diagnose Before inclusion event, &IndexDate";
    label &outcome.LaDateBe&IndexDate     = "Last  date for &outcome diagnose Before inclusion event, &IndexDate";
    label &outcome.FiOutDateBe&IndexDate  = "First outdate for &outcome diagnose Before inclusion event, &IndexDate";
    label &outcome.LaOutDateBe&IndexDate  = "Last  outdate for &outcome diagnose Before inclusion event, &IndexDate";
    label &outcome.FiDiagBe&IndexDate     = "First &outcome code Before inclusion event, &IndexDate";
    label &outcome.LaDiagBe&IndexDate     = "Last  &outcome code Before inclusion event, &IndexDate";
    label &outcome.FiDiagtypeBe&IndexDate = "First &outcome code type Before inclusion event, &IndexDate";
    label &outcome.LaDiagtypeBe&IndexDate = "Last  &outcome code type Before inclusion event, &IndexDate";
    label &outcome.FiPattypeBe&IndexDate  = "First pattype for &outcome diagnose Before inclusion event, &IndexDate";
    label &outcome.LaPattypeBe&IndexDate  = "Last  pattype for &outcome diagnose Before inclusion event, &IndexDate";
  %end;
  label &outcome.DiagAf&IndexDate         = "&outcome code After inclusion event, &IndexDate";
  label &outcome.PattypeAf&IndexDate      = "Pattype After inclusion event, &IndexDate";
  label &outcome.DiagtypeAf&IndexDate     = "&outcome code type After inclusion event, &IndexDate";
  label &outcome.DateAf&IndexDate         = "Date for &outcome diagnose After inclusion event, &IndexDate";
  label &outcome.OutDateAf&IndexDate      = "OutDate for &outcome diagnose After inclusion event, &IndexDate";
  label &outcome.EventsAf&IndexDate       = "Number of events After inclusion event";
  %if &IndexDate = %then %do;
    rename &outcome.DiagAf&IndexDate      = &outcome.Diag;
	rename &outcome.DateAf&IndexDate      = &outcome.Date;
	rename &outcome.PattypeAf&IndexDate   = &outcome.Pattype;
	rename &outcome.DiagtypeAf&IndexDate  = &outcome.Diagtype;
	rename &outcome.OutDateAf&IndexDate   = &outcome.OutDate;
	rename &outcome.EventsAf&IndexDate    = &outcome.Events;
  %end;
%RunQuit;
%cleanup(&temp); /*  ryd op i work */
%mend;





