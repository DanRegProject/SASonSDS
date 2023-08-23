/*
  Macro reduceMediPeriods
  Output data from  %getMedi is reduced to treatment periods,with optional vaiables indicating if
  each period is before, including or after IndexDate.

  Multiple rows per pnr each indicatin a period of treatment.

  Enddate is estimated according to selected type:
  Type 1:  Periods based on drug use per day per person and ATC code (&drug). Enddate is estimated as
           last prescription date plus number of pills available in the last purchase if dose is average
           pills per day in the period.
           If this enddate exceeds startdate of the next period, these periods are joined.
  Type 2:  Periods based on individual dose based on the frequency of aquiring drugs per day per person
           and ATC code (&drug).
  Type 3:  Periods based on days between prescriptions (look at a fixed period=InclusionDays).

  The macro is called outside a datastep.

  Input for macro:
    indata            Input dataset name, should be output from %getMedi. Required
    outdata           Output dataset name. Required.
    drug              Variable in indata identifying the drug, Required.
    type              1: fixed dose strategy, 2: variable dose strategy, 3: fixed period strategy. Required.

  Default, used for all types:
    ajour=            If set, reduce indata to ajour period.
    IndexDate=        Date variable in indata or date constant. Defining the date of required treatment status.
    slipdays=1        Max. allowed days between subsequent prescriptions with same treatment.
    slipscale=1.5     How many pills did you forget? Allowed increase in observed grace period.
    If slipdays is preferred to slipscale, then set slipscale to a high number (and vice versa).

  Type 1:
    tabsperday=       Number of tablets per day
  Type 2:
    stddosage=        Initial standard dose
    maxdosage=        Upper limit of standard dose
    mindosage=0.1     Lower limit of standard dose
  Type 3:
    InclusionDays=    Amount of days in a period from purchase (eksd date) until periodend

  Output:
    pnr
    &IndexDate
    &drug
    startdate
    enddate
    nvisists
    If type 1: dailydose
    If type 2: maxpack
    If &IndexDate:
      &drug.Before&IndexDate = "Indicator, treatment period before inclusion event, &IndexDate"
      &drug.During&IndexDate = "Indicator, treatment period during inclusion event, &IndexDate"
      &drug.After&IndexDate  = "Indicator, treatment period after  inclusion event, &IndexDate"


*/

%macro reduceMediPeriods(indata, outdata, drug, type, IndexDate=, ajour=today(), slipscale=1.5, slipdays=1, tabsprday=, stddosage=, maxdosage=, mindosage=0.1, InclusionDays=,subset=,bydrug=FALSE);

    %if &type=1 and &tabsprday= %then %do;
        %put ERROR: ReduceMediPeriods: tabsprday must be specified if type=1.;
        %abort cancel;
        %end;
    %if &type=2 and &stddosage= %then %do;
        %put ERROR: ReduceMediPeriods: stddosage must be specified if type=2.;
        %abort cancel;
        %end;

%if &bydrug eq FALSE %then %do;
    proc sql noprint;
     	 select distinct &drug into :druglist separated by '_' from &indata;
  	     select length("&druglist") into :lendruglist from &indata(obs=1);
    quit;
%end;
/* reduce dataset to ajour period */
  data _temp1_;
    set &indata;
%if "&ajour" ne "" OR "&subset" ne "" %then %do;
    where
    %if %varexist(&indata, rec_in) %then %do;
     &ajour between rec_in and rec_out
         %if "&subset" ne "" %then and;
     %end;
         %if "&subset" ne "" %then &subset;
         ;
      %if %varexist(&indata, rec_in) %then drop rec_in rec_out;;
%end;

  %runquit;

proc sort data =  _temp1_;
  by pnr &drug eksd;
%runquit;

data _temp1_;
  set _temp1_;
  packsize = packsize*Npack;  /* packsize= antal købte tabletter (stk) i pakken. Npack= antal pakker */
  dosis    = strnum*packsize; /* antal WHO anbefalede doser pr køb */
%runquit;

/* tag hensyn til, at nogle får udskrevet flere recepter på samme drug samme dag */
proc summary data = _temp1_ nway;
  by pnr &drug eksd;
  %if &IndexDate ne %then id &IndexDate;;
  var packsize dosis;
  output out = _temp1_ sum=;
%runquit;

data &outdata;
  set _temp1_;
  by pnr &drug;
  retain startdate enddate nvisits %if &type=1 %then maxpack; %if &type=2 %then cumdosis dailydose ;;

  if first.&drug then do;
    nvisits=1;
	startdate = eksd;
    %if &type=1 %then %do;
	  enddate=floor(startdate+packsize/&tabsprday);
	  maxpack=packsize/&tabsprday;
	%end;
	%if &type=2 %then %do;
	  dailydose=&stddosage;
	  enddate=floor(startdate+dosis/dailydose);
	  cumdosis=dosis;
	%end;
	%if &type=3 %then %do;
	  enddate= startdate+&InclusionDays;
	%end;
  end;

  if first.&drug=0 then do;
    if enddate+min(&slipdays, %if &slipscale<. %then (enddate-startdate)*&slipscale/100; %else .;)+1 ge eksd then do; /* +1 for at undgå at stoppe dagen før ny opstart */
	  nvisits+1;
	  %if &type=1 %then %do;
	    enddate=floor(max(eksd,enddate)+packsize/&tabsprday);
        maxpack=packsize/&tabsprday + max(0,(maxpack-(min(eksd,enddate)-startdate))); /* formodet antal dagsdoser til rådighed nu */
	  %end;
	  %if &type=2 %then %do;
	    cumdosis=cumdosis+dosis;
		dailydose=min(&maxdosage,max((cumdosis-dosis)/(eksd-startdate), &mindosage));
		enddate=floor(startdate+cumdosis/dailydose); /* som ovenfor, da indløste piller bruges fremadrettet */
	  %end;
	  %if &type=3 %then %do;
	    enddate=eksd+&InclusionDays;
	  %end;
	end;
	else do;
	  enddate=floor(enddate+min(&slipdays, %if &slipscale<. %then (enddate-startdate)*&slipscale/100; %else .;));
	  output;
	  startdate=eksd;
	  nvisits=1;
	  %if &type=1 %then %do;
	    enddate=floor(startdate+packsize/&tabsprday);
		maxpack=packsize/&tabsprday;
	  %end;
	  %if &type=2 %then %do;
	    dailydose = &stddosage;
		enddate=floor(startdate+dosis/dailydose);
		cumdosis = dosis;
	  %end;
	  %if &type=3 %then %do;
	    enddate=startdate+&Inclusiondays;
	  %end;
	end;
  end;

  if last.&drug then do;
    enddate=floor(enddate+min(&slipdays, %if &slipscale<. %then (enddate-startdate)*&slipscale/100; %else .;));
	output;
  end;
  label nvisits ="Number of farmacy visits in treatment period";
  format startdate enddate date.;
%runquit;

data %if &IndexDate ne %then _temp1_ _temp2_ ; _temp3_;
  set &outdata;
  by pnr &drug;
  %if &IndexDate ne %then %do;
    &drug.Before&IndexDate = (&IndexDate>enddate);
	&drug.During&IndexDate = (&IndexDate>startdate and &IndexDate<=enddate);
	&drug.After&IndexDate  = (&IndexDate<=startdate);
	label &drug.Before&IndexDate  = "&drug treatment period before &IndexDate";
	label &drug.During&IndexDate  = "&drug treatment period before and at &IndexDate";
	label &drug.After&IndexDate   = "&drug treatment period after or starting at &IndexDate";
  %end;
  format startdate enddate date.;
  rename startdate = &drug.start;
  rename enddate   = &drug.end;
  label startdate  = "&drug treatment period start";
  label enddate    = "&drug treatment period end";
  keep pnr &drug &IndexDate startdate enddate nvisits
  %if &type=2 %then dailydose;
  %if &type=1 %then maxpack;
  %if &IndexDate ne %then &drug.before&IndexDate &drug.after&IndexDate &drug.during&IndexDate;; /* end of keep */
  %if &IndexDate ne %then %do;
    if &drug.before&Indexdate then output _temp1_;
	if &drug.during&IndexDate then output _temp2_;
	if &drug.after&IndexDate  then output _temp3_;
  %end;
  %else %do;
    &drug.After&IndexDate=1;
	output _temp3_;
  %end;
%runquit;
%if &IndexDate ne %then %do;
  proc sort data=_temp1_;
    by pnr &drug descending &drug.start;
  %runquit;
  data _temp1_;
    set _temp1_;
	by pnr &drug;
	if first.&drug then &drug.Period&IndexDate=1;
	else &Drug.Period&IndexDate+1;
  %runquit;
  data _temp1_;
    set _temp1_;
        &drug.period&IndexDate=-1*&drug.Period&IndexDate;
  %runquit;
  data _temp2_;
    set _temp2_;
	&drug.Period&IndexDate=0;
  %runquit;
%end;
data _temp3_;
  set _temp3_;
  by pnr &drug;
  if first.&drug then &drug.Period&IndexDate=1;
  else &drug.Period&IndexDate+1;
%runquit;
data &outdata;
  set %if &IndexDate ne %then _temp1_ _temp2_; _temp3_;
%runquit;
proc sort data=&outdata;
  by pnr &drug &drug.Period&IndexDate;
%runquit;
proc datasets nolist;
  delete %if &Indexdate ne %then _temp1_ _temp2_; _temp3_;
%runquit;

/* cleanup dataset - if no purchase of &drug, then reset to FALSE */
data &outdata;
  set &outdata;
    if &drug = "" then do;
  	  nvisits = 0;
	   %if &Indexdate ne %then &drug.before&IndexDate = 0;;
	  &drug.Period&IndexDate = 0;
          %if &type=2 %then dailydose=0;;
          %if &type=1 %then maxpack=0;;
	end;
%runquit;
%mend;





