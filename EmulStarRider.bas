' emulador de StarRider de Williams (LaserDisc) , por Joseba Epalza
' jepalza@gmail.com, www.ingepal.es/com, 1997-2015

'*******************************************************************************************************
' ********************* IIIIIIMMMMMMPPPPPPOOOOOORRRRRTTTTTTAAAAANNNNNNNTTTTTEEEEEEEE *******************
' cambios necesarios para compilar en FB-1.0 en adelante (Dic-2015):
' estas cuatro lineas DEBEMOS anularlas en el fichero "fb\INC\WIN\VFW.BI" al final del todo
' por que dan error, y en mi modulo de video "LASERDISC.BAS" no se usa
'   declare function GetOpenFileNamePreviewA(byval lpofn as LPOPENFILENAMEA) as WINBOOL
'   declare function GetSaveFileNamePreviewA(byval lpofn as LPOPENFILENAMEA) as WINBOOL
'   declare function GetOpenFileNamePreviewW(byval lpofn as LPOPENFILENAMEW) as WINBOOL
'   declare function GetSaveFileNamePreviewW(byval lpofn as LPOPENFILENAMEW) as WINBOOL
' en MAYO-2017 hay dos nuevas lineas a eliminar: ver el fichero LASERDISC.BAS para detalles
'*******************************************************************************************************

Dim Shared As Integer depuracion=0 	' si es "1" , quito la mascara frontal
												' muestro los colores y datos del juego
												' y registros de la CPU


' necesario para el MULTIKEY
' ademas, si usamos compilacion FB, se necesita el "USING FB"
#include "fbgfx.bi"
#if __FB_LANG__ = "fb"
Using FB 
#EndIf


#include "windows.bi"
#Include "variables.bas"
#Include "rutinas.bas"
#Include "graficos.bas"
#Include "LaserDisc.bas"' emulador de Laser Disc (lectura de AVI XVID)
#Include "m6809\6809_CPU.bas" ' --> este a su vez, incluye TODOS los modulos del 6809
#Include "m6809\6809_DIS.bas" ' incluimos el modulo desensamblador, quitar en la version final


ScreenRes resx,resy,32,2
ScreenSet 1,0 ' establece la 1 de trabajo, y la 0 visible


' leemos las ROMS de la CPU en su banco correspondiente
	LeeROM("roms/R30U8.CPU" ,3) ' 3=0000-3FFF:16k paginados con la U15
	LeeROM("roms/R31U15.CPU",4) ' 4=0000-3FFF:16k paginados con la U8
	LeeROM("roms/R32U26.CPU",5) ' 5=4000-7FFF:16k paginados con una ROM inexistente (vacia en la placa)
  'LeeROM("roms/xxxx37.CPU",5) ' 6=4000-7FFF:16k paginados con la U26, pero VACIO, no existe EPROM real
	LeeROM("roms/R34U45.CPU",7) ' 7=8000-9FFF:8k
	                            '   A000-BFFF:RAM 8k ,C000-C7FF: COLORES, C800-CFFF: I/O ,D000-DFFF:RAM 4k
	LeeROM("roms/R35U52.CPU",8) ' 8=E000-FFFF:8k : principal (inicio)

' 16k : graficos generales	
   ' fila "par"
	LeeROM("roms/R1U4.ROM  ",09)
	LeeROM("roms/R3U5.ROM  ",10)
	LeeROM("roms/R5U6.ROM  ",11)
	LeeROM("roms/R7U7.ROM  ",12)
	LeeROM("roms/R9U8.ROM  ",13)
	LeeROM("roms/R11U9.ROM ",14)
	LeeROM("roms/R13U10.ROM",15) 	
	LeeROM("roms/R15U11.ROM",16) 
	LeeROM("roms/R17U12.ROM",17)
	LeeROM("roms/R19U13.ROM",18) 
	' fila "impar"	
	LeeROM("roms/R2U19.ROM ",19)
	LeeROM("roms/R4U20.ROM ",20)
	LeeROM("roms/R6U21.ROM ",21)
	LeeROM("roms/R8U22.ROM ",22)
	LeeROM("roms/R10U23.ROM",23)
	LeeROM("roms/R12U24.ROM",24)
	LeeROM("roms/R14U25.ROM",25)
	LeeROM("roms/R16U26.ROM",26)
	LeeROM("roms/R18U27.ROM",27)
	'LeeROM("roms/R25U46.ROM",28)

' 8k : graficos de textos	
	LeeROM("roms/R25U46.ROM",33) ' esta debe ir aqui (&H21=33d) por la forma de paginacion  

' PIF: Processor Interface Board
' anulado, hasta saber como va: de momento, lleva su propia CPU
	'LeeROM("roms/R26U3.ROM ",49)

' SND: Sound Board
' anulado, hasta saber como va: de momento, lleva su propia CPU
	'LeeROM("roms/R27U11.ROM",50)

		
' PROMS de mapeo de colores, Consiste en 64 bancos de 16 colores cada uno
' son DOS PROM identicas, la U10 y la U11, para emplear cada una en 4bits, total 4+4=8bits
' pero yo solo uso una, y duplico luego, puesto que son IDENTICAS
	LeePROM("roms/u10.82s137")

' Lee la NVRAM CMOS 
	LeeNVRAM("NVRAM.BIN")
			

' ponemos el banco principal, el 5, en su sitio
' y de paso, los que creo que van paginados
	BancoROM(3,&h0000)
	BancoROM(5,&h4000)
	BancoROM(7,&h8000)
	BancoROM(8,&hE000)

' lo mismo para la ROM de graficos de TEXTO
	BancoROM(33,&h1C000) 

' inicio de la emulacion
	m6809_reset()

' para sacar datos, en un principio, no sale nada, es solo "porsi"
'Open "salida.txt" For Output As 1

' abrimos el video, solo si VIDEO=1. si da error, VIDEO devuelve "0" y lo desactiva
If video Then 
	video=AbrirVideo("..\VIDEO\StarRider_Xvid.avi")
	'video=AbrirVideo("..\LaserDisc\cinepak.avi") ' usando el video en formato CINEPAK de 1gb, NO NECESITA CODECS
	If video=0 Then Print "Error en lectura de VIDEO.(no existe o no es VFW XVID 1.3.3)"' ha dado error, cancelamos video
EndIf
If video=0 Then Print:Print "EJECUCION SIN VIDEO: Pulsa una tecla para seguir sin video.":ScreenCopy:sleep 

cuadro=0
desplaza_video=-380 ' empieza centrado (-100 es para la forma actual)

op_mhz = 1000000 ' 1 mhz ??
cycles_per_interrupt = op_mhz/60 ' 60hz de pantalla, nos da el periodo de interrupciones de 16666 opcycles

Dim temp_double As Double
Dim opcycles_to_irq As Integer ' contador de ciclos hasta generar irq
Dim papa As Integer
opcycles_to_irq = cycles_per_interrupt
papa=cycles_per_interrupt/256
tiempo_real=Timer()

' carga el frontal de la maquina real
Dim frontal As Any Ptr = ImageCreate( 640, 520, RGB(255, 0, 255)  )
If depuracion=0 Then ' solo muestro el frontal si es "0"
	BLoad "frontal/frontal.bmp", frontal
	Put (0,0), frontal
End If



''' -----------------------------------------------------------------------------------------------
'Open "pp.txt" For Output As 1 ' salida de datos depuracion

' bucle infinito de ejecuciones: solo sale con "ESC"
While 1 
  
  While Inkey <> "": Wend ' necesario para vaciar las teclas pulsadas por multikey
  
  ' ejecutamos el M6809, una instruccion cada vez y sumamos los ciclos empleados
  'tiempo_real=Timer()
  ciclos_ejecutados = m6809_execute() 
  'tiempo_consumido=Timer()-tiempo_real
  ciclos_totales += ciclos_ejecutados
  opcycles_to_irq -= ciclos_ejecutados

'Locate 10,10:Print Int((cycles_per_interrupt/256)),opcycles_to_irq,(opcycles_to_irq Mod Int((cycles_per_interrupt/256))):screencopy

	'control_vertical=0
  papa-=1
  If papa<0 Then 
  	papa=cycles_per_interrupt/256
		 	control_vertical-=1
		 	If control_vertical Mod 8=0 Then RAM(&hC900)=&h15 Else RAM(&hC900)=0 ' "Wathcdog" cada 7 cuadros
			If control_vertical<0 Then 
				control_vertical=255
				actualizar_pantalla=1
		 		irq_act=1 ' en cada barrido de pantalla llamamos a IRQ
		 		'pantalla()
			EndIf
  EndIf
   	
  ' a 1mhz de velocidad de CPU M6809 real, se ejecutan 1millon de ciclos por segundo
  ' por eso, debemos comprobar el tiempo que ha tardado la emulacion en nuestro PC
  ' y sumar o restar hasta llegar a la misma velovidad
  'temp_double=1/(cycles_per_interrupt/ciclos_ejecutados)
  'If temp_double > tiempo_consumido Then 
  
  
   ' en STAR RIDER tenemos IRQ en la E3DB, este se ejecuta en cada barrido VSYNC (al final de la linea)
   ' y FIRQ en EAE1 se ejecuta cada vez que salta al BLITTER??
   ' el inicio y la NMI son iguales, en la E003 (la NMI no se usa)


   ' se ejecutan acciones HARDWARE cada 'x' ciclos
   If (opcycles_to_irq <0) Then ' 1.1 mhz 
		'screenlock
   	opcycles_to_irq+=cycles_per_interrupt ' ajustamos ciclos sobrantes
   	'irq_act=1


		'Sleep 1 ' pause de prueba
	
       ' lectura del AVI (solo si VIDEO=1, fondo encendido y actualizar pantalla)
	   If video=1 And actualizar_pantalla=1 Then 'And background=0 Then 
		 If cuadro>-1 Then 
			'If cadaXcuadro=3 Then
			  ' Si RAM(&hCBD0)=0 debemos expandir el video (y tambien mostrar el fondo), con "3", no expande
			  
			  '''''''''''''''''' ANULAR EXPANDER MIENTRAS SE DEPURA ''''''''''''''''''''''''
			  'expander=2 ' con esto anulo el expander mientras depuro (es como activar BIT.1)
			  'desplaza_video=-40 ' con esto fuerzo a centrar el video mientras depuro
			  
			  If expander=1 Then 
			  		desplaza_video=-50 ' expander desactivado (BIT.1 a 1, o sea, =2) el video se centra en -50
			  Else
			 		'If cadaXcuadro And MultiKey(SC_LEFT)   Then desplaza_video+=10
			  		'If cadaXcuadro And MultiKey(SC_RIGHT)  Then desplaza_video-=10
			  		'If MultiKey(SC_LEFT)   Then desplaza_video+=10
			  		'If MultiKey(SC_RIGHT)  Then desplaza_video-=10

   ''==================================================================================================
   '' SynaMax:
   ''  We grab the 16-byte word at $D004.  This is the original expander value before it is modified to be 
   ''  sent out to the PIA.  The center value is 320 ($140).  The left most value 452 ($1C4) and the
   ''  right most value is 187 ($BB).
   ''
   ''	                 LEFT   CENTER  RIGHT
   ''	 Decimal value:   452 <- 320 -> 187
   ''	 Offset:          -132    0    +133
   ''
   ''  -1073 looks like a good position for desplaza_video to align with the sprites.  We add the "raw"
   ''  expander value to desplaza_video and then multiply it by 2 since the video is stretched out.
			  		
			  		Dim As String raw
			  		raw=Str(Hex(leeRAM(&hD004),2))+Str(Hex(leeRAM(&hD005),2))
			  		desplaza_video=-1073+Val("&h"+raw)*2 ' expander activado (BIT.1 a 0, o sea, =0) el video se centra en -420
   ''==================================================================================================
			  EndIf
			  
			  ' compenso 43 cuadros a mayor, para que coincidan con los que pide el real
			  ' la demo que hace cuando juega solo, requiere unos 24 cuadros a restar (-24)
			  ' pero los escenarios principales, requieren +42, un lio
			  MostrarVideo(cuadro, expander , desplaza_video)
			  
			  'If MultiKey(SC_LEFT)   Then desplaza_video+=10
			  'If MultiKey(SC_RIGHT)  Then desplaza_video-=10
			  
			  
			  ' los limites, para la configuracion actual (-40 es centro cuando NO esta expandido)
			  'If desplaza_video<-730 Then desplaza_video=-730
			  'If desplaza_video>-40  Then desplaza_video=-40
			  'Locate 30,30:Print desplaza_video, RAM(&hCBD0)
			  'If pausa=0 Then cuadro+=(1 * play):pausa=1 ' solo avanza si el PLAY esta pulsado
			  'print #1,"play:";play
		 		If leeRAM(&ha136)>0 Then		'' Very important to prevent slow down during black screens
			  		cuadro+=(1 * play):play=0
			  	EndIf
			  'cadaXcuadro=0
			'End If
			'cadaXcuadro+=1
		 EndIf
	   End If     
 

     
		' mostramos la pantalla y miramos cambios en el modulo PIF del LD
		'PtT-=1
		'If ptt <0 Then
		 'PtT=1000 ' probar el mejor en velocidad (3000 va bien)

		 'modulo_PIF()
		' If (cycles_per_interrupt/256) Then 
		' 	control_vertical=0
		''If control_vertical=-1 Then control_vertical=255
		' 	actualizar_pantalla=1 ' cada vez que escribimos, actualizamos
		' 	irq_act=1 ' en cada barrido de pantalla llamamos a IRQ
		' EndIf
		pantalla()

		'End If       
		Put (0,0), frontal,trans
		
		' miramos los mandos de juego e interruptores de configuracion
		'botones()
		
		' refresca la pantalla
		'Wait &h3DA, 8
		'ScreenUnLock 

	  	
		' control de lineas en pantalla (256 lineas verticales)
		' 60hz es 0.0166 ms (1s/60hz)
		' como no funciona bien, lo dejo SIEMPRE a "0" para que el juego avance y no se quede esperando
		'control_vertical=0
		'If control_vertical=-1 Then control_vertical=255
		
	  	botones()
	  	'prt 19,40, "DIPSWITCH:"+str(Bin(DIPSWT,8))  
		'prt 21,40, "Control 2:"+str(Bin(control2,8)) 
		'prt 20,40, "Control 1:"+str(Bin(control1,8)) 
				 
		   	
   	'tiempo_consumido=Timer()-tiempo_real
   	'Locate 10,10:Print tiempo_consumido
   	'If tiempo_consumido>0.01 Then Sleep (1-tiempo_consumido)*10,1

	If depuracion=1 Then ' solo muestro datos si es "1"
		Locate 1,1
		Print "DIP 1 : ";Bin(DIPSWT,8);IIf(Bit(DIPSWT,0), " AUTO-UP", " MANUAL_DOWN")
		Print "CTL 1 : ";Bin(control1,8)
		Print "CTL 2 : ";Bin(control2,8)
		Print "CUADRO: ";cuadro;"    "
		Print "POS. C: ";desplaza_video;"    "
		Print IIf( expander, "EXPANDER OFF", "EXPANDER ON ")
	End If
	
	If depuracion=2 Then ' solo muestro datos si es "1"
		Locate 1,1
		Print "DIP 1 : ";Bin(DIPSWT,8);IIf(Bit(DIPSWT,0), " AUTO-UP", " MANUAL_DOWN")
		Print "CTL 1 : ";Bin(control1,8)
		Print "CTL 2 : ";Bin(control2,8)
		Print "CUADRO: ";cuadro;"    "
		Print "$CB80:"+Str(Hex(leeRAM(&hCB80),2)) +Str(Hex(leeRAM(&hCB81),2))
		Print "$A172:"+Str(Hex(leeRAM(&hA172),2)) +Str(Hex(leeRAM(&hA173),2)) +Str(Hex(leeRAM(&hA174),2))
		Print "$A100 [FieldsLeftBeforeStability]:"+Str(Hex(leeRAM(&hA100),2))
		Print "$A101:"+Str(Hex(leeRAM(&hA101),2))
		Print "$A133:"+Str(Hex(leeRAM(&hA133),2)) +Str(Hex(leeRAM(&hA134),2))
		Print "$A1A4 [PifArray5Bytes]:"+Str(Hex(leeRAM(&hA1A4),2)) +Str(Hex(leeRAM(&hA1A5),2)) +Str(Hex(leeRAM(&hA1A6),2))
		Print "$A1B4 [ExpectedHexPicNum]:"+Str(Hex(leeRAM(&hA1B4),2)) +Str(Hex(leeRAM(&hA1B5),2))
		Print "$A1B6 [PifTimeoutCounter]:"+Str(Hex(leeRAM(&hA1B6),2)) +Str(Hex(leeRAM(&hA1B7),2))
		Print "$A1B9 [ERROR CODE]:"+Str(Hex(leeRAM(&hA1B9),2)) +Str(Hex(leeRAM(&hA1Ba),2))
		Print "$A1BD [SlowPifCounter]:"+Str(Hex(leeRAM(&hA1BD),2))
		Print "$A1BE [PifFindCorrectFrameTimeoutCounter]:"+Str(Hex(leeRAM(&hA1BE),2))
		Print "$A112 [FieldMismatchCount]:"+Str(Hex(leeRAM(&hA112),2))
		Print "$A1D3:"+Str(Hex(leeRAM(&hA1D3),2)) +Str(Hex(leeRAM(&hA1D4),2))
		Print "$A1EB:"+Str(Hex(leeRAM(&hA1EB),2)) +Str(Hex(leeRAM(&hA1EC),2)) +Str(Hex(leeRAM(&hA1ED),2)) +Str(Hex(leeRAM(&hA1EE),2))
		Print "$A12D:"+Str(Hex(leeRAM(&hA12D),2)) +Str(Hex(leeRAM(&hA12E),2)) +Str(Hex(leeRAM(&hA12F),2))
		Print "$A130:"+Str(Hex(leeRAM(&hA130),2)) +Str(Hex(leeRAM(&hA131),2))
		Print "$A132:"+Str(Hex(leeRAM(&hA132),2))
		Print "$D001:"+Str(Hex(leeRAM(&hD001),2)) +Str(Hex(leeRAM(&hD002),2)) +Str(Hex(leeRAM(&hD003),2)) +Str(Hex(leeRAM(&hD004),2))
		Print "$D004:"+Str(Hex(leeRAM(&hD004),2)) +Str(Hex(leeRAM(&hD005),2))
		Print "POS. C: ";desplaza_video;"    "
		Print IIf( expander, "EXPANDER OFF", "EXPANDER ON ")
	End If
	
	  	tiempo_real=Timer()
	  	ScreenCopy
	  	
   	If InKey=Chr(255)+"k" Or MultiKey(SC_ESCAPE) Then GoTo ACABAR ' al pulsar la "X"   
   
   End If ' fin de bucle de interrupciones
'''''''''''''''''''''''''''''''''''''''''''''''''''''
	 
	 'PtT-=1
	 'If PtT<0 Then	 
	 '	PtT=30000
	 ' 	botones()
	 ' 	prt 19,40, "DIPSWITCH:"+str(Bin(DIPSWT,8))  
		'prt 21,40, "Control 2:"+str(Bin(control2,8)) 
		'prt 20,40, "Control 1:"+str(Bin(control1,8))  
	 'End If
     

' bucle sin salida, infinito
Wend



' aqui solo llegamos al pulsar "ESC", o fin de emulacion
ACABAR:


	Close 1,2,3
	
	Open "DUMPRAM.BIN" For Binary Access write As 1
	For FF As Integer=0 To &h1FFFF ' 128k de ram
		Put #1,FF+1, Chr(RAM(FF) And &hFF)
	Next
	Close 1     	

	Open "NVRAM.BIN" For Binary Access write As 1
	For FF As integer=0 To &h3FF
		Put #1,FF+1, Chr(NVRAM(FF) And &hFF)
	Next
	Close 1  
	
End
