
--------------------------------------------------------------------------
--not needed !! only to demonstrate use of custom functions
--common basis is nais.
--erik eriksoeb@gmail.com
-------------------------------------------------------------------------


--------------------------------------------
--sadjust
---------------------------------------------
function sadjust 
argument mserie
glue dot
over on
keep seas
adjust mserie
return id(mserie&seas) 
end function


--------------------------------------------
--Lsub
---------------------------------------------
function lsub 
argument mserie1 , mserie2
return (mserie1 - mserie2)
end function



--------------------------------------------
--shiftyr_1 setter fjorået til i år.
---------------------------------------------
function shiftyr_1
argument mserie
return (shiftyr(mserie,-1))
end function

---------------------------------------------------
--shiftyr_ytypct1 setter fjorået ytypct  til i år.
---------------------------------------------------
function shiftyr_ytypct1
argument mserie
return (shiftyr(ytypct(mserie),-1))
end function


--------------------------------------------
--mave_pct_3 3 periods moving average of pct
---------------------------------------------
function mave_pct_3
argument mserie
return (mave(pct(mserie),3))
end function



---------------------------------------------
--mavec_3  periods moving cumulativeaverage
---------------------------------------------
function mavec_3
argument mserie
return (mavec(mserie,3))
end function


-------------------------------------------
--mave_3  periods moving average
-------------------------------------------
function mave_3
argument mserie
return (mave(mserie,3))
end function



-------------------------------
--commonbasis puts a year = 100
-------------------------------
FUNCTION $cb
argument mserie
BLOCK
over on
date myfame_basis
local scalar mf.bas: numeric = ave(mserie)
date *
return ((mserie / mf.bas ) * 100   )
END BLOCK
END FUNCTION


-------------------------------
--cb puts a year = 100
-------------------------------
FUNCTION cb
argument mserie, myfame_basis
BLOCK
over on
date myfame_basis
local scalar mf.bas: numeric = ave(mserie)
END BLOCK
return ((mserie / mf.bas ) * 100   )
END FUNCTION



