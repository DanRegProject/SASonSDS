/*
  macro %prereduceMediStatus
  #+TYPE          :  SAS
  #+DESCRIPTION   :  Klarg�r til reduktion og omd�ber alle inkluderede medicin til samme navn (atc).
                     f.eks.her hvor findingMedi har samlet alt under A10, som default anvender
                     reduceMediStatus unikke atc koder, hvilket ikke �nskes her.
                     %prereduceMediStatus(DiabATC, A10);
  #+CHANGELOG     :  Date        Initials Status
                  :  01-10-15    JNK      ported from DS
                  :
*/

%macro prereduceMediStatus(indata, outdata, grp, atc, IndexDate, ajour=);
%local localdata;
  %let localdata=%NewDatasetName(temp); /* tempor�rt datas�tnavn s� data i work */

  data localdata;
    set &indata;
	format &grp $10.; /* remove warning */
	ATC=&grp;
	&grp="&atc";
  run;
  %reduceMediStatus(localdata, &outdata, &grp, &indexdate, ATC=ATC, ajour=&ajour);
  %cleanup(&localdata);

%mend;



