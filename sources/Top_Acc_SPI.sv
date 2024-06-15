///////////////////////////////////////////////////////////////////////////////
// Afiliacion: UTFSM
// Autor: Felipe Torres
// Nombre del modulo: Top_Acc_SPI
// Descripcion: 
//				Top para la conexion entre los modulos encargados de generar las señales de la 
//				comunicacion SPI y mostrar la informacion proveniente del acelerometro en el display.
// Nota:        
//				i_Clk debe ser al menos 2 veces mas rapido que i_SPI_Clk, en otras palabras,
//				el reloj generado por la comunicacion sera siempre menor al reloj principal.
//				Se utiliza nomenclatura con i_Variable o o_variable para refereirse si la senal
//				entra o sale del modulo.
// Parametros: 
//              CLKS_PER_HALF_BIT - Establece la frecuencia de o_SPI_Clk. o_SPI_Clk se
//              deriva de i_Clk. Configurado a un numero entero de ciclos de reloj para cada
//              medio bit de datos SPI. Ej. i_Clk de 100 MHz, CLKS_PER_HALF_BIT = 2
//              crearia un o_SPI_CLK de 25 MHz. Debe ser >= 2.
//              MAX_BYTES_PER_CS - Configurado al numero maximo de bytes que
//              se enviaran durante un solo pulso CS bajo.
//              CS_INACTIVE_CLKS - Establece la cantidad de tiempo en ciclos de reloj para
//              mantener el estado de Chip-Select alto (inactivo) antes de que se
//              permita el siguiente comando en la linea. Util si el chip requiere
//              algun tiempo con CS alto entre transferencias.
//				MAX_WAIT - Maximo tiempo de espera para la maquina temporizada.
//				SIX_MS - Parametro de tiempo, para un reloj de 100MHz corresponde a seis milisegundos.
//				TEN_MS - Parametro de tiempo, para un reloj de 100MHz corresponde a diez milisegundos.
//				FOURTY_MS - Parametro de tiempo, para un reloj de 100MHz corresponde a cuarenta milisegundos.
// Commentarios adicionales:
//				Base utilizada de los codigos del ramo IPD432, ademas de los repositorios
//				https://github.com/gcarvajalb/IPD432-reference-modules
//				https://github.com/FPGADude/Digital-Design/tree/main/FPGA%20Projects/Nexys%20A7%203-Axis%20Accelerometer%20SPI
//				https://github.com/nandland/spi-master/tree/master
///////////////////////////////////////////////////////////////////////////////


module Top_Acc_SPI
    #(
	parameter CLKS_PER_HALF_BIT = 50,			// Necesario para 1MHz a partir de 100MHz.
    parameter MAX_BYTES_PER_CS_aux = 10,		// La comunicacion mas larga entre accelerometro y master SPI requiere 8 bytes, se dan 10 como holgura.
	parameter CS_INACTIVE_CLKS = 0,				// Cantidad de clock inactivo entre bytes enviados/recibidos.
	parameter MAX_WAIT = 5000000,      					   		 
    parameter SIX_MS = 600000,        			// Parametros de tiempo:
    parameter TEN_MS = 1000000,        			// Estos variaran dependiendo del reloj de entrada y lo que dija la hoja de datos,
    parameter FOURTY_MS = 4000000    			// de momento estan calculados para un reloj de entrada de 100MHz.
    )
    (
    input logic CLK100MHZ, CPU_RESETN,
    input logic ACL_MISO,                     
    output logic ACL_MOSI,                    
    output logic ACL_SCLK,                    
    output logic ACL_CSN,                     
    output logic [6:0]Segmentos,
    output logic [7:0]AN,
    output logic MISO, MOSI, SCLK, CSN        // Senales del pmod JA, utilizadas para leer con el analizador logico
    );
    
    // RESET Negado //////////////////////
    //Logica negada por la placa NEXYS7 y reset sincrono con ayuda del Double flopping
    logic PB_sync_aux;
    logic reset;
    logic reset_n;
    
    always_ff @(posedge CLK100MHZ) begin
            PB_sync_aux <= ~CPU_RESETN;
            reset <= PB_sync_aux;
    end
    //////////////////////////////////////
    
    // Modulo del clock //////////////////
    // Entrada el reloj de la placa 100MHz - dividido para formar el de 1000Hz
    logic clk_1KHz;
    
    Clock_Divider #(.f_in(100000000),.f_out(1000))
    Clock_Divider_1KHz
    (
    .clk_in(CLK100MHZ),
    .reset(reset),
    .clk_out(clk_1KHz)
    );
    /////////////////////////////////////
    
    // Modulo de Comunicacion_Acc //////
    // Señales auxiliares
    logic TX_Ready_aux;
    logic CPOL_aux;
    logic CPHA_aux;
	logic RX_DV_aux;
	logic [$clog2(MAX_BYTES_PER_CS_aux+1)-1:0] RX_Count_aux;
	logic [7:0] RX_Byte_aux;
	logic TX_DV_aux;
	logic [7:0] TX_Byte_aux;
	logic [$clog2(MAX_BYTES_PER_CS_aux+1)-1:0] TX_Count_aux;  
	logic [47:0] To_Seven_Seg_aux;
	
	///// Modulo logica acelerometro ////
	//Modulo instanciado sobre senales de comunicacion con el acelerometro
    Comunicacion_Acc
    #(
    .MAX_WAIT(MAX_WAIT),                        
    .SIX_MS(SIX_MS),                          
    .TEN_MS(TEN_MS),                          
    .FOURTY_MS(FOURTY_MS),                      
    .MAX_BYTES_PER_CS(MAX_BYTES_PER_CS_aux)     // Debe ser el mismo valor que en el modulo de Master_SPI
    )
    Comunicacion_Acc_inst
    (
	.clk(CLK100MHZ), 
	.rst(reset), 
	.TX_Ready(TX_Ready_aux), 
	.RX_DV(RX_DV_aux),
	.RX_Count(RX_Count_aux),
	.RX_Byte(RX_Byte_aux),
	.TX_DV(TX_DV_aux),
	.CPOL(CPOL_aux),
	.CPHA(CPHA_aux),
	.TX_Byte(TX_Byte_aux),
	.TX_Count(TX_Count_aux),  
	.To_Seven_Seg(To_Seven_Seg_aux)
	);
    /////////////////////////////////////
    
    // Modulo de Master_SPI //////
    SPI_Master
    #(
    .CLKS_PER_HALF_BIT(CLKS_PER_HALF_BIT),                     
    .MAX_BYTES_PER_CS(MAX_BYTES_PER_CS_aux),
    .CS_INACTIVE_CLKS(CS_INACTIVE_CLKS)
    )
    SPI_Master
    (
    //////////////// Senales de Control //////////
    .i_Rst(reset),                  
    .i_Clk(CLK100MHZ),              
    .i_CPOL(CPOL_aux),             
    .i_CPHA(CPHA_aux),              
    
    /////////////// TX (MOSI) senales ////////////
    .i_TX_Count(TX_Count_aux),      
    .i_TX_Byte(TX_Byte_aux),        
    .i_TX_DV(TX_DV_aux),            
    .o_TX_Ready(TX_Ready_aux),      
    
    /////////////// RX (MISO) senales ///////////
    .o_RX_Count(RX_Count_aux),      
    .o_RX_DV(RX_DV_aux),            
    .o_RX_Byte(RX_Byte_aux),       
    
    /////////////// Interfaz SPI //////////////
    .o_SPI_Clk(ACL_SCLK),			
    .i_SPI_MISO(ACL_MISO),			
    .o_SPI_MOSI(ACL_MOSI),			
    .o_SPI_CS_n(ACL_CSN)			
    );
    /////////////////////////////////////
    
    // Modulo de Seven_Seg_Logic ////////
    Seven_Seg_Logic
    Seven_Seg_Logic
    (
    .clk(clk_1KHz), 
    .rst(reset),
    .Data_Acc(To_Seven_Seg_aux),
    .Segmentos(Segmentos),
    .AN(AN)
    );
    /////////////////////////////////////
    
    // Senales para ser vista mediante el analizador logico //////
	// Corresponden a los pines 1,2,3 y 4 del pmod JA.
	assign MISO = ACL_MISO;  		// 1
    assign MOSI = ACL_MOSI;			// 2
    assign SCLK = ACL_SCLK;			// 3
    assign CSN = ACL_CSN;			// 4
	//////////////////////////////////////////////////////////////

endmodule
