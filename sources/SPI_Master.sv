///////////////////////////////////////////////////////////////////////////////
// Afiliacion: UTFSM
// Autor: Felipe Torres
// Nombre del modulo: SPI_Master
// Descripcion: 
//				SPI (Serial Peripheral Interface) Master
//              Con capacidad de chip-select único (también conocido como Slave Select).
//              Soporta transferencias de multiples bytes tanto para envio como recepcion.
//              Instancia un SPI Master y agrega un único CS.
//              Si se necesitan múltiples señales CS, será necesario usar un 
//              módulo diferente, O multiplexar el CS en un bloque externo.
// Nota:        
//				i_Clk debe ser al menos 2 veces más rápido que i_SPI_Clk, en otras palabras,
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
// Commentarios adicionales:
//				Base utilizada de los codigos del ramo IPD432, ademas de los repositorios
//				https://github.com/gcarvajalb/IPD432-reference-modules
//				https://github.com/FPGADude/Digital-Design/tree/main/FPGA%20Projects/Nexys%20A7%203-Axis%20Accelerometer%20SPI
//				https://github.com/nandland/spi-master/tree/master
///////////////////////////////////////////////////////////////////////////////

module SPI_Master
  #(
    parameter CLKS_PER_HALF_BIT = 2,
    parameter MAX_BYTES_PER_CS = 10,
    parameter CS_INACTIVE_CLKS = 0
    )
  (
   //////////////// Senales de Control ////////////////////////////
   input  logic        i_Rst,           					  // Reset desde la FPGA
   input  logic        i_Clk,           					  // Reloj principal desde la FPGA
   input logic         i_CPOL,         						  // Polaridad segun el modo de comunicacion
   input logic         i_CPHA,         						  // Fase segun el modo de comunicacion
   
   /////////////// TX (MOSI) senales ////////////////////////////////
   input  logic [$clog2(MAX_BYTES_PER_CS+1)-1:0] i_TX_Count,  // Numero de bytes a transmitir por cada CS que se active, directo control sobre el reloj.
   input  logic [7:0]  i_TX_Byte,       				      // Byte a transmitir MOSI
   input  logic        i_TX_DV,        						  // Flag de informacion valida relacionado a i_TX_Byte
   output logic        o_TX_Ready,      					  // Flag de transmicion lista de TX_Byte
   
   /////////////// RX (MISO) senales ////////////////////////////////
   output logic [$clog2(MAX_BYTES_PER_CS+1)-1:0] o_RX_Count,  // Numero de bytes recibidos
   output logic        o_RX_DV,     						  // Flag de informacion valida de recepcion 
   output logic [7:0]  o_RX_Byte,   					      // Byte recibido MOSI

   /////////////// Interfaz SPI ////////////////////////////////
   output logic        o_SPI_Clk,							  // Reloj utilizado en la sincronizacion de la transmicion de informacion
   input  logic        i_SPI_MISO,							  // Senal de informacion bit a bit desde el slave hacia el master	
   output logic        o_SPI_MOSI,							  // Senal de informacion bit a bit desde el master hacia el slave
   output logic        o_SPI_CS_n							  // Senal que activa o desactiva la comunicacion con el slave
   );

  ////////////////// Definicion Estados //////////////////////////
  typedef enum logic [3:0] {IDLE, TRANSFER, CS_INACTIVE} state_t;
  state_t r_SM_CS;
  
  ///////////////// Variables auxiliares ////////////////////////
  logic r_CS_n;
  logic [$clog2(CS_INACTIVE_CLKS)-1:0] r_CS_Inactive_Count;
  logic [$clog2(MAX_BYTES_PER_CS+1)-1:0] r_TX_Count;
  logic w_Master_Ready;

  //////////////// Instancia SPI Master core //////////////////////
  SPI_Master_core
	  #(
      .CLKS_PER_HALF_BIT(CLKS_PER_HALF_BIT)
      )
      SPI_Master_core
       (
       //////////////// Senales de Control ////////////////////////////
       .i_Rst(i_Rst),             		
       .i_Clk(i_Clk),             		
       .i_CPOL(i_CPOL),           		
       .i_CPHA(i_CPHA),           		
       
       /////////////// TX (MOSI) senales ////////////////////////////////
       .i_TX_Byte(i_TX_Byte),        	
       .i_TX_DV(i_TX_DV),            	
       .o_TX_Ready(w_Master_Ready),  	
       
       /////////////// RX (MISO) senales ////////////////////////////////
       .o_RX_DV(o_RX_DV),       		
       .o_RX_Byte(o_RX_Byte),   		
    
       /////////////// Interfaz SPI ////////////////////////////////
       .o_SPI_Clk(o_SPI_Clk),			
       .i_SPI_MISO(i_SPI_MISO),			
       .o_SPI_MOSI(o_SPI_MOSI)			
       );

  // Bloque encargado de controlar la senal CS utilizando una maquina de estados
  always_ff @(posedge i_Clk or posedge i_Rst)
  begin
    if (i_Rst)
    begin
      r_SM_CS <= IDLE;
      r_CS_n  <= 1'b1;   						// Normalmente en alto, al resetear se lleva a este valor normal
      r_TX_Count <= 0;
      r_CS_Inactive_Count <= CS_INACTIVE_CLKS;
    end
    else
    begin

      case (r_SM_CS)      
      IDLE:
        begin
          if (r_CS_n & i_TX_DV) 				// Inicio de la transmicion.
          begin
            r_TX_Count <= i_TX_Count - 1'b1; 	// Registro del contador de transmicion.
            r_CS_n     <= 1'b0;       			
            r_SM_CS    <= TRANSFER;  			
          end
        end

      TRANSFER:
        begin
          // Se espera que finalice una transmicion antes de comenzar la siguiente.
          if (w_Master_Ready)
          begin
            if (r_TX_Count > 0)
            begin
              if (i_TX_DV)
              begin
                r_TX_Count <= r_TX_Count - 1'b1;
              end
            end
            else
            begin
              r_CS_n  <= 1'b1; 					// Al terminar la transmicion se vuelve el CS a alto.
              r_CS_Inactive_Count <= CS_INACTIVE_CLKS;
              r_SM_CS             <= CS_INACTIVE;
            end 
          end 
        end 

      CS_INACTIVE:
        begin
          if (r_CS_Inactive_Count > 0)
          begin
            r_CS_Inactive_Count <= r_CS_Inactive_Count - 1'b1;
          end
          else
          begin
            r_SM_CS <= IDLE;
          end
        end

      default:
        begin
          r_CS_n  <= 1'b1;
          r_SM_CS <= IDLE;
        end
      endcase
    end
  end 

  // Bloque encargado de mantener la cuenta de bytes recibidos.
  always_ff @(posedge i_Clk)
  begin
    if (r_CS_n)
    begin
      o_RX_Count <= 0;
    end
    else if (o_RX_DV)
    begin
      o_RX_Count <= o_RX_Count + 1'b1;
    end
  end
  
  // Se conecta la salida CS con el registro interno que guarda el valor de CS.
  assign o_SPI_CS_n = r_CS_n;
  // Se define en alto cuando se ha terminado de enviar un byte, esto puede ser cuando se envia solo 1 o varios bytes.
  assign o_TX_Ready  = ((r_SM_CS == IDLE) | (r_SM_CS == TRANSFER && w_Master_Ready == 1'b1 && r_TX_Count > 0)) & ~i_TX_DV;

endmodule 
