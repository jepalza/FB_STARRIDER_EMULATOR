# FB_STARRIDER_EMULATOR
Freebasic emulador (inconcluso) del juego Arcade LaserDisc StarRider

Actualizacion Octubre 2024:
gracias a SynaMax (SynaMaxMusic) he (hemos) logrado hacer funcionar el video sincronizado y los colores corregidos. Ahora se puede decir que funciona correcto, lo suficiente para poder jugar partidas !!!!

Este es el primer intento en el mundo de crear un emulador del juego StarRider Arcade LaserDisc.

Lo inicié aproximadamente en 2008, cuando aún nadie lo había intentado. Lleva abandonado unos 6 años, por problemas técnicos que impiden su continuación.
Algunos de esos problemas tienen que ver con la información obtenida desde la propia película del juego (la llamada "banda Manchester") que incluye datos del juego, como inercia, velocidad, curvatura/linealidad de los tramos de carretera, fuerza de cada curva, etc.

La única película existente que conzoco, me la pasaron hace muchos años, y la banda de datos no es 100% correcta debido a que se capturó la película con diferentes cuadros por segundo (¿variables?) lo que hacía que algunos de los datos daban saltos y se perdía información, haciendo que el juego acabara descompasado respecto al video, haciéndolo injugable.


Una gran fuente de inspiración ha sido:
http://www.dragons-lair-project.com/games/pages/sr.asp

------------------------------------------
Informacion
--
Para completar el emulador se necesita un VIDEO REAL al que poder extraer el MANCHESTER que indica el número de cuadro!!!!
puedo sacar los 42 datos de abajo (3 columnas por 14 filas), pero no puedoO sacar el número de cuadro, que son tres bytes mas
y que van , si no he investigado mal, en la fila 18 de los cuadros de sincronía (osea, arriba del todo, escondidos, no se ve, vendría antes de la primera línea visible)

en vista de que no puedo encontrar el cuadro leído, no encuentor manera de sincronizar el cuadro que leo de "mi actual vídeo", con el que el juego necesita.
Al no conseguir esa sincronía real, no hay manera de que el video vaya acompasado al juego, se lanza, o se retrasa, y se decompensa.
Es posible hacerlo compensando, pero no es lo mismo. puedo emular y decirle que el cuadro que he leído yo (de MI video), es el número "x", pero el juego tiene que creerselo, y si "mi" cuadro está desfasado, lo normal, dado que desconozco números de cuadros reales, se acaba descompensado

Haría falta un video real, leido con cuadros verdaderos, en los cuales, el cuadro "x" que pide el juego, sea el "x" del video.
o en su defecto, uno que contenga la linea manchester arriba.

mientras eso no ocurra, es difícil seguir emulando.

-------------------------------------------
Este emulador es mio al 100%, desarrollado a lo largo de muchos años de investigación, tanto mia propia como con ayuda de terceros (Matt ownby , auto del emulador Daphne).

Algunos videos publicados por mi en estos años:

https://www.youtube.com/watch?v=27pyGSNUNC4

https://www.youtube.com/watch?v=fSAn1RJJ1Eg

https://www.youtube.com/watch?v=tVKwQn9zctA


![Imagen starrider](https://github.com/jepalza/FB_STARRIDER_EMULATOR/blob/main/fb_starrider.png)

---------------------------------------
Información que ya conozco (retroingeniería):

![Imagen starrider](https://github.com/jepalza/FB_STARRIDER_EMULATOR/blob/main/info/ya_conocidos.png)
