
1. getfame -n :  wildcard search serienames


xterm :     sl-fame-1:~> $REFERTID/system/myfame/api/getfame -s REFERTID/data/fornavn.db  "ERIK"
xterm :     sl-fame-1:~> $REFERTID/system/myfame/api/getfame -s $REFERTID/data/fornavn.db  "?ERIK?,JIM,JAN?"
xterm :     sl-fame-1:~> $REFERTID/system/myfame/api/getfame -s $REFERTID/data/fornavn.db  "?RIK,KRIS|TIN,JIM.HE?"
jupiterlab :  !ssh sl-fame-1.ssb.no '$REFERTID/system/myfame/API/getfame -n $REFERTID/data/fornavn.db "?ERIK" '

[{"GetFameJsonApi": "ErikS",
"ApiVersion": "20240721",
"Executed": "24-Jul-25 19:09:49",
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




2. getfame -e :  (gets one series-expression as a result, based on a fame expression. recommended. last argument not required. Full flexibility for converting

sl-fame-1:~> $REFERTID/system/myfame/api/getfame -e $REFERTID/data/fornavn.db  "ERIK"
sl-fame-1:~> $REFERTID/system/myfame/api/getfame -e $REFERTID/data/fornavn.db  "mave(ERIK,2)" "date 2000 to 2010; deci 1"
jupiterlab :  !ssh sl-fame-1.ssb.no '$REFERTID/system/myfame/API/getfame -e $REFERTID/data/fornavn.db "pct(ERIK)" "date 2000 to *" '
sl-fame-1:~> $REFERTID/system/myfame/api/getfame -e $REFERTID/data/fornavn.db  "Lsum(ERIK,EIRIK)" "date 2000 to *"
sl-fame-1:~> $REFERTID/system/myfame/api/getfame -e $REFERTID/data/kpi_publ.db "convert(total.ipr,annual,constant)" "date 2020 to *"
sl-fame-1:~> $REFERTID/system/myfame/api/getfame -e $REFERTID/data/kpi_publ.db "total.ipr" "freq m; date jan20 to feb20;deci 2"
sl-fame-1:~> $REFERTID/system/myfame/api/getfame -e $REFERTID/data/fornavn.db  "ERIK" "date 2000 to 2010"

[{"GetFameJsonApi": "ErikS",
"ApiVersion": "20240721",
"Executed": "24-Jul-25 19:12:00",
"Famever": "11.53",
"Database": "/ssb/bruker/refertid/data/fornavn.db",
"Series": [  
{"Name": "ERIK",
"Desc": "ERIK",
"Daterange": "2005 TO 2010",
"Frequency": "ANNUAL",
"Observations":[
{"Date":"2005-01-01", "Value":0.7388707, "Epo":[1104537600000, 0.7388707]},
{"Date":"2006-01-01", "Value":0.6718656, "Epo":[1136073600000, 0.6718656]},
{"Date":"2007-01-01", "Value":0.7022091, "Epo":[1167609600000, 0.7022091]},
{"Date":"2008-01-01", "Value":0.6299997, "Epo":[1199145600000, 0.6299997]},
{"Date":"2009-01-01", "Value":0.6326554, "Epo":[1230768000000, 0.6326554]},
{"Date":"2010-01-01", "Value":0.649159, "Epo":[1262304000000, 0.649159]}
]  }     ] } ]   



3. getfame -s  ( 1 or more series ,list of wildcards, but no functions )  last argument not required. Convert will use observed from fame

xterm: sl-fame-1:~> $REFERTID/system/myfame/api/getfame -s /ssb/bruker/refertid/data/kpi_publ.db "total.ipr" 
xterm: sl-fame-1:~> $REFERTID/system/myfame/api/getfame -s /ssb/bruker/refertid/data/kpi_publ.db "total.ipr" "date 2024;deci 1"
xterm: sl-fame-1:~> $REFERTID/system/myfame/api/getfame -s /ssb/bruker/refertid/data/kpi_publ.db "total.ipr" "freq m; date thisday(m)-5 to *""
xterm: sl-fame-1:~> $REFERTID/system/myfame/api/getfame -s  $REFERTID/data/fornavn.db  "?ERIK,KRISTIN,JIM.HE?" "date 2010 to 2012"
xterm: sl-fame-1:~> $REFERTID/system/myfame/api/getfame -s /ssb/bruker/refertid/data/fornavn.db "?JAN?" "date 2000 to 2005"
xterm: sl-fame-1:~> $REFERTID/system/myfame/api/getfame -s /ssb/bruker/refertid/data/fornavn.db "JI?" "date 2000 to *"
jupiterlab :  !ssh sl-fame-1.ssb.no '$REFERTID/system/myfame/API/getfame -s $REFERTID/data/fornavn.db "ERIK?" "date 2000 to *" '

[{"GetFameJsonApi": "ErikS",
"ApiVersion": "20240721",
"Executed": "24-Jul-24 19:27:46",
"Famever": "11.53",
"Database": "/ssb/bruker/refertid/data/fornavn.db",
"Series": [  
{"Name": "JILL",
"Desc": "Jill Popularitet i prosent",
"Daterange": "2004 TO *",
"Frequency": "ANNUAL",
"Observations":[
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
"Daterange": "2004 TO *",
"Frequency": "ANNUAL",
"Observations":[
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

 

