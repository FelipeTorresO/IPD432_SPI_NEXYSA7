# Comunicación SPI en Nexys A7

Este repositorio contiene el proyecto desarrollado para la asignatura "Diseño Avanzado de Sistemas Digitales - IPD 432". El objetivo principal del proyecto es diseñar e implementar un módulo maestro para la comunicación SPI en la FPGA Nexys A7, utilizando el acelerómetro ADXL362 como dispositivo esclavo.

## Introducción

La comunicación SPI (Serial Peripheral Interface) es un protocolo de comunicación síncrona ampliamente utilizado en sistemas digitales para la transferencia de datos entre dispositivos integrados. Este proyecto busca diseñar un módulo maestro SPI generalizado que pueda interactuar con diferentes dispositivos esclavos, optimizando su reutilización en diversas aplicaciones.

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

## Implementación

Los módulos SPI_Master y Comunicacion_Acc controlan la dinámica entre las señales SCLK, MISO, MOSI y CS, permitiendo configurar parámetros como la cantidad de bytes a enviar, la frecuencia del reloj, el modo de operación, entre otros. La implementación se validó mediante la comunicación con el acelerómetro ADXL362, visualizando los datos en el display de la FPGA.

## Resultados

- El módulo maestro SPI se implementó de manera generalizada, permitiendo su reutilización con diferentes dispositivos esclavos.
- La comunicación SPI se verificó con éxito mediante un analizador lógico y la visualización de datos en el display de la FPGA.
- Se proponen mejoras futuras para soportar múltiples esclavos y explorar otras aplicaciones prácticas del sistema SPI.

## Referencias

1. [ADXL362 Micropower, 3-Axis, ±2 g/±4 g/±8 g Digital Output MEMS Accelerometer](https://www.analog.com/en/products/adxl362.html)
2. [Nexys A7 Reference Manual](https://digilent.com/reference/programmable-logic/nexys-a7/reference-manual)
3. [Introduction to SPI Interface](https://www.analog.com/en/resources/analog-dialogue/articles/introduction-to-spi-interface.html)
4. J. Chen and S. Huang, “Analysis and Comparison of UART, SPI and I2C,” in 2023 IEEE 2nd International Conference on Electrical Engineering, Big Data and Algorithms (EEBDA), 2023, pp. 272–276.
