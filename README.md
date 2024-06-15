# Comunicación SPI en Nexys A7

Este repositorio contiene el proyecto desarrollado para la asignatura "Diseño Avanzado de Sistemas Digitales - IPD 432". El objetivo principal del proyecto es diseñar e implementar un módulo maestro para la comunicación SPI en la FPGA Nexys A7, utilizando el acelerómetro ADXL362 como dispositivo esclavo.

## Estructura del Informe

El informe se estructura en las siguientes secciones:

1. **Protocolo de Comunicación SPI**: Se describe el protocolo SPI, sus ventajas, desventajas y modos de operación.
2. **Consideraciones para la Descripción de un Maestro SPI Generalizado**: Se detallan los parámetros y configuraciones necesarias para crear un módulo maestro SPI adaptable a diversos esclavos.
3. **Implementación en SystemVerilog del Protocolo SPI para Nexys A7**: Se presenta la implementación específica del módulo maestro SPI y los módulos necesarios para la comunicación con el acelerómetro ADXL362 en la FPGA Nexys A7.
4. **Resultados y Conclusiones**: Se resumen los resultados obtenidos, las mejoras propuestas y posibles expansiones futuras del proyecto.

## Archivos del Repositorio

- `sources/`: Contiene los archivos source de la descripción en SystemVerilog.
- `constrains/`: Archivo constrain para la NEXYS A7.
- `simulations/`: Archivo testbench utilizado para probar algunos módulos.

## Implementación y reutilización

Los módulos SPI_Master y SPI_Master_core controlan la dinámica entre las señales SCLK, MISO, MOSI y CS, permitiendo configurar parámetros como la cantidad de bytes a enviar, la frecuencia del reloj, el modo de operación, entre otros. La implementación se validó mediante la comunicación con el acelerómetro ADXL362, visualizando los datos en el display de la FPGA.

En caso de querer utilizar el maestro SPI para comunicarse con un esclavo diferente al de esta implementación, basta con reutilizar los módulos SPI_Master y SPI_Master_core. En el módulo SPI_Master_core se puede modificar el modo de operación mediante i_CPOL y i_CPHA, la frecuencia del reloj con CLKS_PER_HALF_BIT y i_Clk, y la información a enviar con i_TX_Byte y i_TX_DV. En el módulo SPI_Master se puede modificar lo ante mencionado, además de la cantidad de bytes por ciclo de CS con MAX_BYTES_PER_CS y la cantidad de ciclos inactivos entre byte enviado con CS_INACTIVE_CLKS. En caso de tener que conectar el maestro SPI con más de un esclavo SPI o en una configuración diferente, se recomienda cambiar la lógica de SPI_Master, manteniendo intacto SPI_Master_core. Finalmente, las demás señales de flag servirán para interactuar con la posible lógica que requiera el nuevo esclavo a comunicar.

## Referencias y material útil

1. [ADXL362 Micropower, 3-Axis, ±2 g/±4 g/±8 g Digital Output MEMS Accelerometer](https://www.analog.com/en/products/adxl362.html)
2. [Nexys A7 Reference Manual](https://digilent.com/reference/programmable-logic/nexys-a7/reference-manual)
3. [Introduction to SPI Interface](https://www.analog.com/en/resources/analog-dialogue/articles/introduction-to-spi-interface.html)
4. J. Chen and S. Huang, “Analysis and Comparison of UART, SPI and I2C,” in 2023 IEEE 2nd International Conference on Electrical Engineering, Big Data and Algorithms (EEBDA), 2023, pp. 272–276.
5. [https://www.youtube.com/watch?v=7b3YwQWwvXM&t=583s](https://youtu.be/7b3YwQWwvXM?si=DtBLZ9bwVR7rxoHE)
6. https://youtube.com/playlist?list=PLnAoag7Ew-vq5kOyfyNN50xL718AtLoCQ&si=sktsFU4r6KqfFhP_
