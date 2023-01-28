'	modos de trabajo
'  0 nulo      : mop_null()
'	1 inmediato : mop_inm()
'	2 directo   : mop_dir()
'	3 indexado  : mop_idx()
'	4 extendido : mop_ext()
'	5 inherente : mop_null()
'	6 relativo  : mop_relb()

' *************************************************************************
'         tratamiento de los diferentes direccionamientos de memoria
' *************************************************************************

Function mop_null() As Integer
  Print "MOP_NULL: Modo de operacion erroneo en ";Hex(PC-1)
  Sleep:End
  Return 0
End Function

' modos inmediatos (8 y 16 bits)
function mop_inmb() As Integer
  v = PC
  PC+=1
  Return v
end Function

Function mop_inmw() As Integer
  v = PC
  PC+=2
  Return v
end Function

' modo directo
Function mop_dir() As Integer
  Return (rDP shl 8) or get_byte()
end Function

' modo indexado
Function mop_idx() As Integer

  Dim dl As Integer
  Dim vtemp As Integer
  
  vc = get_byte()

  'variables rx(X)=0, ry(Y)=1, ru(U)=2, rs(S)=3
  vtemp = ((vc shr 5) And &h3) 

  ' cogemos la variable a tratar segun el caso
  Select Case vtemp
  	Case 0
  		dl=rx
  	Case 1
  		dl=ry
  	Case 2
  		dl=ru
  	Case 3
  		dl=rs
  End Select

 If (vc And &h80)=0 Then 
  	r = dl + nib5(vc) : cicloscpu += 1 : '+-4nib,R
 Else
   Select Case (vc and &h1f)
   	Case &h00 			',R+
	      r = dl
	      dl +=1
	      cicloscpu += 2

   	case &h01,&h11 	',R++
	      r = dl 
	      dl += 2
	      cicloscpu += 3

   	Case &h02 			',-R
	      dl -=1
	      r = dl 
	      cicloscpu += 2

   	case &h03,&h13 	',--R
	      dl -= 2
	      r = dl 
	      cicloscpu += 3

   	case &h04,&h14 	',R
      	r = dl

   	Case &h05,&h15 	'+-B,R
   	   v = rb
   	   If v And &h80 Then v-=&h100
      	r = dl + v 
      	cicloscpu += 1

   	Case &h06,&h16 	'+-A,R
   	   v = ra
   	   If v And &h80 Then v-=&h100
      	r = dl + v
      	cicloscpu += 1

   	Case &h08,&h18 	'+-N7,R
   	   v = get_byte()
   	   If v And &h80 Then v-=&h100
      	r = dl + v
      	cicloscpu += 1

   	Case &h09,&h19 	'+-N15,R
   	   v = get_word()
   	   If v And &h8000 Then v-=&h10000
      	r = dl + v
      	cicloscpu += 4

   	Case &h0b,&h1b 	'+-D,R
   	   v = get_rd()
   	   If v And &h8000 Then v-=&h10000
      	r = dl + v 
      	cicloscpu += 4

   	Case &h0c,&h1c 	'+-N7,PCR
   	   v = get_byte()
   	   If v And &h80 Then v-=&h100
	      r = PC + v
	      cicloscpu += 1

   	Case &h0d,&h1d 	'+-N15,PCR
   	   v = get_word()
   	   If v And &h8000 Then v-=&h10000
      	r = PC + v
      	cicloscpu += 5

   	Case &h1f 			'[N]
      	r = get_word()

   	Case Else
      	Print "IDX: Modo de indexacion equivocado. No podemos continuar.":Sleep:end
   end Select

   if (vc And &h10) then r = peekw(r): cicloscpu += 3 'indireccional
 End If   
 
  ' dejamos la variable tratada con su valor calculado
  Select Case vtemp
  	Case 0
  		rx=dl
  	Case 1
  		ry=dl
  	Case 2
  		ru=dl
  	Case 3
  		rs=dl
  End Select

  return r And &hffff
end Function

' modo extendido
Function mop_ext() As Integer
  Return get_word()
end Function


' modos relativos byte y palabra 
Function mop_relb() As Integer
  vr = get_byte()
  If vr And &h80 Then vr-=&h100
  Return (PC+vr) And &hffff
end Function

Function mop_relw() As Integer
  vr = get_word()
  If vr And &h8000 Then vr -=&h10000
  Return (PC+vr) And &hffff
end Function


' paginas 2 y 3
Sub grupo2()
  vr = get_byte() + &h100
  cicloscpu = opcycles(vr)
  addrmode = addrmod(vr)
  m6809_RunINS(vr)
end Sub

Sub grupo3()
  vr = get_byte() + &h200
  cicloscpu = opcycles(vr)
  addrmode = addrmod(vr)
  m6809_runins(vr)
end Sub


' modos byte y palabra segun direccionamiento
Function get_modob() As Integer

  Select Case addrmode
  	Case 0 
       Return mop_null()
  	Case 1 
       Return mop_inmb() 'And &hffff
  	Case 2
       Return mop_dir() 'And &hffff
  	Case 3 
       Return mop_idx() 'And &hffff
  	Case 4
       Return mop_ext() 'And &hffff
  	Case 5
       Return mop_null() 'And &hffff
  	Case 6
       Return mop_relb() 'And &hffff                                      
  End Select

end Function

function get_modow() As Integer

  Select Case addrmode
  	Case 0 
       Return mop_null()
  	Case 1
       Return mop_inmw() 'And &hffff
  	Case 2 
       Return mop_dir() 'And &hffff
  	Case 3 
       Return mop_idx() 'And &hffff
  	Case 4 
       Return mop_ext() 'And &hffff
  	Case 5 
       Return mop_null() 'And &hffff
  	Case 6  
       Return mop_relw() 'And &hffff                                      
  End Select
  
end Function


'********************************************
'* DIRECCIONAMIENTO PARA LAS INS: EXG Y TFR *
'********************************************
Function Get_VAR(vc As integer) As Integer

  Select case vc
  case 0
    Return Get_rd() ' suma de A*256+B
  case 1
    Return rx 
  case 2
    Return ry 
  case 3
    Return ru 
  case 4
    Return rs 
  case 5
    Return PC 
  case 8
    Return ra 
  case 9
    return rb 
  case 10
    return get_CC() 
  case 11
    return rDP 
  	Case Else
  	 Print "EXG o TFR usa modo desconocido... FIN":Sleep:end
  End Select

end Function

Sub Set_VAR(vc As integer, vr As Integer)

  Select Case vc
  case 0
    set_rd(vr)
  case 1
    rx = vr 
  case 2
    ry = vr 
  case 3
    ru = vr 
  case 4
    rs = vr 
  case 5
    PC = vr 
  case 8
    ra = vr
  case 9
    rb = vr 
  case 10
    set_CC(vr)
  case 11
    rDP = vr
  	Case Else
  	 Print "EXG o TFR usa modo desconocido... FIN":Sleep:end
  End Select

end Sub