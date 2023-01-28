
Declare Sub LeeROM(nombre As String, zona As Integer)
Declare Sub LeePROM(nombre As String)
Declare Sub LeeNVRAM(nombre As String)

Declare Sub pantalla()
'Declare Sub Blitter_pixel(direccion As Integer, valor As Integer, dato As Integer, mascara As Integer, solido As Integer)
'Declare Sub Blitter(n As byte) ' puede emular dos blitter, 0 y 1
Declare Sub modulo_PIF(puerto As integer) ' modulo de control del LaserDisc mediante PIA desde la CPU principal
Declare Sub botones() ' mandos del juego e interruptores de configuracion

Declare Sub BancoROM(nbanco As Integer,zonaram As Integer)
Declare Sub BancoRAM(nbanco As Integer,zonaram As integer)

' ******************************************************************
' llamada a modulo desensamblador, ocultar una vez depurado
  Declare Sub M6809_DIS(direccion As integer, longitud As Integer)
' ******************************************************************







' para imprimir en la consola DOS y ganar velocidad y espacio en la grafica
#Include "console_print.bi"
Declare Sub prt Overload (x As Integer, y As Integer, s As String)
Declare Sub prt Overload (x As Integer, y As Integer, s As Integer)
Sub prt (x As Integer, y As Integer, s As String)
	dim conprint as tagConPrintObject ptr = new tagConPrintObject
	conprint->ConsoleLocate(x-1,y-1)
   conprint->ConsolePrint s
End Sub
Sub prt (x As Integer, y As Integer, s As Integer)
	dim conprint as tagConPrintObject ptr = new tagConPrintObject
	conprint->ConsoleLocate(x-1,y-1)
   conprint->ConsolePrint str(s)+"  " 
End Sub










' intercambios de bancos: lo que hago es copiar el solicitado dentro del general
' se podria hacer mas rápido seleccionandolo sin mas, pero la emulacion de la RAM queda peor
Sub BancoROM(nbanco As Integer,zonaram As integer)
	
	Dim f As Integer
	Dim tambanco as integer=16384 ' tamaño del banco a trasferir
	
	'If nbanco>3 Then tambanco=8192 ' si son los dos ultimos, son de 8k, en lugar de 16k
	'If nbanco>63 Then Print "Error en bancos de ROM":Sleep:End
	For f=0 To tambanco-1
		RAM(f+zonaram)=BROM(nbanco,f)
	Next
	' la zona de RAM desde la FFFF es para los graficos, descontando &H10000
	
End Sub


' en el caso del banqueo de RAM la cosa es mas lenta aun, ya que primero
' debemos dejar en su sitio la original, antes de mover nada....
Sub BancoRAM(nbanco As Integer,zonaram As integer)
	
	'Var f=0

	'For f=0 To &h2000-1
	'	RAM(f+zonaram)=BRAM(nbanco,f)
	'Next
	
End Sub


' su nombre lo dice: lee un archivo de ROM en su banco correspondiente
Sub LeeROM(nombre As String,zona As Integer)
   ' leemos la BIOS (ROM) de un Monitor de 6809 (que incluye FORTH en 8000 y BASIC en B800)
	dim as integer ini=1 ' posiciones en el fichero a leer
	dim as integer rom=0 ' posiciones en ROM
	dim as integer contador=0 ' contador de la linea leida del fichero
	dim linea as string
	linea="                " ' leemos 16 caracteres de golpe
	
	Open nombre For Binary Access read As 1
	dim as integer inirom=Lof(1)
	While Not Eof(1)
		Get #1,ini,linea
		For contador=1 To Len(linea)
			BROM(zona,rom)=Asc(Mid(linea,contador,1))
			rom+=1
		Next
		ini+=len(linea)
	Wend
	Close 1
	
End Sub


' NVRAM CMOS (contenido de configuracion mediante BATERIA)
Sub LeeNVRAM(nombre As String)
   ' leemos la BIOS (ROM) de un Monitor de 6809 (que incluye FORTH en 8000 y BASIC en B800)
	dim as integer ini=1 ' posiciones en el fichero a leer
	dim as integer posicion=0 ' posiciones en ROM
	dim as integer contador=0 ' contador de la linea leida del fichero
	dim linea as string
	linea="                " ' leemos 16 caracteres de golpe
	
	Open nombre For Binary Access read As 1
	dim as integer inirom=Lof(1)
	While Not Eof(1)
		Get #1,ini,linea
		For contador=1 To Len(linea)
			NVRAM(posicion)=Asc(Mid(linea,contador,1))
			posicion+=1
		Next
		ini+=len(linea)
	Wend
	Close 1
End Sub



' PROM de mapeo de colores
Sub LeePROM(nombre As String)
   ' leemos la BIOS (ROM) de un Monitor de 6809 (que incluye FORTH en 8000 y BASIC en B800)
	dim as integer ini=1 ' posiciones en el fichero a leer
	dim as integer posicion=0 ' posiciones en ROM
	dim as integer contador=0 ' contador de la linea leida del fichero
	dim linea as string
	linea="                " ' leemos 16 caracteres de golpe
	
	Open nombre For Binary Access read As 1
	dim as integer inirom=Lof(1)
	While Not Eof(1)
		Get #1,ini,linea
		For contador=1 To Len(linea)
			PROM(posicion)=Asc(Mid(linea,contador,1))
			posicion+=1
		Next
		ini+=len(linea)
	Wend
	Close 1
	
End Sub












' emulacion del modulo PIF, el que controla el LaserDisc de Pioneer
Sub modulo_PIF(puerto As integer)
	' El Modulo PIF lleva su propia CPU6809 y por ende ROM y RAM
	' ademas de una PIA, que va conectada a la PIA principal que va en el modulo EXPANDER.
	' La PIA del modulo expander la controla la CPU principal, mediante los puertos:
	' CB80-1 --> modulo EXPANSOR, FONDO y DESPLAZAMIENTO HORIZONTAL
	' CB82-3 --> modulo PIF

	'Static prueba1 As UByte=0
	'Static prueba2 As UByte=0
	'Dim datoA As Integer
	'Dim datoB As integer
	
	'anulado por ahora
	'Exit Sub
	
	'Locate 35,1:Print "BUS-A PIA:";M6821_PA(2)
	'Locate 36,1:Print "BUS-B PIA:";M6821_PB(2)
	
	'If puerto=&hCB80 Then M6821_PA(2)=Int(Rnd(1)*256)
	'If puerto=&hCB82 Then M6821_PB(2)=Int(Rnd(1)*256)
		
	'M6821_PA(2)=prueba1
	'M6821_PB(2)=prueba1
	'm6821_CA2(2)=prueba2
	'm6821_CB2(2)=prueba2
	
	'If M6821_PB(2)=2 Then
	'	CA2(2)=1 'prueba2
	'	CB2(2)=1 'prueba2
	'Else
	'	CA2(2)=0 'prueba2
	'	CB2(2)=0 'prueba2
	'End If
	
	' trampas en la PIA 2
	'M6821_CA1(2)=1 ' si no tenemos activa esta linea (HALT_CPU) va lento
	'm6821_cb1(2)=1 ' si no tenemos activa esta linea (LD_ACTIVO) no arranca el LD
	'CA2(2)=1
	'CB2(2)=1
	'prueba1+=1
	'prueba2+=1
	'If prueba2=2 Then prueba2=0

	'If M6821_PA(2)<>-1 Then datoA=M6821_PA(2)': M6821_PA(2)=-1
	'If M6821_PB(2)<>-1 Then datoB=M6821_PB(2)': M6821_PB(2)=-1
	'datoB=ODB(2)
	'If datoB<>prueba1 Then Print #1,datoB:prueba1=datoB:cuadro=0
	' cuadro=0 por ahora es una trampa para arrancar el video hasta que sepa como lo hace el solo
	'If m6821_IRQA(2)=1 Then m6809_firq():m6821_IRQA(2)=0:m6821_CA1(2)=1:m6821_CA2(2)=0  ' IRQ generada por el modulo PIF
	'If m6821_IRQB(2)=1 Then m6809_irq() :m6821_IRQB(2)=0:m6821_CB1(2)=1:m6821_CB2(2)=0  ' IRQ generada por el modulo EXPANDER
	
End Sub








Sub botones()
	Dim PV As UByte=0
	'dim conprint as tagConPrintObject ptr = new tagConPrintObject
	Static As Byte AUTO=0 ' estado del interruptor AUTO-UP/MANUAL-DOWN
	
	' Puerto C980
	' "DIP SWITCH" interruptores de configuracion
	' para entrar en el STATUS o en la CONFIG, pulsamos MANUAL-DOWN dentro del juego
	' para entrar en los TESTs, primero en modo MANUAL-DOWN , pulsamos ADVANCE dentro del juego
	' sale el TEST de ROMS, al acabar, sea cual sea el resultado, pulsamos AUTO-UP y entramos en TEST
	' nota, el test de ROMS por segunda vez DA ERROR por que hemos trampeado direcciones antes
	
	' las teclas estan dispuestas asi, para dar continuidad a los 8bits seguidos del 0 al 7
	' pero solo son importantes la "Q", la "W" y la "3", el resto, no he visto que tengan utilidad
	PV=DIPSWT '254 'Xor 2
	' ----------------- TECLAS al SOLTAR
	If Not(MultiKey(SC_W)) Then PV=BitReset(PV,1) ' ADVANCE, avanzar en los TEST o en la configuracion
	If Not(MultiKey(SC_E)) Then PV=BitReset(PV,2) ' SCORE RESET
	'
	If Not(MultiKey(SC_3)) Then PV=BitReset(PV,3) ' LEFT COIN 	
	If Not(MultiKey(SC_4)) Then PV=BitReset(PV,4) ' CENTER COIN
	If Not(MultiKey(SC_5)) Then PV=BitReset(PV,5) ' RIGTH COIN
	'
	If Not(MultiKey(SC_R)) Then PV=BitReset(PV,6) ' SLAM TILT (FALTA)
	If Not(MultiKey(SC_T)) Then PV=BitReset(PV,7) ' MEM PROT (protege RAM)	     
	' ----------------- TECLAS PULSADAS
	If MultiKey(SC_W) Then PV=BitSet(PV,1) ' ADVANCE, avanzar en los TEST o en la configuracion
	If MultiKey(SC_E) Then PV=BitSet(PV,2) ' SCORE RESET
	'
	If MultiKey(SC_3) Then PV=BitSet(PV,3) ' LEFT COIN 	
	If MultiKey(SC_4) Then PV=BitSet(PV,4) ' CENTER COIN
	If MultiKey(SC_5) Then PV=BitSet(PV,5) ' RIGHT COIN
	'
	If MultiKey(SC_R) Then PV=BitSet(PV,6) ' SLAM TILT (FALTA)
	If MultiKey(SC_T) Then PV=BitSet(PV,7) ' MEM PROT (protege RAM)
	
	' AUTO-UP/MANUAL-DOWN es un INTERRUPTOR, o sea, que o esta a un lado, o a al otro, no sirve pulsarlo
	If Not(MultiKey(SC_Q)) Then 
		AUTO=0
	else
		If MultiKey(SC_Q) And AUTO=0 Then 
			AUTO=1
			PV=IIf(Bit(DIPSWT,0),BitReset(PV,0),BitSet(PV,0)) ' AUTO-UP, entrar en modo test/configuracion
		EndIf
	End If

	
	DIPSWT=PV

	
	
	
	
	' Puerto C984	
	' "STEER" : direccion y "START"
	PV=control1 
	' la direccion sigue el patron llamado "black binary" (https://en.wikipedia.org/wiki/Gray_code)
	' y en el caso del StarRider va de 0 a 63, siendo 0 el lado izquierdo, 48 el centro y 63 el derecho
	' en valores binarios, el centro es 110000 (32+16) el izq. 000001 (1) y el der. 100000 (32)
	If MultiKey(SC_LEFT ) Then Steer-=.5
	If MultiKey(SC_RIGHT) Then Steer+=.5
	' volvemos al centro (32) si soltamos manillar
	If Not(MultiKey(SC_LEFT)) And Not (MultiKey(SC_RIGHT)) Then 
		If Steer<32 Then Steer+=.5
		If Steer>32 Then Steer-=.5
	EndIf
	If steer>63 Then steer=63
	If steer< 0 Then steer=0	
	' convertimos de binario estandar a binario "gray_code" (wikipedia binary To Gray "return num ^ (num >> 1);")
	PV=(PV And &b11000000)+(Steer xor (Steer shr 1)) 
	'
	If Not(MultiKey(SC_1)) Then PV=PV Or  &b01000000
	If MultiKey(SC_1) 	  Then PV=PV and &b10111111 ' PLAYER 1 START
	'
	If Not(MultiKey(SC_2)) Then PV=PV Or  &b10000000	
	If MultiKey(SC_2) 	  Then PV=PV And &b01111111 ' PLAYER 2 START   
	control1=PV
	     	
	     	
	     	
	     	
	
	' Puerto C986     	
	' "POWER" :acelerador, ademas de "BRAKES" (2) y "TURBO"
	PV=control2
	If Not(MultiKey(SC_UP))  Then Accel-=.5 
	If MultiKey(SC_UP)	    Then Accel+=.5 ' acelerador (4 puntos)   
	If accel>16 Then Accel=16
	If Accel< 0 Then accel=0	
	' convertimos de binario estandar a binario "gray_code" (wikipedia binary To Gray "return num ^ (num >> 1);")
	PV=(PV And &b11110000)+(accel xor (accel shr 1)) 
	'
	If Not(MultiKey(SC_DOWN))Then PV=PV Or  &b00110000	
	If MultiKey(SC_DOWN)	    Then PV=PV And &b11001111 ' frenos (2 puntos)
	'
	If Not(MultiKey(SC_Z))   Then PV=PV Or  &b01000000
	If MultiKey(SC_Z)		    Then PV=PV And &b10111111 ' turbo 
	'
	If Not(MultiKey(SC_X))   Then PV=PV Or  &b10000000
	If MultiKey(SC_X) 		 Then PV=PV and &b01111111 ' gear HI/LOW
	control2=PV

	
End Sub
