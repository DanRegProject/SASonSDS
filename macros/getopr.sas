%macro getOpr(outlib, oprlist,fromyear=1997, type=opr, pattype=0 1 2, kontakttype=ALCA00 ALCA10, insttype=hospital,prioritet=ATA1 ATA3,
              oprart="" "V" "P" "D", basedata=, basepop=, tilopr=FALSE /* tillægsdiagnose */,
              UAF=FALSE /* uafsluttede */, SOURCE=LPR MINIPAS LPR3SB LPRF);
  %start_timer(getopr); /* measure time for this macro */

  %if %UPCASE(&type)=UBE and &fromyear<1999 %then %let fromyear=1999;
  %if %UPCASE(&type)=OPR and &fromyear<1997 %then %let fromyear=1997;
  %local N nofOPR name code nsource RC;
  
  %let nsource = %sysfunc(countw(&SOURCE));
  %let nofOPR = %sysfunc(countw(&oprlist));
  %if &tilopr=TRUE %then %let oprart="+";
  %do N=1 %to &nofOPR;
    %let code = %lowcase(%scan(&oprlist,&N)); /* go through the oprlist */
    %if %symexist(&type.&code) %then %do;
    %let lastyrOPR=%sysfunc(today(),year4.);
    %let filelist=;
    %let inline=;
    %do s=1 %to &nsource;
	%let stype = %upcase(%scan(&SOURCE,&s));
	%let RC=;
	%if &stype=LPR and &UAF=TRUE %then %do;
         %do %while (%sysfunc(exist(raw.lpr2_mdl_t_adm&lastyrOPR))=0 and &lastyrOPR>&fromyear);
           %let lastyrOPR=%eval(&lastyrOPR - 1);
         %end;
	 %if %sysfunc(exist(raw.lpr2_mdl_uaf_t_adm&lastyrOPR))=1 %then %do;
	 	    /* get the uaf tables */
		    %findingOpr(&type.&code._uaf, &code,  &&&type&code, kontakttype=&kontakttype, insttype=&insttype, prioritet=&prioritet, pattype=&pattype, basedata=&basedata, fromyear=&lastyrOPR, type=&type, tilopr=&tilopr, oprart=&oprart, UAF=TRUE,SOURCE=&stype,returncode=RC); /*See above*/
		    /* repeat findingOPR with UAF=FALSE - get the tables that has an enddate */
	            %findingOpr(&type.&code, &code,  &&&type&code, kontakttype=&kontakttype, insttype=&insttype, prioritet=&prioritet, pattype=&pattype, basedata=&basedata, fromyear=&fromyear, type=&type, tilopr=&tilopr, oprart=&oprart, UAF=FALSE,SOURCE=&stype,returncode=RC); /*See above*/
		    /* combine the two tables, exclude lines from UAF that are ended by now */
		    /* tables are in work, and name &code and &code_uaf */
	            %combineOPRTables(&type.&code.ALL&s, &type.&code.);
	 %end;
    %end;
    %if &UAF=FALSE or &stype ne LPR %then %do;
	    /* "normal case" */
        %findingOpr(&type.&code.ALL&s, &code,  &&&type&code, kontakttype=&kontakttype, insttype=&insttype, prioritet=&prioritet, pattype=&pattype, basedata=&basedata, fromyear=&fromyear, type=&type, tilopr=&tilopr, oprart=&oprart,UAF=FALSE, SOURCE=&stype,returncode=RC); /*See above*/
    %end;
    %if &RC=0 %then %do;
	%let filelist= &filelist &type.&code.ALL&s(in=in&s) ;;
	%let inline = &inline +&s*in&s;;
    %end;
    %end; /* end of do s= */
    data &outlib..&type.&code.ALL;
	set &filelist;
	_in=0 &inline;
	source=lowcase(scan("&SOURCE",_in));
	drop _in;
    %runquit;
    proc sort data=&outlib..&type.&code.ALL;
	by pnr starttime endtime oprstarttime opr rec_in;
   %runquit;


    %if &basepop ne %then %do;
	  proc sql inobs=&sqlmax;
	  %if &N=1 %then create table &outlib..&basepop as ;
	  %else insert into &outlib..&basepop;
	  select pnr, indate as IDate, oprdate, opr length=10, outcome length=10, oprdiag, rec_in, rec_out
	  from &outlib..&type.&code.ALL;
	  %sqlquit;
    %end;
  %end; /* symexist */
  %else %put getOPR WARNING: &code not defined for &type;;
  %end; /* end of do N= */
  %if &basepop ne %then %do;
    proc sort data = &outlib..&basepop; /* do not reduce before &ajour is set */
	  by pnr idate opr outcome rec_out;
	%runquit;
  %end;
  %end_timer(getOPR, text=Measure time for GetOPR macro);
%mend;


/*
  #+NAME          :  %getOpr
  #+TYPE          :  SAS
  #+DESCRIPTION   :  Find records of operations
  #+OUTPUT        :  output datasætnavn
  #+AUTHOR        :  JNK/FLS
  #+CHANGELOG     :  Date        Initials Status
                  :  ??-11-15    JNK      ported from DS, rewritten
                  :  09-11-15    FLS      Revised getOpr
*/
/*
  findingOpr();

  outdata:    output datanavn
  outcome:    tekststreng outcome label, should be short
  opr:	      opr koder 10, uden foranstillet K
  oprart:     Operationsart, tegn, med mellemrum (D, P, V)

  pattype:    patienttyper, ciffer, adskildt med mellemrum (0, 1, 2 og 3)
  basedata:   input datasæt med identer og skæringsdato
  fromyear:   startår
*/

%macro findingOpr(outdata, outcome, opr, kontakttype=, insttype=, prioritet=, pattype=, oprart=, basedata=, fromyear=, type=, tilopr=, UAF==, SOURCE=LPR,returnCode=); /*Defined type to be operation per default - can use UBE*/
  %local localoutdata dlstcnt startOPRtime yr I;
  %let dlstcnt = %sysfunc(countw(&opr));
  %let pattcnt = %sysfunc(countw(&pattype));
  %let kontakttype = %upcase(&kontakttype);
  %let insttype    = %upcase(&insttype);
  %let prioritet   = %upcase(&prioritet);
	
  %let localoutdata=%NewDatasetName(localoutdatatmp); /* temporært datasætnavn så data i work */
  /* log eksekveringstid */
  %put start findingOpr: %qsysfunc(datetime(), datetime20.3);
  %let startOPRtime = %qsysfunc(datetime());
  %let lastyrOPR=%sysfunc(today(),year4.);
  %do %while (%sysfunc(exist(raw.lpr2_mdl_t_adm&lastyrOPR))=0);
      %let lastyrOPR=%eval(&lastyrOPR - 1);
  %end;

  	%if %UPCASE("&SOURCE")="MINIPAS" and &fromyear<2002 %then %let fromyear=2002;
	%if %UPCASE("&SOURCE")="MINIPAS" %then %let tablegrp=minipas;
	%if %UPCASE("&SOURCE")="LPR" and "&UAF"="FALSE" %then %let tablegrp=lpr2_mdl;
	%if %UPCASE("&SOURCE")="LPR" and "&UAF"="TRUE" %then %let tablegrp=lpr2_mdl_uaf;
	%if %UPCASE("&SOURCE")="LPR3SB" %then %do;
		%let fromyear=0;
		%let lastyrOPR=0;
		%let tablegrp=LPR3_SB;
		%let oprart=;
		%let pattcnt=0;
	%end;
	%if %UPCASE("&SOURCE")="LPRF" %then %do;
		%let fromyear = 0;
		%let lastyrOPR = 0;
		%let tablegrp = LPR_F;
		%let pattcnt=0;
		%let oprart=;
		%if %Upcase(&type) = "OPR" %then %do;
			%let tablename = kirurgi;
		%end;
		%if %upcase(&type) = "UBE" %then %do;
			%let tablename = andre;
		%end;
	%end;
	%if &fromyear ne 0 and &lastyrOPR ne 0 %then %do;
		%do %while (%sysfunc(exist(raw.&tablegrp._t_adm&lastyrOPR))=0 and &lastyrOPR>&fromyear);
			%let lastyrOPR=%eval(&lastyrOPR - 1);
		%end;
	%end;

        %let returncode0=0;

	%if %UPCASE("&SOURCE")="LPR" %then %do;
		%if %sysfunc(exist(raw.&tablegrp._t_adm&lastyrOPR))=0 and %sysfunc(exist(raw.&tablegrp._t_sks&type.&lastyrOPR))=0 %then %do;
			%put getOPR WARNING: LPR data not available.;
			%let returncode0=1;
		%end;
	%end;
	%if %UPCASE("&SOURCE")="LPRPSYK" and %sysfunc(exist(raw.&tablegrp._adm))=0 %then %do;
		%put getOPR WARNING: LPR-PSYK data not available.;
		%let returncode0=1;
	%end;
	%if %UPCASE("&SOURCE")="MINIPAS" %then %do;
		%if %sysfunc(exist(raw.&tablegrp._t_adm&lastyrOPR))=0 and %sysfunc(exist(raw.&tablegrp._t_sks&type.&lastyrOPR))=0 %then %do;
			%put getOPR WARNING: MINIPAS data not available.;
			%let returncode0=1;
		%end;
	%end;
	%if %UPCASE("&SOURCE")="LPR3SB" %then %do;
		%if %sysfunc(exist(raw.&tablegrp._kontakt))=0 and %sysfunc(exist(raw.&tablegrp._procedurer))=0 %then %do;
			%put getOPR WARNING: LPR-3SB data not available.;
			%let returncode0=1;
		%end;
	%end;
	%if %UPCASE("&SOURCE")="LPRF" %then %do;
		%if %sysfunc(exist(raw.&tablegrp._kontakter))=0 and %sysfunc(exist(raw.&tablegrp._procedurer_kirurgi_k))=0 and %sysfunc(exist(raw.&tablegrp._procedurer_kirurgi_f))=0 %then %do;
			%put getOPR WARNING: LPR-F data not available.;
			%let returncode0=1;
		%end;
	%end;
	%if &returncode0=0 %then %do;
	%do yr=&fromyear %to &lastyrOPR;
	  proc sql inobs=&sqlmax;
	    %if &yr=0 and %UPCASE("&SOURCE")="LPRPSYK" %then %do;
	    	%let dsn1= raw.LPR_t_PSYK_ADM;
	    	%let dsn2= raw.LPR_t_PSYK_DIAG;
  	    %end;
  	    %else %if  %UPCASE("&SOURCE")="LPR3SB" %then %do;
	      %let dsn1=  raw.&tablegrp._kontakt;
	      %let dsn2=  raw.&tablegrp._procedurer;
	      %let dsn3=  raw.&tablegrp._procedurer_tillaeg;
	    %end;
		%else %if  %UPCASE("&SOURCE")="LPRF" %then %do;
	
			/* her skal der rettets når LPRF procdure tabellerne er samlet i en tabel med opr og en med ube (med kontakter og foløb) 04/08/2023 */
	    	%if %upcase(&type)=OPR %then %do;
				%let dsn1=  raw.&tablegrp._kontakter;
	     		%let dsn2=  raw.&tablegrp._procedurer_kirurgi_k;
		 		%let dsn3=  raw.&tablegrp._procedurer_kirurgi_f;
				%let dsn4=  raw.&tablegrp._organisationer;
			%end;
			%if %upcase(&type)=UBE %then %do;
				%let dsn1=  raw.&tablegrp._kontakter;
	     		%let dsn2=  raw.&tablegrp._procedurer_andre_k;
		 		%let dsn3=  raw.&tablegrp._procedurer_andre_f;
				%let dsn4=  raw.&tablegrp._organisationer;
			%end;
	    %end;
  	    %else %do;
	      %if &yr=&lastyrOPR and &UAF=TRUE and %UPCASE("&SOURCE")="LPR" %then %let dsn1= raw.lpr2_mdl_uaf_t_adm&yr;
	      %else %if &yr<2005 and %UPCASE("&SOURCE")="LPR" %then %let dsn1= raw.lpr_t_adm&yr;
	      %else %let dsn1=  raw.&tablegrp._t_adm&yr;

	      %if &yr=&lastyrOPR and &UAF=TRUE and %UPCASE("&SOURCE")="LPR" %then %let dsn2= raw.lpr2_mdl_uaf_t_sks&type&yr;
	      %else %if &yr<2005 and %UPCASE("&SOURCE")="LPR" %then %let dsn2= raw.lpr_t_sks&type.&yr;
	      %else %let dsn2= raw.&tablegrp._t_sks&type.&yr;
	   %end;
%if %sysfunc(exist(&dsn1)) and %sysfunc(exist(&dsn2)) %then %do;

      %if &yr=&fromyear %then create table &localoutdata as;
      %else insert into &localoutdata ;
      select distinct

	%if %upcase("&SOURCE") eq "LPR3SB" %then %do;
	   a.kontakt_id as contact_id,
	   a.personnummer_encrypted as pnr,
	   "&outcome" as outcome length=12,
	   datepart(a.starttidspunkt) as indate format=date.,
	   case a.sluttidspunkt when . then . else datepart(a.sluttidspunkt) end as outdate format=date.,
	   a.starttidspunkt as starttime,
	   a.sluttidspunkt as endtime,
     	   datepart(b.starttidspunkt) as oprdate label="oprdate" format=date.,
     	   b.starttidspunkt as oprstarttime,
	   b.sluttidspunkt as opendtime,
	   "" as pattype length=1 format=$1.  label="pattype",
	   %if &tilopr=TRUE %then c.tillaegskode; %else b.kode; as opr length=10 label="&type",
	   "" as oprart length=1,
	   put(a.sundhedsinstitution,20.) as hospital length=20  format=$20. label="hospital",
	   a.aktionsdiagnose as oprdiag,
	   put(b.producerende_enhed,20.) as oprunit length=20  format=$20. label="Ansvarlig enhed",
	   %if %varexist(&dsn2,handlingspec) %then  b.handlingspec  ; %else ""; as handlingspec,
	   b.indikation,
	   b.kontrast,
	   b.proceduretype,
	   b.sideangivelse,
	   %if &tilopr=FALSE %then
	   case when a.rec_in<=b.rec_in then b.rec_in
	        when a.rec_in> b.rec_in then a.rec_in
		else .
	   end as rec_in format=date.,
	   case when a.rec_out<=b.rec_out then a.rec_out
	        when a.rec_out> b.rec_out then b.rec_out
		else .
	   end as rec_out format=date.
	   ;
	   %if &tilopr=TRUE %then
	   case when a.rec_in<=b.rec_in and c.rec_in<= b.rec_in then b.rec_in
	        when a.rec_in>b.rec_in  and a.rec_in>  c.rec_in then a.rec_in
	        when a.rec_in<=c.rec_in and b.rec_in<= c.rec_in then c.rec_in
		else .
	   end as rec_in format=date.,
	   case when a.rec_out>=b.rec_out and c.rec_out>= b.rec_out then b.rec_out
	        when a.rec_out<b.rec_out  and a.rec_out<  c.rec_out then a.rec_out
	        when a.rec_out>=c.rec_out and b.rec_out>= c.rec_out then c.rec_out
		else .
	   end as rec_out format=date.
	   ;
      %end;

	/* LPRF start */
		%if %upcase("&SOURCE") eq "LPRF" %then %do;
	   a.DW_EK_KONTAKT as contact_id,
	   a.CPR_ENCRYPTED as pnr,
	   "&outcome" as outcome length=12,
	   a.dato_start as indate format=date.,
	   a.dato_slut as outdate format=date.,
	   a.TIDSPUNKT_START as starttime,
	   a.TIDSPUNKT_SLUT as endtime,
     	   a.DATO_START as oprdate label="oprdate" format=date.,
     	   b.TIDSPUNKT_START as oprstarttime,
	   b.TIDSPUNKT_SLUT as opendtime,
	   "" as pattype length=1 format=$1.  label="pattype",
	   b.PROCEDUREKODE as opr length=10 label="&type",
	   "" as oprart length=1,
	   d.SUNDHEDSINSTITUTION as hospital length=20  format=$20. label="hospital",
	   a.aktionsdiagnose as oprdiag,
	   b.SORENHED_PRO as oprunit length=20  format=$20. label="Ansvarlig enhed",
	   %if %varexist(&dsn2,handlingspec) %then  b.handlingspec  ; %else ""; as handlingspec,
	   "" as indikation,
	   "" as kontrast,
	   b.proceduretype,
	   "" as sideangivelse ,
	   
	   %if &tilopr=FALSE %then
	   case when a.rec_in<=b.rec_in then b.rec_in
	        when a.rec_in> b.rec_in then a.rec_in
		else .
	   end as rec_in format=date.,
	   case when a.rec_out<=b.rec_out then a.rec_out
	        when a.rec_out> b.rec_out then b.rec_out
		else .
	   end as rec_out format=date.
	   ;
	   
      %end;
	/* LPRF "end" */

      %else %if %upcase("&SOURCE") ne "LPRF" and %upcase("&SOURCE") ne "LPR3SB" %then %do;
      	   0 as contact_id, 
           a.v_cpr_encrypted as pnr label="pnr",
	   "&outcome" as outcome length=12,
	   a.d_inddto as indate label="indate", 
	   a.d_uddto as outdate label="outdate",
	   dhms(a.d_inddto,%if %varexist(&dsn1,v_indtime) %then  case a.v_indtime when . then 11 else a.v_indtime end ; %else 11;,
	   %if %varexist(&dsn1,v_indminut) %then case a.v_indminut when . then 59 else a.v_indminut end ; %else 59;,00) as starttime format=datetime.,
	   case a.d_uddto when . then . else dhms(a.d_uddto,11,59,00) end as endtime format=datetime.,
	   b.d_odto as oprdate label="oprdate",
	   dhms(b.d_odto,%if %varexist(&dsn2,v_otime) %then  case b.v_otime when . then 11 else b.v_otime end ; %else 11;,
  	   %if %varexist(&dsn2,v_ominut) %then case b.v_ominut when . then 59 else b.v_ominut end ; %else 59;,00) as oprstarttime format=datetime.,
	   . as oprendtime,
	   a.c_pattype as pattype format=$1. label ="pattype", 
	   %if &tilopr=TRUE %then b.c_tilopr ; %else b.c_opr ; as opr label = "opr",
	   b.c_oprart as oprart label="oprart", 
	   a.c_sgh as hospital  length=20  format=$20. label="hospital",
	   a.c_adiag as oprdiag label="opr adiag" length=40,
	   %if %varexist(&dsn2,c_oafd) %then b.c_oafd; %else ""; as oprunit length=20  format=$20.,
	   "" as handlingsspec ,
	   "" as indikation length=40,
	   "" as kontrast length=40,
	   "" as proceduretype length=40,
	    case when a.rec_in<=b.rec_in then b.rec_in
   	        when a.rec_in> b.rec_in then a.rec_in
		else .
	   end as rec_in format=date.,
	   case when a.rec_out<=b.rec_out then a.rec_out
	        when a.rec_out> b.rec_out then b.rec_out
		else .
	   end as rec_out format=date.
      %end;
      from
      &dsn1 a inner join %if %upcase("&SOURCE") ne "LPRF" %then &dsn2 b on;
	  /* her skal rettes når LPRF tabeller samples */
		%else (select * from &dsn2. union all select * from &dsn3.) b on;
      %if %upcase("&SOURCE") eq "LPR3SB" %then
      (a.kontakt_id=b.kontakt_id );
	  %else %if %upcase("&SOURCE") eq "LPRF" %then
	  /* her skal der rettes når LPRF tabeller samples */
	  (a.DW_EK_KONTAKT=b.DW_EK_KONTAKT and a.DW_EK_forloeb=.) or (a.DW_EK_KONTAKT=. and a.DW_EK_forloeb=b.DW_EK_forloeb)
      %else 
      (a.k_recnum=b.v_recnum);
      %if %upcase("&SOURCE") = "LPR3SB" and &tilopr=TRUE %then
      inner join &dsn3 c on
      (b.procedurer_id=c.procedurer_id );
	  	%if %upcase("&SOURCE") eq "LPRF" %then 
		inner join &dsn4 d on (a.sorenhed_ans = d.sorenhed);
      %if &basedata ne %then %do; 
      inner join &basedata c on
	      %if %upcase("&SOURCE") ne "LPR3SB" and %upcase("&SOURCE") ne "LPRF" %then a.v_cpr_encrypted;
	      %else %if %upcase("&SOURCE") eq "LPR3SB" %then a.personnummer_encrypted 
		  %else %if %upcase("&SOURCE") eq "LPRF" %then a.CPR_ENCRYPTED=c.pnr; =c.pnr
      %end;
	  where /* mangler at holde styr på tilopr  */
	  %if &dlstcnt > 0 %then %do;
	  (
        %do I=1 %to &dlstcnt;
          %let dval = %upcase(%qscan(&opr,&i));
	      %if &i>1 %then OR ;
	          %if %upcase("&SOURCE") ne "LPR3SB" and %upcase("&SOURCE") ne "LPRF" %then %do;
  		    	%if &tilopr=TRUE %then upcase(b.c_tilopr) ; %else upcase(b.c_opr) ;%end;
		  	  %if %upcase("&SOURCE") eq "LPR3SB" %then %do;
  		    	%if &tilopr=TRUE %then upcase(c.tillaegskode) ; %else upcase(b.kode) ;%end;
          	  %if %upcase("&SOURCE") eq "LPRF" %then %do;
				%if &tilopr = TRUE %then b.PROCEDURETYPE eq "+" and PROCEDUREKODE %else b.PROCEDURETYPE ne "+" and PROCEDUREKODE; %end;
			like "&dval%nrstr(%%)"
		  
        %end;
         )
       %end;
	  /* in order to get at numeric list: */
	  
	  %if &pattcnt > 0 %then %do;
	  and
	  (   
          %do I=1 %to &pattcnt;
              %let pval = put(%qscan(&pattype,&i),1.);
	      %if &i>1 %then OR ;
	      a.c_pattype eq &pval
          %end;
          )
	  %end;
          %if &oprart ne %then and b.c_oprart in (%commas(&oprart));
	  and
	  %if %upcase("&SOURCE") ne "LPR3SB" and %upcase("&SOURCE") ne "LPRF" %then a.v_cpr_encrypted; 
		%else %if %UPCASE("&SOURCE") eq "LPR3SB" %then a.personnummer_encrypted;
		%else %if %UPCASE("&SOURCE") eq "LPRF" %then a.CPR_ENCRYPTED; ne "" /* remove empty pnr lines */
	  /* som i getDiag lad det være styret af uaf datasættet
	  %if &UAF=FALSE %then %do;
	  and
	   %if %upcase("&SOURCE") ne "LPR3SB" %then a.d_uddto; %else a.sluttidspunkt; ne .
	  %end;
	  */
	  ;
	   
  %sqlquit;
    %end;
%end;
%end;
proc sort data=&localoutdata out=&outdata;
    by pnr starttime endtime oprstarttime opr rec_in rec_out;
  %RunQuit;
	%let &returnCode=&returncode0;

  %cleanup(&localoutdata);

  data _null_;
    endOPRtime = datetime();
    timeOPRdif=endOPRtime-&startOPRtime;
    put 'executiontime FindingOPR ' timeOPRdif:time20.6;
  run;
%mend;




%macro  combineOPRTables(outdata, name);

	data temp;
	  set &name &name._uaf;
	  by pnr;
	  /* create a compareid - makes it easier to reduce lines */
	  sp = "_";
	  compareid = catx(sp, of pnr opr starttime endtime oprstarttime pattype oprart hospital );
	%runquit;

	proc sort data=temp nodupkey;
	  by pnr compareid indate outdate oprdate pattype oprart hospital opr rec_in rec_out;
	%runquit;

	/* remove dublicate lines - UAF are not updated quite as fast as LPR resulting in double lines */
    data temp1;
	  set temp;
	  by pnr compareid;

	  retain prev_rec_in; /* store information of previous rec_in */
	  if first.compareid then prev_rec_in = rec_in;/* if more than one line with same information */
          if last.compareid  then rec_in = prev_rec_in; /* if not first line, then replace rec_in with the contents from previous line */

	  if last.compareid then output; /* only print one line pr pnr /compareid */
	  drop compareid sp prev_rec_in; /* do not keep variables used for calculations */
	%runquit;

    data &outdata;
	  set temp1;
	  by pnr ;
	%runquit;
%mend;
