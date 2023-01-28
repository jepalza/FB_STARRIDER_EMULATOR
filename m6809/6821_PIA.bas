' RS0-RS1: definicion de los cuatro registros de entrada desde la CPU hacia la PIA
#Define REG_DATA 0 ' Data    Register A   RS0=0  RS1=0
#Define REG_CTLA 1 ' Control Register A   RS0=1  RS1=0

#Define REG_DATB 2 ' Data    Register B   RS0=0  RS1=1
#Define REG_CTLB 3 ' Control Register B   RS1=1  RS1=1

' numero de PIA's emuladas (3 para el StarRider)
Dim Shared MAX_PIA As Integer=3

' registros de uso interno de la PIA 6821 de Motorola
Dim Shared CRA  (MAX_PIA) As Integer ' control register A
Dim Shared CRB  (MAX_PIA) As Integer ' control register B
Dim Shared URA  (MAX_PIA) As Integer ' output register A
Dim Shared URB  (MAX_PIA) As Integer ' output register B
Dim Shared DDRA (MAX_PIA) As Integer ' data direction register A
Dim Shared DDRB (MAX_PIA) As Integer ' data direction register B
' nota para DDRA/B:
' se usa como mascara de direccion, y lo que he podido aprender (espero no colarme)
' es que si es un bit "0" ese bit se lee, si es "1" se guarda, pero los NO usados se mantienen
' por ejemplo, si con un DDRA=&hF (00001111) leemos del puerto A con M6821_PA(nPIA) y el dato leido es 123 (01111011)
' al pasar por la mascara queda como 112 (01110000), por que solo leemos los bits "0" del DDRA
' si fuera guardar un dato, por ejemplo 11 (00001011), como DDRA tiene "1111", guardamos el 11 entero.... puffff.....

' interrupciones (hay dos por cada canal)
' las dos CA1/CA2 (CB1/CB2) generan a su vez otra IRQA (IRQB)
' LAS "CA/CB" son DESDE/HACIA perifericos, y las IRQA/B son HACIA CPU
' el registro interno ISCA/B gestiona las CA/CB y segun lo que hacen
' modifican a la IRQA/B
' CA2/CB2 pueden ser I/O pero CA1/CB1 solo Input
Dim Shared ISCA1 (MAX_PIA) As Integer ' Interrupt Input Control A1
Dim Shared ISCA2 (MAX_PIA) As Integer ' Interrupt Input Control A2
Dim Shared ISCB1 (MAX_PIA) As Integer ' Interrupt Input Control B1
Dim Shared ISCB2 (MAX_PIA) As Integer ' Interrupt Input Control B2

' subrutinas a llamar en la emulacion
Declare Sub      m6821_Write(nPIA As Integer, registro As Integer, dato As Integer)
Declare Function m6821_Read (nPIA As Integer, registro As Integer ) As Integer

' actualizacion de interrupciones, uso interno de la PIA (no llamar desde emulacion)
Declare Sub m6821_IRQ(nPIA As Integer)

' ****************************************************************************************************
' ********   variables que se pueden recoger/alterar desde el exterior, a modo de perifericos ********
' ****************************************************************************************************
   ' NOTA: ES MEJOR QUE SEA LA EMULACION LA ENCARGADA DE ENTREGAR/ALTERAR ESTA INFORMACION
		' almacen de los datos de salida/entrada de la PIA para que los recojan/dejen los perifericos
		Dim Shared M6821_PA  (MAX_PIA) As integer
		Dim Shared M6821_PB  (MAX_PIA) As Integer
		
		' almacen de los datos CA/CB de la PIA para que los recojan los perifericos
		' CB es I/O segun este programado, pero CA es SOLO INPUT (solo recoge de un periferico)
		Dim Shared m6821_ca1 (MAX_PIA) As integer  ' Input
		Dim Shared m6821_ca2 (MAX_PIA) As integer  ' I/O
		Dim Shared m6821_cb1 (MAX_PIA) As Integer  ' Input
		Dim Shared m6821_cb2 (MAX_PIA) As Integer  ' I/O
		
		' en el exterior, tenemos IRQA o IRQB para afectar a la CPU
		Dim Shared m6821_IRQA(MAX_PIA) As Integer
		Dim Shared m6821_IRQB(MAX_PIA) As Integer
' ****************************************************************************************************

' escritura en PIA
Sub m6821_Write(nPIA As Integer, registro As Integer, dato As Integer)

		' 0-1 son PIA PORT A (0=DDRA, 1=CRA)
		' 2-3 son PIA PORT B (2=DDRB, 3=CRB)
				
       Select Case Registro
       	
       	Case REG_DATA ' DDRA = 0
					If (CRA(nPIA) And &h04) Then ' "Data direction register" o "Output register" (bit2)
			        URA(nPIA)=dato ' para uso interno, se guarda completo
			        M6821_PA(nPIA)=(M6821_PA(nPIA) or (DDRA(nPIA) xor 255)) _ 
			               and (dato and DDRA(nPIA) ) ' de cara al exterior, se pasa por la mascara DDRA
					Else
			   	  DDRA(nPIA)=dato ' mascara de I/O
					End If
				
       	Case REG_CTLA ' CRA = 1
       	      dato=dato And &h3f	 
					If (dato And &h20) Then ' CA2 como entrada o como salida (bit5) 
						If (dato And &h10) Then ' CA2 "Strobe" o "reset" (bit4)
			             If (dato And &h08) Then ISCA2(nPIA)=1 Else ISCA2(nPIA)=0 ' Reset? (bit3) 
						Else 
							 ISCA2(nPIA)=1
						End If
					   'If (CRA(nPIA) And &h20)=0) Or ( (CRA(nPIA) And &h20) And (ISCA2(nPIA) Xor rtemp) ) Then 
					   'ISCA2(nPIA)=rtemp
					End If		
				   CRA(nPIA)=dato
				   m6821_IRQ(nPIA)
				
       	Case REG_DATB ' DDRB = 2
					If (CRB(nPIA) And &h04) Then ' "Data direction register" o "Output register" (bit2)
			        URB(nPIA)=dato ' para uso interno, se guarda entero sin tocar
			        M6821_PB(nPIA)=(M6821_PB(nPIA) or (DDRB(nPIA) xor 255)) _ 
			               and (dato and DDRB(nPIA) ) ' de cara al exterior, se pasa por la mascara DDRB
			        If ((CRB(nPIA) And &h20) and (CRB(nPIA) And &h10))=0 Then
                    If (CRB(nPIA) And &h08) Then ISCB2(nPIA)=1 else ISCB2(nPIA)=0  	
			        EndIf
					Else
			   	  DDRB(nPIA)=dato ' mascara de I/O
					End If       	
				
       	Case REG_CTLB ' CRB = 3		
       	      dato=dato And &h3f	 
					If (dato And &h20) Then ' CB2 como entrada o como salida (bit5) 
						If (dato And &h10) Then ' CB2 "Strobe" o "reset" (bit4)
			             If (dato And &h08) Then ISCB2(nPIA)=1 Else ISCB2(nPIA)=0 ' Reset? (bit3) 
						Else 
							 ISCB2(nPIA)=1
						End If
					   'If (CRA(nPIA) And &h20)=0) Or ( (CRA(nPIA) And &h20) And (ISCA2(nPIA) Xor rtemp) ) Then 
					   'ISCA2(nPIA)=rtemp
					End If		
				   CRB(nPIA)=dato
				   m6821_IRQ(nPIA)
				
       End Select
	
End Sub

' lectura de PIA
Function m6821_Read (nPIA As Integer, registro As Integer) As Integer

	 Dim TEMP As Integer
	 DIM DATO AS INTEGER
	 
	 ' actualizamos las ISCA/B internas desde los pines exteriores de la PIA (los que van/vienen del perif.)
     ISCA1(nPIA)=M6821_CA1(nPIA)
     ISCA2(nPIA)=M6821_CA2(nPIA)
     ISCB1(nPIA)=M6821_CB1(nPIA)
     ISCB2(nPIA)=M6821_CB2(nPIA)
	 
	 TEMP=&hff
	
		' 0-1 son PIA PORT A (0=DDRA, 1=CRA)
		' 2-3 son PIA PORT B (2=DDRB, 3=CRB)
				
       Select Case Registro
       	
       	Case REG_DATA ' DDRA = 0
					If (CRA(nPIA) And &h04) Then ' "Data direction register" o "Output register" (bit2)
					  dato=M6821_PA(nPIA) ' cogemos el dato que envia el perif.
			        TEMP=(URA(nPIA) And DDRA(nPIA)) Or (dato And (DDRA(nPIA) xor 255) ) ' se pasa por la mascara DDRA
			        'ISCA1(nPIA)=0
			        'ISCA2(nPIA)=0
			        'm6821_IRQ(nPIA)
			        If ((CRA(nPIA) And &h20) and (CRA(nPIA) And &h10))=0 Then
			        	  ISCA2(nPIA)=0
                    If (CRA(nPIA) And &h08) Then ISCA2(nPIA)=1 ' Reset? (bit3)       	
			        EndIf
					Else
			   	  Return DDRA(nPIA)
					End If
				
       	Case REG_CTLA ' CRA = 1
				   TEMP=CRA(nPIA)
				   If ISCA1(nPIA) Then TEMP=TEMP Or &h80
					If ISCA2(nPIA) And ((CRA(nPIA) And &h20)=0) Then TEMP=TEMP Or &h40
					Return TEMP
				
       	Case REG_DATB ' DDRB	= 2
					If (CRB(nPIA) And &h04) Then ' "Output register" (bit2=1)
					  dato=M6821_PB(nPIA) ' cogemos el dato que envia el perif.
			        TEMP=(URB(nPIA) And DDRB(nPIA)) Or (dato And (DDRB(nPIA) Xor 255))  ' se pasa por la mascara DDRB
			        If ISCB1(nPIA) Then ' IQRB1=1
			        	 if (CRB(nPIA) And &h20) Then ' CB2 como salida (bit5=1)
			        	 	If (CRB(nPIA) And &h10)=0 Then ' CB2 modo "Strobe" (bit4=0)
			        	 		If (CRB(nPIA) And &h08)=0 Then ' modo escritura (bit3=0)
			        	 		   ISCB2(nPIA)=1
			        	 		EndIf
			        	 	EndIf
			        	 End If
			        EndIf
			        
			        'ISCB1(nPIA)=0
			        'ISCB2(nPIA)=0
			        'm6821_IRQ(nPIA)
					Else
			   	  Return DDRB(nPIA)
					End If
				   	
				
       	Case REG_CTLB ' CRB = 3		
				   TEMP=CRB(nPIA)
				   If ISCB1(nPIA) Then TEMP=TEMP Or &h80
					If ISCB2(nPIA) And ((CRB(nPIA) And &h20)=0) Then TEMP=TEMP Or &h40
					Return TEMP
				
       End Select
       
	Return TEMP
End Function

Sub m6821_IRQ(nPIA As integer)
	Dim IRQ_Temp As Integer
	
	IRQ_Temp=0
	
	' actualizamos IRQA
	If ((ISCA1(nPIA)) And (CRA(nPIA) And &h1)) Or ((ISCA2(nPIA)) And (CRA(nPIA) And &h8)) Then IRQ_Temp=1
	M6821_IRQA(nPIA)=IRQ_Temp

	IRQ_Temp=0
	
   ' actualizamos IRQB
	If ((ISCB1(nPIA)) And (CRB(nPIA) And &h1)) Or ((ISCB2(nPIA)) And (CRB(nPIA) And &h8)) Then IRQ_Temp=1
	M6821_IRQB(nPIA)=IRQ_Temp

   ' actualizamos las pines exteriores de la PIA (los que van/vienen del perif.)
   M6821_CA1(nPIA)=ISCA1(nPIA)
   M6821_CA2(nPIA)=ISCA2(nPIA)	
   M6821_CB1(nPIA)=ISCB1(nPIA)
   M6821_CB2(nPIA)=ISCB2(nPIA)
   
End Sub





Sub m6821_debug(nPIA As Integer)
	
	Exit Sub ' de momento, no imprimo nada, por que no tiene utilidad
	prt 1+(nPIA*5),50, "ORA:"+Hex(URA(nPIA),2)+       " DRA:"+Hex(DDRA(nPIA),2)+" BUSA:"+Hex(M6821_PA(nPIA),2)
	prt 2+(nPIA*5),50, "ORB:"+Hex(URB(nPIA),2)+       " DRB:"+Hex(DDRB(nPIA),2)+" BUSB:"+Hex(M6821_PB(nPIA),2)
	prt 3+(nPIA*5),50, "CA1:"+Hex(ISCA1(nPIA),2)+     " CA2:"+Hex(ISCA2(nPIA),2)
	prt 4+(nPIA*5),50, "CB1:"+Hex(ISCB1(nPIA),2)+     " CB2:"+Hex(ISCB2(nPIA),2)
	prt 5+(nPIA*5),50, "IRA:"+Hex(m6821_IRQA(nPIA),2)+" IRB:"+Hex(m6821_IRQB(nPIA),2)
	
End Sub
