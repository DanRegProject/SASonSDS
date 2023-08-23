/* changed order: basedata= at the end */
%macro getMedi(outlib, medlist, basedata=, basepop=,fromyear=1994);
	%local N;
	%put "lookhere" &fromyear &lastyr;

	%let nsets =  %sysfunc(countw(&medlist));
	%if &nsets gt 2 %then %do; /* reduce list */
		%nonrep(mvar=medlist, outvar=newsets);
		%let medlist = &newsets;
		%let nsets = %sysfunc(countw(&newsets));
	%end;

	%do N=1 %to &nsets;
		%let medi = %lowcase(%scan(&medlist,&N));

		%findingMedi(&outlib..LMDB&medi.ALL, &medi, &&ATC&medi, basedata=&basedata, fromyear=&fromyear);
		%if &basepop ne %then %do;
			proc sql inobs=&sqlmax;
				%if &N=1 %then create table &outlib..&basepop as ;
				%else insert into &outlib..&basepop;
				select pnr, eksd as IDate, &medi as drug length=10, rec_in, rec_out 
				from &outlib..LMDB&medi.ALL;
			%sqlquit;
		%end;
	%end; /* end of do */
	%if &basepop ne %then %do;
		proc sort data = &outlib..&basepop; /* do not reduce before &ajour is set */
			by pnr idate drug rec_out;
		%runquit;
	%end;
%mend;


/*
  findingMedi();
  Extract prescription data on specific ATC codes for a population.
  Output dataset can optionally be reduced to at status at a specified time,
  using ''%reducerFA''. Other reduction macros are also available.
  The macro is called outside a datastep.

*/

%macro findingMedi(outdata, drug, atc, basedata=,fromyear=);
	%let sqlrc=0;
	%put "extract based on population in &basedata";
	%put &fromyear &lastyr &sqlrc;
	%local I ; *lastyr;

	/* hack */
	%let isrecthere=;
	proc sql noprint;
		select name into : isrecthere
		from dictionary.columns
		where upcase(libname)="RAW" and upcase(memname) like "LMS_EPIKUR%" and upcase(name)="REC_IN";
	quit;
	/* slut på hack */
	/* log speed */
	%put start findingMedi: %qsysfunc(datetime(), datetime20.3);
	%let startMeditime = %qsysfunc(datetime());

	%let dlstcnt = %sysfunc(countw(&atc));
	/*Commented line so lastyr is not overwritten.
	%let lastyr=%sysfunc(year("&sysdate"d));*/

	%do %while (%sysfunc(exist(raw.lms_epikur&lastyr))=0 and &lastyr>1990);
		%let lastyr=%eval(&lastyr - 1);
		%put her &lastyr;
	%end;
	/* hvis vi har gammel opsætning uden årsopdelt så sæt disse til nul */
	%if &lastyr=1990 %then %do;
		%let fromyear=0;
		%let lastyr=0;
	%end;
	%put &fromyear &lastyr &sqlrc;

	proc sort data=raw.lms_laegemiddeloplysninger out=work.lms_laegemiddeloplysninger nodupkey;
		where volume ne . or packsize ne .;
		by vnr;
	run;
	
	* %if &sqlrc=0 %then %do; ;
	%do y=&fromyear %to &lastyr;
		proc sql inobs=&sqlmax;
			%if &y=0 %then %let yy=;
			%else %let yy=&y;
			%if &y=&fromyear %then 
				create table &outdata as;
			%else 
				insert into &outdata;
			select
			a.cpr_encrypted as pnr, a.eksd, a.atc as &drug, a.apk as Npack, b.packsize, b.volume,
			b.voltypetxt, b.strnum, b.strunit,
			%if &isrecthere ne  %then a.rec_in as rec_in format=date.,;
			%else mdy(01,01,1994) as rec_in format=date.,;
			%if &isrecthere ne  %then a.rec_out as rec_out format=date.;
			%else mdy(12,31,2099) as rec_out format=date.;
			from
			%if &basedata ne %then &basedata c inner join ;
			raw.lms_epikur&yy as a
			%if &basedata ne %then on a.cpr_encrypted=c.pnr ;
			join work.lms_laegemiddeloplysninger b on a.vnr=b.vnr
			where
			%macro void;      
				((a.eksd le mdy(01,13,2016) and b.rec_in=mdy(01,13,2016)) or
				/* %if &isrecthere ne %then */ a.eksd between b.rec_in and b.rec_out  /*;*/
				/* %else (a.eksd gt mdy(01,01,&yy.) and a.eksd le mdy(12,31,2099) ); */ /* denher betingelse dur ik */
				) and /* get lms information available at the date of purchase, could be changed later */
			%mend;
			%if &dlstcnt > 1 %then (;
			%do I=1 %to &dlstcnt;
				%let dval = %upcase(%qscan(&atc,&I));
				%if &i>1 %then OR ;
				upcase(a.atc) like "&dval.%"
			%end;
			%if &dlstcnt >1 %then );
			;
		%end;
		%sqlquit;
	%end;
	proc sort data=&outdata;
		by pnr &drug eksd;
	run;
	data _null_;
		endMeditime=datetime();
		timeMedidif=endMeditime - &startMeditime;
		put 'execution time FindingMedi ' timeMedidif:time20.6;
	run;
%mend;


