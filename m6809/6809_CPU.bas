' emulador 6809:
'  registros A,B,DP como 8bits (y suma en D de A*256+B)
'  registros X,Y,U,S como 16bits
'  PC para direccion en curso
'  estados: E-F-H-I-N-Z-V-C (registro CC)
' 
' direcciones ROM de inicio e interrupciones:
'  FFF0-1 -> Reserved by Motorola ...  :o            
'  FFF2-3 -> Instruction interrupt vector (SWI3) 
'  FFF4-5 -> Instruction interrupt vector (SWI2) 
'  FFF6-7 -> Fast hardware int. vector    (FIRQ)   
'  FFF8-9 -> Hardware interrupt vector    (IRQ)    
'  FFFA-B -> Onstruction interrupt vector (SWI)  
'  FFFC-D -> Non-maskable interrupt vector(NMI)
'  FFFE-F -> Reset vector, start program  (RST)  

#Include "6821_PIA.BAS" ' emulador de PIA 6821
#Include "6809_VAR.BAS" ' variables y declaraciones
#Include "6809_TMM.BAS" ' ciclos de ejecucion, modos de memoria y nombres de instrucciones
#Include "6809_MEM.BAS" ' operaciones de memoria
#Include "6809_BIT.BAS" ' operaciones de bits
#Include "6809_DIR.BAS" ' modos de direccionamiento
#Include "6809_INS.BAS" ' instrucciones generales




Function m6809_execute() As Integer
	
  ' variables temporales solo para depuracion, borrar tras el depurado
  Dim AA As Integer
  Dim BB As Integer
  Dim CC As Integer
  Dim DD As Integer
  Dim EE As Integer
  Dim FF As Integer
  Dim XX As Integer
  Dim YY As Integer
  Dim SS As String
  
  ' variables del depurador y desensambladro, borrar tras el depurado
  '&h7c3a= 1 test ld, el de los reset
  '&h8cb4= 2 test LD, el de los cuadros, justo al salir cuando se escribe uno de 5cifras
  '&h7b3b=test sonido 
  '&h19ec=dir parada error LD 

  Static DIR_BREAK As Integer= -1 '&he715 'direccion donde queremos parar (-1 anula)
  Static debug As Integer=0 ' si es 1, se para nada mas iniciarse
  Static DirIni As Integer=&ha000 ' zona de la RAM a visualizar
  Static refresco As Integer=0 ' valor inicial de refresco de pantalla (no tocar aqui)
  Static refresco2 As Integer=10 ' valor inicial de refresco de pantalla (no tocar aqui)

   


	' miramos IRQ's antes de ejecutar nueva INS
	If nmi_act Then 
		m6809_NMI() ' NMI no enmascarable
	End If
	If firq_act Then 
		m6809_firq() ' FIRQ
	End If
	If irq_act Then 
		m6809_irq()  ' IRQ
	End If
	

  vd = get_byte() ' cogemos la instruccion (e incrementamos PC en +1)
  cicloscpu = opcycles(vd) ' se cogen datos de la instruccion a ejecutar
  addrmode = addrmod(vd)
  
  
  
  
  
  ''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
  
  
  
  
'GoTo nodebug
' para acelerar las cosas, si no hay debug=1, no dibujamos NADA (no vemos nada)  
refresco-=1
If refresco <0 Then
	
       'vemos los registros de las PIA's
       m6821_debug(1)
       m6821_debug(2)
       
  refresco=50000
  'If debug=0 Then GoTo nodebug 
  
  M6809_dis(PC-1,1) ' desensamblamos 

  prt 2,1, "CICLOS:"+Str(cicloscpu)+" DIRECCIONAMIENTO:"+Str(addrmode)
 
  prt 3,1,"A: "+Hex(rA,4)+" B: "+Hex(rB,2)+" Dp: "+Hex(rDP,2)
  prt 4,1,"X: "+Hex(rX,4)
  prt 5,1,"Y: "+Hex(rY,4)
  prt 6,1,"U: "+Hex(rU,4)
  prt 7,1,"S: "+Hex(rS,4)
  prt 8,1,"CC:"+Hex(get_CC(),2)
  prt 9,1,"E F H I N Z V C --- PC: "+Hex(PC-1,4)
  prt 10,1,Str(cce)+" "+Str(ccf)+" "+Str(cch)+" "+Str(cci)+" "+Str(ccn)+" "+Str(ccz)+" "+Str(ccv)+" "+Str(ccc)


  'If MultiKey(SC_ESCAPE) Then End  
  
'GoTo nodebug

  'If MultiKey(SC_PAGEDOWN) Then dirini+=256:dirini=dirini And &hffff
  'If MultiKey(SC_PAGEUP  ) Then dirini-=256:dirini=dirini And &hffff
  'AA=1:BB=49
  'Locate 10,20:Print "Direccion RAM:";Hex(dirini);"    "
  'For FF=0+dirini To 1871+dirini -(52*15) ' con la resta, quitamos altura de pantalla, para que vaya mas rapido
  '	Locate AA,BB
  '	 CC=RAM(FF)
  '	 'If ff<&ha000 Then cc=VRAM(ff) 'para ver la VRAM en lugar de la RAM
  '	 If CC<32 Then SS=Chr(CC+32) Else SS=Chr(CC)
  '	 If CC>254 Then SS="." 
  '	 If SS=" " Then SS="_" 
  '	 Print SS;
  '	 BB+=1:If BB=101 Then BB=49:AA+=1
  'Next

' hasta aqui, no se dibuja, mientras DEBUG=0
NODEBUG:
      
' pruebas ver info del expander
'Locate 14,1
'For ff=&ha200 To &ha200+59
'  Print "---";leeRAM(ff);"---"
'next  	

prt 21,1, "pos volante?:"+Str(Hex(leeRAM(&ha106),2)) ' posiblemente la posicion del volante
prt 22,1, "pos video?  :"+Str(Hex(leeRAM(&ha136),2)) ' quizas posicion video segun volante
prt 23,1, "1-0 siempre?:"+Str(Hex(leeRAM(&ha137),2)) ' solo pone 1 o 0 segun volante
prt 24,1, "pos video?  :"+Str(Hex(leeRAM(&ha138),2)) ' quizas posicion video segun volante
    ' por ahora actualizo aqui el video, por lo lento que se vuelve todo
    'MostrarVideo(cuadro):cuadro+=1:Locate 37,1:Print "Cuadros de video:";cuadro
End If

  ' actualizamos la pantalla
  'ptt-=1
  'If ptt <0 Then
    'ptt=10000
    ''''pantalla
    ' debug para guardar las ultimas ins antes de un error
    'Close 1
    'Open "pepe.txt" For Output As 1
    'For ff=&hc000 To &hd000
    '	 If ram(ff)<>255 Then Print #1,Hex(ff),Hex(ram(ff))
    'Next
    'Close 1
  'End If  

'End If

'Print #1,Hex(PC)
'If pc=&he740 Then For ff=&hc000 To &hd000:Print #1,Hex(ff),Hex(ram(ff)):next


  ' para depuracion, borrar tras depurar
  If (PC-1)=dir_break Then debug=1:screencopy
  If MultiKey(SC_F1) Then debug=1
  If MultiKey(SC_F2) Then debug=0
  If debug=1 Then refresco=-1:pantalla:Sleep

   'Open "pepe.txt" For Output As 1
     'Print #1,Hex(PC)
     'Print Hex(PC);".................................."
     'M6809_dis(PC-1,1)
   'Close 1
   
   
   
   
   
   
   
   ''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

	
	' depuracion, grabamos TODOS los bytes ejecutados, para su estudio	
	'Print #1,Hex(PC-1,4),Hex(vd,2)
	
   m6809_RunINS(vd) 

      'If irq<2 Then
   	  'irq+=1
   	  'm6809_firq() ' FIRQ
   	'Else  
   	  'irq=0
   	  'm6809_irq() ' IRQ
      'End If

   
  return cicloscpu

end Function


' funciones de reset, interrupciones y testeo de BIT's
sub m6809_reset()
	
  ra = 0
  rb = 0
  rDP = 0
  	
  rx = 0
  ry = 0
  ru = 0
  rs = 0
  
  set_CC(0)
  
  ' estado de interrupciones IRQ y FIRQ deshabilitados
  ccf = 1
  cci = 1
   
  ' control de IRQ internos del emulador
  firq_act = 0
  irq_act = 0
  nmi_act = 0
  
  PC = peekw(&hfffe) ' rom

End Sub


sub m6809_firq()

  if ccf=0 Then 'CCF=FIRQ
  	 cce = 0  'a cero porque solo guarda PC y CC
    Push(rs, ru, &h81) ' guarda PC y CC
    rs=d1temp
    cci = 1 ' evita nuevas FIRQ y IRQ
    ccf = 1
    PC = peekw(&hfff6) 'rom
    cicloscpu = 12
    firq_act = 0 ' apagamos FIRQ (variable de uso interno del emulador)
  End If

End Sub
  
sub m6809_irq()

  if cci=0 Then 'CCI=IRQ
  	 cce = 1 ' a uno por que guarda todo
    Push(rs, ru, &hff) ' guarda TODOS los registros
    rs=d1temp
    cci = 1 ' evita que se repita una IRQ
    PC = peekw(&hfff8) 'rom
    cicloscpu = 21
    irq_act = 0 ' apagamos IRQ (variable de uso interno del emulador)
  End If

End Sub

sub m6809_NMI()

  	 cce = 1 ' a uno porque guarda todo
    Push(rs, ru, &hff) ' guarda PC y CC
    rs=d1temp
    cci = 1 ' desactiva IRQ
    ccf = 1 ' desactiva FIRQ
    PC = peekw(&hfffc) 'rom
    cicloscpu = 21
 	 nmi_act = 0 ' apagamos NMI (variable de uso interno del emulador)

End Sub

Sub m6809_RunINS(vr As Integer)
	
 Select Case vr
  Case 0,96,112
    neg ()
  Case 3,99,115
    com ()
  Case 4,100,116
    lsr ()
  Case 6,102,118
    ror ()
  Case 7,103,119
    asr ()
  Case 8,104,120
    asl ()
  Case 9,105,121
    rol ()
  Case 10,106,122
    dec ()
  Case 12,108,124
    inc ()
  Case 13,109,125
    tst ()
  Case 14,110,126
    jmp ()
  Case 15,111,127
    clr ()
  Case 16
    grupo2()
  Case 17
    grupo3()
  Case 18
    nop ()
  Case 19
    syn ()
  Case 22
    lbra()
  Case 23
    lbsr()
  Case 25
    daa ()
  Case 26
    orcc()
  Case 28
    andc()
  Case 29
    sex ()
  Case 30
    exg ()
  Case 31
    tfr ()
  Case 32
    bra ()
  Case 33
    brn ()
  Case 34
    bhi ()
  Case 35
    bls ()
  Case 36
    bcc ()
  Case 37
    bcs ()
  Case 38
    bne ()
  Case 39
    beq ()
  Case 40
    bvc ()
  Case 41
    bvs ()
  Case 42
    bpl ()
  Case 43
    bmi ()
  Case 44
    bge ()
  Case 45
    blt ()
  Case 46
    bgt ()
  Case 47
    ble ()
  Case 48
    leax()
  Case 49
    leay()
  Case 50
    leas()
  Case 51
    leau()
  Case 52
    pshs()
  Case 53
    puls()
  Case 54
    pshu()
  Case 55
    pulu()
  Case 57
    rts ()
  Case 58
    abx ()
  Case 59
    rti ()
  Case 60
    cwai()
  Case 61
    mul ()
  Case 63
    swi ()
  Case 64
    nega()
  Case 67
    coma()
  Case 68
    lsra()
  Case 70
    rora()
  Case 71
    asra()
  Case 72
    asla()
  Case 73
    rola()
  Case 74
    deca()
  Case 76
    inca()
  Case 77
    tsta()
  Case 79
    clra()
  Case 80
    negb()
  Case 83
    comb()
  Case 84
    lsrb()
  Case 86
    rorb()
  Case 87
    asrb()
  Case 88
    aslb()
  Case 89
    rolb()
  Case 90
    decb()
  Case 92
    incb()
  Case 93
    tstb()
  Case 95
    clrb()
  Case 128,144,160,176
    suba()
  Case 129,145,161,177
    cmpa()
  Case 130,146,162,178
    sbca()
  Case 131,147,163,179
    subd()
  Case 132,148,164,180
    anda()
  Case 133,149,165,181
    bita()
  Case 134,150,166,182
    lda ()
  Case 136,152,168,184
    eora()
  Case 137,153,169,185
    adca()
  Case 138,154,170,186
    ora ()
  Case 139,155,171,187
    adda()
  Case 140,156,172,188
    cmpx()
  Case 141
    bsr ()
  Case 142,158,174,190
    ldx ()
  Case 151,167,183
    sta ()
  Case 157,173,189
    jsr ()
  Case 159,175,191
    stx ()
  Case 192,208,224,240
    subb()
  Case 193,209,225,241
    cmpb()
  Case 194,210,226,242
    sbcb()
  Case 195,211,227,243
    addd()
  Case 196,212,228,244
    andb()
  Case 197,213,229,245
    bitb()
  Case 198,214,230,246
    ldb ()
  Case 200,216,232,248
    eorb()
  Case 201,217,233,249
    adcb()
  Case 202,218,234,250
    orb ()
  Case 203,219,235,251
    addb()
  Case 204,220,236,252
    ldd ()
  Case 206,222,238,254
    ldu ()
  Case 215,231,247
    stb ()
  Case 221,237,253
    std ()
  Case 223,239,255
    stu ()
  Case 289
    lbrn()
  Case 290
    lbhi()
  Case 291
    lbls()
  Case 292
    lbcc()
  Case 293
    lbcs()
  Case 294
    lbne()
  Case 295
    lbeq()
  Case 296
    lbvc()
  Case 297
    lbvs()
  Case 298
    lbpl()
  Case 299
    lbmi()
  Case 300
    lbge()
  Case 301
    lblt()
  Case 302
    lbgt()
  Case 303
    lble()
  Case 319
    swi2()
  Case 387,403,419,435
    cmpd()
  Case 396,412,428,444
    cmpy()
  Case 398,414,430,446
    ldy ()
  Case 415,431,447
    sty ()
  Case 462,478,494,510
    lds ()
  Case 479,495,511
    sts ()
  Case 575
    swi3()
  Case 643,659,675,684,691,700
    cmpu()
  Case 652,668
    cmps()
  Case else
    nulo()
 End Select
 
End Sub

