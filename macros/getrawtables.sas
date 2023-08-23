%macro getRawTables(lib, name, compby, startyr, endyr, sortby, void, void2,oldsort=, mergenew=, newfromyear=.,crit=);
/* løkke fra startyr til slutyr */
	%let uid=fskFleSkj;
	%local M;
	/* store variable list */
	%global varliste;
	%put oldsort=&sortby;
	%let cpr = %scan(&sortby,1);
	%if %index(&cpr,cpr)=0 %then %let cpr=;
	%put cpr=&cpr;
	%if &startyr=0 %then %do;
		proc sql inobs=&sqlmax;
			connect to odbc as projdata (datasrc=forskerdatabase uid=&uid);
			create table &lib..&name as
			select * , &last_dataupdate as rec_in format=date., &globalend as rec_out format=date.
			from connection to projdata (select * from &Defaultproject..&&Name)
			%if %index(&cpr,cpr)>0 %then where missing(&cpr)=0;
			;
			disconnect from projdata;
		%sqlquit;
		/* tjek log for warning hvis work.new er tom */
		%put sqlrc =&sqlrc;
		%if &sqlrc gt 0 %then %do; %put "&lib..&name stopped by error in ODBC connection"; quit; %end;

		%getDatasetVarNames(&lib..&name, varliste); /* creates the variable list in a global macro named varliste */
	%end;
	%else %do;
/* replace startyear with another */
		%if &newfromyear ne . %then %let startyr = %SYSFUNC(max(&startyr,&newfromyear));; /* update only from newfromyear, no matter what the table in data_variables says */

		proc sql inobs=&sqlmax;
			connect to odbc as projdata (datasrc=forskerdatabase uid=&uid);
			%do M=&startyr %to &endyr;
				create table &lib..&name.&M as
				select * , &last_dataupdate as rec_in format=date., &globalend as rec_out format=date.
				from connection to projdata (select * from
					%if &Name=LMS_epikur or &Name=LAB_lab_dm_forsker %then &DefaultProject..&&Name;
					%else     &DefaultProject..&&Name.&M;
					%if &Name=LMS_epikur or &Name=LAB_lab_dm_forsker %then where year(&crit)=&M;
				)
				%if %index(&cpr,cpr)>0 %then where missing(&cpr)=0;
				;
			%end;
			disconnect from projdata;
		%sqlquit;
/* tjek log for warning hvis work.new er tom */
		%put sqlrc =&sqlrc;
		%if &sqlrc > 0 %then %do; %put "&lib..&name.&endyr stopped by error in ODBC connection"; quit; %end;
		%if &Name=LMS_epikur %then %do;
			/* der er dublikater i EPIKUR som vi ikke må miste der antyder multible receptudskrivninger */
			%let newsort = cpr_encrypted eksd atc packsize vnr  doso indo volapk voltypecode voltypetxt rec_in rec_out;
			%do M=&startyr %to &endyr;
				proc summary data=&lib..&name.&M nway;
					class &newsort / missing;
					var apk;
					output out=&lib..&name.&M(drop=_freq_ _type_) sum=;
				%runquit;
			%end;
		%end;
		%if %sysfunc(fileexist(&lib..&name.&endyr)) %then %do;
			%getDatasetVarNames(&lib..&name.&endyr, varliste); /* creates the variable list in a global macro named varliste */
		%end;
		%else %do;
			%let varliste =	&sortby extra1 extra2; *tricks check below to pass, as varliste could not be made;
		%end;
	%end;

/* compare number of variables to stored list */
	%if (%sysfunc(countw(&sortby))) ne (%sysfunc(countw(&varliste))-2/* do not count rec_in and rec_out */) %then %do;
		%put "ERROR ERROR ERROR";
		%put "ERROR: Change of variable numbers in &name.";
		%put "new list (incl rec_in and rec_out) ";
		%put %lowcase(&varliste);
		%put "expected list ";
		%put &sortby;
		proc printto; run;
		%abort cancel;
	%end;
%mend;

%macro GetSingleNewRawTable(lib, name);
	proc sql inobs=&sqlmax;
		connect to odbc as projdata (datasrc=forskerdatabase uid=&uid);
		create table &lib..&name as
		select * , &last_dataupdate as rec_in format=date., &globalend as rec_out format=date.
		from connection to projdata (select * from &DefaultProject..&&Name);
		disconnect from projdata;
	%sqlquit;
%mend;

%macro GetNewRawTables(lib, prefix, nof, newfromyear = .,crit=);
	%local I;
	%start_log(&currentpath/log, &prefix.raw);
	%start_timer(getraw);
	%header(path=&localpath, ajour=&last_dataupdate, dataset=&prefix, initials=JNK, reason=Update RAW data);

	%do I=1 %to &nof;
		%GetRawTables(&lib, &&&prefix._table&I, newfromyear=&newfromyear,crit=&crit); /* if newfromyear is set, then loop starts from this year  */
		/* order new data as in data_variable_list.sas */
		%SortNewData(&lib, &&&prefix._table&I, newfromyear=&newfromyear);
	%end;
	%end_timer(getraw, text=execution time getting table &prefix with ODBC);
	%end_log;
%mend;


/* new data is unsorted, can be done with this macro */
%macro SortNewData(lib, Name, compby, startyr, endyr, sortby, void, void2, newfromyear=);
	%local M;
	%if &newfromyear ne . %then %let startyr = %sysfunc(max(&startyr,&newfromyear));; /* update only from newfromyear, no matter what the table in data_variables says */

	%if &startyr=0 %then %do;
		proc sort data=&lib..&name;
		 	by &sortby;
		%runquit;
	%end;
	%else %do;
		%do M=&startyr %to &endyr;
			proc sort data=&lib..&name.&M;
				by &sortby;
			%runquit;
		%end;
	%end;
%mend;


/* Single tables are unsorted, can be done with this macro */
%macro SortSingleNewData(fromyear, lib, Name, compby, startyr, endyr, sortby, void, void2);
	%local M;

	%if &startyr=0 %then %do;
		proc sort data=&lib..&name;
			by &sortby;
		%runquit;
	%end;
	%else %do;
		proc sort data=&lib..&name.&fromyear;
			by &sortby;
		%runquit;
	%end;
%mend;

