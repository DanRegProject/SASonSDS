/*
  #+NAME          :  %smoothhosp
  #+TYPE          :  SAS
  #+DESCRIPTION   :  Smoother indlæggelsesperioder
                     the variable nofDays will determine how long time between periods before smoothing.
  #+OUTPUT        :  output datasætnavn
  #+AUTHOR        :  JNK/FLS
  #+CHANGELOG     :  Date        Initials Status
                  :  03-11-15    JNK      ported from DS, rewritten
                  :  09-11-15    FLS      Revised, with new arguments

*/
%macro smoothhosp(hospsmo, hospall, ajour=today(), nofDays=1, nofHours=12, basedata=, IndexDate=,);
%local nof_days_to_smooth nof_hours_to_smooth;
  %let nof_days_to_smooth=&nofDays;
  %let nof_hours_to_smooth=3600*&nofHours;

  data _hosptemp_;
  set &hospall(where=(&ajour between rec_in and rec_out));
  %if %varexist(&hospall,starttime) %then if endtime eq . then endtime = dhms(&ajour,11,59,00);;
  run;

    proc sort data=_hosptemp_
        out= _hosptemp_;
        by pnr
            %if %varexist(&hospall,starttime) %then starttime endtime; %else indate outdate;;
        %runquit;
    data _hosptemp_;
        set _hosptemp_;

	by pnr
            %if %varexist(&hospall,starttime) %then starttime endtime; %else indate outdate;;
        %if %varexist(&hospall,starttime)=0 %then %do;
            starttime =dhms(indate,11,59,00);
            endtime=dhms(outdate,11,59,00);
            format starttime endtime datetime.;
         %end;
	retain in out seg;
        format in out datetime.;

	if first.pnr then do; /* reset */
	  in = starttime;
	  out = endtime;
	  seg = 1;
	end;
    else do;
	  if (year(indate)<2019 and (datepart(starttime) - datepart(out)) <= &nof_days_to_smooth) or
             (year(indate)>=2019 and (starttime - out) <= &nof_hours_to_smooth) then do;
		if endtime>out then do;
              out=endtime;
          end;
	  end;
      else do;
              in  = starttime;
              out = endtime;
              seg = seg+1; /* next hospitalisation period */
	  end;
    end;
    hosphours = (out-in)/3600;
    hospdays = hosphours/24; /* always update hospdays */
  %RunQuit;


  data &hospsmo; /* keep in mydate for testing purpose */
    set _hosptemp_;
    by pnr seg;
    rename in = hosp_indt;
    hosp_in=datepart(in);
    label in = "hospital period starttime";
    label hosp_in = "hospital period startdate";
    rename out = hosp_outdt;
    hosp_out=datepart(out);
    label out = "hospital period endtime";
    label hosp_out = "hospital period enddate";
    format hosp_in hosp_out date.;
    format hospdays hosphours 5.1;
    keep pnr in out hosp_in hosp_out hospdays hosphours;
    if last.seg then output; /* the last line in each segment will hold the entire hospitalisation period from in to out */
  %RunQuit;


%if &basedata ne and &indexdate ne %then %do;
    proc sql;
    create table _basetemp_ as
    select
	a.*,
        b.hosp_in as hosp_in&IndexDate,
	b.hosp_out  as hosp_out&IndexDate,
        b.hosp_indt as hosp_indt&IndexDate,
        b.hosp_outdt  as hosp_outdt&IndexDate,
	b.hospdays  as hospdays&IndexDate,
        b.hosphours  as hosphours&IndexDate
	from &basedata(drop=
        %if %varexist(&basedata,hosp_in&IndexDate) eq 1 %then  hosp_in&IndexDate;
        %if %varexist(&basedata,hosp_out&IndexDate) eq 1 %then  hosp_out&IndexDate;
        %if %varexist(&basedata,hosp_indt&IndexDate) eq 1 %then  hosp_indt&IndexDate;
        %if %varexist(&basedata,hosp_outdt&IndexDate) eq 1 %then  hosp_outdt&IndexDate;
        %if %varexist(&basedata,hospdays&IndexDate) eq 1 %then  hospdays&IndexDate;
        %if %varexist(&basedata,hosphours&IndexDate) eq 1 %then  hosphours&IndexDate;
        ) a left join &hospsmo b on
	a.pnr=b.pnr
        %if &IndexDate ne %then and &IndexDate between b.hosp_in and b.hosp_out;
	order by pnr;
  %sqlquit;
  data &basedata;
    set _basetemp_;
  %runquit;
  %end;
%mend;

