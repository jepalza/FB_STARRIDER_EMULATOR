#Include "WIN/VFW.BI"

Declare function AbrirVideo(AVInombre As String) As integer
Declare Sub CerrarVideo()
Declare Sub MostrarVideo(ByRef frame As Integer, expandir As Integer, desplaza As integer)

' medidas del video AVI
Dim Shared anchoAvi As integer=720 ' el ancho luego se expande al doble
Dim Shared altoAvi  As Integer=520 '520

' medidas pantalla y posicion de inicio (deben coincidir con juego)
Dim Shared anchovisual As Integer
Dim Shared altovisual  As Integer
anchovisual=resx ' usamos la resolucion del juego, de 640x480
altovisual =resy

' punteros AVI
dim shared avifile As PAVIFILE 
dim Shared avistream As PAVISTREAM 
Dim shared aviframe As PGETFRAME
Dim Shared avilonframe As Integer

' expansion y desplazamiento del video, especial para el juego StarRider
Dim Shared desplaza_video As Integer


function AbrirVideo(AVInombre As String) As Integer
	
	' declaramos la estructura del cuadro AVI
	dim Bitmap As BITMAPINFOHEADER
	With Bitmap
	  .biSize=42
	  .biWidth=anchoAvi
	  .biHeight=altoAvi
	  .biPlanes=1
	  .biBitCount=24 ' 24 bits de color 
	  .biCompression=0
	  .biSizeImage=(anchoAvi*altoAvi*3)+(1024)
	   aviframe=callocate(.biSizeImage)
	end With
	
	' revisa que exista el video
	If Open(AVInombre For Binary Access Read As #11)<>0 Then Return 0 Else Close 11

   ' inicializamos AVI
   AVIFileInit()
	
	' abrimos el fichero: si no existe, salimos con error
	If AVIFileOpen(@avifile,AVInombre, OF_READ ,0)<>0 Then CerrarVideo():Return 0

	' puntero al "flujo" (stream) de datos
	if AVIFileGetStream(avifile,@avistream,streamtypeVIDEO,0)<>0 Then CerrarVideo():Return 0

	' cogemos la longitud del video en cuadros
	aviLonFrame=AVIStreamLength(avistream)
   If avilonframe=0 Then CerrarVideo():Return 0
   
	' se habilita el flujo (Stream) de datos codificados XVID a leer
	aviframe=AVIStreamGetFrameOpen (avistream, @Bitmap )
   If aviframe=0 Then CerrarVideo():Return 0

	Return 1 ' correcto
End Function

' expandir es para expandir la imagen al 2x de ancho, para el StarRider
' desplaza es para mover el video de un lado a otro, en el StarRider, y que parezca una moto en curvas
Sub MostrarVideo(ByRef Frame As Integer, expandir As Integer, desplazar As integer)

	If frame<0 Then frame=0 ' evito que de error si da cuadros negativos
	
	' ajusta el video a los cuadros reales, mientras encuentro una solucion
	'If frame=3 Then frame=50 ' principio, carta de ajuste
	'If frame=68 Then frame=107'-38 ' primer cuadro de video real, nada mas empezar  
	'If frame=1050 Then frame=1000 ' primer cuadro de video real, nada mas empezar  
	'If frame=3839 Then frame=3891 ' demo inicial, cuando no hacemos nada
	If frame=3939 Then frame=3981 ' 1 Cubitania 
	If frame=8099 Then frame=8141 ' 2 Hexagonia
	If frame=12259 Then frame=12301 ' 3 Crystallia
	If frame=15919 Then frame=15961 ' 4 Milky Way
	If frame=19629 Then frame=19671 ' 5 Stalactia  ??
	If frame=23339 Then frame=23381 ' 6 Titania
	If frame=27499 Then frame=27451 ' 7 Metropolia
	
	' puntero del cuadro descodificado
	Dim rgbBits As byte Ptr
	
	' puntero de inicio XY en pantalla
	Dim pScreen As byte Ptr
	
	' variables de dibujo del AVI
	Dim xAvi As Integer
	Dim yAvi As Integer
	
	' variables genericas AVI
	Dim OrigAVI As Integer
	Dim DestAVI As Integer
	
	' variables genericas de pantalla
	Dim iniavi_desp As integer
	'Dim ancho_expandido As Integer
	
	' copia de "expandir"
	Dim copia_expandir As Integer=expandir

  rgbBits=AVIStreamGetFrame(aviFrame,frame)
  If rgbBits=0 Then CerrarVideo():Print "error formato de video":ScreenCopy:sleep:Exit Sub

  iniavi_desp=0
  iniAvi_desp=desplazar*4

  ScreenLock
  pScreen=screenptr
  pScreen+=(altoAvi-1)*(anchovisual*4)
  for yAvi=0 to altoAvi-1
  	    
    If yAvi<160 Then 
    	If copia_expandir=0 Then 
    		expandir=1
    		iniavi_desp=-116
    		'copia_expandir=2
    	End If
    End If
    If yAvi>159 Then 
    	If copia_expandir=0 Then 
    		expandir=copia_expandir
    		copia_expandir=2
    		iniAvi_desp=desplazar*4
    	End If
    EndIf
    
  	 ' los pixeles origen ocupan 3 bytes, por lo que multiplicamos *3 todo (formato AVI)
    OrigAVI=(yAvi*anchoAvi*3)+42
    ' los pixeles destino ocupan 4 bytes, por lo que multiplicamos *4 todo (32bits RGB+ALPHA=4 bytes)
    DestAVI=iniAvi_desp
    'If DestAVI>(altovisual*(anchovisual*4)) Then Exit Sub
    for xAvi=0 to anchoAvi-1
    	If DestAVI>=0 And DestAVI<(anchovisual*4) Then ' si los pixeles salen del marco ventana, no se muestran
	      pScreen[DestAVI+0]=rgbBits[OrigAVI+0] ' azul
	      pScreen[DestAVI+1]=rgbBits[OrigAVI+1] ' rojo
	      pScreen[DestAVI+2]=rgbBits[OrigAVI+2] ' verde
    	End If
      ' si esta habilitado el modo expandir(0), expandimos en horizontal
      ' para ellopintamos un pixel repetido igual al anterior, pero un pixel mas a la derecha
      ' e incrmentados x8, en lugar de x4 (8 bytes de datos, en vez de 4)
      If expandir=0 Then 
      	If DestAVI>=0 And DestAVI<(anchovisual*4) Then ' si los pixeles salen del marco ventana, no se muestran
	      	pScreen[DestAVI+4]=rgbBits[OrigAVI+0] ' azul
	      	pScreen[DestAVI+5]=rgbBits[OrigAVI+1] ' rojo
	      	pScreen[DestAVI+6]=rgbBits[OrigAVI+2] ' verde
      	End if
      	DestAVI+=8
      Else
      	DestAVI+=4
      EndIf
      OrigAVI+=3
    next
    pScreen-=((anchovisual)*4)
    
  Next
  ScreenUnLock
  
  'sleep 1000\25

End Sub

Sub CerrarVideo()
  AVIStreamRelease(avistream)
  AVIFileRelease(avifile)
  AVIFileExit
End Sub