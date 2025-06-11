# Tareas
Tabla “Empresas”
Esta tabla contiene información sobre las empresas que realizan ventas dentro de nuestro sistema hipotético.
Incluye columnas como:

el identificador único de la empresa (ID),

el número de teléfono,

la dirección de correo electrónico,

el nombre del país en el que opera la empresa,

y el enlace a su sitio web.

Tabla “Transacciones”
Esta tabla almacena información general sobre todas las transacciones realizadas por las empresas dentro de nuestro sistema de análisis.
Incluye columnas como:

el ID de la transacción,

el ID de la tarjeta de crédito utilizada,

el ID de la empresa (identificador único que se relaciona con la tabla “Empresas”),

el identificador único del usuario,

las coordenadas geográficas: latitud (Lat) y longitud (Longitude), que indican el lugar donde se realizó la transacción,

Timestamp, que registra la fecha y hora de la operación,

Amount, que representa el importe de la transacción en unidades monetarias,

Declined, una variable booleana que indica el estado de la operación: si la transacción fue exitosa, se registra un 0; si fue rechazada, se registra un 1.