%macro riskSetMatch(outdata,basedata,basedate,nControls=5,pop=,ajour=today());
%local yr fromyr toyr ds;
%let ds=%sysfunc(round(%qsysfunc(datetime()),1));

    %if &pop ne %then %do;
       proc sql;
            create table _con_&ds as
                select distinct pnr
                from &pop
                union
                select distinct pnr
                from &basedata
               ;
        quit;
        %end;
    %if &pop= %then %do;
        %let pop=raw.cpr3_t_person;
        proc sql;
            create table _con_&ds as
                select distinct v_pnr_encrypted as pnr
                from &pop;
        quit;
        %end;
%getPOP(_cas_&ds,&basedata);
%mergePOP(_cas_&ds,_cas2_&ds,&basedata,&basedate,ajour=&ajour);
%getPOP(_con2_&ds,_con_&ds);
data _con2_&ds;
    merge _con2_&ds(in=a) &basedata(keep=pnr &basedate);
    by pnr;
run;

    proc sql inobs=&sqlmax;
        select min(birthyear), max(birthyear) into :fromyr, :toyr
            from _cas_&ds
/*            where &ajour between rec_in and rec_out*/;
    quit;

%do yr = &fromyr %to &toyr;
    proc sql inobs=&sqlmax;
        create table _temp_&ds as
            select a.pnr as pnr_case, b.pnr as pnr_control, a.sex, a.t as &basedate, (a.pnr ne b.pnr) * (uniform(&yr)+1) as ran
            from
            (select pnr, sex, &basedate as t from _cas2_&ds
            where &basedate ne . and year(birthdate) = &yr /*and &ajour between rec_in and rec_out*/) a
            inner join
            (select pnr, sex, &basedate as t, deathdate, out_date, in_date from _con2_&ds
            where birthyear=&yr  and &ajour between rec_in and rec_out) b
            on
            a.pnr=b.pnr or
            (a.sex=b.sex and (b.t=. or b.t>a.t)
            and not (b.out_date <= a.t < b.in_date
            or (b.deathdate ne . and b.deathdate<=a.t)))
            order by a.pnr, ran;
    quit;
    data _temp_&ds(keep=pnr_case pnr_control  &basedate) _tempN_&ds(keep=pnr_case nRisk);
        set _temp_&ds;
        nRisk+1;
        by pnr_case;
        if first.pnr_case then nRisk=0;
        if nRisk < &ncontrols+1 then output _temp_&ds;
        if last.pnr_case then output _tempN_&ds;
    run;
    data _temp_&ds;
        merge _temp_&ds _tempN_&ds;
        by pnr_case;
    run;
    %if &yr = &fromyr %then %do;
        data &outdata;
            set _temp_&ds;
        run;
        %end;
    %else %do;
        proc append base=&outdata data=_temp_&ds;
        run;
        %end;
    %end;
proc datasets nolist;
    delete _con_&ds _con2_&ds _cas_&ds _cas2_&ds _temp_&ds _tempN_&ds;
%runquit;

%mend;
