# randomlist
A test project in flutter to list movies

******* ¿Cómo ejecutar la aplicación? *******

1. Clona el repositorio en tu entorno y carpeta deseados:
     git clone https://github.com/sitmorelia/randomlist.git

2. Navega en la consola al directorio del proyecto con el comando cd

3. Instala Flutter y las herramientas necesarias como visual studio code o tu editar preferido. Puedes encontrar información detallada en: https://docs.flutter.dev/

4. Instala las dependencias necesarias ejecutando el siguiente comando:
     flutter pub get

5. Selecciona la plataforma de ejecución (En caso de iOS y Android asegurate de ejecutar primero el emulador correspondiente)
     flutter run -d chrome
     flutter run -d <NOMBRE_DEL_DISPOSITIVO>
     flutter run -d ios

6. Iniciar la aplicación:
     flutter run


******* Preguntas teóricas *******

1. ¿Qué es Flutter y cuáles son sus principales ventajas? 
Es un framework para el desarrollo de aplicaciones multiplataforma que se basa en el lenguaje dart creado por Google. Las aplicaciones se construyen mediante la lógica de widgets que sería algo similar a los componentes en web. Entre sus ventajas están:
- Un sólo código para todas las plataformas, aunque esta puede ser una desventaja en rendimiento frente a los lenguajes nativos. Por lo tanto, programas una sola vez y puede correr en web, móviles y escritorio.
- Los widgets son una forma muy sencilla de construir aplicaciones en periodos de tiempo cortos.
- Cuenta con una amplia comunidad que permite la incrustación o uso de librerías y dependencias para no reinventar la rueda, pero esto puede ser una desventaja a largo plazo por las complicaciones que se presentan cuando librerías de terceros pierden compatibilidad.


2. ¿Qué es el widget Tree en Flutter y cómo funciona? 
Es la manera jerárquica en que se organizan los widgets, esto determina su visualización y comportamiento, es algo similar al DOM en web. Por ejemplo:

Scaffold( 
     appBar: AppBar(title: Text('Widget Tree Example')), 
     body: Column(
           children: Text(“Hola”), Text(“Mundo”),
)

Scaffold es el padre que tiene un AppBar y un Column, este último tiene como hijos a dos elementos Text. Conocer el widget Tree es importantes para comprender los contextos de acción de los widgets. 


3. Explique la diferencia entre StatelessWidget y StatefulWidget. 
Los StatelessWidget son widgets sin estado interno, es decir, que se espera no cambien durante la ejecución, se podría decir que son estáticos, aunque sí pueden emplear providers externos o manejar cambios a través del padre, pero sería complicarse un poco más la vida. Por otro lado, los StatefulWidget si cuentan con un estado interno para poder manipular su comportamiento o actualizarlos en tiempo de ejecución.

Un ejemplo super sencillo, si queremos que un campo aparezca o desaparezca de acuerdo al valor de un select, lo más sencillo es usar un stateful widget que permita reaccionar a los cambios de valor del select.


4. Explique el ciclo de vida de un StatefulWidget. ¿Cómo se pueden utilizar métodos como initState, didChangeDependencies y dispose? 
El ciclo de vida son las etapas por las que pasa un stateful widget desde que es creado hasta que es destruido, estas etapas nos sirven para realizar acciones en momentos clave. El ciclo de vida comienza con createState, initState, build, didChangeDependencies, setState y dispose.

initState se ejecuta cuando se monta el widget y nos sirve para realizar precargas, inicializar valores y configuraciones iniciales.

didChangeDependencies se ejecuta cuando hay cambios en el árbol, por ejemplo, si el padre recibió un cambio en su estado. Aquí podemos aprovechar para realizar acciones que dependan de cambios entre los diferentes componentes.

Finalmente, dispose se ejecuta cuando deseamos destruir el widget para que deje de consumir recursos, nos sirve para realizar acciones finales antes de que desaparezca del árbol, por ejemplo, cancelar acciones periódicas.


5. ¿Qué son los Future y Stream en Dart, y cómo se utilizan en Flutter? 
Los Future son procesos que permiten que los widget FutureBuilder se reconstruyen cuando una operación asíncrona termina su ejecución, por ejemplo, si realizamos la llamada a una API podemos emplear un Future para que el widget se construya y cambie automáticamente su estado cuando los resultados de la llamada a la API terminen.

Los Streams son mecanismos que nos permiten abrir un túnel o conexión asíncrona para recibir datos de manera continua, a diferencia del Future que solo recibe un valor, los Streams pueden recibir múltiples valores a lo largo del tiempo. Se emplean cuando deseamos recibir actualizaciones de manera continua. Son similares a los WebSockets en desarrollo web.


6. ¿Cómo se implementa la navegación entre pantallas en Flutter?
La navegación se emplea a través de un Navigator que es el encargado de gestionar la pila de navegación, una buena práctica en aplicaciones más robustas es usar algún gestor de rutas para mantener una mejor organización de todas las pantallas de la app.
