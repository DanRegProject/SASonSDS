%macro getDiag(outlib, diaglist, diagtype=A B ALGA01 ALGA02, pattype=0 1 2 3, kontakttype=ALCA00 ALCA10, insttype=hospital,prioritet=1 2 ATA1 ATA3, 
               ICD8=FALSE, basedata=, fromyear=1977, basepop=, tildiag=FALSE, UAF=FALSE, SOURCE=LPR LPRPSYK MINIPAS LPR3SB);
	%local N nsets diag nsource s stype;
	%global RC;
	%start_timer(getdiag); /* measure time for this macro */
	%let tildiag=%UPCASE(&tildiag);
	%let ICD8=%UPCASE(&ICD8);

	%let nsource = %sysfunc(countw(&SOURCE));
	%let nsets = %sysfunc(countw(&diaglist));
	%if &nsets > 1 %then %do;
		%nonrep(mvar=diaglist, outvar=newdiaglist);
		%let nsets = %sysfunc(countw(&newdiaglist));
		%let diaglist = &newdiaglist;
	%end;

	%do N=1 %to &nsets; /* start of outer do */
		%let diag = %lowcase(%scan(&diaglist,&N));
		%if %symexist(LPR&diag) %then %do;
		%let filelist=;
		%let inline=;
		%do s=1 %to &nsource; /* start of inner do */
			%let stype = %lowcase(%scan(&SOURCE,&s));
			%let RC=;
			%findingDiag(&diag.ALL&s, &diag, %if &ICD8=TRUE and %symexist(LPR&diag._ICD8)=1 %then &&LPR&diag._ICD8; &&LPR&diag, diagtype=&diagtype, kontakttype=&kontakttype, insttype=&insttype, prioritet=&prioritet, pattype=&pattype, basedata=&basedata, fromyear=&fromyear, tildiag=&tildiag, UAF=FALSE,SOURCE=&stype,returncode=RC);
			/* combine the two tables, exclude lines from UAF that are ended by now */
			/* tables are in work, and name &diag and &diag_uaf */
			%if &UAF=TRUE and &stype=lpr %then %do;
				/* get the uaf tables */
				%let lastyrGH=%sysfunc(today(),year4.);
				%do %while (%sysfunc(exist(raw.lpr2_mdl_t_adm&lastyrGH))=0 and &lastyrGH>&fromyear);
					%let lastyrGH=%eval(&lastyrGH - 1);
				%end;
				%if %sysfunc(exist(raw.lpr2_mdl_uaf_t_adm&lastyrGH))=1 %then %do;
					%findingDiag(&diag._uaf&s, &diag, %if &ICD8=TRUE and %symexist(LPR&diag._ICD8)=1 %then &&LPR&diag._ICD8; &&LPR&diag, diagtype=&diagtype, kontakttype=&kontakttype, insttype=&insttype, prioritet=&prioritet, pattype=&pattype, basedata=&basedata, fromyear=&lastyrGH /* no uaf tables before this time */, tildiag=&tildiag, UAF=TRUE,SOURCE=&stype,returncode=RC);
					/* repeat findingDiag with UAF=FALSE - get the tables that has an enddate */
					%combineDiagTables(&diag.ALL&s, &diag.ALL&s,&diag._uaf&s);
				%end;
			%end;
			%if &RC=0 %then %do;
				%let filelist= &filelist &diag.ALL&s(in=in&s) ;;
				%let inline = &inline +&s*in&s;;
			%end;
		%end; /* end of inner do */
		/* Combine all data from potential sources and include a source identifier in the final dataset */

		data &outlib..LPR&diag.ALL;
			set &filelist;
			_in=0 &inline;
			source=lowcase(scan("&SOURCE",_in));
			if priority="1" and pattype="2" then pattype="3";
			%if &pattype ne  %then %do; 
			if source ne "lpr3sb" and upcase(pattype) not in (%quotelst(&pattype,delim=%str(, ))) then delete;
			%end;
			drop _in;
		%runquit;
		proc sort data=&outlib..LPR&diag.ALL;
			by pnr starttime endtime rec_in;
		%runquit;
		%if &basepop ne %then %do;
			proc sql inobs=&sqlmax;
			%if &N=1 %then create table &outlib..&basepop as ;
			%else insert into &outlib..&basepop;
			select pnr, indate as IDate, diagnose length=10, outcome length=12, rec_in, rec_out, source
			from &outlib..LPR&diag.ALL;
			%sqlquit;
		%end;
	   %end; /* symexist */
	%end; /* end of outer do */
	%if &basepop ne %then %do;
		proc sort data = &outlib..&basepop; /* do not reduce before &ajour is set */
			by pnr idate diagnose outcome rec_out;
		%runquit;
	%end;


	%end_timer(getDiag, text=Measure time for GetDiag macro);
%mend;

/*
findingDiag();

outdata:    output datanavn
outcome:    tekststreng outcome label, should be short
icd:	      ICD koder version 8 eller 10, uden foranstillet D eller punktum,
adskilles ved mellemrum.
diagtype:   diagnosetyper, tegn, med mellemrum (A, B, C, G, H og +) og nu med LPR3 koder også
pattype:    patienttyper, ciffer, adskildt med mellemrum (0, 1, 2 og 3)
kontakttype= : LPR3
insttype= : LPR3
prioritet=: LPR3
basedata:   input datasæt med identer og skæringsdato
fromyear:   start later than 1977
UAF:        Include unfinished diagnosis
SOURCE:     basic source of data
*/

%macro findingDiag(outdata, outcome, icd, diagtype=, pattype=,  kontakttype=, insttype=, prioritet=, basedata=, fromyear=, tildiag=, UAF=, SOURCE=LPR,returnCode=);
	%local localoutdata localoutdata yr I dval dsn1 dsn2 M tablegrp;
	%let dlstcnt     = %sysfunc(countw(&icd));
	%let pattcnt     = %sysfunc(countw(&pattype));
	%let diagtype    = %upcase(%sysfunc(dequote(&diagtype)));
	%let kontakttype = %upcase(&kontakttype);
	%let insttype    = %upcase(&insttype);
	%let prioritet   = %upcase(&prioritet);

	%let localoutdata=%NewDatasetName(localoutdatatmp); /* temporært datasætnavn så data i work */

	/* log eksekveringstid */
	%put start findingDiag: %qsysfunc(datetime(), datetime20.3);
	%let startDiagtime = %qsysfunc(datetime());
	/* find last available dataset */
	%let lastyrGH=%sysfunc(today(),year4.);

	%if &tildiag=TRUE %UPCASE("&SOURCE")="LPR"  %then %do;
		%if &fromyear<1995 %then %let fromyear = 1995; /* tillægsdiagnoser først fra 1995 */
		%let diagtype = +;
	%end;
	%if %UPCASE("&SOURCE")="LPRPSYK" %then %do;
		%let fromyear=0;
		%let lastyrGH=0;
		%let tablegrp=lpr_t_psyk;
	%end;
	%if %UPCASE("&SOURCE")="MINIPAS" and &fromyear<2002 %then %let fromyear=2002;
	%if %UPCASE("&SOURCE")="MINIPAS" %then %let tablegrp=minipas;
	%if %UPCASE("&SOURCE")="LPR" and "&UAF"="FALSE" %then %let tablegrp=lpr2_mdl;
	%if %UPCASE("&SOURCE")="LPR" and "&UAF"="TRUE" %then %let tablegrp=lpr2_mdl_uaf;
	%if %UPCASE("&SOURCE")="LPR3SB" %then %do;
		%let fromyear=0;
		%let lastyrGH=0;
		%let tablegrp=LPR3_SB;
	%end;
	%if &fromyear ne 0 and &lastyrGH ne 0 %then %do;
		%do %while (%sysfunc(exist(raw.&tablegrp._t_adm&lastyrGH))=0 and &lastyrGH>&fromyear);
			%let lastyrGH=%eval(&lastyrGH - 1);
		%end;
	%end;
	%let returncode0=0;

	%if %UPCASE("&SOURCE")="LPR" %then %do;
		%if %sysfunc(exist(raw.&tablegrp._t_adm&lastyrGH))=0 %then %do;
			%put WARNING getDiag: LPR data not available.;
			%let returncode0=1;
		%end;
	%end;
	%if %UPCASE("&SOURCE")="LPRPSYK" and %sysfunc(exist(raw.&tablegrp._adm))=0 %then %do;
		%put WARNING getDiag: LPR-PSYK data not available.;
		%let returncode0=1;
	%end;
	%if %UPCASE("&SOURCE")="MINIPAS" %then %do;
		%if %sysfunc(exist(raw.&tablegrp._t_adm&lastyrGH))=0 %then %do;
			%put WARNING getDiag: MINIPAS data not available.;
			%let returncode0=1;
		%end;
	%end;
	%if %UPCASE("&SOURCE")="LPR3SB" %then %do;
		%if %sysfunc(exist(raw.&tablegrp._kontakt))=0 and %sysfunc(exist(raw.&tablegrp._diagnose))=0 %then %do;
			%put WARNING getDiag: LPR-3SB data not available.;
			%let returncode0=1;
		%end;
	%end;
	%if &returncode0=0 %then %do;
		%do yr=&fromyear %to &lastyrGH;
			proc sql inobs=&sqlmax;
				%if &yr=0 and %UPCASE("&SOURCE") eq "LPRPSYK" %then %do;
					%let dsn1= raw.LPR_t_PSYK_ADM;
					%let dsn2= raw.LPR_t_PSYK_DIAG;
				%end;
				%else %if  %UPCASE("&SOURCE") eq "LPR3SB" %then %do;
					%let dsn1=  raw.&tablegrp._kontakt;
					%let dsn2=  raw.&tablegrp._diagnose;
					%let dsn3=  raw.&tablegrp._diagnose_tillaeg;
				%end;
				%else %do;
					%if &yr=&lastyrGH and &UAF=TRUE and %UPCASE("&SOURCE") eq "LPR" %then %let dsn1= raw.lpr2_mdl_uaf_t_adm&yr;
					%else %if &yr<2005 and %UPCASE("&SOURCE")="LPR" %then %let dsn1= raw.lpr_t_adm&yr;
					%else %let dsn1=  raw.&tablegrp._t_adm&yr;

					%if &yr=&lastyrGH and &UAF=TRUE and %UPCASE("&SOURCE") eq "LPR" %then %let dsn2= raw.lpr2_mdl_uaf_t_diag&yr;
					%else %if &yr<2005 and %UPCASE("&SOURCE") eq "LPR" %then %let dsn2= raw.lpr_t_diag&yr;
					%else %let dsn2= raw.&tablegrp._t_diag&yr;
				%end;
				%if %sysfunc(exist(&dsn2)) and %sysfunc(exist(&dsn2)) %then %do;
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
						"" as pattype length=1 format=$1.  label="pattype",
						%if &tildiag=TRUE %then c.tillaegskode; %else b.kode; as diagnose length=10 label="diagnose",
						b.art as diagtype format=$6. length=6 label="diagnosetype",
						put(a.sundhedsinstitution,20.) as hospital length=20  format=$20. label="hospital",
						a.inst_type length=30,
						put(a.ansvarlig_enhed,20.) as hospitalunit length=20  format=$20. label="Ansvarlig enhed",
						a.hovedspeciale as speciality label="hovedspeciale" length=40,
						a.kontakttype as contacttype length=6,
						a.kontaktaarsag as contactcause length=6,
						a.prioritet as priority length=4 format=$4.,
						%if &tildiag=FALSE %then
	   case when a.rec_in<=b.rec_in then b.rec_in
	        when a.rec_in> b.rec_in then a.rec_in
		else .
	   end as rec_in format=date.,
	   case when a.rec_out<=b.rec_out then a.rec_out
	        when a.rec_out> b.rec_out then b.rec_out
		else .
	   end as rec_out format=date.
	   ;
	   %if &tildiag=TRUE %then
	   case when a.rec_in<=b.rec_in and c.rec_in<= b.rec_in then b.rec_in
	        when a.rec_in>b.rec_in  and a.rec_in>  c.rec_in then a.rec_in
	        when a.rec_in<=c.rec_in and b.rec_in<= c.rec_in then c.rec_in
		else .
	   end as rec_in format=date.,
	   case when a.rec_out>=b.rec_out and c.rec_out>= b.rec_out then b.rec_out
	        when a.rec_out<b.rec_out  and a.rec_out<  c.rec_out then a.rec_out
	        when a.rec_out>=c.rec_out and b.rec_out>= c.rec_out then c.rec_out
		else .
	   end as rec_out format=date.,
	   ;
	   /*a.rec_in format=date.,
						b.rec_out format=date.*/
					%end;
					%else %do;
						0 as contact_id,
						a.v_cpr_encrypted as pnr label="pnr",
						"&outcome" as outcome length=12,
						a.d_inddto as indate label="indate",
						a.d_uddto as outdate label="outdate",
						dhms(a.d_inddto,%if %varexist(&dsn1,v_indtime) %then  case a.v_indtime when . then 11 else a.v_indtime end ; %else 11;,
						%if %varexist(&dsn1,v_indminut) %then case a.v_indminut when . then 59 else a.v_indminut end ; %else 59;,00) as starttime format=datetime.,
						case a.d_uddto when . then . else dhms(a.d_uddto,11,59,00) end as endtime format=datetime.,
						a.c_pattype as pattype length=1 format=$1. label="pattype",
						%if &tildiag=TRUE %then b.c_tildiag; %else b.c_diag; as diagnose length=10 label="diagnose",
						b.c_diagtype as diagtype format=$6. length=6 label="diagnosetype",
						a.c_sgh as hospital length=20 format=$20. label="hospital",
						"Hospital" as inst_type length=30,
						a.c_afd as hospitalunit length=20  format=$20.,
						"" as speciality length=40,
						"" as contacttype length=6,
						"" as contactcause length=6,
						%if %varexist(&dsn1,c_indm) %then a.c_indm; %else ""; as priority length=4 format=$4.,
						case when a.rec_in<=b.rec_in then b.rec_in
   						when a.rec_in> b.rec_in then a.rec_in
						else .
						end as rec_in format=date.,
						case when a.rec_out<=b.rec_out then a.rec_out
						when a.rec_out> b.rec_out then b.rec_out
						else .
						end as rec_out format=date.
	  					%end;
					from &dsn1
					a inner join &dsn2 b on
					%if %upcase("&SOURCE") ne "LPR3SB" %then (a.k_recnum=b.v_recnum 
					);
					%else (a.kontakt_id=b.kontakt_id );
					%if %upcase("&SOURCE") eq "LPR3SB" and &tildiag=TRUE %then
					inner join &dsn3 c on (b.diagnose_id=c.diagnose_id );
					%if &basedata ne %then %do; 
						inner join &basedata c on
						%if %upcase("&SOURCE") ne "LPR3SB" %then a.v_cpr_encrypted;
						%else a.personnummer_encrypted; =c.pnr
					%end;
					where
					%if &dlstcnt > 0 %then %do;
					(
					%do Y=1 %to &dlstcnt;
						%let dval = %UPCASE(%qscan(&icd,&Y));
						%if &Y>1 %then OR ;
						/* ICD8 er numerisk ICD10 starter altid med et bogstav */
						%if %sysfunc(anyalpha(&dval),1) ne 0 %then %do;  /* If there is a character in the diagnosis (result from anyalpha ne 0) -> IDC-10 */
							%if &tildiag=TRUE %then %do; UPCASE(%if %upcase("&source") eq "LPR3SB" %then c.tillaegskode; %else b.c_tildiag;) like "&dval.%" ; %end; 
							%else %do; UPCASE(%if %upcase("&source") eq "LPR3SB" %then b.kode; %else b.c_diag;) like  "D&dval.%"  %end;
						%end; /* ICD-10, tillægskode uden D */
						%else %do;
							UPCASE(%if %upcase("&source") eq "LPR3SB" %then b.kode; %else b.c_diag;) like  "&dval.%"
						%end; /* ICD-8 - ingen tillægskoder */
					%end;
					 )
					 %end;
					/* in order to get at numeric list: */
					%if %upcase("&source") ne "LPR3SB" %then %do;					
						%if &prioritet ne and %varexist(&dsn1,c_indm) %then %do;    and
						    (a.c_indm eq "" or upcase(a.c_indm) in (%quotelst(&prioritet,delim=%str(, ))))
						%end;
					%end;
					%if &diagtype ne %then %do;    and
						%if %upcase("&source") eq "LPR3SB" %then upcase(b.art); %else upcase(b.c_diagtype); in (%quotelst(&diagtype,delim=%str(, )))
					%end;
					%if %upcase("&source") eq "LPR3SB" %then %do;
						%if &kontakttype ne %then %do;    and
							upcase(a.kontakttype) in (%quotelst(&kontakttype,delim=%str(, )))
						%end;
						%if &insttype ne %then %do;    and
							upcase(a.inst_type) in (%quotelst(&insttype,delim=%str(, )))
						%end;
						%if &prioritet ne %then %do;    and
						    upcase(a.prioritet) in (%quotelst(&prioritet,delim=%str(, )))
						%end;
					%end;						
					
					and %if %upcase("&source") ne "LPR3SB" %THEN a.v_cpr_encrypted; %else a.personnummer_encrypted; ne "";
				%end;
			%SqlQuit;
		%end;
		proc sort data=&localoutdata out=&outdata;
		by pnr starttime endtime diagnose;
		%RunQuit;

		%cleanup(&localoutdata);
	%end;
	%let &returnCode=&returncode0;
	data _null_;
		endDiagtime = datetime();
		timeDiagdif=endDiagtime-&startDiagtime;
		put 'executiontime FindingDiag ' timeDiagdif:time20.6;
	run;
%mend;



%macro  combineDiagTables(out, in1, in2);
	%let _temp=%NewDatasetName(localtmpdatatmp); /* temporært datasætnavn så data i work */

	data &_temp;
		set &in1 &in2;
		by pnr;
		/* create a compareid - makes it easier to reduce lines */
		sp = "_";
		compareid = catx(sp, of pnr contact_id starttime endtime  diagnose diagtype pattype hospital hospitalunit);
	%runquit;

	proc sort data=&_temp nodupkey;
		by compareid pnr contact_id starttime endtime diagnose diagtype pattype hospital hospitalunit rec_in rec_out;
	%runquit;

	/* remove dublicate lines - UAF are not updated quite as fast as LPR resulting in double lines */
	data &_temp;
		set &_temp;
		by compareid pnr;

		retain prev_rec_in; /* store information of previous rec_in */
		if first.compareid then prev_rec_in = rec_in;/* if more than one line with same information */
		if last.compareid  then rec_in = prev_rec_in; /* if not first line, then replace rec_in with the contents from previous line */

		if last.compareid then output; /* only print one line pr pnr */
		drop compareid sp prev_rec_in; /* do not keep variables used for calculations */
	%runquit;

	data &out;
		set &_temp;
		by pnr ;
	%runquit;
	%cleanup(&_temp);
%mend;

