/*
  macro %reduceMediStatus
  #+TYPE          :  SAS
  #+DESCRIPTION   :  Output data from  %findingMedi is reduced to a status at a specific time.
                     One row pr pnr. The macro is called outside a datastep";
  #+OUTPUT        :  pnr
                     &IndexDate
                     &drug
  #+AUTHOR        :  JNK/FLS
  #+CHANGELOG     :  Date        Initials Status
                  :  10-09-15    JNK      ported from DS
                  :
*/

%macro reduceMediStatus(indata, outdata, drug, IndexDate, atc=, ajour=today());
%local temp;
%let temp=%NewDatasetName(temp);

%if &atc= %then %let atc=&drug;
proc sort data=&indata;
  by pnr &IndexDate eksd;
run;
data &temp;
  set &indata;
  afterbase=1;
  %if &IndexDate ne %then %do;
    afterbase=(eksd ge &IndexDate);
  %end;
  where &ajour between rec_in and rec_out;
run;
data &outdata;
  set &temp;
  by pnr &IndexDate afterbase;

  length %if &IndexDate ne %then %do;
    &drug.LaDrugBe&IndexDate
	&drug.LaUnitBe&IndexDate
	&drug.FiDrugBe&IndexDate
	&drug.FiUnitBe&IndexDate
  %end;
  &drug.FiUnitAf&IndexDate
  &drug.FiDrugAf&IndexDate $7;
  length %if &IndexDate ne %then %do;
    &drug.LaVTTBe&IndexDate
	&drug.FiVTTBe&IndexDate
  %end;
  &drug.FiVTTAf&IndexDate $12;
  retain %if &IndexDate ne %then %do;
    &drug.LaEksdBe&IndexDate  &drug.LaDrugBe&IndexDate
	&drug.LaPSBe&IndexDate    &drug.LaVolBe&IndexDate
	&drug.LaVTTBe&IndexDate   &drug.LaStrBe&IndexDate
	&drug.LaUnitBe&IndexDate  &drug.LaNPackBe&IndexDate
	&drug.FiEksdBe&IndexDate &drug.FiDrugBe&IndexDate
    &drug.FiPSBe&IndexDate   &drug.FiVolBe&IndexDate
	&drug.FiVTTBe&IndexDate  &drug.FiStrBe&IndexDate
	&drug.FiUnitBe&IndexDate &drug.FiNPackBe&IndexDate
  %end;
  &drug.FiEksdAf&IndexDate &drug.FiDrugAf&IndexDate
  &drug.FiPSAf&IndexDate   &drug.FiVolAf&IndexDate
  &drug.FiVTTAf&IndexDate  &drug.FiStrAf&IndexDate
  &drug.FiUnitAf&IndexDate &drug.FiNPackAf&IndexDate;
  format %if &IndexDate ne %then %do;
    &drug.LaEksdBe&IndexDate
	&drug.FiEksdBe&IndexDate
  %end;
  &drug.FiEksdAf&IndexDate date.;
  if %if &IndexDate ne %then first.&IndexDate; %else first.pnr; then do;
    %if &IndexDate ne %then %do;
	  &drug.LaEksdBe&IndexDate=.;   &drug.LaDrugBe&IndexDate="";
	  &drug.LaPSBe&IndexDate=.;     &drug.LaVolBe&IndexDate=.;
	  &drug.LaVTTBe&IndexDate="";   &drug.LaStrBe&IndexDate=.;
	  &drug.LaUnitBe&IndexDate="";  &drug.LaNPackBe&IndexDate=.;
	  &drug.FiEksdBe&IndexDate=.;   &drug.FiDrugBe&IndexDate="";
	  &drug.FiPSBe&IndexDate=.;     &drug.FiVolBe&IndexDate=.;
	  &drug.FiVTTBe&IndexDate="";   &drug.FiStrBe&IndexDate=.;
	  &drug.FiUnitBe&IndexDate="";  &drug.FiNPackBe&IndexDate=.;
	%end;
	&drug.FiEksdAf&IndexDate=.;     &drug.FiDrugAf&IndexDate="";
	&drug.FiPSAf&IndexDate=.;       &drug.FiVolAf&IndexDate=.;
	&drug.FiVTTAf&IndexDate="";     &drug.FiSterAf&IndexDate=.;
	&drug.FiUnitAf&IndexDate="";    &drug.FiNPackAf&IndexDate=.;
  end;
  %if &IndexDate ne %then %do;
    if first.afterbase and afterbase=0 then do;
	  &drug.FiEksdBe&IndexDate=eksd;       &drug.FiDrugBe&IndexDate=&atc;
	  &drug.FiPSBe&IndexDate=packsize;     &drug.FiVolBe&IndexDate=volume;
	  &drug.FiVTTBe&IndexDate=voltypetxt;  &drug.FiStrBe&IndexDate=strnum;
      &drug.FiUnitBe&IndexDate=strunit;    &drug.FiNPackBe&IndexDate=NPack;
	end;
	if last.afterbase and afterbase=0 then do;
	  &drug.LaEksdBe&IndexDate=eksd;       &drug.LaDrugBe&IndexDate=&atc;
	  &drug.LaPSBe&IndexDate=packsize;     &drug.LaVolBe&IndexDate=volume;
	  &drug.LaVTTBe&IndexDate=voltypetxt;  &drug.LaStrBe&IndexDate=strnum;
      &drug.LaUnitBe&IndexDate=strunit;    &drug.LaNPackBe&IndexDate=NPack;
	end;
  %end;
  if first.afterbase and afterbase=1 then do;
    &drug.FiEksdAf&IndexDate=eksd;       &drug.FiDrugAf&IndexDate=&atc;
	&drug.FiPSAf&IndexDate=packsize;     &drug.FiVolAf&IndexDate=volume;
	&drug.FiVTTAf&IndexDate=voltypetxt;  &drug.FiStrAf&IndexDate=strnum;
	&drug.FiUnitAf&IndexDate=strunit;    &drug.FiNPackAf&IndexDate=NPack;
  end;
  if %if &IndexDate ne %then last.&IndexDate; %else last.pnr; then output;
  keep pnr
  %if &IndexDate ne %then &IndexDate
    &drug.LaEksdBe&IndexDate  &drug.LaDrugBe&IndexDate
	&drug.LaPSBe&IndexDate    &drug.LaVolBe&IndexDate
	&drug.LaVTTBe&IndexDate   &drug.LaStrBe&IndexDate
	&drug.LaUnitBe&IndexDate  &drug.LaNPackBe&IndexDate
    &drug.FiEksdBe&IndexDate  &drug.FiDrugBe&IndexDate
	&drug.FiPSBe&IndexDate    &drug.FiVolBe&IndexDate
	&drug.FiVTTBe&IndexDate   &drug.FiStrBe&IndexDate
	&drug.FiUnitBe&IndexDate  &drug.FiNPackBe&IndexDate
  ;
  &drug.FiEksdAf&IndexDate   &drug.FiDrugAf&IndexDate
  &drug.FiPSAf&IndexDate     &drug.FiVolAf&IndexDate
  &drug.FiVTTAf&IndexDate    &drug.FiStrAf&IndexDate
  &drug.FiUnitAf&IndexDate   &drug.FiNPackAf&IndexDate;
  %if &IndexDate ne %then %do;
    label &drug.LaEksdBe&IndexDate=   "Last ekspdate before inclusion event, &IndexDate";
	label &drug.LaDrugBe&IndexDate=   "Last drug before inclusion event, &IndexDate";
	label &drug.LaPSBe&IndexDate=     "Last packsize before inclusion event, &IndexDate";
	label &drug.LaVolBe&IndexDate=    "Last volume before inclusion event, &IndexDate";
	label &drug.LaVTTBe&IndexDate=    "Last volumetext before inclusion event, &IndexDate";
	label &drug.LaStrBe&IndexDate=    "Last strnum before inclusion event, &IndexDate";
	label &drug.LaUnitBe&IndexDate=   "Last strunit before inclusion event, &IndexDate";
	label &drug.LaNPackBe&IndexDate=  "Last NPack before inclusion event, &IndexDate";
    label &drug.FiEksdBe&IndexDate=   "First ekspdate before inclusion event, &IndexDate";
	label &drug.FiDrugBe&IndexDate=   "First drug before inclusion event, &IndexDate";
	label &drug.FiPSBe&IndexDate=     "First packsize before inclusion event, &IndexDate";
	label &drug.FiVolBe&IndexDate=    "First volume before inclusion event, &IndexDate";
	label &drug.FiVTTBe&IndexDate=    "First volumetext before inclusion event, &IndexDate";
	label &drug.FiStrBe&IndexDate=    "First strnum before inclusion event, &IndexDate";
	label &drug.FiUnitBe&IndexDate=   "First strunit before inclusion event, &IndexDate";
	label &drug.FiNPackBe&IndexDate=  "First NPack before inclusion event, &IndexDate";
  %end;
  label &drug.FiEksdAf&IndexDate=     "First ekspdate Af inclusion event, &IndexDate";
  label &drug.FiDrugAf&IndexDate=     "First drug after inclusion event, &IndexDate";
  label &drug.FiPSAf&IndexDate=       "First packsize after inclusion event, &IndexDate";
  label &drug.FiVolAf&IndexDate=      "First volume after inclusion event, &IndexDate";
  label &drug.FiVTTAf&IndexDate=      "First volumetext after inclusion event, &IndexDate";
  label &drug.FiStrAf&IndexDate=      "First strnum after inclusion event, &IndexDate";
  label &drug.FiUnitAf&IndexDate=     "First strunit after inclusion event, &IndexDate";
  label &drug.FiNPackAf&IndexDate=    "First NPack after inclusion event, &IndexDate";
  %if &IndexDate = %then %do;
    rename &drug.FiEksdAf&IndexDate=  &drug.FiEksd;
	rename &drug.FiDrugAf&IndexDate=  &drug.FiDrug;
	rename &drug.FiPSAf&IndexDate=    &drug.FiPS;
	rename &drug.FiVolAf&IndexDate=   &drug.FiVol;
	rename &drug.FiVTTAf&IndexDate=   &drug.FiVTT;
	rename &drug.FiStrAf&IndexDate=   &drug.FiStr;
	rename &drug.FiUnitAf&IndexDate=  &drug.FiUnit;
	rename &drug.FiNPackAf&IndexDate= &drug.FiNPack;
  %end;
run;
%mend;



