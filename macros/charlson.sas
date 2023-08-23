/* basedata    = input basedataset with at least pnr and dDate
   outlib      = output library where charlson table is placed
   IndexDate   = dDate, target date for each patient.
   PeriodStart = if not set, period will be from birth to IndexDate. Else period is from PeriodStart-IndexDate
   ajour       = ajour
   output: charlson table placed in outlib.
*/

%macro charlson (basedata, outlib, IndexDate, PeriodStart=, ajour=today());
  /* merge the two tables - maybe some of the variables from &basedata= is used when calculating charlson, e.g. date=dDate or indate=dDate-356 */;
  proc sql;
    create table work.charlson as
    select a.pnr, a.&IndexDate, b.outcome, b.indate as charlindate,  b.rec_in, b.rec_out, b.weight
    from &basedata a
    join charlib.lprcharlson b on a.pnr=b.pnr
    where &ajour between b.rec_in and b.rec_out
    order by pnr, &IndexDate, outcome;
   %sqlquit;


    data &outlib..charlson&IndexDate;
        set work.charlson;
        by pnr &IndexDate;

        length diagtype $12;
        format charlson&IndexDate 8.;
        retain diagtype; /* only count one time for each diag-group */;
        retain charlson&IndexDate; /* index summary */;

        if first.&IndexDate then do;
            charlson&IndexDate=0;
            diagtype = ''; /* make sure diagtype is not truncated when comparing to outcome */;
            end;

        if diagtype ^= outcome then do;
            diagtype = outcome;
          %if "&PeriodStart"="" %then %do;
          /* count charlson index from birth until &IndexDate */;
              charlsonDate&IndexDate=&IndexDate;
              format charlsonDate&IndexDate date.;
              if charlindate <=&IndexDate then charlson&IndexDate = charlson&IndexDate+weight;
              label charlson&IndexDate = "CHARLSON index at &IndexDate";
              keep pnr charlson&IndexDate charlsonDate&IndexDate &IndexDate;
              retain charlsonDate&IndexDate;
              %end;
          %else %do;
          /* count charlson index in the period from &periodStart to &IndexDate */;
              charlsonDateStart&IndexDate=&PeriodStart;
              charlsonDateEnd&IndexDate = &IndexDate;
              format  charlsonDateStart&IndexDate charlsonDateEnd&IndexDate date.;
              if &PeriodStart<=charlindate<=&IndexDate then charlson&IndexDate = charlson&IndexDate+weight;
              label charlson&IndexDate = "CHARLSON index mesured between &PeriodStart and &IndexDate";
              keep pnr charlson&IndexDate charlsonDateStart&IndexDate CharlsonDateEnd&IndexDate &IndexDate;
              retain charlsonDateStart&IndexDate;
              retain charlsonDateEnd&IndexDate;
              %end;
          end;

      if last.&IndexDate then output;
      %runquit;

	  data &outlib..charlson&IndexDate;
	    merge &basedata (in=a keep=pnr &IndexDate) &outlib..charlson&IndexDate (in=b);
		by pnr &IndexDate;
		if a and not b then charlson&IndexDate = 0; /* fill out with zeroes if pnr not in charlib.charlson */
	  %runquit;
    %mend;




