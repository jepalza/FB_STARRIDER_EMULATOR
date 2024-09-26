


Sub Blitter_pixel(direccion As Integer, valor As integer, dato As integer, mascara As integer, solido As Integer)
   Dim pixel As Integer

   'If direccion<&hA000 Then Pixel=VRAM(direccion) Else Print "Error direccion VRAM en Blitter_Pixel:";Hex(direccion,4):screencopy
	Pixel=VRAM(direccion)

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
	
	If direccion < &ha000 Then vram(direccion)=pixel
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
		  	  
		  Dim mask As Integer
        Dim pix  As Integer

	
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

' depuracion solo
Sub ponpaleta()
	  
	Dim As Integer f,g,h
	Dim As Integer r1,g1,b1,a1
	Dim As Integer tintes(16)
	
	Dim As Integer x,y

	x=400:y=340
	
	For f=0 To 10
		
		g=0
		For h=&hC000+(f*32) To &hC000+(f*32)+32 Step 2
		  	r1=RAM(h) And &h0F
	     	g1=RAM(h) Shr 4
	     	b1=RAM(h+1) And &h0F
	     	a1=RAM(h+1) Shr 4
	     	r1=((r1*a1) Shr 4)
	     	g1=((g1*a1) Shr 4)
	     	b1=((b1*a1) Shr 4)
	     	tintes(g)=RGBA(r1*16,g1*16,b1*16,a1*16)
	     	Print #1,Chr(9);Chr(9);Hex(r1,2);" , ";Hex(g1,2);" , ";Hex(b1,2);" ,"
	     	g+=1
		Next

		For h=0 To 15
			Line (x,y)-Step(13,13),tintes(h),bf
			Line (x,y)-Step(14,14),RGBA(255,255,255,255),B
			x+=15
		Next
		x=400
		y+=15
		
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
  
  			CC=0
	   	For FF=(paleta*32)+&hC000 To (paleta*32)+&hC000+30 Step 2
	   		Dim As Integer r1,g1,b1,a1
	   	  	r1=RAM(FF) And &h0F
		     	g1=RAM(FF) Shr 4
		     	b1=RAM(FF+1) And &h0F
		     	a1=RAM(FF+1) Shr 4
	     		r1=((r1*a1) Shr 4)
	     		g1=((g1*a1) Shr 4)
	     		b1=((b1*a1) Shr 4)
		     	tinte(CC)=RGBA(r1*16,g1*16,b1*16,a1*16)
		     	CC+=1
	   	Next
	   	
  If actualizar_pantalla Then ' si es "0" no se permite dibujar aun
       actualizar_pantalla=0
		  
		  For FF=0 To anchoxalto-1
		  	  CC=PROM( (VRAM(FF) Shr 4   ) + (paleta*16) )
		  	  DD=PROM( (VRAM(FF) And &H0F) + (paleta*16) ) 

		  	  ' NOTAAAAAAAAAAAAAA : para el escalado, mejor con LINE
		      'Line (XX*escala,YY*escala)-Step(escala,escala),CC,bf
		      'Line ((XX+1)*escala,YY*escala)-Step(escala,escala),DD,bf
		     ' para escala 1:1 mejor con PSET
		       
		     ' para "trampear" el fondo, si quito el video mientras depuro. deberia eliminarla cuando todo funcione
		     If video=0 Then RAM(&hCBD0)=1 ' SEGUN CBD0, EL FONDO ES TRANSPARENTE=0. LO DEJO SIEMPRE OPACO=1
		     
		     If RAM(&HCBD0) And 1 Then
		     	 ' 1=FONDO SOLIDO
		     	 Line ( XX   *escala,YY*escala)-Step(escala,escala),(tinte(cc)),bf
		       Line ((XX+1)*escala,YY*escala)-Step(escala,escala),(tinte(DD)),bf
		     Else 
		     	 ' 0=COLOR "0" TRANSPARENTE
		       If cc Then Line ( XX   *escala,YY*escala)-Step(escala,escala),(tinte(cc)),bf
		       If dd Then Line ((XX+1)*escala,YY*escala)-Step(escala,escala),(tinte(DD)),bf
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

	ponpaleta()
	     
End Sub
