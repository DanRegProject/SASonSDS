%macro riskmacros(basetable, indexdate, risktable, indicators, nof_days, docpath, ajour, mergetoinputtable=TRUE);
/* path:        Documentation of how the calculations are done. Results are stored as txt files in the path directory */
/* IndexDate:    Date for risk calculation */
/* basetable:   must include pnr and IndexDate */
/* risktable:   Name of resulting table with riskscores */
/* indicators:  Name of resulting table with comorbidity indicators */
/* ajour:       Using only tables that are valid at the time of &ajour */
/* nof_days:    counting the period from &IndexDate-nof_days to &IndexDate when calculating hypertension */


%local M riskvarATC riskvarLPR riskvarN riskvarATCN riskvarLPRN hasbledindi chadsvascindi chadsindi atriastrokeindi
atriableedindi orbitindi;
%let riskvarATC  = loop DIABATC Aspirin Clopi NSAID Thien renin;
%let riskvarATCeksd  = loopeksd DIABATCeksd Aspirineksd Clopieksd NSAIDeksd Thieneksd renineksd;
%let riskvarLPR  = hyplpr HFstr /*LVD*/ DIABLPR Istroke SE TIA PADvasc /*Aplaq*/ MIstr Renal GIbleed ICbleed impbleed genbleed ocbleed /*Ibleed Mbleed3 Gbleed2 TIBleed*/ Alco Liver Mrenal Anemia;
%let riskvarN    = %sysfunc(countw(&riskvarATC &riskvarLPR));
%let riskvarATCN = %sysfunc(countw(&riskvarATC));
%let riskvarLPRN = %sysfunc(countw(&riskvarLPR));

%let hasbledindi     =  hypertension_hasbled&IndexDate renal_hasbled&IndexDate liver_hasbled&IndexDate stroke_hasbled&IndexDate bleeding_hasbled&IndexDate drugs_hasbled&IndexDate alcohol_hasbled&IndexDate;
%let chadsvascindi   =  hypertension_chadsvasc&IndexDate hf_chadsvasc&IndexDate diabetes_chadsvasc&IndexDate stroke_chadsvasc&IndexDate vascular_chadsvasc&IndexDate;
%let chadsindi       =  hypertension_chads&IndexDate hf_chads&IndexDate diabetes_chads&IndexDate stroke_chads&IndexDate;
%let atriastrokeindi =  hypertension_atriastroke&IndexDate proteinuria_atriastroke&IndexDate renal_atriastroke&IndexDate hf_atriastroke&IndexDate diabetes_atriastroke&IndexDate;
%let atriableedindi  =  hypertension_atriableed&IndexDate bleeding_atriableed&IndexDate renal_atriableed&IndexDate anemia_atriableed&IndexDate;
%let orbitindi       =  renal_orbit&IndexDate antiplat_orbit&IndexDate bleeding_orbit&IndexDate anemia_orbit&IndexDate;

%macro ATCrisk(name, count=1, date=. , before= ); (&name >= &count) AND (&name ne .) %if ("&date" ne "" AND "&before" ne "") %then AND (&date - &name.EKSD < &before ) ; %mend;
%macro LPRrisk(name, date, before= ); (&name <= &Date) AND (&name ne .) %if ("&before" ne "") %then AND (&date - &name.l < &before ) ;  %mend;

%let localbasetable = %NewDatasetName(localbasetable);
data &localbasetable; set &basetable;
    keep pnr &indexDate;
%runquit;
proc sort data=&localbasetable nodupkey;
        by pnr &indexdate;
%runquit;

 /* store documentation in the destination &path */
 %risk_documentation(&docpath);

/* merge LPR input tables and reduce to valid tabel at &ajour time */
/* LPR tables are only one line per pnr */ /* this has changed now lpr has all rows, to be able to finde last record before indexdate */
 %findLPRrisktables(&localbasetable, work.giantLPRtable, &IndexDate, &nof_days, &ajour);

  /* create a similar table for medication, check for drug use within the &nof_days period */
 %findATCrisktables(&localbasetable, work.giantATCtable, &IndexDate, &nof_days, &ajour);

 /* calculate hypertension */
 %findhypertension(&localbasetable, &IndexDate, work.hyp, &nof_days, &ajour);

 /* add age */
 proc sql;
   create table work.pop
   as select a.pnr, a.sex, a.birthday, b.&IndexDate as riskdate
   from
   risklib.riskpopulation a, &localbasetable b where a.pnr=b.pnr and &ajour between a.rec_in and a.rec_out
   order by pnr, riskdate;
 quit;

 /* merge hypertension with the other risks, calculate at the end */
 data %if &risktable ne %then &risktable&IndexDate(keep=pnr &IndexDate hasbled&IndexDate chads2&IndexDate cha2ds2vasc&IndexDate atriastroke&IndexDate atriableed&IndexDate orbit&IndexDate);
    %if &indicators ne %then &indicators&IndexDate(keep=pnr &IndexDate sex age&IndexDate age65&IndexDate age75&IndexDate &hasbledindi &chadsvascindi &chadsindi &atriastrokeindi &atriableedindi &orbitindi);;
   merge work.giantLPRtable work.hyp work.giantATCtable work.pop (in=a);
   by pnr riskdate;

   if a; /* only continue if information is stored in work.pop */

   &IndexDate=riskdate;
   format &IndexDate date.;
   format age&IndexDate age65&IndexDate age75&IndexDate 4.;

   if birthday ne . then Age&IndexDate   = intck('year', birthday, riskdate);;
   if Age&IndexDate eq . then Age&IndexDate = 0;; /* in case indexdate and birthday are the same */
   Age75&IndexDate = (Age&IndexDate>=75);
   Age65&IndexDate = (Age&IndexDate>=65);


   array atria_age          (0:3) (0 64 74 84);  /* age > atria_age(x) */
   array atria_prior_stroke (0:3) (8  7  7  9); /* scale if stroke    */
   array atria_no_stroke    (0:3) (0  3  5  6);  /* scale if no stroke */
   atria_age_point&IndexDate = 0;

   %do M=1 %to &RISKhypN;
   %let name = %scan(&RiskHyp,&M); /* the names are corresponding to defines in ATCkoder.sas */
	 if &name eq . then &name = 0; /* if pnr is not present in hyp-dataset, then set all to zero */
   %end;
/* FLS rettet HF definition */
   hf_chads&IndexDate                 = %LPRrisk(hfstr, riskdate) OR (%ATCrisk(loop) AND %ATCrisk(Renin));
   hf_chadsvasc&IndexDate             = hf_chads&IndexDate /*OR %LPRrisk(LVD,riskdate)*/;
   hf_atriastroke&IndexDate           = hf_chads&IndexDate;
   diabetes_chadsvasc&IndexDate       = %LPRrisk(diabLPR,riskdate) OR %ATCrisk(diabATC,count = 1);
   diabetes_chads&IndexDate           = diabetes_chadsvasc&IndexDate;
   diabetes_atriastroke&IndexDate     = diabetes_chadsvasc&IndexDate;
   stroke_chads&IndexDate             = %LPRrisk(istroke,riskdate) OR %LPRrisk(TIA,riskdate);
   stroke_atria&IndexDate             = %LPRrisk(istroke,riskdate);
   stroke_hasbled&IndexDate           = stroke_chads&IndexDate;
   stroke_atriastroke&IndexDate       = %LPRrisk(istroke,riskdate);
   stroke_chadsvasc&IndexDate         = stroke_chads&IndexDate OR %LPRrisk(SE,riskdate);
   vascular_chadsvasc&IndexDate       = (%LPRrisk(mistr,riskdate) OR %LPRrisk(PADvasc,riskdate)/* OR %LPRrisk(Aplaq,riskdate)*/);
   liver_hasbled&IndexDate            = %LPRrisk(liver,riskdate);
   bleeding_hasbled&IndexDate         = %LPRrisk(GIbleed,riskdate) OR %LPRrisk(icbleed,riskdate) OR %LPRrisk(impbleed,riskdate) OR %LPRrisk(genbleed,riskdate) OR %LPRrisk(ocbleed,riskdate);
   bleeding_atriableed&IndexDate      = bleeding_hasbled&IndexDate;
   bleeding_orbit&IndexDate           = bleeding_hasbled&IndexDate;
   drugs_hasbled&IndexDate            = %ATCrisk(Aspirin,date=riskdate,before=365.25/2) OR %ATCrisk(Clopi,date=riskdate,before=365.25/2) OR %ATCrisk(NSAID,date=riskdate,before=365.25/2);
   alcohol_hasbled&IndexDate          = %LPRrisk(alco,riskdate,before=365.25/2);
   renal_hasbled&IndexDate            = %LPRrisk(renal,riskdate);
   renal_atriastroke&IndexDate        = renal_hasbled&IndexDate;
   renal_atriableed&IndexDate         = renal_hasbled&IndexDate;
   renal_orbit&IndexDate              = renal_hasbled&IndexDate;
   hypertension_hasbled&IndexDate     = %ATCrisk(hypscore) OR %LPRrisk(hyplpr,riskdate,before=365.25);
   hypertension_chads&IndexDate       = hypertension_hasbled&IndexDate;
   hypertension_chadsvasc&IndexDate   = hypertension_hasbled&IndexDate;
   hypertension_atriastroke&IndexDate = hypertension_hasbled&IndexDate;
   hypertension_atriableed&IndexDate  = hypertension_hasbled&IndexDate;
   proteinuria_atriastroke&IndexDate  = %LPRrisk(mrenal,riskdate);
   anemia_atriableed&IndexDate        = %LPRrisk(anemia,riskdate);
   anemia_orbit&IndexDate             = anemia_atriableed&IndexDate;
   antiplat_orbit&IndexDate           = %ATCrisk(Aspirin) OR %ATCrisk(Thien);

   /* sørg for at nedenstående udregninger ender i dokumentationen */
   hasbled&IndexDate     = hypertension_hasbled&IndexDate + renal_hasbled&IndexDate + liver_hasbled&IndexDate + stroke_hasbled&IndexDate + bleeding_hasbled&IndexDate + age65&IndexDate + drugs_hasbled&IndexDate + alcohol_hasbled&IndexDate;
   cha2ds2vasc&IndexDate = hypertension_chadsvasc&IndexDate + hf_chadsvasc&IndexDate + age65&IndexDate + age75&IndexDate + diabetes_chadsvasc&IndexDate + (stroke_chadsvasc&IndexDate*2) + vascular_chadsvasc&IndexDate + sex;
   chads2&IndexDate      = hypertension_chads&IndexDate + hf_chads&IndexDate + age75&IndexDate + diabetes_chads&IndexDate + (stroke_chads&IndexDate*2);

   /* calculate input from age in ATRIA score */
  %do M=0 %to 3;
     if (age&IndexDate > atria_age(&M)) then do;
       if stroke_atria&IndexDate>0 then atria_age_point&IndexDate = atria_prior_stroke(&M);
	   else atria_age_point&IndexDate = atria_no_stroke(&M);
	 end;
   %end;
   atriastroke&IndexDate  = hypertension_atriastroke&IndexDate + proteinuria_atriastroke&IndexDate + renal_atriastroke&IndexDate + hf_atriastroke&IndexDate + sex + diabetes_atriastroke&IndexDate + atria_age_point&IndexDate;
/* FLS Rettet vægte i atriableed */
   atriableed&IndexDate   = 3*anemia_atriableed&IndexDate + hypertension_atriableed&IndexDate + 3*renal_atriableed&IndexDate + 2*age75&IndexDate + bleeding_atriableed&IndexDate;
   orbit&IndexDate        = age75&IndexDate + 2*anemia_orbit&IndexDate + 2*bleeding_orbit&IndexDate + renal_orbit&IndexDate + antiplat_orbit&IndexDate;
/* set to zero if result is missing */
   if cha2ds2vasc&IndexDate = . then cha2ds2vasc&IndexDate = 0;
   if atriastroke&IndexDate = . then atriastroke&IndexDate = 0;

   if hasbled&indexdate = . then hasbled&indexdate = 0;
   if cha2ds2vasc&indexdate = . then cha2ds2vasc&indexdate = 0;
   if chads2&indexdate = . then chads2&indexdate = 0;
   if atriastroke&indexdate = . then atriastroke&indexdate = 0;
   if atriableed&indexdate = . then atriableed&indexdate = 0;
   if orbit&indexdate = . then orbit&indexdate = 0;
%runquit;


 /* merge result on &basetable */
/* %if &risktable ne or &indicators ne %then %do;*/
 %if %upcase(&mergetoinputtable)=TRUE %then %do;
  data &basetable;
  merge &basetable &risktable&IndexDate &indicators&IndexDate;
  by pnr &IndexDate;
  %runquit;
 %end;
%cleanup(&localbasetable);
%mend;



/* below helpful macros for running %riskmacros() */
%macro findLPRrisktables(basetable,outputtable, IndexDate, nof_days, ajour);
%local M var;

/* find last observation before indexdate and collapse data into one row */
 %do M = 1 %to &RiskvarLPRN;
	%let var = %scan(&RiskvarLPR,&M);

		proc sql;
			create table risk&var as
				select a.*, b.&indexdate
				from
				risklib.&var as a 
				left join &basetable as b 
				on a.pnr = b.pnr and b.&indexdate ge &var;
			quit;
		run;

		proc sort data=risk&var;
		by pnr &var;
		run;

		data risk&var.red;
		set risk&var;
		by pnr &var;
		retain tempfirst templast;

		if first.pnr then tempfirst = &var;
		templast = &var;

		&var = tempfirst;
		&var.l = templast;

		format &var date.;
		format &var.l date.;
		drop tempfirst;
		drop templast;
		if last.pnr;
	run;
 %end;


/* merge all LPR input with valid timestamp */
data work.LPRtable;
  merge
    %do M=1 %to &RiskvarLPRN;
      %let var = %scan(&RiskvarLPR,&M);
	  risk&var.red
	%end;
	;
	where &ajour between rec_in and rec_out;
	by pnr;
%runquit;

/* select only pnr from &basetable */
proc sql;
  create table work.risktable
  as select a.*, b.&IndexDate as riskdate
  from
  work.LPRtable a, &basetable b where a.pnr=b.pnr 
		and &ajour between a.rec_in and a.rec_out 
  order by pnr, riskdate;
quit;

/* create the outputtable with one single line pr pnr/riskdate */
  data &outputtable;
    set work.risktable;
	by pnr riskdate;

	retain
    %do M=1 %to &riskvarLPRN;
	  temp&M
    %end;;

	/* save first set of variables in temp for each riskdate */
	if first.riskdate then do;
      %do M=1 %to &riskvarLPRN;
        %let var = %scan(&riskvarLPR,&M);
         temp&M = &var;
	   %end;
	end;

	if last.riskdate then do;
	  %do M=1 %to &riskvarLPRN;
        %let name = %scan(&riskvarLPR,&M);
		if &name eq . then &name = temp&M;
		drop temp&M;
	  %end;
	end;
	if first.riskdate = 0 and last.riskdate = 0 then do;
	/* more than two lines of data to merge */
	  %do M=1 %to &riskvarLPRN;
        %let name = %scan(&riskvarLPR,&M);
		if &name ne . and &name < temp&M then temp&M = &name;
		/* replace information in temp&M if it is present in this line and the date is prior to the temp&M date */
	  %end;
	end;

	if last.riskdate then output;
    drop rec_in rec_out;
  run;
%mend;

%macro findATCrisktables(basetable,outputtable, IndexDate, nof_days, ajour);
  %local Q var name;

    data work.riskATC;
      merge
      %do Q=1 %to &RiskvarATCN;
        %let var = %scan(&RiskvarATC,&Q);
        risklib.&var
	  %end;
	  ;
	  by pnr eksd;
          where &ajour between rec_in and rec_out;
	%runquit;

/* select only pnr from &basetable, within &ajour-period and with ekspedition date from &IndexDate-nofdays to &IndexDate */
   proc sql;
     create table work.ATCtable as
	 select a.*, b.&IndexDate as riskdate
     from work.riskATC a, &basetable b
	 where a.pnr=b.pnr and &ajour between rec_in and rec_out and
     a.eksd between (&IndexDate-&nof_days) and &IndexDate
     order by pnr, riskdate, eksd;
  %sqlquit;

  /* reduce to a single line for each pnr/riskdate */
   data &outputtable;
     set work.ATCtable ;
	 by pnr riskdate eksd;

	 retain
	 %do Q=1 %to &RiskvarATCN;
       h&Q
	   t&Q
     %end;;
     /* loop replacing  h1 h2 h3 h4 h5 and t1 t2 t3 t4 t5 t6 for the last time;*/

	 if first.riskdate then do;
	 /* reset all temp variables */
     %do Q=1 %to &RiskvarATCN;
       h&Q = 0;
	   t&Q = 0;
     %end;
     end;

	 /* count H&Q */
	 %do Q=1 %to &RiskvarATCN;
       %let name = %scan(&RiskvarATC,&Q); /* the names are corresponding to defines in ATCkoder.sas */
	   h&Q = sum(h&Q,&name);
	   if &name ne . then t&Q = eksd;
       if last.riskdate and last.eksd then do;
	     &name = h&Q;
		 &name.EKSD = t&Q;
	   end;
     %end;

     if last.riskdate and last.eksd then do;
	   keep pnr riskdate &RiskvarATC &RiskvarATCeksd;
	   output;
	 end;
   %runquit;
%mend;


%macro findhypertension(basetable, IndexDate, outputtable, nofdays, ajour);
   %local I U name;

	/* select only pnr from &basetable, within &ajour-period and with ekspedition date from &IndexDate-nofdays to &IndexDate */
   proc sql;
     create table work.hyptemp as
	 select a.*, b.&IndexDate as riskdate
     from risklib.hypall a, &basetable b
	 where a.pnr=b.pnr and &ajour between rec_in and rec_out and
	 a.eksd between (&IndexDate-&nofdays) and &IndexDate;
   %sqlquit;

   proc sort data=work.hyptemp;
     by pnr riskdate eksd;
  %runquit;

   data &outputtable;
     set work.hyptemp ;
	 by pnr riskdate eksd;
	 /* specify format for h&I and the names from the hypertension list */
	 format
	 %do I=1 %to &RISKhypN;
       %let name = %scan(&RiskHyp,&I); /* the names are corresponding to defines in ATCkoder.sas */
	   &name.hyp h&I
	 %end;
	 hypscore hyp1score 4.;
	 /* end format */

    retain
    %do I=1 %to &RISKhypN;
	   h&I
    %end;
	;
	/*  retain h1 h2 h3 h4 h5 h6 ;*/

	 if first.riskdate then do;
	 /* reset all temp variables */
     %do I=1 %to &RISKhypN;
       h&I = 0;
     %end;
     end;

	 /* count H&I */
	 %do I=1 %to &RISKhypN;
       %let name = %scan(&RiskHyp,&I); /* the names are corresponding to defines in ATCkoder.sas */
	   if h&I = 0 then do;
  	     if find(&name,'C0', 'i') ge 1 then h&I = 1; /* not in the combination drug list, weight 1 */
	   end;

       if h&I eq 1 then do;
 	     %do U=1 %to &RISKhypCompN;
           %let drug = &&RISKHypComp&U; /* the names are corresponding to defines in ATCriskscores.sas */
/*		   if &name="&drug" then do;*/
               if index(&name,"&drug")>0 then do;
             h&I = 2; /* on the combination list, weight 2 */
*			 put "Combination drug: &name is &drug, " &&RISKLHypComp&U;
	       end;
	     %end;
	   end;
	   &name.hyp = h&I ;

     %end;

     if last.riskdate and last.eksd then do;
	   hypscore = 0; /* reset hypscore */
	 %do I=1 %to &RISKhypN;
	   hypscore = hypscore + h&I;
     %end;
	   hyp1score = hypscore;
       Hypscore =  hypscore > 1;
	   output;
	end;

    keep pnr eksd riskdate hypscore hyp1score
	%do I=1 %to &RISKhypN;
      %let name = %scan(&RiskHyp,&I); /* the names are corresponding to defines in ATCkoder.sas */
	  &name.hyp
	%end;
	  ; /* end of keep */
%runquit;
%mend;

/* FLS Rettet heart failure doc */
%macro risk_documentation(path);
data _null_;
  file "&path\chads2_description.txt";

  put " The CHADS2 score calculation is based on: ";
  put " | Component         | Prefix                                   | Weight | ";
  put " |-------------------+------------------------------------------+--------| ";
  put " | Heart failure     | hfstr or (loop AND Renin)                 | 1      | ";
  put " | Hypertension      | (Alfa+NonLoop+Vaso+Beta+Calcium+Renin)>1  |		 | ";
  put " |					| or hypLPR < 365.25 days 					|        | ";
  put " |                   | or combination drug                      | 1      | ";
  put " | Age               | Age>75                                   | 1      | ";
  put " | Diabetes          | DiabLPR or DiabATC > 1				   | 1      | ";
  put " | Stroke            | Istroke or TIA                           | 2      | ";

  put " ";
%runquit;
/* Prefix description in seperate tables: */
%create_datalist(ATC, &path, loop Alfa Nonloop Vaso Beta Calcium Renin DiabATC, chads2_atc);
%create_datalist(LPR, &path, hfstr DiabLPR Istroke TIA, chads2_lpr);
%create_datalist(RISK, &path, &RISKhypComp, hyp_comp);

/* FLS Rettet heart failure doc */
data _null_;
  file "&path\cha2ds2vasc_description.txt";
  put "  The CHA2DS2-VASc score calculation is based on: ";
  put " | Component         | Prefix                                   | Weight | ";
  put " |-------------------+------------------------------------------+--------| ";
  put " | Heart failure     | (hfstr or (loop and Renin))	           | 1      | ";
  put " | Hypertension      | (Alfa+NonLoop+Vaso+Beta+Calcium+Renin)>1 |        | ";
  put " |                   | or combination drug or hypLPR < 365.25 days | 1      | ";
  put " | Age               | Age>=75                                  | 1      | ";
  put " | Age               | Age>=65                                  | 1      | ";
  put " | Diabetes          | DiabLPR or DiabATC > 1                   | 1      | ";
  put " | Stroke            | Istroke or SE or TIA                     | 2      | ";
  put " | Vascular Disease  | MIstr or PADvasc			                | 1      | ";
  put " | Sex               | Female sex                               | 1      | ";

  put " ";
%runquit;
/* Prefix description in seperate tables: */
%create_datalist(ATC, &path, loop Alfa Nonloop Vaso Beta Calcium Renin DiabATC, cha2ds2vasc_atc);
%create_datalist(LPR, &path, hfstr /*LVD*/ DiabLPR Istroke TIA SE MIstr PADvasc /*APLAQ*/, cha2ds2vasc_lpr);


data _null_;
  file "&path\hasbled_description.txt";
  put "  The HAS-BLED score alculation is based on: ";
  put " | Component         | Prefix                                   | Weight | ";
  put " |-------------------+------------------------------------------+--------| ";
  put " | Hypertension      | (Alfa+NonLoop+Vaso+Beta+Calcium+Renin)>1 |        | ";
  put " |                   | or combination drug or hypLPR < 365.25 days| 1      | ";
  put " | Renal Disease     | Renal                                    | 1      | ";
  put " | Liver Disease     | Liver                                    | 1      | ";
  put " | Stroke            | Istroke or TIA                           | 1      | ";
  put " | Bleeding          | GIbleed or icbleed or impbleed		   | 1      | ";
  put " | Age               | Age>=65                                  | 1      | ";
  put " | Drugs             | Aspirin or clopidogrel or NSAID          | 1      | ";
  put " | Alcohol           | Alco                                     | 1      | ";
%runquit;
/* Prefix description in seperate tables: */
%create_datalist(ATC, &path, Alfa Nonloop Vaso Beta Calcium Renin Aspirin clopi nsaid, hasbled_atc);
%create_datalist(LPR, &path, Renal Liver Istroke TIA Ibleed Mbleed3 Gbleed2 TIbleed Alco, hasbled_lpr);

data _null_;
  file "&path\atriastroke_description.txt";
  put "  The ATRIA Stroke score calculation is based on: ";
  put " | Component         | Prefix                                   | Weight without           | Weight with              | ";
  put " |                   |                                          | prior stroke             | prior stroke             | ";
  put " |-------------------+------------------------------------------+--------------------------|--------------------------| ";
  put " | Age               | Age>=85                                  | 6                        | 9                        | ";
  put " | Age               | 75<=Age<85                               | 5                        | 7                        | ";
  put " | Age               | 65<=Age<75                               | 3                        | 7                        | ";
  put " | Age               | Age<65                                   | 0                        | 8                        | ";
  put " | Sex               | Female sex                               | 1                        | 1                        | ";
  put " | Diabetes          | DiabLPR or DiabATC > 1                   | 1                        | 1                        | ";
  put " | Heart failure     | hfstr and loop                            | 1                        | 1                        | ";
  put " | Hypertension      | (Alfa+NonLoop+Vaso+Beta+Calcium+Renin)>1 |                          |                          | ";
  put " |                   | or combination drug or hypLPR < 365.25 days| 1                        | 1                        | ";
  put " | Proteinuria       | Mrenal                                   | 1                        | 1                        | ";
  put " | eGFR<45 pr ESRD   | Renal                                    | 1                        | 1                        | ";
  put " | Stroke            | Istroke                                  | used for age calculation | used for age calculation | ";

%runquit;
/* Prefix description in seperate tables: */
%create_datalist(ATC, &path, Alfa Nonloop Vaso Beta Calcium Renin loop diabATC, atriastroke_atc);
%create_datalist(LPR, &path, Renal mrenal hfstr diabLPR Istroke TIA, atriastroke_lpr);

/* FLS Rettet atriableed vægte doc */
data _null_;
  file "&path\atriableed_description.txt";
  put "  The ATRIA Bleeding score calculation is based on: ";
  put " | Component            | Prefix                                   | Weight | ";
  put " |----------------------+------------------------------------------+--------| ";
  put " | Anemia               | Anemia                                   | 3      | ";
  put " | dGFR<30 or dialysis  | Renal                                    | 3      | ";
  put " | Age                  | Age>=75                                  | 2      | ";
  put " | Bleeding             | GIbleed or icbleedor or impbleed	 	  | 1      | ";
  put " | Hypertension         | (Alfa+NonLoop+Vaso+Beta+Calcium+Renin)>1 |        | ";
  put " |                      | or combination drug or hypLPR < 365.25 days| 1      | ";

%runquit;
/* Prefix description in seperate tables: */
%create_datalist(ATC, &path, Alfa Nonloop Vaso Beta Calcium Renin , atriableed_atc);
%create_datalist(LPR, &path, Anemia Renal Ibleed Mbleed3 Gbleed2 TIbleed, atriableed_lpr);

data _null_;
  file "&path\orbit_description.txt";
  put "  The ORBIT Bleeding score calculation is based on: ";
  put " | Component         | Prefix                                   | Weight | ";
  put " |-------------------+------------------------------------------+--------| ";
  put " | Age               | Age>=75                                  | 1      | ";
  put " | Anemia/red.haem   | Anemia                                   | 2      | ";
  put " | Bleeding          | GIbleed or icbleedor or impbleed		   | 2      | ";
  put " | <60mL/min/1.73m2  | Renal                                    | 1      | ";
  put " | Antiplatelet      | Aspirin or thienpyrides                  | 1      | ";

%runquit;
/* Prefix description in seperate tables: */
%create_datalist(ATC, &path, Aspirin Thien, orbit_atc);
%create_datalist(LPR, &path, Anemia Renal IBleed MBleed3 GBleed2 TIBleed, orbit_lpr);
%mend;
