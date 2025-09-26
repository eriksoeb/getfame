

----------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------
--ERIK Summer 2025 erik.soberg@ssb.no / eriksoeb@gmail.com       
--Programmed in FAME 4GL
---------------------------------------------------------------------------------------------------------------------
--jul2024 init version with json for jupiterlab R Python 
--sep2024 takes fame argument, such as freq a, convert on; deci 1 semikolon separated in double quotes
--oct 2024 can take comma separated list of wildcards

--dec2024 can open several database comma separated
--jun2025 openeing databases as of the databasename ( withouth path and without .
--jun2025 Can use getfame -e with dbname'series
--seriesnames prefixed with ' after dbchannel and seriesname
--jun2025 Handeling identical seriesnames in different databases
--and more:
--jun2025 Handeling 2 similar databasenames if they are opened in different paths..by adding 2,3,4 to the openas names
--jun2025 Adding frequiency for series and NC for formulas using the -n get fameseriesnames option
--jun2025 Cleaning away old writerror procedure
--jun2025 writerrror back as exit procedure if errors in script
--jun2025 added getfame -h and getfame -t to test database 
--jun2025 added quite more -nq -sq -eq 
--sep2025 duplicates removed for repeating wildcards
--sep2025 problem with ?? double question mark as wildcard removed
--sep2025 sample date file for highcharts created for get fameseries and getfameexpr 
--sep2025 New error structure with errors and series not found
--sep2025 If Formulas evaluates series not available or incorrect formulas, getfame will continue with other series and not stop
--sep2025 Name and DB er split into different JSON fields
--sep2025 getfame -e takes a number of expressions separated with ; semikolon "pct(total.ipr); mave(total.ipr,3)"
--sep2025 getfame -s now ; semikolon as separator when listing a list of wildcards "sn1? ; ?.IPR; SN?ADJ.ARIMA?"
--sep2025 sept 20 -
--sep2025 sept 20 - descriptions for getfame -s removed problem python jupityer removed desc
--sep2024 fix for description, name and db-name for expressions containing series from many expressions
--sep2024 chars

---------------------------------------------------------------------------------------------------------------------






----------------------------------------------------
procedure $createwildlist
argument fbase, wild, mpathfile



TRY --remove for debug

over on
 scalar mcount :numeric = 0
 series finnescase:string by case
 series argcase:string by case
 
 series mycase:string by case --new
 scalar num_missing :numeric = 0
 scalar missings :string = "" --collects series not found

local scalar reststr :string = trim(wild)
local scalar curwild :string = ""


local scalar <over on>  myledd:numeric = 1



loop while not missing(location(reststr, ";")) and reststr NE ";"
	

set curwild =   trim(substring(reststr,1,location(reststr,";")-1))
--if  curwild NE ""  --duplicate commas
if  (curwild NE "" AND curwild NE "??")  --duplicate commas or memory fault

        set argcase[myledd] =  curwild
	
        set myledd = myledd+1



end if
	set reststr=substring(reststr, location(reststr,";")+1, length(reststr))

end loop

if (length(reststr) GT 0 ) and (trim(reststr) NE ";")
        set argcase[myledd] =  reststr
	set reststr = "" 
end if




local scalar mbase :string =""

loop for i=1 to lastvalue(basecase)



if i GT  1
set mbase = $getdbas(basecase[i]) + string(i) --if databases with identical names different places I add a number to make unique
else
set mbase = $getdbas(basecase[i]) --the first databse keeps original name
end if


--tester hele listen for valid wildcards
loop for w=1 to lastvalue( argcase)

		if ((trim(argcase[w])) EQ "??")

			set missings = missings +argcase[w]+" "
			set num_missing = num_missing +1

		else if (length (wildlist(id(mbase),argcase[w])) EQ 0)
			set missings = missings +argcase[w]+" "
			set num_missing = num_missing +1
		end if 
	

--maa lope for alle basene i global liste 1 ... eller open.db

loop for s in (wildlist(id(mbase),argcase[w]))
	
	if exists(id(name(s)))

		set finnescase[mcount] = upper(mbase)+"'"+trim(name(s)) --obs new

		set mcount = mcount +1
		
	else
		set missings = missings +name(s)+" "
		set num_missing = num_missing +1
	end if
end loop --wild for each
end loop -- case
end loop --base(r)



-/mycase  = MERGE(sortdata(finnescase))



OTHERWISE

	$writeerror_clean "Ups! check for valid wildcard-list: "+wild, fbase,mpathfile+ lasterror
	$close_html_file
	$exitfame



END TRY


end proc ---createwildliste

----------------------------------------------------------






-----------------------------------------------------------
proc $getfamenames
argument fbase, wild,fameargnotused

store work; over on
channel warning none
close all
$defaults




local scalar mpath:string ="$HOME/.GetFAME/"
local scalar mfile:string ="getfamenames.json"
local scalar mpathfile:string =mpath+mfile

local scalar sn:string ="series_name"
local scalar myclass:string ="series"

local scalar mycreated:string ="created time"
local scalar myupdated:string ="upd time"
local scalar mydescr:string ="desc of object"
local scalar myobs:string = "myobs" 
local scalar myfreq:string = "myfreq" 
--sep25
local scalar mylastval:string = "last" 
local scalar myfirstval:string = "first" 


$open_html_file mpathfile

$openbase fbase




item class on, series on, formulas on, glformula off, glname off, scalar off
item type string off, namelist off, boolean off
item type precision on, numeric on
item alias on


$createwildlist fbase, wild, mpathfile


try
local scalar mylength:numeric = lastvalue (mycase) 
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



replace NC "NC" 


loop for s=1 to lastvalue(mycase)  --ny 

	set mycount = mycount+1
	set sn = mycase[s] --seriesname

try
execute "set myfirstval = datefmt(firstvalue(id(name(" +sn+ "))))"
execute "set mylastval = datefmt(lastvalue(id(name(" +sn+ "))))"
otherwise
set myfirstval = "NC"
set mylastval = "NC"
end try

execute "set myclass = class(id(name(" +sn+ ")))"

if myclass EQ "SERIES"
execute "set myobs = observed(id(name(" +sn+ ")))"
execute "set myfreq = freq(id(name(" +sn+ ")))"

else if myclass EQ "FORMULA"
set myfreq = "NC"  --will always return this anyway
execute "set myobs = source(id(name(" +sn+ ")))"

else  --other objects will never occur due to wildcarding formulas and series only..
set myobs="OBSproblemClass"
set myfreq = "freqproblem" 

end if



execute "set mycreated =  datefmt(created("+sn+",secondly), "+quote+"<YEAR>-<MZ>-<DZ>T<HHZ>:<MMZ>:<SSZ>"+quote +" )"
execute "set myupdated =  datefmt(updated("+sn+",secondly), "+quote+"<YEAR>-<MZ>-<DZ>T<HHZ>:<MMZ>:<SSZ>"+quote +" )"


--øæå problam norwegeian Desc
execute "set mydescr =  descr(" +sn +")"
--set mydescr = "" 
--sat
	    --+ quote+"Desc"+quote+":"+quote+replace(mydescr,quote,"'")+quote +"," &&





	write <crlf off> "{"+quote +"Name"+quote+":"+ quote + substring(sn,location(sn,"'")+1,length(sn)) +quote +","        &&
	    + quote+"Db"+quote+":"+quote+ substring(sn,1,location(sn,"'")-1)   +quote +","   &&
	    + quote+"Class"+quote+":"+quote+myclass+quote +","   &&
	    + quote+"Observed"+quote+":"+quote+myobs+quote+","        &&
	    + quote+"Freq"+quote+":"+quote+myfreq+quote+","        &&
	    + quote+"Desc"+quote+":"+quote+replace($replace_chars(mydescr),quote,"'")+quote +"," &&
	    + quote+"Created"+quote+":"+ quote+mycreated+quote+","+     &&
	    + quote+"Updated"+quote+ ":"+ quote+myupdated +quote  +"}" to Outfile






--oif (lastvalue(myserie) NE mydate) 
if mycount NE mylength 
	write <crlf on> "," to OUTFILE --adder comma if not last line
--else
--	$footer
end if

end loop



otherwise 
--$writeerror_clean "-- "+lasterror + " !", fbase,"NC"
$saveerrors lasterror
$listerrors
$footer
$close_html_file
$exitfame

end try


$listerrors
$footer
$close_html_file
close all
$exitfame
end proc

----------------------------fame namea ------------------- 




----------------------------------------
proc $defaults

close all
width 30000
store work; over on
channel warning none
ignore on;over on
series getfame.err :string by case

scalar getfame_replace:numeric =  location(upper( getenv("GETFAMESYS")),"MYFAME")


image date Quarterly index "<FYEAR>:<PZ>"
image date Quarterly value "<FYEAR>:<PZ>"
image date BiMonthly value "<FYEAR>:<PZ>"
image date BiMonthly index "<FYEAR>:<PZ>"
image date Monthly value "<FYEAR>:<PZ>"
image date Monthly index "<FYEAR>:<PZ>"


image date Annual value "<FYEAR>"
image date value annual "<FYEAR>-01-01"
image date value monthly "<FYEAR>-<MZ>-01"

--for jimmy sep18
image date Quarterly index "<FYEAR>:<PZ>"
image date Quarterly value "<FYEAR>-<MZ>-01"

deci auto
end proc
------------------------------------------


 




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
local scalar reststr :string = (trim(curve2))
local scalar curwild :string = ""
local scalar myledd:numeric = 1
--local scalar num_missing:numeric = 0
--local scalar my_success:numeric = 0
local scalar my_failed:numeric = 0

local series argcase :string by case

$open_html_file mpathfile

$openbase fbase
$header fbase , mpathfile



write quote+"Series"+quote+": [  " to OUTFILE

try
execute famearg
otherwise
$saveerrors lasterror + " OBS argument"
$listerrors
$footer

$close_html_file
$exitfame
end try



----  --nytt
loop while not missing(location(reststr, ";")) and reststr NE ";"
	
set curwild =   trim(substring(reststr,1,location(reststr,";")-1))
if  (curwild NE "" AND curwild NE "??")  --duplicate commas or memory fault

        set argcase[myledd] =  curwild
	
        set myledd = myledd+1

end if
	set reststr=substring(reststr, location(reststr,";")+1, length(reststr))

end loop

--setter inn the last one
if (length(reststr) GT 0 ) and (trim(reststr) NE ";")
        set argcase[myledd] =  reststr
	set reststr = "" 
end if





local scalar mbase :string =""



  set my_failed = 0
loop for e = 1 to lastvalue(argcase)
TRY

  execute "local new getfame_ser = "+argcase[e]
  desc (getfame_ser) = argcase[e]    --just name is best, if lsum is used what is description

if e  GT 1 and my_failed EQ 0  

  write "   ,   "  to OUTFILE --komma
end if


otherwise

  set my_failed = 1

  $saveerrors "Expression NOT Found:  " + argcase[e]
end try




try

if firstvalue(getfame_ser) NE NC and my_failed EQ 0
$namedesc_e fbase, argcase[e], getfame_ser
  $getobs fbase, argcase[e], getfame_ser 

else if my_failed EQ 0 

$namedesc_e fbase, argcase[e] , getfame_ser

  $norange curve2,getfame_ser
end if

end try
		

end loop -- expressioncase



$listerrors --if any
$footer

$close_html_file
$exitfame
--end if


end proc
-------------------------------------------getfame expression-------------------------------------

--------------------------------------------------------------------------------------------------

proc $footer
try
--write " ],  "  to OUTFILE fllytter hack
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






--------------------------------------------------------
proc $getfametest --test to see if database is opened in read mode access
argument fbase 

$defaults

local scalar mpath:string = "$HOME/.GetFAME/"
local scalar mfile:string = "getfametest.json"
local scalar mpathfile:string =  mpath+mfile

$open_html_file mpathfile
$openbase fbase
$writesuccess "OpenReadMode", fbase
$close_html_file
$exitfame
end proc
-----------------------------------------------------------------------------


-----------------------------getfame series wildcard ----------------------------

proc $getfameseries
argument fbase,  wild , famearg

$defaults
local scalar mpath:string = "$HOME/.GetFAME/"
local scalar mfile:string = "getfameseries.json"
local scalar mpathfile:string =  mpath+mfile
--not to be renames as script assume



$open_html_file mpathfile
$openbase fbase




try

execute famearg

otherwise
$writeerror_clean lasterror , fbase,mpathfile
$close_html_file
$exitfame
end try


try --new
item class on, series on, formulas on, glformula off, glname off, scalar off
item type string off, namelist off, boolean off
item type precision on, numeric on
item alias on



$createwildlist fbase, wild, mpathfile
--local scalar mylength:numeric = length (myliste) 

local scalar mylength:numeric = lastvalue (mycase) 


local scalar mycount:numeric = 0 
local scalar mysname :string = "Ups"

if mylength EQ 0
	$writeerror_clean "No Series/Formulas found for wildcard: "+wild, fbase, mpathfile
	$close_html_file
	$exitfame
end if




$header fbase ,mpathfile
write quote+"Wildcard"+quote+ ": "+quote+trim(string(upper(wild)))+quote +"," to OUTFILE
write quote+"Found"+quote+ ": "+string(mylength) +"," to OUTFILE
write quote+"Notfound"+quote+ ": "+string(num_missing) +"," to OUTFILE
write quote+"Missing"+quote+ ": "+quote+trim(missings)+quote +"," to OUTFILE



write quote+"Series"+quote+": [  " to OUTFILE



set mysname =  "floopsname" 



--bedre meldig om ikke noe treff på wildcard
if missing(lastvalue(mycase))
$writeerror_clean  "No objects found for: '"+wild+"'" , fbase, mpathfile
$close_html_file
$exitfame

end if



loop for s =1 to lastvalue(mycase)  
	set mycount = mycount +1


set mysname =   mycase[mycount]



	
try
	execute "local new myseries = "+mysname	

	execute "desc (myseries) = desc(" +mysname +")" 
       desc(myseries) = replace( desc(myseries), quote, "'")
       

if firstvalue(myseries) NE NC
	$namedesc_s fbase, mysname, myseries
	$getobs fbase, mysname,  myseries
else

	$namedesc_s fbase, mysname, myseries
	$norange mysname, myseries

end if
	if mycount NE mylength
		write " ," TO OUTFILE
	end if
	

otherwise

$saveerrors lasterror
end  try

end loop
otherwise

$saveerrors lasterror +" err 2"



end try 

$listerrors --mpathfile
$footer

$close_html_file

$exitfame
end proc

-----------------------end -----get fame series -----------------------------


proc $norange
argument mysname, myser

--write "{" +quote+"Name"+quote+ ": "+quote+string(upper( substring(mysname, location(mysname,"'" )+1 ,length(mysname) ) ))+quote +"," to OUTFILE
--write quote+"Db"+quote+ ": "+quote+string(upper( substring(mysname, 1, location(mysname,"'")-1)))+quote +"," to OUTFILE
--hackett deler opp
--write "{" +quote+"Name"+quote+ ": "+quote+string(upper(  mysname))+quote +"," to OUTFILE
--write quote+"Desc" +quote+": "+ quote+desc(myser) + quote + ","  to OUTFILE
--write quote+"Desc" +quote+": "+ quote+"" + quote + ","  to OUTFILE
--sat
write quote+"Date" +quote+": "+ quote+(replace(@date,"NULL","*")) + quote +","  to OUTFILE
--write quote+"Freq" +quote+": "+ quote+freq(myser) + quote + ","  to OUTFILE
write quote+"Observations"+quote+":[ ]" +NEWLINE + "}" to Outfile

end proc
-----------------------------------------------------------------------------------------------




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
if mpathfile NE "NC"  --deleting the json file case its corrupted
	system("rm -f "+mpathfile)
	system("touch "+mpathfile)
end if

end proc
-----------------------------------ny write error-------------------------



-------------------not in use after jun 4 2025 only startup----------------------
procedure $writeerror
argument myerror
 
local scalar err1: string = replace(myerror, NEWLINE, "-")
local scalar err2: string = replace(err1, quote, "'")

local scalar myday:string = today ("<FYEAR>-<MZ>-<DZ>")

width 30000
open <kind text; acc overwrite>file ("$HOME/.GetFAME/fame.error") as ERRORFILE

write "{" + quote+"error"+quote+": {"  to ERRORFILE
write quote+"GetFameError"+quote+":"+quote+err2+quote + "," to ERRORFILE
write quote+"Date"+quote+":"+quote+myday +"T"+now+quote to ERRORFILE

write " } }"  to ERRORFILE

close !ERRORFILE
$exitfame

end proc

-------------------still in use for startup before getfame starts.. ----------------------


----------------------just write short ok if database is opened -- called by one datae at a time..----------

procedure $writesuccess
argument msgtype, mymsg
width 30000
local scalar myday:string = today ("<FYEAR>-<MZ>-<DZ>")

write "{" + quote+msgtype+quote+": {"  to OUTFILE
write quote+"Database"+quote+":"+quote+mymsg+quote + "," to OUTFILE
write quote+"Openas"+quote+":"+quote+@open.db+quote + "," to OUTFILE
write quote+"Date"+quote+":"+quote+myday +"T"+now+quote to OUTFILE

write " } }"  to OUTFILE

end proc
------------------------------------------------------------------------------------------------------------



------------------------
proc $saveerrors 
argument myerror

local scalar mylast:numeric

if missing(lastvalue(getfame.err))
	set getfame.err[1] = myerror

else
	set  mylast = lastvalue(getfame.err)  +1
	
	set getfame.err[mylast] = myerror
	
end if
end proc

-----------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------------
proc $listerrors
 
local scalar err1: string ="e1" 
local scalar err2: string ="e2"
local scalar myday:string = today ("<FYEAR>-<MZ>-<DZ>")

width 30000



write "],"  to OUTFILE
if NOT missing(lastvalue(getfame.err)) --then list errors

write quote+"ErrorCount"+quote +":"+ string(lastvalue(getfame.err)) + ","  to OUTFILE

write quote+"Errors"+quote+": ["  to OUTFILE

  loop for i=1 to lastvalue(getfame.err)

	set err1  = replace(getfame.err[i], NEWLINE, " ")
	set err2  = replace(err1, quote, "'")
if i EQ lastvalue(getfame.err) --last
	write "{"+quote+"Error"+quote+":"+quote+err2+quote + "}" to OUTFILE

else -- comma needed
	write "{"+quote+"Error"+quote+":"+quote+err2+quote + "}," to OUTFILE
end if

  end loop 

write "],"  to OUTFILE

else --no eroors
  write quote+"ErrorCount"+quote +": 0 ,"  to OUTFILE
  write quote+"Errors"+quote+": [],"  to OUTFILE

end if
end proc

-----------------------------





-------------------debug  use ----------------------
procedure $debug

end proc
--------------------------------------------------------------------



---------------------------------- ---------------------------------------------
proc $openbase
argument fbase

over on
local scalar restbase :string = trim(fbase)
local scalar curbase :string = ""
series basecase :string by case
local scalar myledd :numeric = 1


loop while not missing(location(restbase, ";")) and restbase NE ";"

set curbase =   trim(substring(restbase,1,location(restbase,";")-1))
if  curbase NE ""  --duplicate commas
        set basecase[myledd] =  curbase
        set myledd = myledd+1
end if
        set restbase=trim(substring(restbase, location(restbase,";")+1, length(restbase)))

end loop

if (length(restbase) GT 0 ) and (trim(restbase) NE ";")
        set basecase[myledd] =  trim(restbase )
end if


loop for i = 1 to lastvalue(basecase)


try
if i GT 1
execute "open <acc r> "+ quote+trim(basecase[i]) +quote + " as  "+$getdbas(basecase[i]) +string(i) 
else
execute "open <acc r> "+ quote+trim(basecase[i]) +quote + " as  "+$getdbas(basecase[i]) 
end if


otherwise
$writeerror_clean "Open:" + lasterror, basecase[i],"NC"
$close_html_file
$exitfame
end try
end loop

end proc
-----------------------------------------------------------


--------------------------------------------------------------
-- returning openas name --
--------------------------------------------------------------
function $getdbas
argument mbase
over on
local scalar bname:string  =mirror(mbase)
local scalar dotfree:string  =bname 
local scalar slashfree:string  

if (location(bname,".") NE NC )
set dotfree =substring(bname, location(bname,".")+1 , length(bname))
end if

set slashfree=dotfree

if (location(dotfree,"/") NE NC )
set slashfree =substring(dotfree, 1, location(dotfree,"/")-1)
end if

--withoit dot and slashes
return mirror(trim(string(slashfree)))

end function
------------------------------





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
write quote+"Version" +quote+": "+ quote+"Hack-20251019" + quote+","  to OUTFILE

write quote+"Executed" +quote+": "+ quote+ + mynow +quote+","  to OUTFILE
write quote+"Famever"+quote+": "+quote+ string(@release)+quote+","  to OUTFILE
write quote+"Database"+quote+": "+quote+ fbase+quote +"," to OUTFILE

write quote+"Openas"+quote+": "+quote+ @open.db+quote +"," to OUTFILE

--write quote+"Result"+quote+": "+quote+ replace(ofile,"iso","")+quote +"," to OUTFILE
write quote+"Result"+quote+": "+quote+ ofile+quote +"," to OUTFILE
otherwise
$writeerror_clean "  " + lasterror, fbase,"NC"
end try
end proc
---------------------------



-------------------------------------------
--used for EXPRESSUINNS 
proc $namedesc_e
argument fbase,curve,  myserie
-------------------------------------------

block
ignore on
replace NC ""
replace NA ""
local scalar curve_tmp :string = ""
local scalar curve_tmp2 :string = ""
local scalar curve_tmp3 :string = ""

--try
set curve_tmp = replace(curve, "(", " ")   
set curve_tmp2 = replace(curve_tmp, ")", "")   
set curve_tmp3 = replace(curve_tmp2, ",", " ")   

write "{" +quote+"Name"+quote+ ": "+quote+replace(curve_tmp3,"'"," ") +quote +"," to OUTFILE

--one expression may be from different databases
write quote+"Db"+quote+ ": "+quote+ @open.db +quote +"," to OUTFILE
write quote+"Desc" +quote+": "+ quote+replace(curve_tmp3,"'", " ") + quote + ","  to OUTFILE

--end try
end block
end proc


------------------------------------------------------------------------
--used for getfame -SERIES only 
proc $namedesc_s
argument fbase,curve,  myserie

block
ignore on

--the split for jimmy
write "{" +quote+"Name"+quote+ ": "+quote+string(upper( substring(curve, location(curve,"'" )+1 ,length(curve) ) ))+quote +"," to OUTFILE
write quote+"Db"+quote+ ": "+quote+string(upper( substring(curve, 1, location(curve,"'" )-1  ) ))+quote +"," to OUTFILE

--norway cahar jupiter tbc
--write quote+"Desc" +quote+": "+ quote+replace(desc(myserie),"'"," ") + quote + ","  to OUTFILE

write quote+"Desc" +quote+": "+ quote+ $replace_chars(desc(myserie)) + quote + ","  to OUTFILE
--testing specials
--write quote+"Desc" +quote+": "+ quote+"" + quote + ","  to OUTFILE

end block
end proc
--SERIES END header obs-----------------------------------------------------------


-------------------------------------------------------
proc $getobs
argument fbase,curve,  myserie

ignore on
replace NC "null"
replace NA "null"
replace ND "null"



local scalar < over on> mydate:date
try



write quote+"Date" +quote+": "+ quote+(replace(@date,"NULL","*")) + quote +","  to OUTFILE
write quote+"Freq" +quote+": "+ quote+freq(myserie) + quote + ","  to OUTFILE

otherwise
$writeerror_clean "  " + lasterror, fbase, "NC"
end try

write quote+"Observations"+quote+":[" to Outfile
loop for mydate = firstvalue(myserie) to lastvalue(myserie)

try
write <crlf off> "{"+quote+"Date"+quote +":"+ quote+datefmt(mydate)+quote +", "+  quote+"Value"+quote +":" +string(numfmt(myserie[mydate],auto,@deci)) + &&
 ", "+ quote +"Epo"+quote+":[" +string($epoc(mydate)) +", " + string(numfmt(myserie[mydate],*, @deci)) +  "]}" to OUTFILE

if (lastvalue(myserie) NE mydate) 
	write <crlf on> "," to OUTFILE --adder comma if not last line
else
        write <crlf off> NEWLINE+"]  }    " to  OUTFILE  --last linene
end if

otherwise
$writeerror_clean "  " + lasterror, fbase,"NC"
end try
end loop

end proc
-------------------------------------------------------------------




proc $log
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
$writeerror_clean "  " + lasterror, "closing" ,"NC"--makes no sense with database 
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
--$epoc --Kudos to Jeff for help on this one
--when having a timeseries system, you should never stop using the real date ..
------------------------------------------------------------------------------------------
function $epoc --msec since 1970
argument fdate
return dateof(fdate,millisecondly,after,begin) - millisecondly(1)(1jan1970:0:0:0)
end function
------------------------------------------------------------------------------------------



------------------------------------------------------------
function $replace_chars
argument  mystring

if  not (missing(getfame_replace))

--myfame path
local scalar tmp_str1 :string = ""
local scalar tmp_str2 :string = ""
local scalar tmp_str3 :string = ""
local scalar tmp_str4 :string = ""
local scalar tmp_str5 :string = ""
local scalar tmp_str6 :string = ""

--set tmp_str = replace(replace(mystring,"ø","o"), "Ø","O")

--ok oe  æÆ
set tmp_str1 = replace(mystring,"æ","o")
set tmp_str2 = replace(tmp_str1,"Æ","O")

--åÅ oj  åÅ
Set tmp_str3 = replace(tmp_str2,"å","a")
set tmp_str4 = replace(tmp_str3,"Å","A")

--vrøøøl  øØ som i beer
Set tmp_str5 = replace(tmp_str4,"ø","o")
set tmp_str6 = replace(tmp_str5,"Ø","O")

return (tmp_str6)
else
return mystring
end if

end function


-----------------------------------------------------------





--Eof









