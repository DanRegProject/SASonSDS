libname myfmtlib "&macropath/sas/formats";
proc format library=myfmtlib;
  value yesno 0="No" 1="Yes";

value cancerstage
	1 = 'Localized'
	2 = 'Regional spread'
	3 = 'Distant spread'
	9 = 'Missing/unknown';
run;
options fmtsearch = (myfmtlib);
