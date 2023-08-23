/* changed order: basedata= at the end */
%macro getMFR(outlib=work, focus=m, basedata=,info=basis, fromyear=1997);

    %let info = %sysfunc(substr(&info,1,5));
%findingMFR(&outlib..mfr&info.ALL, &focus, &info, fromyear=&fromyear, basedata=&basedata);

%mend;


/*
  findingMFR();
  Extract data from the medicinal birth register.
  The macro is called outside a datastep.

*/

%macro findingMFR(outdata, focus, info, fromyear=, basedata=);
  %let sqlrc=0;
  %put "extract based on population in &basedata";

  %local I;

  /* log speed */
  %put start findingMFR: %qsysfunc(datetime(), datetime20.3);
  %let startMFRtime = %qsysfunc(datetime());
 %let lastyr=%sysfunc(today(),year4.);

  %do %while (%sysfunc(exist(raw.mfr_mfr&lastyr))=0);
      %let lastyr=%eval(&lastyr - 1);
      %end;

    proc sql inobs=&sqlmax;
        %if &sqlrc=0 %then %do;
        proc sql inobs=&sqlmax;
            %do yr=&fromyear %to &lastyr;
                %if &yr=&fromyear %then
                    create table &outdata as;
                %else insert into &outdata;
                select
                    %if &info=basis %then %do;
                       %if &focus=m %then a.cpr_moder_encrypted as pnr, ;
                       %if &focus=c %then a.cpr_barn_encrypted as pnr, ;
                       a.*
                       %end;
                   %if &info ne basis %then a.cpr_moder_encrypted, a.cpr_barn_encrypted, a.foedselsdato,  b.kodetype as &info.kodetype, b.skskode as &info.skskode, a.rec_in as pk_rec_in, a.rec_out as pk_rec_out, b.rec_in as fk_rec_in, b.rec_out as fk_rec_out;
                   from
                       %if &basedata ne %then (select distinct pnr from &basedata) c inner join;
                   raw.mfr_mfr&yr a
                       %if &basedata ne %then %do;
                       on
                           %if &focus=m %then a.cpr_moder_encrypted=c.pnr ;
                           %if &focus=c %then a.cpr_barn_encrypted=c.pnr ;
                       %end;
                   %if &info ne basis %then %do;
                       join
                           %if &info = andre %then raw.mfr_andre_foedselskomplikat&yr;
                       %if &info = cardi %then raw.mfr_cardiomyopati&yr;
                       %if &info = gravi %then raw.mfr_graviditetskomplikation&yr;
                       %if &info = igang %then raw.mfr_igangsaettelse&yr;
                       %if &info = infek %then raw.mfr_infektioner&yr;
                       %if &info = kejse %then raw.mfr_kejsersnit&yr;
                       %if &info = medic %then raw.mfr_medicinske_sygdomme&yr;
                       %if &info = misda %then raw.mfr_misdannelser&yr;
                       %if &info = vesti %then raw.mfr_vestimulation&yr;

                       b on a.pk_mfr=b.fk_mfr and a.rec_out>b.rec_in and a.rec_out<=b.rec_out;
                       %end;
                   ;
%end;
%end;
%sqlquit;

   proc sort data=&outdata;
	  by cpr_moder_encrypted %if &info=basis & %varexist(&outdata,FOEDSELSDATO) %then FOEDSELSDATO; cpr_barn_encrypted;
	run;
    data _null_;
      endMFRtime=datetime();
      timeMFRdif=endMFRtime - &startMFRtime;
      put 'execution time FindingMFR ' timeMFRdif:time20.6;
    run;
  %mend;


