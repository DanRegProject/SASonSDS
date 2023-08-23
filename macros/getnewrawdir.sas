
%macro get_new_rawdir(rawdir);

filename tmp pipe "dir /B /A:D ""&rawdir""";
%local dir;
%let dir =;
data want;
	infile tmp dlm = "," length=reclen truncover;
	length dir $256;
	input dir $varying256. reclen;
	want = index(dir,"HENID");
	if want then do;
		lbnr = substr(dir,7,reclen);
		output;
	end;
run;

proc sort data = want;
by lbnr;
run;

data ;
set want end=end;
if end then call symputx('dir',dir);
run;

proc datasets library=work noprint;
delete want;
run;
quit;
libname raw  "&rawdir" access=readonly;
%if "&dir" ne "" %then libname raw  "&rawdir/&dir" access=readonly;;
%mend;

*%get_new_rawdir(F:/Projekter/FSEID00004385/InputData/);
*%put &newraw;

