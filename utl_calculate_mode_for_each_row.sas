
Calculate mode for each  row in SAS/WPS base, more direct in R.

The mode is not so easy

  Two solutions (same result WPS and SAS)

     1. PROC UNIVARIATE
     2. IML/R or WPS/Proc R

  If here is no more the correct result is all the values?

  Forcing the many R data structures int a 'SAS/WPS' dataframe can often be very difficult..

  Coercing 3 Missing types * 7 data types * 7 major data structures * and hundreds of specialized list structures
  into a retangular table of limited datatypes is hard. This is where I spen the most of my time time. (Less is More)

github
https://github.com/rogerjdeangelis/utl_calculate_mode_for_each_row

SAS forum
https://communities.sas.com/t5/Base-SAS-Programming/Calculate-mode-for-each-row/m-p/468952

Good read
https://stackoverflow.com/questions/2547402/is-there-a-built-in-function-for-finding-the-mode

Good Read
Looks like a solid package (just computes modes)
https://cran.r-project.org/web/packages/modeest/modeest.pdf

34 pages and two pages of references.
Calculating the mode is for various densities and domain widths is not a simple problem.

## Estimate of the mode
mlv(x, method = "lientz", bw = 0.2)
mlv(x, method = "naive", bw = 1/3)
mlv(x, method = "venter", type = "shorth")
mlv(x, method = "grenander", p = 4)
mlv(x, method = "hrm", bw = 0.3)
mlv(x, method = "hsm")
mlv(x, method = "parzen", kernel = "gaussian")
mlv(x, method = "tsybakov", kernel = "gaussian")
mlv(x, method = "asselin", bw = 2/3)
mlv(x, method = "vieu")


INPUT
=====

 SD1.HAVE total obs=4

             CUSIP_
   DATE       HLD      V1    V2    V3    V4

  01DEC05      A        3     5     3     2
  01DEC05      B        2     4     2     1
  01JAN06      A        1     2     3     4
  01JAN06      C        4     4     4     0

EXAMPLE OUTPUT


WORK  want total obs=4

   VARIABLE    MODE

      V1         .
      V2         4
      V3         3
      V4         .


PROCESS
=======

1. PROC UNIVARIATE

   proc transpose data=sd1.have out=havXpo;
      by date notsorted cusip_hld notsorted;
      var v:;
   run;quit;

   ods output summary=wantUnv(keep=_name_ mode);
   proc means data=havXpo stackodsoutput mode;
     class _name_;
     var col1;
   run;quit;

     _NAME_      MODE

       V1         .
       V2         4
       V3         3
       V4         .


2. IML/R or WPS/Proc R ( working code)

    want<-apply(have,1,function(x) mlv(as.integer(x), method = "mfv")[[1]]);

      V1    V2    V3    V4

       1     4     3     0
       2     .     .     1
       3     .     .     2
       4     .     .     4


OUPUT
=====

1. proc univariate

WORK.WANTUNV total obs=4

  VARIABLE    MODE

     V1         .
     V2         4
     V3         3
     V4         .


2. IML/R or WPS/Proc R ( working code)

 WORK.WANT total obs=4

   V1    V2    V3    V4

    1     4     3     0
    2     .     .     1
    3     .     .     2
    4     .     .     4
*                _               _       _
 _ __ ___   __ _| | _____     __| | __ _| |_ __ _
| '_ ` _ \ / _` | |/ / _ \   / _` |/ _` | __/ _` |
| | | | | | (_| |   <  __/  | (_| | (_| | || (_| |
|_| |_| |_|\__,_|_|\_\___|   \__,_|\__,_|\__\__,_|

;

options validvarname=upcase;
libname sd1 "d:/sd1";
data sd1.have;
  input date $ cusip_hld $ v1  v2  v3 v4 ;
cards4;
01DEC05 A 3 5 3 2 3
01DEC05 B 2 4 2 1 2
01JAN06 A 1 2 3 4 1
01JAN06 C 4 4 4 0 1
;;;;
run;quit;

*          _       _   _
 ___  ___ | |_   _| |_(_) ___  _ __  ___
/ __|/ _ \| | | | | __| |/ _ \| '_ \/ __|
\__ \ (_) | | |_| | |_| | (_) | | | \__ \
|___/\___/|_|\__,_|\__|_|\___/|_| |_|___/

;

* wps base;
%utl_submit_wps64('
libname sd1 "d:/sd1";
libname wrk sas7bdat "%sysfunc(pathname(work))";
   ods output summary=wrk.wantWpsUnv;
   proc means data=sd1.have  mode;
     var v1-v4;
   run;quit;
run;quit;
');

* R
%utl_submit_wps64('
libname sd1 "d:/sd1";
options set=R_HOME "C:/Program Files/R/R-3.3.2";
libname wrk "%sysfunc(pathname(work))";
proc r;
submit;
source("C:/Program Files/R/R-3.3.2/etc/Rprofile.site", echo=T);
library(haven);
library(modeest);
library(data.table);
have<-read_sas("d:/sd1/have.sas7bdat")[,3:6];
have;
want<-apply(have,1,function(x) mlv(as.integer(x), method = "mfv")[[1]]);
want<-as.data.frame(do.call("rbind", want));
want;
endsubmit;
import r=want data=wrk.wantR;
run;quit;
');

data want;

  set wantR;
  array vs[*] v:;
  do i=1 to dim(vs);
     if lag(vs[i])=vs[i] then vs[i]=.;
  end;
  drop i;

run;quit;

