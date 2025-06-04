# getfame-json-api
API, getfame for exporting fame data as json for further use and analysis
Use the API to get one or more series from a Fame database, into your favorite programming language such as Python, javascript, R other..
Using fameexpressions you can evaluate series-expressions, converting, summing and take use of all the functionality and power FAME offers. 
### Easy to parse and read. Custom functions can be used from getfameexpr 
#### common basis year: cb(seriesname,yyyy)

## install /test
```
1. Create a directory mkdir api ie ../../../api where the application and files can be stored
2. copy all files to this folder first time.
3. start FAME and compile the 2 .pro files: getfame and functions
4. All users should have (rx) access to files in this folder) If log file stored here users need w access to common log file
5. getfameseries getfameexpr getfamenames need to be in PATH or you need to prefix with the path when executing--
5b.The 3 scripts cannot be renamed, and they are using the name od the script to call fame procedures and name .json files
5c.Test to execute ie getfamenames from a xterm before jupiterlab or other to get better control errormessage
5d.New users may use getfame -n getfame -s and getfame -e indtead of the 3 identical scripts.
6. Explore the directory $HOME/.GetFAME for error messages and output (this will also be listed as part of the execution)
7. When getfamenames works ( need to change FAME paths inside to start Fame ) then you can cp getfamenames getfameexpr and cp getfamenames getfameseries 
```

>[!NOTE]
>Idea: The 3 IDENTICAL scripts ( could/should have been written as one ) each produce a getfameexpr.json, getfamenames.json and getfameseries.json for external programs to have the possibility to read and connect the metadata from getfamenames and getfameseries in one qry /map. The scripts are identical.
>The script getfame can be used instead in attition to the 3 identical scripts, then use getfame -n getfame -s getfame -e


>[!NOTE]
>Use double quotes around parameters when special characters is in use as the parameters ```getfameexpr "mydb.db" "pct(myseries.A)" ``` which is similar to ```getfame -e "mydb.db" "pct(myseries.A)" ```




>[!NOTE]
>Idea: To Use epoch date representation for comparison of timeseries of unequal frequencies and length, and use the json format in python R & not Excel. See sample.py for an starting template using python in jupiterlab and/or R-n-fameexpr.ipynb for a R-sample template.

## The getfame toolbox:
> [!IMPORTANT]
> 1)getfamenames, 2)getfameseries & 3)getfameexpr


### 1. getfamenames :  wildcard/objectname search for famenames -> gets metadata info ( no date param)

```
xterm :   getfamenames $REFERTID/data/fornavn.db  "ERIK"
xterm :   getfamenames $REFERTID/data/fornavn.db  "?ERIK?,JIM,JAN?"
xterm :   getfamenames $REFERTID/data/fornavn.db  "?RIK,KRISTIN,JIM,HE?"
xterm :   getfamenames "/ssb/bruker/refertid/data/kpi_publ.db, /ssb/bruker/refertid/data/fornavn.db"  "?T?I?" | more

jupiterlab :  !ssh sl-fame-1.ssb.no 'getfamenames $REFERTID/data/fornavn.db "?ERIK" '
```
=> sample getfamenames json result:
```
[{"GetFameJsonApi": "ErikS",
"ApiVersion": "20240721",
"Executed": "24-Jul-24 19:09:49",
"Famever": "11.53",
"Database": "/ssb/bruker/refertid/data/fornavn.db",
"Wildcard": "?ERIK?",
"Found": 4,
"Series":[
{"Name":"ERIK","Class":"SERIES","Desc":"Erik Popularitet i prosent","Updated":"16MAY18"},
{"Name":"ERIKA","Class":"SERIES","Desc":"Erika Popularitet i prosent","Updated":"16MAY18"},
{"Name":"FREDERIK","Class":"SERIES","Desc":"Frederik Popularitet i prosent","Updated":"16MAY18"},
{"Name":"JAN_ERIK","Class":"SERIES","Desc":"Jan_erik Popularitet i prosent","Updated":"16MAY18"}
]
}]
```

### 2. getfameseries  -> gets observations for >=1 series/wildcards. No functions.  Convert will use observed settings from FAME definition
```
xterm:      getfameseries /ssb/bruker/refertid/data/kpi_publ.db "total.ipr" 
xterm:      getfameseries /ssb/bruker/refertid/data/kpi_publ.db "total.ipr" "date 2024"
xterm:      getfameseries /ssb/bruker/refertid/data/kpi_publ.db "total.ipr" "freq m; date thisday(m)-5 to *""
xterm:      getfameseries  $REFERTID/data/fornavn.db  "?ERIK,KRISTIN,JIM?}" "date 2010 to 2012"
xterm:      getfameseries /ssb/bruker/refertid/data/fornavn.db "?JAN?" "date 2000 to 2005"
xterm:      getfameseries /ssb/bruker/refertid/data/fornavn.db "JI?" "date 2000 to *; deci 2"
jupiterlab: !ssh sl-fame-1.ssb.no 'getfameseries $REFERTID/data/fornavn.db "ERIK?" "date 2000 to *" '
```
=> sample getfameseries json result:
  ```
[{"GetFameJsonApi": "ErikS",
"ApiVersion": "20240721",
"Executed": "24-Jul-24 19:27:46",
"Famever": "11.53",
"Database": "/ssb/bruker/refertid/data/fornavn.db",
"Series": [  
{"Name": "JILL",
"Desc": "Jill Popularitet i prosent",
"Daterange": "2000 TO *",
"Frequency": "ANNUAL",
"Observations":[
{"Date":"2000-01-01", "Value":0.006154793, "Epo":[946684800000, 0.006154793]},
{"Date":"2001-01-01", "Value":0.00958834, "Epo":[978307200000, 0.00958834]},
{"Date":"2002-01-01", "Value":null, "Epo":[1009843200000, null]},
{"Date":"2003-01-01", "Value":0.01281312, "Epo":[1041379200000, 0.01281312]},
{"Date":"2004-01-01", "Value":0.003196829, "Epo":[1072915200000, 0.003196829]},
{"Date":"2005-01-01", "Value":0.01283326, "Epo":[1104537600000, 0.01283326]},
{"Date":"2006-01-01", "Value":0.006285158, "Epo":[1136073600000, 0.006285158]},
{"Date":"2007-01-01", "Value":null, "Epo":[1167609600000, null]},
{"Date":"2008-01-01", "Value":0.006213496, "Epo":[1199145600000, 0.006213496]},
{"Date":"2009-01-01", "Value":0.003051292, "Epo":[1230768000000, 0.003051292]},
{"Date":"2010-01-01", "Value":0.003093772, "Epo":[1262304000000, 0.003093772]},
{"Date":"2011-01-01", "Value":0.006469979, "Epo":[1293840000000, 0.006469979]},
{"Date":"2012-01-01", "Value":0.003376325, "Epo":[1325376000000, 0.003376325]}
]  }     ,
{"Name": "JIM",
"Desc": "Jim Popularitet i prosent",
"Daterange": "2000 TO *",
"Frequency": "ANNUAL",
"Observations":[
{"Date":"2000-01-01", "Value":0.02642551, "Epo":[946684800000, 0.02642551]},
{"Date":"2001-01-01", "Value":0.02763109, "Epo":[978307200000, 0.02763109]},
{"Date":"2002-01-01", "Value":0.02512405, "Epo":[1009843200000, 0.02512405]},
{"Date":"2003-01-01", "Value":0.03990913, "Epo":[1041379200000, 0.03990913]},
{"Date":"2004-01-01", "Value":0.03663787, "Epo":[1072915200000, 0.03663787]},
{"Date":"2005-01-01", "Value":0.0215504, "Epo":[1104537600000, 0.0215504]},
{"Date":"2006-01-01", "Value":0.0119976, "Epo":[1136073600000, 0.0119976]},
{"Date":"2007-01-01", "Value":0.02411018, "Epo":[1167609600000, 0.02411018]},
{"Date":"2008-01-01", "Value":0.008790693, "Epo":[1199145600000, 0.008790693]},
{"Date":"2009-01-01", "Value":0.02022186, "Epo":[1230768000000, 0.02022186]},
{"Date":"2010-01-01", "Value":0.01475361, "Epo":[1262304000000, 0.01475361]},
{"Date":"2011-01-01", "Value":0.006076072, "Epo":[1293840000000, 0.006076072]},
{"Date":"2012-01-01", "Value":0.003228097, "Epo":[1325376000000, 0.003228097]}
]  }     ] } ]   
```


### 3. getfameexpr:  ->gets observations, series-expression as a result, based on a fame expression. recommended. Full flexibility for converting.
```
xterm:          getfameexpr $REFERTID/data/fornavn.db  "ERIK"
xterm:          getfameexpr $REFERTID/data/fornavn.db  "mave(ERIK,2)" "date 2000 to 2010"
xterm:          getfameexpr $REFERTID/data/fornavn.db  "Lsum(ERIK,EIRIK)" "date 2000 to *"
xterm:          getfameexpr $REFERTID/data/kpi_publ.db "convert(total.ipr,annual,constant)" "date 2020 to *"
--use eof custom common basis to set base-year to 2010 (instead of current 2015:)
xterm:          getfameexpr /ssb/bruker/refertid/data/kpi_publ.db "cb(total.ipr,2010)"   "date 2010 to 2020"   
xterm:          getfameexpr $REFERTID/data/kpi_publ.db "total.ipr" "freq m; date jan20 to feb20;deci 0"
xterm:          getfameexpr $REFERTID/data/fornavn.db  "ERIK+EIRIK" "date 2000 to 2010;deci 1"
jupiterlab :    !ssh sl-fame-1.ssb.no 'getfameexpr $REFERTID/data/fornavn.db "pct(ERIK)" "date 2000 to *" '
```
=> sample getfameexpr json result:
 ```
[{"GetFameJsonApi": "ErikS",
"ApiVersion": "20240721",
"Executed": "24-Jul-24 19:12:00",
"Famever": "11.53",
"Database": "/ssb/bruker/refertid/data/fornavn.db",
"Series": [  
{"Name": "ERIK",
"Desc": "ERIK",
"Daterange": "2000 TO 2010",
"Frequency": "ANNUAL",
"Observations":[
{"Date":"2000-01-01", "Value":0.786893, "Epo":[946684800000, 0.786893]},
{"Date":"2001-01-01", "Value":0.8105121, "Epo":[978307200000, 0.8105121]},
{"Date":"2002-01-01", "Value":0.731738, "Epo":[1009843200000, 0.731738]},
{"Date":"2003-01-01", "Value":0.8473015, "Epo":[1041379200000, 0.8473015]},
{"Date":"2004-01-01", "Value":0.6900131, "Epo":[1072915200000, 0.6900131]},
{"Date":"2005-01-01", "Value":0.7388707, "Epo":[1104537600000, 0.7388707]},
{"Date":"2006-01-01", "Value":0.6718656, "Epo":[1136073600000, 0.6718656]},
{"Date":"2007-01-01", "Value":0.7022091, "Epo":[1167609600000, 0.7022091]},
{"Date":"2008-01-01", "Value":0.6299997, "Epo":[1199145600000, 0.6299997]},
{"Date":"2009-01-01", "Value":0.6326554, "Epo":[1230768000000, 0.6326554]},
{"Date":"2010-01-01", "Value":0.649159, "Epo":[1262304000000, 0.649159]}
]  }     ] } ]   
```
