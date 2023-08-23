/* macro     : ICD_ATCdefines(type, name, short_txt, code, icd8="") */
/* purpose   : creates the codelists for %getXXX macros, replaces manual typing in the ICD_ATC_codes */
/* type      : LPR, ATC, OPR or UBE */
/* name      : short variable name used in lists - e.g. AFli */
/* short_txt : variable description in txt. Use "" */
/* code      : list of ICD-10/ATC or SKS codes */
/* icd8=""   : only in case of LPR. Store ICD8 code here if available */

/* macrovaiables will be created for the &name and printed to the screen/log for verification purpose */

%macro ICD_ATCdefines(type, name, short_txt, code, icd8="");
  %global &type.&name &type.L&name ;
  %if &type = LPR %then %global &type.&name._ICD8;;
  %let &type.&name      = &code;
  %let &type.L&name     = &short_txt; /* "label" - description */

  /* print names */
  %put &type.&name   = &&&type.&name;
  %put &type.L&name  = &&&type.L&name;
  /* special case for LPR - also including ICD8 */
  %if &type = LPR %then %do;
    %let &type.&name._ICD8  = &icd8; /* list of ICD8 codes - if any */
	%put &type.&name._ICD8  = &&&type.&name._ICD8;
  %end;
%mend;

