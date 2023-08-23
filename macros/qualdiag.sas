%macro QualDiag(out,in,datevar,basedata=,keepbasevar=,if=,medi=, medidays=30, oprube=, oprubedays=10 10, label=,ajour=today(),medilib=mydata,oprubelib=mydata,hospdata=,incident=TRUE);
%local QD QDhosp QDhosp0 medibef mediaf medidays2 oprubedays oprubedays2 keepmedi keepoprube ifmedi ifoprube;
%let   QD=%NewDatasetName(tempdat); /* temporært datasætnavn så data i work ikke overskrives */
%let   QDhosp=%NewDatasetName(tempdat1); /* temporært datasætnavn så data i work ikke overskrives */
%let   QDhosp0=%NewDatasetName(tempdat2); /* temporært datasætnavn så data i work ikke overskrives */

    data &QD;
    %if &basedata ne %then %do;
        merge &in &basedata(keep=pnr &keepbasevar in=a);
        by pnr;
        if a %if &if ne %then and ; &if;
       %if %varexist(&in,rec_in) eq 1 %then if  rec_in<&ajour  and &ajour<=rec_out;;
        drop &keepbasevar
           %if %varexist(&in,rec_in) eq 1 %then rec_in rec_out;;
        %end;
    %if &basedata eq %then set &in;;
    %runquit;

/* insert information relative to &datevar on mediation and/or procedures */
%if &medi ne %then %mergeMedi(&QD, &medilib, work, &datevar, &medi,  ajour=&ajour);;
%if &oprube ne %then %mergeopr(&QD, &oprubelib, work, &datevar,  &oprube,  ajour=&ajour);;
/* find information closest to &datevar */
    data &QD;
    set &QD;
    by pnr;
    %if &medi ne %then %do;
        %let medidays2=0;
        %if %sysfunc(countw(&medidays))=2 %then %do;
            %let medidays2=%scan(&medidays,1); /* days before */
            %let medidays=%scan(&medidays,2);  /* days after */
            %end;
        %let mediaf=;
        %let medibef=;
        %do i=1 %to %sysfunc(countw(&medi));
            %let v = %scan(&medi, &i);
            %let mediaf = &mediaf &v.fieksdaf&datevar;
            %if &medidays2 ne %then %let medibef = &medibef &v.laeksdbe&datevar;
            %end;
        %let mediaf = %commas(&mediaf);
        %if &medidays2 ne %then %let medibef = %commas(&medibef);
        firsteksd&datevar.&label=min(&mediaf);
        lasteksd&datevar&label= %if &medidays2 ne %then max(&medibef);%else .;;
        %let ifmedi = .<firsteksd&datevar&label-&datevar<=&medidays;
        %if &medidays2 ne  %then %let ifmedi = &ifmedi or .<&datevar-lasteksd&datevar&label<=&medidays2    ;
        %let keepmedi =  firsteksd&datevar&label lasteksd&datevar&label;
        format firsteksd&datevar&label lasteksd&datevar&label date.;
        %end;
    %if &oprube ne %then %do;
        %let oprubedays2=0;
        %if %sysfunc(countw(&oprubedays))=2 %then %do;
            %let oprubedays2=%scan(&oprubedays,1); /* days before */
            %let oprubedays=%scan(&oprubedays,2);  /* days after */
            %end;
        %let oprubebe =;
        %let oprubeaf =;
        %do i=1 %to %sysfunc(countw(&oprube));
            %let v = %scan(&oprube, &i);
            %let oprubeaf = &oprubeaf &v.dateaf&datevar;
            %if &oprubedays2 ne %then %let oprubebe = &oprubebe &v.ladatebe&datevar;
            %end;
        %let oprubeaf = %commas(&oprubeaf);
        %let oprubebe = %commas(&oprubebe);
        lastoprube&datevar&label=max(&oprubebe);
        firstoprube&datevar&label=min(&oprubeaf);
        %let ifoprube= .<firstoprube&datevar&label-&datevar<=&oprubedays;
        %if &oprubedays2 ne  %then %let ifoprube = .<&datevar-lastoprube&datevar&label<=&oprubedays2 or &ifoprube;
        %let keepoprube= firstoprube&datevar&label lastoprube&datevar&label;
        format firstoprube&datevar&label lastoprube&datevar&label  date.;
        %end;
    if &ifmedi %if &medi ne and &oprube ne %then or; &ifoprube;
    keep  pnr &datevar &keepmedi &keepoprube;
    %runquit;
    proc sort data=&QD;
        by pnr &datevar;
        %RunQuit;

%if &hospdata ne %then %do;
    proc sort data=&hospdata out=&QDhosp0;
        by pnr hosp_in;
        %runquit;

    proc sql;
        create table &QDhosp as
            select a.*, b.hosp_in, b.hosp_out
            from &QD a left join &QDhosp0 b on
            a.pnr=b.pnr and b.hosp_in<a.&datevar
            order by pnr, &datevar, hosp_in;
    quit;

    data &QD;
    set &QDhosp;
    by pnr &datevar;
    retain la2hospindatebe&datevar&label la2hospoutdatebe&datevar&label;

    if first.&datevar then do;
         la2hospindatebe&datevar&label=.; la2hospoutdatebe&datevar&label=.;
        end;
    lahospindatebe&datevar&label=hosp_in;
    if hosp_out>. then lahospoutdatebe&datevar&label=min(hosp_out,&datevar);
    format lahospindatebe&datevar&label lahospoutdatebe&datevar&label     la2hospindatebe&datevar&label la2hospoutdatebe&datevar&label date.;
    if last.&datevar then output;
    la2hospindatebe&datevar&label=hosp_in;
    if hosp_out>. then la2hospoutdatebe&datevar&label=min(hosp_out,&datevar);
    drop hosp_in hosp_out;
%runquit;
%cleanup(&QDhosp);
%cleanup(&QDhosp0);
%describeSASchoises("Hospitalization periods are joined to &datevar history, such that we have both the period where diagnosis is obtained and the previous hospitalization.");
%end;
proc sort data=&QD;
    by pnr &datevar;
    %runquit;
        data &out;
        set &QD;
        by pnr ;
    /* find the first occation within datevar of &datevar.*/
        %if &incident=TRUE %then %do;
            if first.pnr;
            %end;
        %if &label ne  %then rename &datevar=&datevar.&label;;
        %RunQuit;
        %cleanup(&QD);
%mend;
