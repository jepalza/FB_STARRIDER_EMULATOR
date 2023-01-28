' ****************************************************************************
'                    ****** INSTRUCCIONES GENERALES ********
' ***************************************************************************


Sub nulo()
 Print "NULL: Instruccion desconocida en ";Hex(PC-1);" Dato:";Hex(peekb(PC-1)):Sleep
End Sub



Sub abx
  rx += rb 
  rx = rx And &hffff
end sub  





'+++++++++++++++++++++++++++++++++++++++++++++++++
Function adc8(r2 As integer) As Integer
  vv = peekxb()
  vr = (r2 + vv + ccc) 
  SET_NZVC8(r2,vv,vr) 
  SET_H(r2,vv,vr) 
  adc8 = vr And &hff
End Function                

Sub adca
  ra=adc8(ra) 
end sub  

Sub adcb
  rb=adc8(rb)
end sub  
'++++++++++++++++++++++++++++++++++++++++++++++++++






'+++++++++++++++++++++++++++++++++++++++++++++++++++
Function add8(r2 As integer) As Integer 
  vv = peekxb() 
  vr = (r2 + vv)
  SET_NZVC8(r2,vv,vr) 
  SET_H(r2,vv,vr) 
  add8 = vr And &hff
End Function  

Sub adda
  ra=add8(ra)
end sub  

Sub addb
  rb=add8(rb)
end sub  
'+++++++++++++++++++++++++++++++++++++++++++++++++++++






Sub addd
  vr = peekxw()
  vv = get_rd()
  vd = vv
  vv = (vd + vr)
  SET_NZVC16(vd,vr,vv)
  set_rd(vv)
end sub  




Sub andc
  set_CC(get_CC() And peekxb())
end sub  





'+++++++++++++++++++++++++++++++++++++++++++++++++++++++
function and8(vr As integer) As Integer 
  vr = vr And peekxb()
  SET_NZ8(vr) 
  ccv = 0 
  and8 = vr
end function  

Sub anda
  ra=and8(ra)
end sub  

Sub andb
  rb=and8(rb)
end sub  
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++






'++++++++++++++++++++++++++++++++++++++++++++++++++++++
function asl8(vr As integer) As Integer 
  ccc = cogebit(vr, &h80)
  ccv = ccc Xor (cogebit(vr, &h40))
  vr =(vr Shl 1)
  SET_NZ8(vr) 
  asl8 = vr And &hff
End function  

Sub asla
  ra=asl8(ra)
end sub  

Sub aslb
  rb=asl8(rb)
end sub  

Sub asl
  vd = get_modob
  vt = peekb(vd)
  vv = asl8(vt)
  pokeb(vd, vv) 
End sub  
'++++++++++++++++++++++++++++++++++++++++++++++++++++++





'++++++++++++++++++++++++++++++++++++++++++++++++++++++
Function asr8(vr As integer) As Integer
  ccc = vr And &h01 
  vr = (vr and &h80) or (vr Shr 1) 
  SET_NZ8(vr) 
  asr8 = vr And &hff
End Function  

Sub asra
  ra=asr8(ra)
end sub  

Sub asrb
  rb=asr8(rb)
end sub  

Sub asr
  vd = get_modob
  vt = peekb(vd)
  vv = asr8(vt)
  pokeb(vd, vv)
End sub  
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++






'++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Sub bit8(vr As integer)
  vr = vr And peekxb()
  SET_NZ8(vr) 
  ccv = 0 
End Sub 

Sub bita
  bit8(ra)
end sub  

Sub bitb
  bit8(rb)
end sub  
'++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++







'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
sub clr8()  
  ccn = 0
  ccz = 1 
  ccv = 0
  ccc = 0 
End sub  

Sub clra
  clr8()
  ra=0
end sub  

Sub clrb
  clr8()
  rb=0
end sub  

Sub clr
  vv=get_modob()
  pokeb(vv, 0)
  clr8()
end sub  
'++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++




'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
sub cmp8(r2 As Integer) 
  vv = peekxb() 
  vr = r2 - vv
  SET_NZVC8(r2,vv,vr) 
End sub  

Sub cmpa
  cmp8(ra)
End sub  

Sub cmpb
  cmp8(rb)
end sub  
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++






'++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
sub cmp16(r2 As Integer) 
  vv = peekxw()  
  vr = r2 - vv 
  SET_NZVC16(r2,vv,vr) 
End sub  

Sub cmpd
  cmp16(get_rd)
end sub  

Sub cmps
  cmp16(rs)
end sub  

Sub cmpu
  cmp16(ru)
end sub  
  
Sub cmpx
  cmp16(rx)
end sub  

Sub cmpy
  cmp16(ry)
end sub  
'++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++






'++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Function com8(vr As integer) As Integer
  vr = vr Xor 255
  SET_NZ8(vr) 
  ccv = 0 
  ccc = 1 
  com8 = vr
end Function   

Sub coma
  ra=com8(ra)
End sub  

Sub comb
  rb=com8(rb)
end sub  

Sub com
  vd = get_modob
  vt = peekb(vd)
  vv = com8(vt)
  pokeb(vd, vv)
End sub  
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++






Sub cwai
  set_CC( (get_CC() And get_byte() ) or &h80)
End sub  

Sub daa
  Dim aa As Integer
  Dim bb As Integer
  Dim ee As Integer
  Dim ff As Integer

  ee = 0: ff = 0
  aa = ra  and  &hf0
  bb = ra  and  &h0f
  
  if ((bb > &h09) Or  (cch = 1))   Then ee += &h06 
  if ((aa > &h80) And (bb > &h09)) Then ee += &h60
  if ((aa > &h90) Or  (ccc = 1))   Then ee += &h60 

  ff = (ee + ra)
  SET_NZ8(ff)
  SET_C8(ff)
  ccv = 0
  
  ra = ff And &hff
End sub  





'++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
function dec8(vr As integer) As Integer
  ccv = (vr = &h80) * -1
  vr -= 1 
  SET_NZ8(vr)
  dec8 = vr And &hff
End function 

Sub deca
  ra=dec8(ra)
end sub  

Sub decb
  rb=dec8(rb)
end sub  

Sub dec
  vd = get_modob()
  vt = peekb(vd)
  vv = dec8(vt)
  pokeb(vd, vv)
End sub  
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
' ***************************************************************
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Function inc8(vr As integer) As Integer
  ccv = (vr = &h7f) *-1 
  vr+=1 
  SET_NZ8(vr) 
  inc8 = vr And &hff
end Function 

Sub inca
  ra=inc8(ra)
end sub  

Sub incb
  rb=inc8(rb)
end sub  

Sub inc
  vd = get_modob
  vt = peekb(vd)
  vv = inc8(vt)
  pokeb(vd, vv)
End sub  
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++








'++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Function eor8(vr As integer)  As Integer
  vr = vr Xor peekxb()
  SET_NZ8(vr) 
  ccv = 0 
  eor8 = vr
end Function  

Sub eora
  ra=eor8(ra)
end sub  

Sub eorb
  rb=eor8(rb)
end sub  
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++








Sub exg
  dim dst As Integer
  Dim src As Integer

  vv  = get_byte()  ' "postbyte": byte post-instruccion

  dst = vv and &h0f ' registro destino-final "R2"
  src = vv shr 4    ' registro fuente-inicio "R1"

  vd = Get_VAR(dst) ' variable destino 
  vr = Get_VAR(src) ' variable fuente

  Set_VAR(dst, vr)
  Set_VAR(src, vd)
End sub  







'*****************************************************
Sub jmp
  PC = get_modow()
End sub  

Sub jsr
  vd = get_modow()
  rs -= 2
  rs = rs And &hffff
  pokew(rs, PC)
  PC = vd
End sub  
'*****************************************************







'++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Function ld8() As Integer
  vv = peekxb() 
  SET_NZ8(vv) 
  ccv = 0 
  ld8 = vv And &hff
end Function 

Sub lda
  ra=ld8()
End sub  

Sub ldb
  rb=ld8()
end sub  
'++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++








'++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Function ld16() As Integer
  vv = peekxw() 
  SET_NZ16(vv) 
  ccv = 0 
  ld16 = vv And &hffff
End Function  

Sub ldd
  vr=ld16()
  set_rd(vr)
End sub  

Sub lds
  rs=ld16()
End sub  

Sub ldu
  ru=ld16()
End sub  

Sub ldx
  rx=ld16()
End sub  

Sub ldy
  ry=ld16()
end sub  
'++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++





'++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Sub leas
  rs = get_modow()
End sub  

Sub leau
  ru = get_modow()
End sub  

Sub leax
  rx = get_modow()
  SET_Z16(rx)
End sub  

Sub leay
  ry = get_modow()
  SET_Z16(ry)
End sub  
'++++++++++++++++++++++++++++++++++++++++++++++++++++++++++






'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
function lsr8(vr As integer) As Integer
  ccc = vr and &h01 
  vr = (vr Shr 1)
  SET_Z8(vr) 
  ccn = 0 
  lsr8 = vr And &hff
end Function  

Sub lsra
  ra=lsr8(ra)
end sub  

Sub lsrb
  rb=lsr8(rb)
end sub  

Sub lsr
  vd = get_modob
  vt = peekb(vd)
  vv = lsr8(vt)
  pokeb(vd, vv)
End sub  
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++








Sub mul
  vr = (ra * rb)
  SET_Z16(vr)
  set_rd(vr)
  ccc = cogebit(rb, &h80)
end sub  





'++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Function neg8(vr As integer) As Integer
  vv = (Not vr) +1 
  SET_NZVC8(0,vr,vv) 
  neg8 = vv And &hff
End Function  

Sub nega
  ra=neg8(ra)
end sub  

Sub negb
  rb=neg8(rb)
end sub  

Sub neg
  vd = get_modob
  vt = peekb(vd)
  vv = neg8(vt)
  pokeb(vd, vv)
End sub  
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++






Sub nop
  ' NADA: ;-) que le vamos a hacer
end sub  




'++++++++++++++++++++++++++++++++++++++++++++++
Function or8(vr As integer) As Integer
  vr = vr Or peekxb()
  SET_NZ8(vr)  
  ccv = 0 
  or8 = vr
end Function  

Sub ora
  ra=or8(ra)
end sub  

Sub orb
  rb=or8(rb)
end sub  
'+++++++++++++++++++++++++++++++++++++++++++





Sub orcc
  vr = get_CC()
  vc = peekxb()
  set_CC( vr or vc )
End sub  





'++++++++++++++++++++++++++++++++++++
Sub pshs
  Push( rs, ru, get_byte)
  rs=d1temp
  'ru=d2temp
End sub  

Sub pshu
  Push( ru, rs, get_byte)
  ru=d1temp 
  'rs=d2temp
End sub  

Sub puls
  Pull( rs, ru, get_byte)
  rs=d1temp
  ru=d2temp
End sub  

Sub pulu
  Pull( ru, rs, get_byte)
  ru=d1temp
  rs=d2temp
End sub  
'++++++++++++++++++++++++++++++++++++++++++++++++++++++






'++++++++++++++++++++++++++++++++++++++++++++++
function rol8(vr As integer) As Integer
  vv = ((vr shl 1) or ccc)
  ccc = cogebit(vr, &h80) ' va antes o despues del SHL?? (por ahora funciona bien asi!!)
  ccv = ccc Xor (cogebit(vr, &h40))
  SET_NZ8(vv) 
  rol8 = vv And &hff
End Function 

Sub rola
  ra=rol8(ra)
end sub  

Sub rolb
  rb=rol8(rb)
end sub  

Sub rol
  vd = get_modob
  vt = peekb(vd)
  vv = rol8(vt)
  pokeb(vd, vv)
End sub  
'+++++++++++++++++++++++++++++++++++++++++++++++
'+++++++++++++++++++++++++++++++++++++++++++++++
Function ror8(vr As integer) As Integer
  vv = ( (vr shr 1) or (ccc shl 7) )
  ccc = vr and &h01 
  SET_NZ8(vv) 
  ror8 = vv And &hff
end Function  

Sub rora
  ra=ror8(ra)
end sub  

Sub rorb
  rb=ror8(rb)
end sub  

Sub ror
  vd = get_modob
  vt = peekb(vd)
  vv = ror8(vt)
  pokeb(vd, vv)
End sub  
'++++++++++++++++++++++++++++++++++++++++++++++++






'******************************************
Sub rti

  ' primero, recuperamos el registro CC para ver el estado de CCE (bit "E")
  Pull(rs, ru, &h01)
  rs=d1temp ' solo cogemos RS, no el RU
  
  ' y actuamos en consecuencia
  if cce Then ' caso de IRQ
  	 ' si CCE esta "activo a 1", recuperamos TODO lo demas (incluido RU)
    Pull(rs, ru, &hfe)
    rs=d1temp
    ru=d2temp
    cicloscpu = 15
  Else ' casos FIRQ y NMI
  	 ' si CCE esta "apagado a 0", solo recuperamos el PC (no recuperamos RU, solo RS)
    Pull(rs, ru, &h80)
    rs=d1temp
    cicloscpu = 6
  end if  

end sub  

Sub rts
  PC = peekw(rs)
  rs += 2
end sub  
'********************************************







'+++++++++++++++++++++++++++++++++++++++++++
Function sbc8(r2 As integer) As Integer
  vv = peekxb() 
  vr = (r2 - vv - ccc)
  SET_NZVC8(r2,vv,vr) 
  'SET_H(r2,vv,vr) ' segun el documento oficial, "H" queda indefinido, asi que mejor no tocarlo
  sbc8 = vr And &hff
end Function                

Sub sbca
  ra=sbc8(ra)
end sub  

Sub sbcb
  rb=sbc8(rb)
end sub  
'++++++++++++++++++++++++++++++++++++++++++++






Sub sex
  ' que simple: si bit7 de RB es 1(negativo o CCN=1), RA=255, sino, RA=0
  If (rb And &h80) Then ra=&hff Else ra=&h00
  SET_NZ8(ra)
End sub  







'+++++++++++++++++++++++++++++++++++++++++++
sub st8(vr As Integer)  
  SET_NZ8(vr) 
  ccv = 0 
  vd=get_modob()
  pokeb(vd, vr) 
End sub  

Sub sta
  st8(ra)
end sub  

Sub stb
  st8(rb)
end sub  
'+++++++++++++++++++++++++++++++++++++++++++






'+++++++++++++++++++++++++++++++++++++++++++
sub st16(vr As Integer) 
  SET_NZ16(vr) 
  ccv = 0 
  vd=get_modow()
  pokew(vd, vr)
End sub  

Sub std
  vv = get_rd()
  st16(vv)
end sub  

Sub sts
  st16(rs)
end sub  

Sub stu
  st16(ru)
end sub  

Sub stx
  st16(rx)
end sub  

Sub sty
  st16(ry)
end sub  
'++++++++++++++++++++++++++++++++++++++++++++++++++++++++++






'+++++++++++++++++++++++++++++++++++++++++++++++++++++++
function sub8(r2 As integer) As Integer
  vv = peekxb()
  vr = r2 - vv
  SET_NZVC8(r2,vv,vr) 
  'SET_H(r2,vv,vr) ' segun el documento oficial, "H" queda indefinido, asi que mejor no tocarlo
  sub8 = vr And &hff
End Function

Sub suba
  ra = sub8(ra)
end sub  

Sub subb
  rb = sub8(rb)
end sub  
'++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


Sub subd
  vv = peekxw()
  vd = get_rd() ' tengo dudas, no se si es RD o cualquier registro de 16bits
  vr = vd - vv
  SET_NZVC16(vd,vv,vr)
  vr = vr And &hffff
  set_rd(vr)
end sub  




' *************************************************************+
' interrupciones
' **************
Sub swi
  cce = 1
  Push(rs, ru, &hff)
  rs=d1temp
  cci = 1
  ccf = 1
  PC = peekw(&hfffa)
     ' Print "Interrupcion SWI  fffa : salta -->";PC:Sleep
end sub  

Sub swi2
  cce = 1
  Push(rs, ru, &hff)
  rs=d1temp
  PC = peekw(&hfff4)
     ' Print "Interrupcion SWI2 fff4 : salta -->";PC:Sleep
end sub  

Sub swi3
  cce = 1
  Push(rs, ru, &hff)
  rs=d1temp
  PC = peekw(&hfff2)
     ' Print "Interrupcion SWI3 fff2 : salta -->";PC:sleep
end sub  
' ********************************************************************




Sub syn
  Print "Syn incompleto (falta TODO)....":Sleep
end sub  





Sub tfr
  vt = get_byte()
  Set_VAR(vt and &h0f, Get_VAR(vt Shr 4))
end sub  






'++++++++++++++++++++++++++++++++++++++++++++++++++++++++
sub tst8(vr As Integer) 
  'vr=vr-0 ' es necesario esta resta??? segun el doc. oficial si....mmmmmm, no se....la quitare
  SET_NZ8(vr) 
  ccv = 0 
end sub  

Sub tsta
  tst8(ra)
end sub  

Sub tstb
  tst8(rb)
end sub  

Sub tst
  vt = peekxb()
  tst8(vt)
end sub  
'++++++++++++++++++++++++++++++++++++++++++++++++++++++






'+++++++++++++++++++++++++++++++++++++++++++++++++++++++
'   de aqui al final: saltos condicionales
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++

' ++++++++++++ saltos CCC
Sub bcc
  vd = get_modob()
  if ccc=0 then PC = vd
end sub  

Sub lbcc
  vd = get_modow()
  if ccc=0 Then PC = vd : cicloscpu += 1
End sub  

Sub bcs
  vd = get_modob()
  if ccc then PC = vd
end sub  

Sub lbcs
  vd = get_modow()
  if ccc Then PC = vd : cicloscpu += 1
end sub  



' ++++++++++++ saltos CCZ
Sub beq
  vd = get_modob()
  if ccz Then PC = vd
end sub  

Sub lbeq
  vd = get_modow()
  if ccz Then PC = vd : cicloscpu += 1
End sub  

Sub bne
  vd = get_modob()
  if ccz=0 Then PC = vd
end sub  

Sub lbne
  vd = get_modow()
  if ccz=0 Then PC = vd : cicloscpu += 1
End sub  



' ++++++++++++++ saltos CCN
Sub bmi
  vd = get_modob()
  if ccn Then PC = vd
end sub  

Sub lbmi
  vd = get_modow()
  if ccn Then PC = vd : cicloscpu += 1
End sub  

Sub bpl
  vd = get_modob()
  if ccn=0 Then PC = vd
end sub  

Sub lbpl
  vd = get_modow()
  if ccn=0 Then PC = vd : cicloscpu += 1 
end sub  



' ++++++++++++++  saltos CCV
Sub bvc
  vd = get_modob()
  if ccv=0 Then PC = vd
end sub  

Sub lbvc
  vd = get_modow()
  if ccv=0 Then PC = vd : cicloscpu += 1 
end sub  

Sub bvs
  vd = get_modob()
  if ccv Then PC = vd
end sub  

Sub lbvs
  vd = get_modow()
  if ccv then PC = vd : cicloscpu += 1
End sub  



' ++++++++++++++++ otros saltos
Sub bge
  vd = get_modob()
  if (ccn xor ccv)=0 then PC = vd
end sub  

Sub lbge
  vd = get_modow()
  if (ccn xor ccv)=0 Then PC = vd : cicloscpu += 1
End sub  

Sub bgt
  vd = get_modob()
  if (ccz or (ccn Xor ccv))=0 Then PC = vd
End sub  

Sub lbgt
  vd = get_modow()
  if (ccz or (ccn xor ccv))=0 Then PC = vd: cicloscpu += 1
End sub  

Sub bhi
  vd = get_modob()
  if (ccz Or ccc)=0 Then PC = vd
end sub  

Sub lbhi
  vd = get_modow()
  if (ccz OR ccc)=0  Then PC = vd : cicloscpu += 1
End sub  

Sub ble
  vd = get_modob()
  if (ccz or (ccn xor ccv)) Then PC = vd
end sub  

Sub lble
  vd = get_modow()
  if (ccz or (ccn xor ccv)) Then PC = vd : cicloscpu += 1 
end sub  

Sub bls
  vd = get_modob()
  if (ccc or ccz) Then PC = vd
end sub  

Sub lbls
  vd = get_modow()
  if (ccc or ccz) Then PC = vd : cicloscpu += 1
End sub  

Sub blt
  vd = get_modob()
  if (ccn xor ccv) Then PC = vd
end sub  

Sub lblt
  vd = get_modow()
  if (ccn xor ccv) Then PC = vd : cicloscpu += 1 
end sub  




' ++++++++++++++  saltos IN-condicionales
Sub bra
  PC = get_modob()
end sub  

Sub lbra
  PC = get_modow()
end sub  

Sub brn
  get_modob()
end sub  

Sub lbrn
  get_modow()
end sub  

Sub bsr
  rs -= 2
  pokew(rs, PC+1)
  PC = get_modob()
end sub  

Sub lbsr
  rs -= 2
  pokew(rs, PC+2)
  PC = get_modow()
End sub  
