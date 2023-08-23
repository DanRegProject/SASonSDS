/* copy RAW tables, reduce to only the variables agreed upon and the pnr from population */
%macro CreateProjectTables(inpop,outlib,Name, compby, startyr, endyr, sortby, primtab,primkey, oldsort=, mergenew=, prefix=,ajour=today());
	%local M compare tmpds;
	%let tmpds=%sysfunc(round(%qsysfunc(datetime()),1));
	%let prefix=%upcase(&prefix);
	%let name=%upcase(&name);


	%let compare = %qscan(&sortby,1); /* pnr or recnum are typically first in the sortby list */
/*
  %if &prefix=LPR %then %do;
      %if %index(&name,LPR2_MDL_UAF_T)>0 %then %let primtab=lpr2_mdl_uaf_t_adm;;
      %if %index(&name,LPR2_MDL_T)>0 %then %let primtab=lpr2_mdl_t_adm;;
      %if %index(&name,LPR_T)>0 %then %let primtab=lpr_t_adm;;
      %end;
  %if &prefix=LPRPSYK %then %do;
      %if %index(&name,LPR_T_PSYK)>0 %then %let primtab=lpr_t_psyk_adm;;
      %end;
  %if &prefix=MINIPAS %then %do;
      %if %index(&name,MINIPAS_T)>0 %then %let primtab=minipas_t_adm;;
      %end;
  %if &prefix=MINIPASPSYK %then %do;
      %if %index(&name,MINIPAS_T_PSYK)>0 %then %let primtab=minipas_t_psyk_adm;;
      %end;
  %if &prefix=MFR %then %do;
      %if %index(&name,MFR)>0 %then %let primtab=mfr_mfr;;
      %end;
 %if &prefix=LPR3_SB %then %do;
      %if %index(&name,LPR3_SB)>0 %then %let primtab=LPR3_SB_kontakt;;
      %end;
*/
  /* create a temporary table with the current compare id of the population */
	data temppop&tmpds;
  /* in case of LPR then use recnum */
/*
%if &prefix=LPR or &prefix=LPRPSYK or  &prefix=MINIPAS or &prefix=MINIPASPSYK %then %do;
%if &prefix=LPR %then set &inpop.lpr;
%if &prefix=LPRPSYK %then set &inpop.psyk;
%if &prefix=MINIPAS %then set &inpop.minipas;
%if &prefix=MINIPASPSYK %then set &inpop.minipaspsyk;
;
   rename recnum = &compare;
%end;
%else %if &prefix=MFR and &Name eq mfr_mfr and &Name ne mfr_t_lpr_mfr %then %do;
    %let compare = pk_mfr;
	rename fk_mfr = &compare;
    set &inpop.mfr;
    %end;
%else %if &prefix=LPR3_SB %then %do;
    %if %index(&Name,LPR3_SB_DIAGNOSE)>0 %then %do;
        set &inpop.LPR3SBdiag;
    %end;
    %if %index(&Name,LPR3_SB_PROCEDURE)>0 %then %do;
        set &inpop.LPR3SBpro;
    %end;
    %if %index(&Name,LPR3_SB_KONTAKT)>0 %then %do;
        set &inpop.LPR3SBkon;
    %end;
    %if %index(&Name,LPR3_SB_FORLOEB)>0 %then %do;
        set &inpop.LPR3SBforl;
    %end;
    %end;
%else %do;
    set &inpop;
    rename pnr = &compare;
	%let primtab =;
%end;
*/
		%if %length(&primtab)=0 %then set &inpop; %else set &inpop.&primtab;;
		%if %length(&primtab)=0 %then rename pnr = &compare; %else rename &primkey = &compare;;
	run;


	proc sort data=temppop&tmpds nodupkey;
		by &compare %if &primtab ne %then table;;
	run;

  /* if no looping years then go here */
	%if &startyr=0 %then %do;
		data &outlib..&name (keep=&sortby rec_in rec_out);
			merge temppop&tmpds (in=a
				%if &primtab ne %then where=(table=%upcase("raw.&primtab"));
				) raw.&name (in=b where=(rec_in<= &ajour and &ajour<rec_out))  ;
			by &compare;
			if b and a;
			*     if last.&compare;
		%runquit;
		/* optimize final table output - remove identical lines */
		*    %CombineLinesWithSameInfo(&outlib..&name, &sortby); * FLS 2/12-19 avoid additional versioning as already done in 1220;
	%end;
  /* else loop from start to endyear of the table  */
	%else %do;
		%do M=&startyr %to &endyr;
			%if %sysfunc(exist(raw.&name.&M)) %then %do;

				proc sort data=raw.&name.&M;
					by &compare;
				run;

				data &outlib..&name.&M (keep=&sortby rec_in rec_out);
					merge temppop&tmpds (in=a
						%if &primtab ne %then where=(table=%upcase("raw.&primtab.&M"));
						) raw.&name.&M (in=b where=(rec_in<= &ajour and &ajour<rec_out)) ;
					by &compare;
					if b and a;
					*    if last.&compare;
				%runquit;

			%end;
		/* optimize final table output - remove identical lines */
		*	%CombineLinesWithSameInfo(&outlib..&name.&M, &sortby);
		%end;
	%end;
	proc datasets nolist;
		delete temppop&tmpds;
	%runquit;
%mend;


/* some tables with no PNR information are just plain copied */
%macro SimpleMove(inpop,outlib,Name, compby, startyr, endyr, sortby, primtab,primkey, oldsort=, mergenew=,ajour=);
  %local M;
  /* if no looping years then go here */
  %if &startyr=0 %then %do;
    data &outlib..&name (keep=&sortby rec_in rec_out);
      set raw.&name( where=(rec_in<= &ajour and &ajour<rec_out));
    %runquit;
  %end;
  /* else loop from start to endyear of the table  */
  %else %do;
    %do M=&startyr %to &endyr;
      %if %sysfunc(exist(raw.&name.&M)) %then %do;
      data &outlib..&name&M (keep=&sortby rec_in rec_out);
        set raw.&name&M( where=(rec_in<= &ajour and &ajour<rec_out));
      %runquit;
%end;
%end;
  %end;
%mend;

%macro CopyProjectData(inpop,outlib,prefix, nof, SimpleCopy=FALSE,ajour=today());
  %local I;

  %start_log(&&projectpath\OutputData/log, &prefix._raw);
  %header(path=&projectpath, ajour=&Last_DataUpdate, dataset=&prefix, initials=JNK, reason=Moved from RAW to StudyFolder &PROJECT_NAME and reduced to selected list of pnr );

  %start_timer(startcombinetime);

  %if &nof %then %do;
      %do I=1 %to &nof; /* loop amount of tables */
        %if &SimpleCopy=TRUE %then %do;
          %SimpleMove(&inpop,&outlib,&&&prefix._table&I,ajour=&ajour); /* Copying table, no pnr in the files OR no limitation to table */
        %end;
        %else %do;
          %CreateProjectTables(&inpop,&outlib,&&&prefix._table&I, prefix=&prefix,ajour=&ajour);
        %end;
      %end;
	%end;
    %else %do;
      %CreateProjectTables(&inpop,&outlib,&&&prefix, prefix=&prefix,ajour=&ajour); /* get only one table - typically for test purpose */
    %end;

 %end_timer(startcombinetime, text=moving all tables to project (study) folder);
 %end_log;
%mend;

%macro refresh(first,inlib,outlib);
    %let inlib=%upcase(&inlib);
    %if &first=TRUE %then %do;
proc sql;
    select memname into :ds_list separated by ' '
        from dictionary.tables where libname = "&inlib";
%macro loops;
    %local n i this;
    %let n = %sysfunc(countw(&ds_list));
    %do i = 1 %to &n;
        %let this= %sysfunc(scan(&ds_list,&i));
        %if %index(&this,POP)=0 %then %do;
            proc sql;
                select max(rec_out) into :lastrec_out from &inlib..&this where rec_out<&globalend;
                %put &lastrec_out;
                update &inlib..&this set rec_out=&globalend where rec_out= &lastrec_out;
                %put Copy &this from &inlib to &outlib;
                create table &outlib..&this as select * from &inlib..&this;
                %end;
            %end;
    %mend;
%loops;
quit;
%end;
%mend;

