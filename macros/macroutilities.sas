/* RunQuit
  ref: analytics.ncsu.edu/sesug/2010/cc07.blanchette.pdf
  RunQuit anvendes i stedet for Run eller Quit.
  Hvis fejl stoppes efterfølgede SAS kørsel
*/

%macro RunQuit;
  ;
  run;
  quit;
  %if &syserr. gt 4 %then %do;
  	%end_log;
    %abort cancel;
  %end;
%mend ;

/*
  calcdays
  Datastep utility to calculate days since startdate for a bunch of endpoints
*/
%macro calcdays(sets, basedate, EndDateStr=EndDate, EndDayStr=Endday);
  %do i=1 %to %sysfunc(countw(&sets));
    %let var=%sysfunc(compress(%qscan(&sets,&i)));
	&var.EndDayStr=&var.EndDateStr-&basedate;
  %end;
%mend;

/*
   quotelst
*/
%macro quotelst(str, quote=%str(%"),delim=%str( ));
  %local i quotelst;
  %let i=1;
  %do %while(%length(%qscan(&str, &i, %str( ))) GT 0);
    %if %length(&quotelst) EQ 0 %then %let quotelst = &quote.%qscan(&str, &i, %str( ))&quote;
	%else %let quotelst=&quotelst.&quote.%qscan(&str,&i, %str( ))&quote;
	%let i=%eval(&i + 1);
	%if %length(%qscan(&str,&i,%str( ))) GT 0 %then %let quotelst=&quotelst.&delim;
	%end;
  %unquote(&quotelst)
%mend; /* quotelst */


/*
   commas
   convert at string of words to a string of comma separated words
*/
%macro commas(str);
  %quotelst(&str, quote=%str(), delim=%str(, ))
%mend; /* commas */


%macro NewDatasetName(proposalname);
  %local i newdatasetname;
  %let proposalname=%sysfunc(compress(&proposalname));
  %let newdatasetname=_&proposalname;
  %do %while(%sysfunc(exist(&newdatasetname)));
    %let i=%eval(&i+1);
	%let newdatasetname=_&proposalname&i;
  %end;
  &newdatasetname
%mend;

%macro cleanup(sets);
  proc datasets nolist;
    delete &sets;
  run;
  quit;
%mend;

%macro isBlank(param);
  %sysevalf(%superq(param)=,boolean)
%mend;

%macro varexist(ds /* dataset name */, var /* variable name */);
  %local dsid rc;
  %let dsid = %sysfunc(open(&ds));
  %if (&dsid) %then %do;
    %if %sysfunc(varnum(&dsid, &var)) %then 1;
    %else 0;
    %let rc=%sysfunc(close(&dsid));
  %end;
  %else 0;
  %mend varexist;

%macro sqlquit;
  ;quit;
  %if &sqlrc gt 4 %then %do;
    %put ERROR: Proq SQL failed, execution stopped!;
    %abort cancel;
  %end;
%mend;

%macro start_timer(name);
  %if &create_timelog=TRUE %then %do;
    %global st&name;
	%let st&name = %qsysfunc(datetime());
	/* simple timestamp in log */
	%put start &name %sysfunc(today(),date.) %sysfunc(time(),time.);
  %end;
%mend;

%macro end_timer(name, text=);
  %if &create_timelog=TRUE %then %do;
    data _null_;
      end&name = datetime();
	  diff&name=end&name-&&st&name;
	  put "executiontime &text " diff&name:time20.6;
    %runquit;
  %end;
%mend;

%macro start_log(path, name, option=new); /* replace option=new with option= if log is to be appended to old */
  %if &create_log=TRUE %then %do;
    proc printto log="&path/&name..log" print="&path/&name..log" &option;
    run;
  %end;
%mend;

%macro end_log;
  %if &create_log=TRUE %then %do;
    proc printto;
	run;
  %end;
%mend;

/* create a macrovariable with all the names of variables in the dataset */
%macro getDatasetVarNames(dsn, liste, var1=, var2=);
  proc contents data=&dsn
    out = vars(keep = varnum name)  order = varnum
	noprint;
  %runquit;
  proc sql noprint;
    select NAME
	into :orderedvars separated by ' '
	from vars
/*	order by varnum*/;
  %sqlquit;

  %put %lowcase(&orderedvars);
  %let &liste = %lowcase(&orderedvars);

%mend;


/* test utility to validate if periodification is correct in a dataset */
%macro testrec(table,id);
   title "test of &table, id : &id";
   proc sql;
   create table test as
   select * from &table
   group by &id
   having (sum(rec_out-rec_in)+count(*)-1) ne max(rec_out)-min(rec_in)
   order by &id, rec_in;
   select "Number of errors: ", count(*) from test;
   quit;
%mend;


* Utility to generate a string variable by concatenation of variables allowing for missing values;
%macro makeid(id,vars);
    length &id $ 1000;
_SP_="_";
%let lvars=%sysfunc(tranwrd(%QUOTE(&vars),%STR( ),%STR( _SP_ )));
&id=catx("",of &lvars);
drop _SP_;
%mend;
