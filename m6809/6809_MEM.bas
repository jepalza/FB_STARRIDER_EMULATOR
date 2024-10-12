 
'******************************************
' Funciones de lectura/escritura de RAM/ROM
'*******************************************
Sub guardaRAM(pt As Integer, pv As Integer)
	If PT>&h1FFFF Then  CLS:PRINT "ERROR 1 EN RAM":SLEEP
	RAM(PT)=PV
End Sub

Function leeRAM(pt As Integer) As Integer
	If PT>&h1FFFF Then CLS:PRINT "ERROR 2 EN RAM":SLEEP
    'if PT=&ha101 then RETURN INT(RND(1)*256) ' NI IDEA, PERO EN LA A101 SE QUEDA PARADO MUCHAS VECES ESPERANDO ALGO
	leeRAM=RAM(PT)
End Function

Sub pokeb(PT As integer, PV As Integer)

	' ROM principal no escribible 
	If PT>=&hE000 Then Exit Sub 
	
   ' guardamos el dato en VRAM
	If (PT>=&h0000 And PT<&HA000) Then
		' RAM DE VIDEO
		VRAM(PT)=PV ' las escrituras son SIEMPRE en VRAM
		Exit Sub
	End If
	
	' RAM PRINCIPAL
	If (PT>=&hA000 And PT<&HC000) Then
      GuardaRAM(PT,PV) 
 	   Exit Sub
	EndIf

	' NVRAM: RAM con "baterias" para salvaguardas
	If (PT>=&hCC00 And PT<&HD000) Then
		NVRAM(PT-&hCC00)=PV
		Exit Sub
	EndIf	
	
	' 2k de RAM superior
	If (PT>=&hD000 And PT<&HD800) Then
      GuardaRAM(PT,PV) 
	   Exit Sub
	EndIf

	' RAM SECUNDARIA: segun los esquemas NO EXISTE!!! 
	If (PT>=&hD800 And PT<&HE000) Then
      'GuardaRAM(PT,PV) ' como NO existe, no hacemos nada
 	   Exit Sub
	EndIf

	' Paleta de colores
	If (PT>=&hC000 And PT<&HC800) Then
      GuardaRAM(PT,PV) 

	   	' ---------------------------------------------------------------------
	   	' la paleta de colores la genera STARRIDER y la copia en la RAM C000-C7ff
	   	' ATENCION: NO DEBERIA leer esta paleta continuamente, solo una vez, cuando esta cambia
	   	' pero aun no se donde debo hacerlo, ni como, por lo tanto, hasta ese momento, la leo de continuo
	   	Dim As Integer npaleta,ncolor,h
	   	Dim As Integer r1,g1,b1,a1
	   	' paleta 0: el rojo, verde, azul de aqui se usa en los test de LD, en las letras
	   	' 64 paletas de 16 colores (2 bytes cada uno) ocupando la RAM C000-C7FF (2048 bytes)
			For npaleta=0 To 9 ' solo leo las 10 primeras, el resto, no se emplean, y asi, ahorro velocidad 
				ncolor=0
				'Print "PALETA:";npaleta
				For h=&hC000+(npaleta*32) To &hC000+(npaleta*32)+30 Step 2 ' 32 bytes=16 colores de 2 bytes cada uno
				  	r1=RAM(h) And &h0F
			     	g1=RAM(h) Shr 4
			     	b1=RAM(h+1) And &h0F
			     	a1=RAM(h+1) Shr 4
			     	' parche añadido por SYNAMAXMUSIC en GITHUB el 26-09-2024
			     	r1=((r1*a1) Shr 4)
			     	g1=((g1*a1) Shr 4)
			     	b1=((b1*a1) Shr 4)
			     	tinte(ncolor+(npaleta*16))=RGBA(r1*16,g1*16,b1*16,a1*16)
			     	'Print "COLOR:";ncolor;Chr(9);Hex(r1,2);" , ";Hex(g1,2);" , ";Hex(b1,2)';" ,"
			     	ncolor+=1
				Next
			Next
			' ----------------------------------------------------------------------
		
 	   Exit Sub
	EndIf

	 ' *******   PRIMERA PIA  ********
		'If PT=&hcbb0 Then m6821_Write(1,0,PV):GuardaRAM(PT,PV):Exit Sub
		'If PT=&hcbb1 then m6821_Write(1,1,PV):GuardaRAM(PT,PV):Exit Sub
		'If PT=&hcbb2 Then m6821_Write(1,2,PV):GuardaRAM(PT,PV):Exit Sub
		'If PT=&hcbb3 Then m6821_Write(1,3,PV):GuardaRAM(PT,PV):Exit Sub
	 ' *******   PIA EXPANDER/PIF  ********
		'If PT=&hcb80 Then m6821_Write(2,0,PV)':GuardaRAM(PT,PV):Exit Sub
		'If PT=&hcb81 then m6821_Write(2,1,PV)':GuardaRAM(PT,PV):Exit Sub
		'If PT=&hcb82 Then m6821_Write(2,2,PV)':GuardaRAM(PT,PV):Exit Sub
		'If PT=&hcb83 Then m6821_Write(2,3,PV)':GuardaRAM(PT,PV):Exit Sub
	 ' *******   FINA DE PIAs ********
	
   
   ' ==================== zona de puertos I/O ==========================
	If (PT>=&hC800 And PT<&HCC00) Then 

		' WATCHDOG, sirve para saber que el sistema esta "vivo". para ello, debe valer &h15 (binario 00-010101)
		If (PT>=&hC900 And PT<&HC97F) Then 
			GuardaRAM(PT,&h15)
			Exit Sub
		EndIf

		' intercambio de ROMS de CPU
		If PT=&hC800 Then  
			' intercambio de ROMS 3 y 5
			BancoROMS=PV And &hF
			If BancoROMS=0  Then
			  	BancoROM(3,&h0000) 'R30U8
			  	BancoROM(5,&h4000) 'R32U26
			End If
			' intercambio de ROMS 4 y 6 (la 6 no existe, pero se habilita, aun siendo "0's")
			If BancoROMS=4 Then
			  	BancoROM(4,&h0000) 'R31U15
			  	'BancoROM(5,&h4000) 'no existe en placa, pero por seguridad, dejo la 	R32U26
			End If
			GuardaRAM(PT,PV)
			Exit sub
		End If
		
		
		' intercambio de ROMS graficas
		If PT=&hCBC0 Then 
		   ' ROMS (0=ROM Graficas para VGG, 1=ROM Graficas para Testeo por CPU)
		   If BancoROMS<2 Then
		   	If BancoROMS=1 Then BancoROMG=0 Else BancoROMG=&h10000
				BancoROM(09+(PV And &hf),&h0000+BancoROMG)
	  	 		BancoROM(19+(PV And &hf),&h4000+BancoROMG)
	  	 		' nota: los caracteres (ROM R25U46) van situados en la &hC000 en el hard real
		   End if	
		   GuardaRAM(PT,PV)
		   Exit sub
		End If	
		
		' podria ser mascara blitter para cambio de colores
		' NOTA: al parece, los puertos CBC2 al CBCF no se emplean....
		If PT=&hCBC1 Then ' en fase de pruebas
			'YA1= PV And &h0f
			'YA2=(PV And &hf0) Shr 4
			COLORMASK = PV And &h3F ' no se si esto es correcto, maximo 64 paletas???
			'If COLORMASK > 63 Then Print #1,PV,Hex(PV,2):beep
			'Print #1,YA3,YA2,YA1,Hex(YA3,2),Bin(YA2,8);"-";Bin(YA1,8)
		EndIf
		
		' BLITTER: chip encargado de mover los bloques graficos entre ROM y VRAM
		' al parecer, los puertos del B0 al B7 "no" existen, el HARD elimina el BIT3, y solo "ve" de la B8 a la BF
	   If (PT>=&HCBB0 And PT<=&HCBBF) Then  
	   	' anulado, no se emplean If PT<&hcbb8 Then end
			Blitter_reg(PT-&hCBB0)=PV	
			If PT=&hCBB8 Then
				Blitter(1) ' salta a escribir el BLITTER
				firq_act=1 ' al acabar el BLITTER genera una FIRQ???
				'm6809_firq()
			EndIf
	   EndIf
	   
	   
	   
		' PIA Sonido A
	   'If PT=&HC982 Then 
	   '  PV=PV Xor 128
	   'EndIf  
	   ' PIA Sonido B
	   'If PT=&HC983 Then 
	   '  PV=PV Xor 128
	   'EndIf 
	   
   	 'If pt=&hc900 Then PV=&h15 ' watchdog
   	 
   	 ' control_vertical
   	 If pt=&hcba0 Then 
   	 	'control_vertical=PV
   	 	Exit Sub ' NOTA: escribir en "control vertical" no tiene efecto, salimos sin hacer nada
   	 EndIf
	   
	   
	   
	   ''''''''''''''''''''''''''''''''''''
   	' estos 4 segun parece, son PIA del expander (80 y 81, puerto A) y PIF-LD (82 y 83, puerto B)
	   If PT=&hCB80 Then 
	   	'PV=PV Xor 128
	   EndIf 
	   If PT=&hCB81 Then 
	   	'PV=PV Xor 128 ' muy importante: sin el, los textos del inicio, aparecen lentiiiiiiiisimos
	   EndIf  
	   ' placa PIF, la del LaserDisc
	   
	   ' en la DIR A172 se almacenan los 3+42 datos del manchester, que el HARD REAL lee desde el disco
	   ' como yo no tengo nada , esta zona permanece siempre a "0"(3+42=3 del cuadro F9xxxx y 42 de MIS datos)
	   'For FF=&ha172 To &ha172+48:RAM(FF)=Int(Rnd(1)*256):next
  
	   If PT=&hCB82 Then 
	   	'If PV<>5 Then Print #1,"LASERDISC CB82 out:";Hex(PV,2);" en PC:";Hex(PC,2), play
	   	If capturar_cuadro=2 Then
		   		capturar_cuadro=0
		   		tempcuadro=tempcuadro+PV
		   		cuadro=tempcuadro
		   		'Locate 10,10:Print "Cuadro:";cuadro:ScreenCopy:Sleep 10,1:Sleep
		   		'Print #1,"Cuadro:";cuadro
		   		'pausa=1

		   		play=1
		   		guardaRAM(PT,PV)
		   		Exit sub
	   	End If
	   	If capturar_cuadro=1 Then
		   		capturar_cuadro=2
		   		tempcuadro=PV*256
		   		guardaRAM(PT,PV)
		   		Exit Sub
	   	End If
	   	If capturar_cuadro=0 Then
		   	If PV=&h13 Or PV=&h03 Then
		   		capturar_cuadro=1
		   		Exit Sub
		   	EndIf
	   	End If
	   	'If PV=&h01 Then ' se supone que es PLAY, pero no aparece nunca!!
	   	'If PV=&h02 Then ' es una especie de "hola, estoy aqui", sin uso
	   	'If PV=&h05 Then Rem play=0' no hace nada, es como un espacio en blanco, un simple NOP
	   	'If PV=&h08 Then End' pausa=1 ' no se si es una pausa o avanzar un cuadro y parar
	   	'If PV=&h09 Then End' pausa=1 ' no se si es una pausa o retroceder un cuadro y parar
	   	'If PV=&h0C Then ' TEST?? envia 1,2,4,8,10,20,40,80 en hexa seguidos!!!!
	   	'play=0
	   	
	   	If PV=&h0D Then play=1 ' PLAY x1 velocidad normal
	   	If PV=&h0E Then play=2 ' PLAY x2 doble de velocidad (al acelerar)
	   	If PV=&h0F Then play=3 ' PLAY x3 modo turbo, al apretar el turbo
	   	If PV=&h10 Then play=4 ' PLAY x4 creo que lo usa de modo interno, para saltar a por otro cuadro, si el actual da error
	   	If PV=&h11 Then play=-1 ' RETROCEDE x1 , creo que solo se usa en los test
	   	If PV=&h12 Then play=-2 ' RETROCEDE x2 , idem
	   	
	   	'Print #1,"Speed:";play
	   	'Print #1,play
	   	' buscando comandos no utilizados. si aparecen, se escriben en el fichero PEPE.TXT externo
	   	' he eliminado el 02 y el 05 por que salen muchas veces y no tienen utilidad
	   	'If PV=0 Or pv=1 Or pv=3 Or pv=4 Or pv=6 Or pv=7 Or pv=8 Or pv=9 Or pv=10 Or pv=11 Or pv=12 Or pv=17 Or pv=18 Then
	   			'Print #1,"CB82 out:";Hex(PV,2);" en PC:";Hex(PC,2)
	   			'Print #1,"CB83 out:";Hex(RAM(PT),4);" -> ";Hex(PV,2);" en PC:";Hex(PC,2)
	   	'EndIf
	   	
	   	' los comandos mas comunes salgo sin hacer nada
	   	'If PV=2 Or pv=5 Or pv=16 Then
				'Exit Sub
	   	'EndIf
	   	
	   	' el resto los almaceno para estudiarlos
	   	'Print #1,"CB82 out:";Hex(PV,2);" en PC:";Hex(PC,2)
	   	'PV=PV Xor 128
	   EndIf  
	   If PT=&hCB83 Then 
	   	'Print #1,"CB83 out:";Hex(RAM(PT),4);" -> ";Hex(PV,2);" en PC:";Hex(PC,2)
	   	'PV=PV Xor 128 ' PARECE QUE INDICA A LA "IRQ" DEL LECTOR DE "LD" QUE SE INICIE: NO TOCARLO
	   EndIf
		''''''''''''''''''''''''''''''''''''
		
	   
	   
	   ' BACKGROUND ON/OFF -- EXPANDER ON/OFF -- "0"=ON
	   If PT=&hCBD0 Then 
	   	expander=IIf(Bit(PV,1),1,0) ' 0 o 1, 1 OFF
	   	background=Bit(PV,0) ' 0 o 1, 1 OFF
	   	' esto es un puerto de salida. activa o desactiva tanto el fondo como el expander
	      ' solo emplea dos bits para ello, el 0 y el 1, y solo he visto dos combinaciones por ahora: 00 y 11
	      ' segun he averiguado, solo admite 00 y 11 (o sea 0 y 3), no hay mas estados, o estan ON o OFF
	   	' podria ser "0" para mostrar fondo y expandir y "3" para ocultar fondo y estrechar????
	   EndIf 


	   ' paleta de colores (he visto hasta la 9 por ahora, cuando explota al chocarse con una roca)
	   If PT>=&hCBE0 And PT<=&hCBEF Then ' NOTA: no parece que se usen desde CBE1 hasta CBEF, nunca llegan aqui!!
	   	paleta=PV And &h3F ' solo 6bits tienen sentido (64 bancos de 16 colores)	
	   EndIf 
	   
	   
	EndIf
	' ======================  FIN DE PUERTOS =========================

	' resto de casos
	 guardaRAM(PT,PV)

	'If ( PT<&Ha000 ) Then Exit Sub ' ROM no escribible 
End Sub

Function peekb(PT As integer) As Integer	
	'If PT=&h676e And bancorom<>0 Then Print "hola":ScreenCopy:sleep
   ' el modulo VGG es capaz de leer desde la VRAM, por eso
   ' necesito tener una VRAM accesible, independiente de la RAM
	' para su Testeo por la CPU (y asi no da error al principio)
   If (BancoROMS=2 And PT<&hA000) Then 
   	PV=VRAM(PT)
   	Return PV
   EndIf
	
	' RAM PRINCIPAL
	If (PT>=&hA000 And PT<&HC000) Then
		PV = LeeRAM(PT) ' Dato desde RAM (o ROM paginada)
   	Return PV
	EndIf

	' NVRAM: RAM con "baterias" para salvaguardas
	If (PT>=&hCC00 And PT<&HD000) Then
		PV=NVRAM(PT-&hCC00)
   	Return PV
	EndIf	
	
	' 2k de RAM superior
	If (PT>=&hD000 And PT<&HD800) Then
		PV = LeeRAM(PT)
   	Return PV
	EndIf

	' RAM SECUNDARIA: segun los esquemas NO EXISTE!!! 
	If (PT>=&hD800 And PT<&HE000) Then
		'PV = LeeRAM(PT) ' como no existe, no lo uso
   	Return 255' PV
	EndIf

	' Paleta de colores
	If (PT>=&hC000 And PT<&HC800) Then
		PV = LeeRAM(PT)
   	Return PV
	EndIf



	' resto de casos (ROM y puertos I/O)
	PV=leeRAM(PT)

	
	'If RAM(&hCBD0)=&h3 And RAM(&hC800)=0 Then PV=VRAM(PT)
   'If pt = &h6995 Then Print "---";Hex(pc):Sleep:sleep ' para cazar el texto de NOTIFY al dar error el LD

   ' ==============================================
   '              zona de puertos I/O
   ' ==============================================
		If (PT>=&hC800 And PT<&HCC00) Then 
	
	   		' WATCHDOG, sirve para saber que el sistema esta "vivo". para ello, debe valer &h15 (binario 00-010101)
				If (PT>=&hC900 And PT<&HC97F) Then 
					Return &h15
				EndIf
	   	
	   	 'If pt>=&hc980 And pt<=&hc987 Then a=1 ' PIA 1 y 2 de la CPU (mandos, volante, dipswitch)
	   	 'If pt>=&hcb80 And pt<=&hcb83 Then a=1 ' PIA del sonido??
	   	 'If pt>=&hcba0 And pt<=&hcba3 Then a=1 ' PIA del LaserDisc??
	   	 'If PT>=&HCBB8 And PT<=&HCBBF Then a=1 ' blitter
	   	 'If PT=&hcbb0 Or PT=&Hcb8 Then Print #1,Hex(pc);" = ";Hex(pt);" <---- ";Hex(pv)
		    'Print #1,"ENTRADA A Puerto:";Hex(PT,4);"  PC:";Hex(PC,4)
		
			'If pt=&Hc880 Then ' LED DE SALIDA DE DATOS, EL DISPLAY TIPO "8" DE UN SOLO DIGITO DE LA PLACA DE TEST
			   
			If (PT>&hC7ff And PT<&HCC00) Then
					'If pt=&hcb80 Then Locate 18,1:Print #1,"l:";Hex(PT);" ";Hex(pv,2);"   "
				 	'If pt=&hcb81 Then Locate 19,1:Print #1,"l:";Hex(PT);" ";Hex(pv,2);"   "
				 	'If pt=&hcb82 Then Locate 20,1:Print #1,"l:";Hex(PT);" ";Hex(pv,2);"   "
				 	'If pt=&hcb83 Then Locate 21,1:Print #1,"l:";Hex(PT);" ";Hex(pv,2);"   "
				 	'If pt=&hc880 Then Locate 22,1:Print "l:";Hex(PT);" ";Hex(pv);"   "
				 	'If pt=&hc881 Then Locate 23,1:Print "l:";Hex(PT);" ";Hex(pv);"   "
			 	   'If pt=&hc882 Then Locate 24,1:Print "l:";Hex(PT);" ";Hex(pv);"   "
			 	   'If pt=&hc883 Then Locate 25,1:Print "l:";Hex(PT);" ";Hex(pv);"   "
			 	   'If pt=&hc983 Then Locate 26,1:Print "l:";Hex(PT);" ";Hex(pv);"   "
		   EndIf
	
	
	
		
		'''''   puertos entre C980 y C986
		   ' "DIP SWITCH" interruptores de configuracion
		   If PT=&HC980 Then 
				PV=DIPSWT
		   EndIf  
	
		   ' PIA2-A Sonido control
		   If PT=&HC982 Then 
		     'PV=PV Xor 128
		   EndIf  
		   
		   ' PIA2-B Sonido datos
		   If PT=&HC983 Then 
		     PV=128 ' no quitar, da error el audio y se queda esperando en el TEST
		   EndIf 
		   
		   ' "STEER" : direccion y "START"
		   If PT=&HC984 Then 
		   	PV=control1
		   EndIf     
		   
		   ' "POWER" :acelerador, ademas de "BRAKES" (2) y "TURBO"
		   If PT=&HC986 Then 
		   	PV=control2
		   EndIf  
		''''''
	
			' entre la CB00 y la CB2C se leen los 42+3 datos que llegan del PIF, el lector del machester del laser
			' ademas, hay una copia de la zona manchester, entre CB03 y CB2C, que se repite entre la CB2D y CB56
			If (PT>=&HCB00 And PT<=&HCB56) Then  
		
			   ' trampa para meter el cuadro leido en el formato que pide el starrider (no funciona aun, solo prueba)
   			Dim As String sa
			   sa=Right("00000"+Trim(Str(cuadro)),5)
			   
			   If Left(sa,1)="0" Then sa="F8"+Mid(sa,2)
			   If Left(sa,1)="1" Then sa="F9"+Mid(sa,2)
			   If Left(sa,1)="2" Then sa="FA"+Mid(sa,2)
			   If Left(sa,1)="3" Then sa="FB"+Mid(sa,2)
			   
			   'RAM(&hA172+0)=Val("&h"+Mid(sa,1,2))
			   'RAM(&hA172+1)=Val("&h"+Mid(sa,3,2))
			   'RAM(&hA172+2)=Val("&h"+Mid(sa,5,2))	
			   'RAM(&hA172+(PT-&hCB03))=0	
			   
			   '' We feed the VBI frame number into $CB00, they will automatically go to $A172-A174
			   
			   RAM(&hCB00+0)=Val("&h"+Mid(sa,1,2))
			   RAM(&hCB00+1)=Val("&h"+Mid(sa,3,2))
			   RAM(&hCB00+2)=Val("&h"+Mid(sa,5,2))	
			   RAM(&hCB00+(PT-&hCB03))=0	
			    
			   'If PT=&hCB00 Then PV=Val("&h"+Mid(sa,1,2))
			   'If PT=&hCB01 Then PV=Val("&h"+Mid(sa,3,2))
			   'If PT=&hCB02 Then PV=Val("&h"+Mid(sa,5,2))	 
			   'If PT>&hCB02 Then PV=0'Int(Rnd(1)*256) ' aleatorio todo lo demas, por ahora, pero deberian ser MIS 42 bytes manchester	 

				'Print #1,"1:";Hex(PT,4),PV
				'PV=Int(Rnd(1)*256)
			End If		
		
   ''==================================================================================================
   '' SynaMax:
   ''  in order to get the video to sync correctly, we need to bypass the fields and vert counters since
   ''  we're not doing interlated video.
   ''
   ''  Let's match up FIELD_HW ($CB90) with FieldVal ($A101), this will tell the game program that
   ''  the (fake) hardware matches up with what the software is expecting which interlaced field the CRT is on.
   ''
   		If PT=&hCB90 Then 
  			
   		RAM(&hCB90)=leeRAM(&hA101) ' THIS IS IT!! (3:32 pm 10/5/24)
   			
   		EndIf	
   ''==================================================================================================		
		  	
		   ' estos 4 segun parece, son PIA del expander (80 y 81, puerto A) y PIF-LD (82 y 83, puerto B)
		   If PT=&hCB80 Then 
		   	'PV=(PV Xor 128)+Int(Rnd(1)*258)
		   EndIf 
		   If PT=&hCB81 Then 
		   	PV=128 ' muy importante: sin el, los textos del inicio, aparecen lentiiiiiiiisimos
		   EndIf  
		   ' quizas el LD
		   If PT=&hCB82 Then 
		   	'PV=Int(Rnd(1)*256)
		   	'Print #1,Rnd
		   	'sa=Trim(Str(cuadro)),5
		   	'If hCB82=0 Then PV=
		   	
		   	'RAM(&hA133)=68
		   EndIf  
		   If PT=&hCB83 Then 
		   	PV=128  ' PARECE QUE INDICA A LA "IRQ" DEL LECTOR DE "LD" QUE SE INICIE: NO TOCARLO
		   EndIf

		  
		  
		  
		  
		   ' estos 4 ni idea, pero parecen una PIA mas
		   If PT=&hCBA0 Then 
		   	' control vertical?? entiendo que es el contador de lineas....
		   	' si CBA0<>0 no avanza (se usa para detectar el control vertical del CRT)
		   	' se queda en la E0B3 esperando a que alcance el valor "0"
		   	Return control_vertical
		   EndIf  
		   If PT=&hCBA1 Then 
		   	'PV+=1 'PV Xor 128
		   EndIf  
		   If PT=&hCBA2 Then 
		   	'PV+=1 'PV Xor 128
		   EndIf  
		   If PT=&hCBA3 Then 
		   	'PV+=1 'PV xor 128
		   EndIf
		  
		  
		  
		   
		   ' ni idea, segun esquemas es FIELD pero esta por la zona que lee del LD
		   If PT=&hCB90 Then
		   	'PV+=1 'PV xor 128
		   EndIf
		   
		   
		   
		   
		   ' y mas que no se....
		   If PT=&hCB00 Then
		   	'PV+=1 'PV xor 128
		   EndIf
		   If PT=&hCB01 Then
		   	'PV+=1 'PV xor 128
		   EndIf
		   If PT=&hCB02 Then
		   	'PV+=1 'PV xor 128
		   EndIf   
		   If PT=&hCB03 Then
		   	'PV+=1 'PV xor 128
		   EndIf   
		   
		   
		   
		  
			 ' importante, en el modulo 6821_pia esta trampeado, para que devuelva 255 o aleatorio
			 ' *******   PRIMERA PIA  ********
				'If PT=&hcbb0 Then PV=m6821_Read(1,0):GuardaRAM(PT,PV): Return pv 'Xor 128 
				'If PT=&hcbb1 then PV=m6821_Read(1,1):GuardaRAM(PT,PV): Return pv 'Xor 128
				'If PT=&hcbb2 Then PV=m6821_Read(1,2):GuardaRAM(PT,PV): Return pv 'Xor 128 
				'if PT=&hcbb3 Then PV=m6821_Read(1,3):GuardaRAM(PT,PV): Return pv 'Xor 128 
			 ' *******   PIA EXPANDER/PIF  ********
				'If PT=&hcb80 Then PV=m6821_Read(2,0):'Print #1,Hex(PT),Hex(PC)':GuardaRAM(PT,PV): Return PV 
				'If PT=&hcb81 then PV=m6821_Read(2,1):'Print #1,Hex(PT),Hex(PC)':GuardaRAM(PT,PV): Return PV Xor 128 ' sin este, va lento
				'If PT=&hcb82 Then PV=m6821_Read(2,2):'Print #1,Hex(PT),Hex(PC)':GuardaRAM(PT,PV): Return PV 
				'If PT=&hcb83 Then PV=m6821_Read(2,3):'Print #1,Hex(PT),Hex(PC)':GuardaRAM(PT,PV): Return PV 'or 128 ' sin este (ni el de CBA0) no avanza
			 ' *******   PIA EXPANDER/PIF  ********
				'If PT=&hcb80 Then modulo_PIF(PT):PV=m6821_Read(2,0):'Print #1,Hex(PT),Hex(PC)':GuardaRAM(PT,PV): Return PV 
				'If PT=&hcb81 then modulo_PIF(PT):PV=m6821_Read(2,1):'Print #1,Hex(PT),Hex(PC)':GuardaRAM(PT,PV): Return PV Xor 128 ' sin este, va lento
				'If PT=&hcb82 Then modulo_PIF(PT):PV=m6821_Read(2,2):'Print #1,Hex(PT),Hex(PC)':GuardaRAM(PT,PV): Return PV 
				'If PT=&hcb83 Then modulo_PIF(PT):PV=m6821_Read(2,3):'Print #1,Hex(PT),Hex(PC)':GuardaRAM(PT,PV): Return PV 'or 128 ' sin este (ni el de CBA0) no avanza
	
		End If
   ' ==============================================
	'    fin de puertos I/O entre la C800 y CC00
   ' ==============================================   
  
  		  	   
	   
					   ''''''''''''''''''''''''''''''''''''''''''''''''''''''''
					   ' falseos para saltarse el error de DISC FAULT
					   If PT=&h19ea Then 
					     ccz=1
					   EndIf
					   '''''''''''''''''''''''''''''''''''''''''''''''''''''''
  
  
	   'If YA1=0 Then 	   
		  'If (pt=&hf178) Then ccz=1 ' trampeos ram para que no haga el test inicial de RAM
	   'End If
	
	   ' trampa para que no de error de LD (no se si anda muy bien)
	   ' como anteriormente se ha "tocado" la DIR:&h19E9 21 veces, solo trampeamos desde la 22ava vez.
	   'If PT=&h19e8 Then 
	   	'ccz=0
	   	'guardaRAM(&ha10e,7)
	   	'Print "hola";ya2,leeRAM(&ha10e):ScreenCopy:sleep
	   	'ya2+=1
	   	'If ya2>22 then ya2=23:PV=&h0
	   	'PV=0
	   'EndIf
	   'If ya2=21 Then
	   	'Print #1,"desde ahora"
	   	'ya2+=1
	      'If PT=&h19dc Then 
	      	'ccz=0
	   	'pv=6: 'leeRAM(&ha10e)
	   	'pv=pv+1:If pv=5 Then pv=0
	   	'If ya2>22 then ya2=23:PV=&h0
	      'EndIf

	   
	   
	   'If PT=&h9351 Then 
	     'ccz=1 ' este no es necesario para las pruebas, pero lo dejo
	   'EndIf
	   'If PT=&he813 Then 
	     'ccz=1
	   'EndIf
  
  
  
  
  
  
   
   'End if
   'If PT=&h89f3 Then ccz=0: cuadro=0:' no se por que aun, pero si no trampeo el BEQ, da error de RAM en FB
	Return PV And &hFF
End Function




'*******************************************
' cogemos o ponemos dos bytes (word)
Sub pokew(PT As integer, PV As Integer) 
	pokeb(PT  ,(PV Shr 8) )
	pokeb(PT+1, PV And &hff)
End Sub

Function peekw(PT As integer) As Integer
	PV = peekb(PT+1) Or ( peekb(PT) Shl 8 )
	Return PV
End Function
'*******************************************




'*******************************************
' coge un byte o palabra segun el modo de direccionamiento
Function peekxb() As Integer 
	Return peekb(get_modob())
End Function

Function peekxw() As Integer 
   Return peekw(get_modow())
End Function
'*******************************************





'*******************************************
' coge un byte o palabra e incrementa PC
Function get_byte() As Integer
  PV = peekb(PC)
  PC += 1
  Return PV And &hff
end Function

function get_word() As Integer
  PV = peekw(PC)
  PC += 2
  Return PV And &hffff
end Function
'******************************************





' rutinas de obtencion de datos en 8 o 16bits
function get_rd() As Integer    
	PR = ((ra And &hff) shl 8) or (rb And &hff)
	Return PR 'And &hffff
End Function

sub set_rd(vt As Integer) 
	ra = (vt shr 8) And &hff
	rb =  vt And &hff
End Sub

Function nib5(PV As integer) As Integer
	If (PV and &h10) Then nib5 = (PV or &hffe0) Else nib5 = (PV and &h000f)
End Function

Function get_CC() As Integer
  PV=(ccc or (ccv shl 1) or (ccz shl 2) or (ccn Shl 3) Or (cci shl 4) or (cch shl 5) or (ccf Shl 6) or (cce Shl 7))   
  Return PV And &hff            
end function

Sub set_CC(PV As Integer)

  ccc = cogebit(PV, &h01)
  ccv = cogebit(PV, &h02)
  ccz = cogebit(PV, &h04)
  ccn = cogebit(PV, &h08)
  cci = cogebit(PV, &h10)
  cch = cogebit(PV, &h20)
  ccf = cogebit(PV, &h40)
  cce = cogebit(PV, &h80)

End Sub




' ****************************************************************
'                        rutinas PUSH y PULL 
' ****************************************************************

Sub Push(d1 As integer, d2 As integer, PR As Integer)
 	
	' nota: el orden aqui es importante: no alteralo, ya que se almacena segun va (como en FIFO)
	If (PR And &h80) Then d1 -= 2 : pokew(d1, PC     ) : cicloscpu += 2
	If (PR And &h40) Then d1 -= 2 : pokew(d1, d2     ) : cicloscpu += 2 ' U o S segun sea PSHS o PSHU	
	if (PR And &h20) Then d1 -= 2 : pokew(d1, ry     ) : cicloscpu += 2
	if (PR And &h10) Then d1 -= 2 : pokew(d1, rx     ) : cicloscpu += 2
	
	if (PR And &h08) Then d1 -= 1 : pokeb(d1, rDP    ) : cicloscpu += 1	
	If (PR and &h04) Then d1 -= 1 : pokeb(d1, rb     ) : cicloscpu += 1	
	If (PR and &h02) Then d1 -= 1 : pokeb(d1, ra     ) : cicloscpu += 1	
   If (PR and &h01) Then d1 -= 1 : pokeb(d1, get_CC()): cicloscpu += 1
    
   d1temp=d1 ' devolvemos el estado final de la pila (Bien sea U o S)
   'd2temp=d2 ' y el valor de U o S segun se lo pida D2 (no se altera, por lo que lo anulo por ahora)
    
End Sub

Sub Pull(d1 As integer, d2 As integer, PR As Integer)
' en realidad, la variable D2 no sirve de nada como dato de entrada
' ya que, la leemos aqui, y la devolvemos en d2temp
' pero queda mas claro y mas real asi construido
' vamos, que queda igual a PUSH y queda mas "vistoso"

	' nota: el orden aqui es importante: no alteralo, ya que se recupera segun va
	if (PR And &h01) Then set_CC(peekb(d1)): d1 += 1 : cicloscpu += 1
	if (PR And &h02) Then ra   = peekb(d1) : d1 += 1 : cicloscpu += 1
	if (PR and &h04) Then rb   = peekb(d1) : d1 += 1 : cicloscpu += 1
	if (PR And &h08) Then rDP  = peekb(d1) : d1 += 1 : cicloscpu += 1
	
	if (PR And &h10) Then rx   = peekw(d1) : d1 += 2 : cicloscpu += 2
	if (PR And &h20) Then ry   = peekw(d1) : d1 += 2 : cicloscpu += 2
	if (PR And &h40) Then d2   = peekw(d1) : d1 += 2 : cicloscpu += 2  ' U o S segun sea PSHS o PSHU
	if (PR And &h80) Then PC   = peekw(d1) : d1 += 2 : cicloscpu += 2
	
   d1temp=d1 ' devolvemos el estado final de la pila (Bien sea U o S)
   d2temp=d2 ' y el valor de U o S segun se lo pida D2

end Sub
