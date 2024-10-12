
' http://www.seanriddle.com/blittest.html
' https://seanriddle.com/blitter.html
' https://seanriddle.com/blittercode.txt  (codigo fuente que acabo de encontrar en 2024, pendiente de revisar)

Sub Blitter_pixel(direccion As Integer, valor As UByte, dato As uByte, mascara As Ubyte, solido As Ubyte)
   Dim pixel As Ubyte

   'If direccion<&hA000 Then Pixel=VRAM(direccion) Else Print "Error direccion VRAM en Blitter_Pixel:";Hex(direccion,4):screencopy
	Pixel=VRAM(direccion)

	CC=PROM( (valor Shr 4   ) + (COLORMASK*16) )
	DD=PROM( (valor And &H0F) + (COLORMASK*16) ) 
	valor=DD Or (CC Shl 4)
	
	If dato And &h8 Then
		If (valor And &hf0)=0 Then mascara=mascara Or &hf0
		If (valor And &h0f)=0 Then mascara=mascara Or &h0f
	EndIf
	
	pixel=pixel And mascara
	
	If (dato And &h10) Then
		pixel=pixel Or (solido And (255 Xor mascara))
	Else
		pixel=pixel Or (valor  And (255 Xor mascara))
	EndIf
	
	If direccion < &ha000 Then VRAM(direccion)=pixel
End Sub


Sub Blitter (n As byte)
	' manejo del BLITTER, el chip encargado de dibujar (mas bien mover) los bloques graficos entre ROM y VRAM
		 ' BROM(&h28,ORIGEN And &H3FFF) ' rom de los textos
		
		 
		 Dim dato    As Integer=blitter_reg(0+(n*8))
		 Dim mascara As Integer=Blitter_reg(1+(n*8))
		 Dim origen  As Integer=blitter_reg(2+(n*8))*256+blitter_reg(3+(n*8))
		 Dim destino As Integer=blitter_reg(4+(n*8))*256+blitter_reg(5+(n*8))
		 Dim anchoB  As Integer=blitter_reg(6+(n*8))
		 Dim altoB   As Integer=blitter_reg(7+(n*8))
		 	
		  Dim FF As Integer
		  Dim DD As Integer	
		  
		  Dim sxadv As integer
		  Dim syadv As Integer
		  Dim dxadv As Integer
		  Dim dyadv As Integer	
		  
		  Dim origen2  As Integer=origen
		  Dim destino2 As Integer=destino
		  	  
		  Dim mask As UByte
        Dim pix  As UShort

	
		If (dato And 1) Then sxadv=256:syadv=1 Else sxadv=1:syadv=anchob
		If (dato And 2) Then dxadv=256:dyadv=1 Else dxadv=1:dyadv=anchob

		mask=0
		If (dato And &h80) Then mask=mask Or &hf0
		If (dato And &h40) Then mask=mask Or &h0f
		'If mask=&hff Then Exit Sub 
		
      If (dato And &h20)=0 Then
      ' caso normal, sin rotaciones
		 	For ff=0 To altob-1
		 		origen = origen2 And &hffff
            destino=destino2 And &hffff
		    	For dd=anchob To 1 Step -1
		    		pix=RAM(ORIGEN+&h10000) ' ROM de GRAFICOS
		    		If RAM(&hCBC0)=&hff Then pix=VRAM(ORIGEN)
		         Blitter_pixel(destino,pix,dato,mask,mascara)
		         origen = (origen + sxadv) And &hffff
               destino=(destino + dxadv) And &hffff
		    	Next
		    	origen2+=syadv
		    	If (dato And 2) Then 
		    		destino2=(destino2 And &hff00) Or ((destino2 + dyadv) And &hff)
		    	Else
		    		destino2+=dyadv
		    	EndIf
		 	Next	
      Else
       'caso con rotaciones (un pixel a la derecha, lo que sale por la derecha, aparece por la izquierda)
      	mask=((mask And &hf0) Shr 4) Or ((mask and &h0f) Shl 4)
      	mascara=((mascara and &hf0) Shr 4) Or ((mascara and &h0f) Shl 4)
      	
		 	For ff=0 To altob-1
		 		
            origen = origen2 And &hffff
            destino=destino2 And &hffff
            
            pix=RAM(ORIGEN+&h10000)
            If RAM(&hCBC0)=&hff Then pix=VRAM(ORIGEN)
		 		Blitter_pixel(destino,(pix Shr 4) And &h0f,dato,mask Or &hf0,mascara)
            
            origen = (origen + sxadv) And &hffff
            destino=(destino + dxadv) And &hffff
            
		    	For dd=anchob-2 To 0 Step -1
		         pix=(pix Shl 8) Or RAM(ORIGEN+&h10000)
		         If RAM(&hCBC0)=&hff Then pix=(pix Shl 8) Or VRAM(ORIGEN)
		         Blitter_pixel(destino,(pix Shr 4) And &hff,dato,mask,mascara)
		         origen = (origen + sxadv) And &hffff
               destino=(destino + dxadv) And &hffff
		    	Next
		    	
		    	Blitter_pixel(destino2,(pix Shl 4) And &hf0,dato,mask Or &h0f,mascara)
		    	origen2+=syadv
		    	
		    	If (dato And 2) Then 
		    		destino2=(destino2 And &hff00) Or ((destino2 + dyadv) and &hff)
		    	Else
		    		destino2+=dyadv
		    	EndIf
		 	Next
      End If

End Sub

' depuracion, solo para ver las paletas
' paleta de colores: (Matt Ownby) 
' los colores podrian ser 64 paletas de 16 colores de 2 bytes cada color
' que dan 2*16*64=2048 bytes y ocupan la RAM desde la &hC000 hasta &hC7FF
Sub ponpaleta()
	  
	Dim As Integer npaleta,ncolor,h
	Dim As Integer r1,g1,b1,a1
	
	Dim As Integer x,y

	x=460:y=400
	
	' STAR RIDER solo emplea 10 paletas ????  (de 0 a 9)
	For npaleta=0 To 9

		For h=0 To 15
			Line (x,y)-Step(10,10),tinte(h+(npaleta*16)),bf
			Line (x,y)-Step(11,11),RGBA(255,255,255,255),B
			x+=11
		Next
		x=460
		y+=11
		
	Next

	Locate 60,35:Print "PALETA:";paleta
	
End Sub

Sub pantalla

  'Dim Contador As Integer

  Dim xx As Integer=0
  Dim yy As Integer=0

  Dim cc As Integer
  Dim dd As Integer
  Dim ff As Integer
	   	
	ScreenLock  	
   If actualizar_pantalla Then ' si es "0" no se permite dibujar aun
        actualizar_pantalla=0
		  For FF=0 To anchoxalto-1
		  	  ' los datos a escribir en pantalla pasan a traves de las PROM (PAR e IMPAR con igual contenido)
		  	  'YA1=8 azul, 9 rojo, 10 verde, 11 amarillo
		  	  ' la PROM en las posiciones 8,9,10,11(*16) tiene estos valores
		  	  ' se ve como cambian los colores del centro, y el resto, se mantienen
		  	   ' 00 01 02 03 04 05 06   07 08   09 0C 0B 0E 0D 0D 0F   moto azul
		  	   ' 00 01 02 03 04 05 06   0E 0D   09 0C 0B 0E 0D 0D 0F     "  roja
		  	   ' 00 01 02 03 04 05 06   09 0A   09 0C 0B 0E 0D 0D 0F     "  verde
		  	   ' 00 01 02 03 04 05 06   0C 0B   09 0C 0B 0E 0D 0D 0F     "  amarilla
		  	  'CC=PROM( (VRAM(FF) Shr 4   ) + (YA1*16) )
		  	  'DD=PROM( (VRAM(FF) And &H0F) + (YA1*16) ) 
		  	  CC=VRAM(FF) Shr 4 
		  	  DD=VRAM(FF) And &H0F
		  	  ' NOTAAAAAAAAAAAAAA : para el escalado, mejor con LINE
		      'Line (XX*escala,YY*escala)-Step(escala,escala),CC,bf
		      'Line ((XX+1)*escala,YY*escala)-Step(escala,escala),DD,bf
		     ' para escala 1:1 mejor con PSET
		       
		     ' para "trampear" el fondo, si quito el video mientras depuro. deberia eliminarla cuando todo funcione
		     'If video=0 Then RAM(&hCBD0)=1 ' SEGUN CBD0, EL FONDO ES TRANSPARENTE=0. LO DEJO SIEMPRE OPACO=1

				' NOTA: con el nuevo cambio de mascara PROM "creo" que la variable "PALETA" ya NO tiene sentido
		     If RAM(&HCBD0) And 1 Then
		     	 ' 1=FONDO SOLIDO
		     	 Line ( XX   *escala,YY*escala)-Step(escala,escala),tinte(CC+(paleta*16)),bf
		       Line ((XX+1)*escala,YY*escala)-Step(escala,escala),tinte(DD+(paleta*16)),bf
		     Else 
		     	 ' 0=COLOR "0" TRANSPARENTE
		       If CC Then Line ( XX   *escala,YY*escala)-Step(escala,escala),tinte(CC+(paleta*16)),bf
		       If dd Then Line ((XX+1)*escala,YY*escala)-Step(escala,escala),tinte(DD+(paleta*16)),bf
		     End If
		    YY+=1
		    If YY>(altopan-1) Then YY=0:XX+=2
		  Next
  
  		  ' en esta linea no, que es el marco de alrededor
		  'Line (0,356)-step(640,10),RGB(21,21,21),bf ' contadores, superior
		  'Line (180,360)-step(16,160),RGB(21,21,21),bf ' contadores, medio izq.
		  'Line (440,360)-step(16,160),RGB(21,21,21),bf ' contadores, medio der.
		  'Line (0,480)-step(640,40),RGB(21,21,21),bf ' inferior (el mas gordo)
		  'Line (0,0)-step(8,520),RGB(21,21,21),bf ' lado der.
		  'Line (632,0)-step(8,520),RGB(21,21,21),bf ' lado izq.
		  'Line (0,0)-step(640,8),RGB(21,21,21),bf ' superior
   End If
	screenunlock
	If depuracion=1 Then ' solo muestro la paleta si es "1"
		ponpaleta()
	End If
	     
End Sub