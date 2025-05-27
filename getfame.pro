----------------------------------------------------------------------
----------------------------------------------------------------------
--ERIK Summer 2024 / 2025 erik.soberg@ssb.no / eriksoeb@gmail.com       
--Programmed in FAME 4GL
----------------------------------------------------------------------



----------------------------------------------------------------------
procedure $createwildlist
argument fbase, wild, mpathfile



TRY --remove for debug

over on
 scalar mcount :numeric = 0
 series finnescase:string by case
 series argcase:string by case
 scalar myliste :namelist = {}
 scalar num_missing :numeric = 0
 scalar missings :string = "" --collects series not found

local scalar reststr :string = trim(wild)
local scalar curwild :string = ""

--type wild
local scalar <over on>  myledd:numeric = 1



loop while not missing(location(reststr, ",")) and reststr NE ","
	

set curwild =   trim(substring(reststr,1,location(reststr,",")-1))
if  curwild NE ""  --duplicate commas

        set argcase[myledd] =  curwild
	
        set myledd = myledd+1
end if
	set reststr=substring(reststr, location(reststr,",")+1, length(reststr))

end loop

if (length(reststr) GT 0 ) and (trim(reststr) NE ",")
        set argcase[myledd] =  reststr
	set reststr = "" 
end if



local scalar mbase :string ="MYFAMEBASE"

loop for i=1 to lastvalue(basecase)
set mbase = "MYFAMEBASE"+string(i)

--tester hele listen for gyldig wildcard
loop for w=1 to lastvalue( argcase)
	--write "arcase: "+ argcase[w] to OUTFILE

		if (length (wildlist(id(mbase),argcase[w])) EQ 0)
			set missings = missings +argcase[w]+" "
			set num_missing = num_missing +1
		end if 
	

--maa lope for alle basene i global liste 1 ... eller open.db

loop for s in (wildlist(id(mbase),argcase[w]))
	--write "wild TESTING FINNES: "+ name(s) to OUTFILE
	if exists(id(name(s)))
		set finnescase[mcount] = trim(name(s))
		set mcount = mcount +1
		--write "JEG FINNES: "+ name(s) to OUTFILE
	else
		set missings = missings +name(s)+" "
		set num_missing = num_missing +1
	end if
end loop --wild for each
end loop -- case
end loop --base(r)


set myliste = alpha(unique(NL(finnescase)))

OTHERWISE
	$writeerror_clean "Ups check for valid wildcard-list: "+wild, fbase,mpathfile
	$close_html_file
	$exitfame
END TRY


end proc ---createwildliste





---------------------------------------------------
proc $getfamenames
argument fbase, wild,fameargnotused

store work; over on

channel warning none
close all

local scalar mpath:string ="$HOME/.GetFAME/"
local scalar mfile:string ="getfamenames.json"
local scalar mpathfile:string =mpath+mfile


$open_html_file mpathfile

$openbase fbase


item class on, series on, formulas on, glformula off, glname off, scalar off
item type string off, namelist off, boolean off
item type precision on, numeric on
item alias on


--type  "the calling counte "
$createwildlist fbase, wild, mpathfile


try
local scalar mylength:numeric = length  (myliste) 
local scalar mycount:numeric = 0  --new variable counting
if mylength EQ 0.0 or missing(mylength)
	$writeerror_clean "No Series/Formulas found for wildcard "+wild, fbase,mpathfile
	$close_html_file
	$exitfame
end if
 

$header fbase, mpathfile
write quote+"Wildcard"+quote+ ": "+quote+trim(string(upper(wild)))+quote +"," to OUTFILE
write quote+"Found"+quote+ ": "+string(mylength) +"," to OUTFILE
write quote+"Notfound"+quote+ ": "+string(num_missing) +"," to OUTFILE
write quote+"Missing"+quote+ ": "+quote+trim(missings)+quote +"," to OUTFILE

write quote+"Series"+quote+":[" to Outfile



image date value annual "<FYEAR>-01-01"
image date value monthly "<FYEAR>-<MZ>-01"
image date value quarterly "<FYEAR>-<P>"
image date value quarterly "<FYEAR>-<PTL>-01"
image date value quarterly "<FYEAR>-<MZ>-01"

local scalar myobs:string = "HI" 

replace NC "NC" 

loop for x in (myliste) 
	set mycount = mycount+1

if class(x) EQ "SERIES"
set  myobs =  observed(x) 
else
--set myobs = "FORMULA"
set  myobs =  source(x) 
end if





	write <crlf off> "{"+quote +"Name"+quote+":"+ quote + name(x)+quote +","            + quote+"Class"+quote+":"+quote+class(x)+quote +","    +quote+"Observed"+quote+":"+quote+myobs+quote+","           + quote+"Desc"+quote+":"+quote+replace(desc(x),quote,"'")+quote +"," +quote+"Created"+quote+":"+ quote+string(datefmt(created(x,secondly), "<YEAR>-<MZ>-<DZ>T<HHZ>:<MMZ>:<SSZ>"))+quote+","+     quote+"Updated"+quote+ ":"+ quote+string(datefmt(updated(x,secondly),"<YEAR>-<MZ>-<DZ>T<HHZ>:<MMZ>:<SSZ>")) +quote  +"}" to Outfile

	


--oif (lastvalue(myserie) NE mydate) 
if mycount NE mylength 
	write <crlf on> "," to OUTFILE --adder comma if not last line
else
	$footer
end if

end loop

$log "getfamenames", fbase, wild , ""

otherwise 
$writeerror "-- "+lasterror + " !!!", fbase
end try


$close_html_file
close all
$exitfame
end proc

----------------------------fame namea ------------------- 








proc $defaults

close all
width 30000
store work; over on
channel warning none
ignore on

deci auto

end proc





 




-------------------------------------------------------------
--gets observations for one series or sim avg of many series
--returns only 'one' serieS
-------------------------------------------------------------
proc $getfameexpr
argument fbase,  curve , famearg

$defaults

local scalar  curve1:string = replace( curve ,"[", "(" )
local scalar  curve2:string = replace( curve1 ,"]", ")" )
 

local scalar mpath:string = "$HOME/.GetFAME/"
local scalar mfile:string = "getfameexpr.json"

local scalar mpathfile:string =  mpath+mfile

$open_html_file mpathfile



$openbase fbase
$header fbase , mpathfile

write quote+"Series"+quote+": [  " to OUTFILE


--tbc
image date value annual "<FYEAR>-01-01"
image date value monthly "<FYEAR>-<MZ>-01"
image date value quarterly "<FYEAR>-<P>"
image date value quarterly "<FYEAR>-<PTL>-01"
image date value quarterly "<FYEAR>-<MZ>-01"

try
execute famearg
execute "local new mytest = "+curve2

	desc (mytest) = curve2   

otherwise
$writeerror_clean lasterror, fbase, mpathfile

$close_html_file
$exitfame
end try



if firstvalue(mytest) NE NC 
$getobs fbase, curve2,  mytest
else 
$writeerror_clean "Series " + Curve2 + " No Values in Range", fbase, mpathfile
end if

$footer
$log "getfameexpr", fbase, curve , famearg

$close_html_file
$exitfame
end proc
-------------------------------------------getfame expression-------------------------------------


proc $footer
try
write " ],  "  to OUTFILE
set stop_time =$gettime()
--new improved
write  quote+"Elapsed_time_in_seconds"+quote+ ":" + string((stop_time-start_time)/1000)  to OUTFILE
write "  } ]   "  to OUTFILE
otherwise
write  lasterror to OUTFILE
end try

end proc
------------------------------------------------


------------------------------------------------
--used for logging of time used
------------------------------------------------
function $gettime
block
over on
date thisday(millisecondly)
local scalar my_time:precision = time(millisecondly)
return (my_time)
end block
end function
----------------------------------------------------








-----------------------------getfame series wildcard ----------------------------

proc $getfameseries
argument fbase,  wild , famearg

$defaults


local scalar mpath:string = "$HOME/.GetFAME/"
local scalar mfile:string = "getfameseries.json"
--not to be renames as script assume

local scalar mpathfile:string =  mpath+mfile

$open_html_file mpathfile
$openbase fbase

--tbc
image date value annual "<FYEAR>-01-01"
image date value monthly "<FYEAR>-<MZ>-01"
image date value quarterly "<FYEAR>-<P>"
image date value quarterly "<FYEAR>-<PTL>-01"
image date value quarterly "<FYEAR>-<MZ>-01"

try
execute famearg

otherwise
$writeerror "  " + lasterror , fbase
$writeerror_clean lasterror , fbase,mpathfile
$close_html_file
$exitfame
end try


try --new
item class on, series on, formulas on, glformula off, glname off, scalar off
item type string off, namelist off, boolean off
item type precision on, numeric on
item alias on

----

$createwildlist fbase, wild, mpathfile
local scalar mylength:numeric = length (myliste) 
local scalar mycount:numeric = 0 
local scalar mysname :string = "Ups"

if mylength EQ 0
	$writeerror_clean "No Series/Formulas found for wildcard: "+wild, fbase, mpathfile
	$close_html_file
	$exitfame
end if


--extra for founds


$header fbase ,mpathfile
write quote+"Wildcard"+quote+ ": "+quote+trim(string(upper(wild)))+quote +"," to OUTFILE
write quote+"Found"+quote+ ": "+string(mylength) +"," to OUTFILE
write quote+"Notfound"+quote+ ": "+string(num_missing) +"," to OUTFILE
write quote+"Missing"+quote+ ": "+quote+trim(missings)+quote +"," to OUTFILE



write quote+"Series"+quote+": [  " to OUTFILE


set mysname =  "floop" 
--loop for x in (wildlist(mydb, wild)) 
loop for x in (myliste) 
	set mycount = mycount +1

set mysname =  string(name(x)) 

	execute "local new mytest = "+name(x)
	execute "desc (mytest) = desc(" +name(x) +")" 

desc(mytest) = replace( desc(mytest), quote, "'")
        --write string(mylength) + " / " + string(mycount) to outfile --debug

if firstvalue(mytest) NE NC
	$getobs fbase, name(x),  mytest
else

write "{" +quote+"Name"+quote+ ": "+quote+string(upper( name(x)))+quote +"," to OUTFILE

--tbc øæå nor char
write quote+"Desc" +quote+": "+ quote+desc(mytest) + quote + ","  to OUTFILE
--write quote+"Desc" +quote+": "+ quote+"tbc" + quote + ","  to OUTFILE

write quote+"Daterange" +quote+": "+ quote+(replace(@date,"NULL","*")) + quote +","  to OUTFILE
write quote+"Frequency" +quote+": "+ quote+freq(mytest) + quote + ","  to OUTFILE
write quote+"Observations"+quote+":[ ]" +NEWLINE + "}" to Outfile

end if
	if mycount NE mylength
		write " ," TO OUTFILE
	end if
	
end loop
otherwise
$writeerror_clean  "For "+mysname + "- "+ lasterror, fbase, mpathfile
$close_html_file
$exitfame

end try --kampala


$footer


$log "getfameseries", fbase, wild, famearg

$close_html_file
$exitfame
end proc

-----------------------end -----get fame series -----------------------------



-----------------write error with some cleanup of headers-------------------------
--for getgameexpr and getfameseries
----------------------------------------------------------------------------------
procedure $writeerror_clean
argument myerror, mybase, mpathfile

 
local scalar err1: string = replace(myerror, NEWLINE, "-")
local scalar err2: string = replace(err1, quote, "'")

local scalar myday:string = today ("<FYEAR>-<MZ>-<DZ>")

width 30000
open <kind text; acc overwrite>file ("$HOME/.GetFAME/fame.error") as ERRORFILE

write "{" + quote+"Error"+quote+": {"  to ERRORFILE
write quote+"GetFameError"+quote+":"+quote+err2+quote + "," to ERRORFILE
write quote+"Database"+quote+":"+quote+mybase+quote + "," to ERRORFILE
write quote+"Date"+quote+":"+quote+myday +"T"+now+quote to ERRORFILE

write " } }"  to ERRORFILE

close !ERRORFILE

system("rm -f "+mpathfile)
system("touch "+mpathfile)


end proc
-----------------------------------ny write error-------------------------



-------------------still in use ----------------------
procedure $writeerror
argument myerror, mybase

--image date value annual "<FYEAR>-01-01"
 
local scalar err1: string = replace(myerror, NEWLINE, "-")
local scalar err2: string = replace(err1, quote, "'")

local scalar myday:string = today ("<FYEAR>-<MZ>-<DZ>")

width 30000
open <kind text; acc overwrite>file ("$HOME/.GetFAME/fame.error") as ERRORFILE

write "{" + quote+"Error"+quote+": {"  to ERRORFILE
write quote+"GetFameError"+quote+":"+quote+err2+quote + "," to ERRORFILE
write quote+"Database"+quote+":"+quote+mybase+quote + "," to ERRORFILE
write quote+"Date"+quote+":"+quote+myday +"T"+now+quote to ERRORFILE

write " } }"  to ERRORFILE

close !ERRORFILE

end proc




---------------------------------------------
proc $openbase
argument fbase

over on
local scalar restbase :string = trim(fbase)
local scalar curbase :string = ""
series basecase :string by case
local scalar myledd :numeric = 1

loop while not missing(location(restbase, ",")) and restbase NE ","

set curbase =   trim(substring(restbase,1,location(restbase,",")-1))
if  curbase NE ""  --duplicate commas
        set basecase[myledd] =  curbase
        set myledd = myledd+1
end if
        set restbase=trim(substring(restbase, location(restbase,",")+1, length(restbase)))

end loop

if (length(restbase) GT 0 ) and (trim(restbase) NE ",")
        set basecase[myledd] =  trim(restbase )
end if


loop for i = 1 to lastvalue(basecase)


try
execute "open <acc r> "+ quote+trim(basecase[i]) +quote + " as  myfamebase"+string(i)
otherwise
$writeerror "  " + lasterror, basecase[i]
$close_html_file
$exitfame
end try
end loop

end proc
-----------------------------------------------------------







---------------------------
--header
----------------------------
proc $header 
argument fbase,ofile

scalar <over on>  start_time :precision =$gettime() --must set before qry
scalar <over on>  stop_time  :precision =start_time --init to 0


local scalar mynow :string = string(datefmt(created(start_time,secondly),"<YEAR>-<MZ>-<DZ>T<HHZ>:<MMZ>:<SSZ>"))




try
write "[{"+quote+"GetFAME_Json_Api" +quote+": "+ quote+"Erik.Soberg@ssb.no" + +quote+","  to OUTFILE
write quote+"Version" +quote+": "+ quote+"Oslo-20240505" + quote+","  to OUTFILE

write quote+"Executed" +quote+": "+ quote+ + mynow +quote+","  to OUTFILE
write quote+"Famever"+quote+": "+quote+ string(@release)+quote+","  to OUTFILE
write quote+"Database"+quote+": "+quote+ fbase+quote +"," to OUTFILE

write quote+"Result"+quote+": "+quote+ replace(ofile,"iso","")+quote +"," to OUTFILE
otherwise
$writeerror "  " + lasterror, fbase
end try
end proc
---------------------------






-------------------------------------------------------
proc $getobs
argument fbase,curve,  myserie

ignore on
replace NC "null"
replace NA "null"
replace ND "null"

local scalar < over on> mydate:date
--local scalar < over on> myobs:numeric

try
write "{" +quote+"Name"+quote+ ": "+quote+string(upper( curve))+quote +"," to OUTFILE
write quote+"Desc" +quote+": "+ quote+desc(myserie) + quote + ","  to OUTFILE
write quote+"Daterange" +quote+": "+ quote+(replace(@date,"NULL","*")) + quote +","  to OUTFILE
write quote+"Frequency" +quote+": "+ quote+freq(myserie) + quote + ","  to OUTFILE


otherwise
$writeerror "  " + lasterror, fbase
end try

write quote+"Observations"+quote+":[" to Outfile
loop for mydate = firstvalue(myserie) to lastvalue(myserie)

try


write <crlf off> "{"+quote+"Date"+quote +":"+ quote+datefmt(mydate)+quote +", "+  quote+"Value"+quote +":" +string(numfmt(myserie[mydate],auto,@deci)) + &&
 ", "+ quote +"Epo"+quote+":[" +string($epoc(mydate)) +", " + string(numfmt(myserie[mydate],*, @deci)) +  "]}" to OUTFILE

if (lastvalue(myserie) NE mydate) 
	write <crlf on> "," to OUTFILE --adder comma if not last line
else
        --write <crlf on> NEWLINE+"]"+NEWLINE+"}]" to  OUTFILE  --last linene
        write <crlf off> NEWLINE+"]  }    " to  OUTFILE  --last linene
end if


otherwise
$writeerror "  " + lasterror, fbase
end try
end loop

end proc
-------------------------------------------------------------------





-------------------------------------------------------------------
--logger med semi kolons that may occure in famearg
-------------------------------------------------------------------
proc $log
argument modul, fbase, wildcurve, famearg

try
local scalar mylogstr :string = upper(modul)+"3; "+getenv("USER") +"; "+getenv("HOST")+ "; "+today("<YEAR><MZ><DZ>T<HHZ>:<MMZ>:<SSZ>")  + "; "&&
+fbase+ "; " +wildcurve+ ";" +famearg+";Sec:" + string((stop_time-start_time)/1000)

local scalar filename :string = getenv("GETFAMELOG")
open <kind text; acc append >file (filename) as LOGFILE
write mylogstr to LOGFILE
close !LOGFILE
otherwise
end try
end proc
-------------------------------------------------------------------



---------------------------------------------------------------
proc $open_html_file
argument filename
open <kind text; acc overwrite>file (filename) as OUTFILE
end proc
---------------------------------------------------------------


---------------------------------------------
proc $close_html_file

try
output terminal
close !outfile
close all
otherwise
$writeerror "  " + lasterror, "closing" --makes no sense with database 
end try
end proc
---------------------------------------------


------------------------------------------------
proc $exitfame
close all
exit -- ext fame
end proc
------------------------------------------------



------------------------------------------------------------------------------------------
--$epoc --Kudos to Jeff K for inspiring on this one
--when having a timeseries system, you should never stop using the real date ..
------------------------------------------------------------------------------------------
function $epoc --Kudos to Jeff K for inspiring on this one
argument fdate
return dateof(fdate,millisecondly,after,begin) - millisecondly(1)(1jan1970:0:0:0)
end function
------------------------------------------------------------------------------------------









