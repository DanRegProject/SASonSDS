/*
  getHosp();
  the macro findingHOSPperiods finds periods of hospital admissions.
  the macro smoother smoothes periods of admission, joining them if there is 1 day our less between admission.
*/

%macro getHosp(outdata, basedata=, pattype=0, fromyear=1977);
  %local localoutdata yr dsn1;
  /* log hastighed */
  %put start getHosp: %qsysfunc(datetime(), datetime20.3);
  %let startHOSPtime = %qsysfunc(datetime());

  %let pattcnt = %sysfunc(countw(&pattype));

  %let localoutdata=%NewDatasetName(localoutdatatmp); /* temporært datasætnavn så data i work */

  %put &basedata;
  %let lastyrGH=%sysfunc(today(),year4.); /*local lastyr for getHosp*/
  %do %while (%sysfunc(exist(raw.lpr2_mdl_t_adm&lastyrGH))=0);
      %let lastyrGH=%eval(&lastyrGH - 1);
      %end;

  proc sql inobs=&sqlmax;
    %do yr=&fromyear %to &lastyrGH;
        %if &yr<1994       %then %let dsn1=raw.lpr_t_adm&yr;
        %else %if &yr<2005 %then %let dsn1=raw.lpr_t_adm&yr;
        %else                    %let dsn1=raw.lpr2_mdl_t_adm&yr;
	  %if &yr=&fromyear %then create table &localoutdata as;
	  %else insert into &localoutdata;
	  select
              a.v_cpr_encrypted as pnr,
              a.d_inddto as indate label="indate",
              a.d_uddto as outdate label="outdate",
              dhms(a.d_inddto,%if %varexist(&dsn1,v_indtime) %then  case a.v_indtime when . then 11 else a.v_indtime end ; %else 11;,
              %if %varexist(&dsn1,v_indminut) %then case a.v_indminut when . then 59 else a.v_indminut end ; %else 59;,00) as starttime format=datetime.,
              case a.d_uddto when . then . else dhms(a.d_uddto,11,59,00) end as endtime format=datetime.,
              a.d_uddto-a.d_inddto as hospdays,
              year(a.d_inddto) as year label="year", input(a.c_sgh,4.) as hospital label="hospital",
              /* a.c_afd as hospitalunit label="hospitalunit",*/
              input(a.c_adiag,$20.) as diagnose label="diagnose",
              a.rec_in format=date., a.rec_out format=date.
          from
             &dsn1
          a
              %if &basedata ne %then join &basedata c;
              %if &basedata ne %then on a.v_cpr_encrypted=c.pnr ;
	   where
	  /* in order to get at numeric list: */
           %if &pattcnt > 1 %then (;
           %do I=1 %to &pattcnt;
               %let pval = put(%qscan(&pattype,&i),1.);
               %if &i>1 %then OR ;
               a.c_pattype eq &pval
           %end;
           %if &pattcnt >1 %then );;
    %end;
    %if %sysfunc(exist(raw.LPR3_SB_kontakt))=1 %then %do;
   	  %if &fromyear<2019 and %sysfunc(exist(&localoutdata))=1 %then insert into &localoutdata;
          %else create table &localoutdata as;
	  select
   	      a.personnummer_encrypted as pnr,
              datepart(a.starttidspunkt) as indate format=date.,
              case a.sluttidspunkt when . then . else datepart(a.sluttidspunkt) end as outdate format=date.,
              a.starttidspunkt as starttime,
              a.sluttidspunkt as endtime,
              case a.sluttidspunkt when . then . else datepart(a.sluttidspunkt)-datepart(a.starttidspunkt) end as hospdays,
              year(datepart(a.starttidspunkt)) as year,
              a.sundhedsinstitution as hospital,
            /*  a.ansvarlig_enhed as hospitalunit,*/
              input(a.aktionsdiagnose,$20.) as diagnose label="diagnose",
              a.rec_in format=date., a.rec_out format=date.
          from
              raw.LPR3_SB_kontakt	  a
              %if &basedata ne %then join &basedata c;
              %if &basedata ne %then on a.personnummer_encrypted=c.pnr ;
              where upcase(a.inst_type)="HOSPITAL" and upcase(a.kontakttype) in ("ALCA00","ALCA10");
        %end;
  %SqlQuit;

  proc sort data=&localoutdata out=&outdata;
	by pnr indate outdate diagnose;
  run;


  %cleanup(&localoutdata);
 data _null_;
   endHOSPtime=datetime();
   timeHOSPdif=endHOSPtime - &startHOSPtime;
   put 'execution time FindingHOSPcases ' timeHOSPdif:time20.6;
 run;

%mend;
