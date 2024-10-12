

Dim Shared video As Integer=1 ' para mostrar el video de fondo si VIDEO=1

' modo de pantalla 640x480 FIJO, no se puede tocar, por que todo va calculado respecto a ella
Dim Shared resx As Integer= 640
Dim Shared resy As Integer= 520

Dim Shared Escala As Integer=2 ' al ser pantalla 640x480 real, y el juego de 320x240, doblamos la resolucion a mostrar

' resolucion grafica del juego REAL
Dim Shared anchopan As Integer=320 '304
Dim Shared altopan  As Integer=256 '256
Dim Shared anchoxalto As Integer
anchoxalto=((anchopan/8)*altopan)*4 ' an x al x 4 (16 colores=4 planos) total de datos que emplea la grafica

' control de ciclos y tiempos para emulacion real
Dim Shared ciclos_ejecutados As Integer=0 ' almacena los ciclos ejecutados en EXECUTE
Dim Shared ciclos_totales As Integer=0 ' guarda los totales
Dim Shared tiempo_real As Double ' para ajustar los ciclos ejecutados a los reales, usamos dos relojes (orig y copia)
Dim Shared tiempo_consumido As Double

' variables  para lectura de ficheros, como la ROM
Dim Shared linea As String*32
Dim Shared ini As Integer ' inicio de la rom, para su lectura secuencial
Dim Shared inirom As Integer
Dim Shared contador As Integer
Dim Shared IRQ As Integer =0 ' una prueba

'Dim Shared blitter_accesos As Integer=0 ' mantiene un registro de la ultima mascara empleada en el BLITTER
Dim Shared actualizar_pantalla As Integer=0 ' refresca la pantalla cuando se indica "1"
Dim Shared tinte(16*64) As uinteger ' paleta de 1024 colores (16 colores x 64 paletas) (necesario LongInt)
Dim Shared control_vertical As Integer=255 ' contador vertical, para la direccion CBA0
Dim Shared op_mhz As Integer = 0 ' velocidad de la CPU en MHZ (se ajusta antes de iniciar la CPU, abajo)
Dim Shared cycles_per_interrupt As integer

' DIP SWITCH (no activar AUTO-UP ni ADVANCE)
Dim shared DIPSWT As Ubyte= &b00000000 ' "0" apagado, "1" activado
									'	0 AUTO-UP --> modo test
									'	1 ADVANCE --> avanzar por los test. poner a "0" tras su uso
									'	2 SCORE-RESET
									'	3 LEFT-COIN
									'	4 CENTER-COIN
									'	5 RIGHT-COIN
									'	6 SLAM-SWITCH (TILT)
									'	7 MEM PROT

' Mando de direccion y botones "start"
Dim Shared control1 As UByte = 255

' acelerador, freno, turbo y velocidad (¿no usado?)
Dim Shared control2 As UByte = 255

' expander y background: a 0 activos, a 1 apagados (puerto CBDO)
' el expander es el que expande el video al doble de ancho
' el background es el que muestra o no el fondo sobre el video (color "0" transparente)
Dim Shared expander As Integer=1 ' los desactivo por defecto, por si acaso
Dim Shared background As Integer=1

' colores (puerto CBE0)
Dim Shared paleta As Integer=0

' mascara de color para PROM
Dim Shared COLORMASK As Integer=0

'---------------------------------
' variables temporales (no usar, en la version final, solo depuracion)
Dim Shared AA As Integer
Dim Shared BB As Integer
Dim Shared CC As Integer
Dim Shared DD As Integer
Dim Shared EE As Integer
Dim Shared FF As Integer
Dim Shared XX As Integer
Dim Shared YY As Integer

Dim SHARED YA1 As Integer
Dim SHARED YA2 As Integer
Dim Shared YA3 As Integer
'--------------------------------

Dim Shared Blitter_reg(&hF) As integer ' almacen de bytes para el emulador de Blitter (usa 2, de 8+8)


Dim Shared PtT As Integer=0 ' PRUEBAS SOLO
Dim Shared Accel As Single=0 ' acelerador (con decimales, para que no acelere de golpe)
Dim Shared Steer As Single=32 ' manillar (centro=32) (con decimales, para que no gire de golpe)
Dim Shared BancoROMG As Integer=0 ' banco actual de ROM grafica
Dim Shared BancoROMS As Integer=0 ' banco actual de ROM de la CPU


Dim Shared cuadro As Integer=0 ' prueba para el video
'Dim Shared cadaXcuadro As Integer=0 ' para la velocidad del video

' para capturar el cuadro de inicio de la escena que pide el puerto CB82 del PIF
Dim Shared capturar_cuadro As Integer=0 
Dim Shared tempcuadro As Integer=0
Dim Shared pausa As Integer =0
Dim Shared play As Integer=0 ' velocidad de avance de 1x a 4x (0 no avanza??)





' *****************************************************************************************


		' definicion de espacios RAM y ROM
		' la ram se divide en dos zonas de 0000-FFFF RAM de CPU, y de 10000-1FFFF zona de GRAFICOS
		' NOTA: es un invento mio para no liarme con el banqueo de ROMS
		Dim Shared RAM  (&h20000)   As Integer ' RAM general: en realidad, el espacio donde se trabaja
		'Dim Shared BRAM (5,&h800)  As Integer ' 5 bancos de RAM de 2k cada uno, para la CPU (10k)
	   'Dim Shared SRAM (1,1)      As Integer ' necesitamos guardar el estado de los bancos de RAM
		Dim Shared NVRAM (&h400)    As Integer ' RAM de CMOS de 1k para la configuracion (CC00 a CFFF)
		Dim Shared BROM (64,&h4000) As Integer ' Memorias ROM
		
		' PROM de colores, 2 de 1k cada una, situadas en U10 y U11 (nota: solo cargo una de ellas, la otra es identica)
		Dim Shared PROM (1023) As Integer ' Memoria PROM
		                                      
		Dim Shared VRAM (&hc000)   As Integer ' RAM de video, 48k?? (son 6 DRAM-4416, de 8k cada una)

		' Borramos la RAM a ceros (solo por precaucion)
		For ini=0 To &h1FFFF: ram(ini)=&h0:Next
		'For ini=0 To &h9FFF:vram(ini)=&h0:Next


' ****************************************************************************************