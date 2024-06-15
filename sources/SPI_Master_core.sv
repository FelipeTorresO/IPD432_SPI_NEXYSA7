///////////////////////////////////////////////////////////////////////////////
// Afiliacion: UTFSM
// Autor: Felipe Torres
// Nombre del modulo: SPI_Master_core
// Descripcion: 
//				SPI (Serial Peripheral Interface) Master core.
//              Este modulo describe un master basado en la configuracion de entrada.
//              Envia un byte (8 bits) un bit a la vez en MOSI.
//              Tambien recibira datos byte en MISO, respetando un bit a la vez.
//              Para iniciar la operacion, el usuario debe utilizar i_TX_DV.
//              Este modulo soporta transmisiones de multiples bytes utilizando
//              i_TX_DV y cargando i_TX_Byte.
//              Este modulo es responsable unicamente de controlar SPI_Clk, SPI_MOSI
//              y SPI_MISO. Si el periferico SPI requiere un chip-select,
//              esto debe hacerse a un nivel superior.
// Nota:        
//				i_Clk debe ser al menos 2 veces mas rápido que i_SPI_Clk, en otras palabras,
//				el reloj generado por la comunicacion sera siempre menor al reloj principal.
//				Se utiliza nomenclatura con i_Variable o o_variable para refereirse si la senal
//				entra o sale del modulo.
// Parametros: 
//              CLKS_PER_HALF_BIT - Establece la frecuencia de o_SPI_Clk. o_SPI_Clk se
//              deriva de i_Clk. Configurado a un numero entero de ciclos de reloj para cada
//              medio bit de datos SPI. Ej. i_Clk de 100 MHz, CLKS_PER_HALF_BIT = 2
//              crearia un o_SPI_CLK de 25 MHz. Debe ser >= 2.
// Commentarios adicionales:
//				Base utilizada de los codigos del ramo IPD432, ademas de los repositorios
//				https://github.com/gcarvajalb/IPD432-reference-modules
//				https://github.com/FPGADude/Digital-Design/tree/main/FPGA%20Projects/Nexys%20A7%203-Axis%20Accelerometer%20SPI
//				https://github.com/nandland/spi-master/tree/master
///////////////////////////////////////////////////////////////////////////////

module SPI_Master_core
  #(
  parameter CLKS_PER_HALF_BIT = 2		// Parametro que define cuantas cuentas se haran del reloj principal
  )										// para generar el reloj de la comunicacion SPI (o_SPI_Clk)
  (
   //////////////// Senales de Control ////////////////////////////
   input logic         i_Rst,           // Reset desde la FPGA
   input logic         i_Clk,           // Reloj principal desde la FPGA
   input logic         i_CPOL,          // Polaridad segun el modo de comunicacion
   input logic         i_CPHA,          // Fase segun el modo de comunicacion
   
   
   /////////////// TX (MOSI) senales ////////////////////////////////
   input logic [7:0]   i_TX_Byte,       // Byte a transmitir MOSI
   input logic         i_TX_DV,         // Flag de informacion valida relacionado a i_TX_Byte
   output logic        o_TX_Ready,      // Flag de transmicion lista de TX_Byte
   
   /////////////// RX (MISO) senales ////////////////////////////////
   output logic        o_RX_DV,         // Flag de informacion valida de recepcion 
   output logic [7:0]  o_RX_Byte,       // Byte recibido MOSI

   /////////////// Interfaz SPI ////////////////////////////////
   output logic        o_SPI_Clk,		// Reloj utilizado en la sincronizacion de la transmicion de informacion
   input logic         i_SPI_MISO,		// Senal de informacion bit a bit desde el slave hacia el master
   output logic        o_SPI_MOSI		// Senal de informacion bit a bit desde el master hacia el slave
   );

  // Variables auxiliares como registros y flags
  logic [$clog2(CLKS_PER_HALF_BIT*2)-1:0] r_SPI_Clk_Count;
  logic r_SPI_Clk;
  logic [4:0] r_SPI_Clk_Edges;
  logic r_Leading_Edge;
  logic r_Trailing_Edge;
  logic r_TX_DV;
  logic [7:0] r_TX_Byte;
  logic [2:0] r_RX_Bit_Count;
  logic [2:0] r_TX_Bit_Count;


  // Bloque encargado de generar el Clock SPI el numero correcto de veces cuando se recibe un pulso de TX_DV
  always_ff @(posedge i_Clk or posedge i_Rst)
  begin
    if (i_Rst)
    begin
      o_TX_Ready      <= 1'b0;
      r_SPI_Clk_Edges <= 0;
      r_Leading_Edge  <= 1'b0;
      r_Trailing_Edge <= 1'b0;
      r_SPI_Clk       <= i_CPOL; 							// Se asigna la polaridad correspondiente al resetear
      r_SPI_Clk_Count <= 0;
    end
    else
    begin

      // Asignaciones default para las flags del canto de reloj SPI
      r_Leading_Edge  <= 1'b0;
      r_Trailing_Edge <= 1'b0;
      
      if (i_TX_DV)
      begin
        o_TX_Ready      <= 1'b0;
        r_SPI_Clk_Edges <= 16;  							// Numero total de cantos necesarios para un byte (Siempre 16)
      end
      else if (r_SPI_Clk_Edges > 0)
      begin
        o_TX_Ready <= 1'b0;
        
        if (r_SPI_Clk_Count == CLKS_PER_HALF_BIT*2-1)
        begin
          r_SPI_Clk_Edges <= r_SPI_Clk_Edges - 1'b1;
          r_Trailing_Edge <= 1'b1;
          r_SPI_Clk_Count <= 0;
          r_SPI_Clk       <= ~r_SPI_Clk;
        end
        else if (r_SPI_Clk_Count == CLKS_PER_HALF_BIT-1)
        begin
          r_SPI_Clk_Edges <= r_SPI_Clk_Edges - 1'b1;
          r_Leading_Edge  <= 1'b1;
          r_SPI_Clk_Count <= r_SPI_Clk_Count + 1'b1;
          r_SPI_Clk       <= ~r_SPI_Clk;
        end
        else
        begin
          r_SPI_Clk_Count <= r_SPI_Clk_Count + 1'b1;
        end
      end  
      else
      begin
        o_TX_Ready <= 1'b1;
      end
      
      
    end 
  end 

  // Registro de i_TX_Byte cuando el flag de informacion valida en la transmicion es pulsado.
  always_ff @(posedge i_Clk or posedge i_Rst)
  begin
    if (i_Rst)
    begin
      r_TX_Byte <= 8'h00;
      r_TX_DV   <= 1'b0;
    end
    else
    begin
      r_TX_DV <= i_TX_DV; 
      if (i_TX_DV)
      begin
        r_TX_Byte <= i_TX_Byte;
      end
    end 
  end


  // Bloque encargado de generar la informacion del MOSI, funciona en cualquier modo de fase.
  always_ff @(posedge i_Clk or posedge i_Rst)
  begin
    if (i_Rst)
    begin
      o_SPI_MOSI     <= 1'b0;
      r_TX_Bit_Count <= 3'b111; 							// Por el protocolo, se envia el MSB primero.
    end
    else
    begin
      // Si la flag ready esta en alto, se resetea la cuenta de bits al default.
      if (o_TX_Ready)
      begin
        r_TX_Bit_Count <= 3'b111;
      end
      else if (r_TX_DV & ~i_CPHA)
      begin
        o_SPI_MOSI     <= r_TX_Byte[3'b111];
        r_TX_Bit_Count <= 3'b110;
      end
      else if ((r_Leading_Edge & i_CPHA) | (r_Trailing_Edge & ~i_CPHA))
      begin
        r_TX_Bit_Count <= r_TX_Bit_Count - 1'b1;
        o_SPI_MOSI     <= r_TX_Byte[r_TX_Bit_Count];
      end
    end
  end


  // Bloque encargado de leer la ifnormacion de MISO.
  always_ff @(posedge i_Clk or posedge i_Rst)
  begin
    if (i_Rst)
    begin
      o_RX_Byte      <= 8'h00;
      o_RX_DV        <= 1'b0;
      r_RX_Bit_Count <= 3'b111;
    end
    else
    begin

      // Asignaciones default para la flag de validez en la recepcion de informacion.
      o_RX_DV   <= 1'b0;

      if (o_TX_Ready)
      begin
        r_RX_Bit_Count <= 3'b111;
      end
      else if ((r_Leading_Edge & ~i_CPHA) | (r_Trailing_Edge & i_CPHA))
      begin
        o_RX_Byte[r_RX_Bit_Count] <= i_SPI_MISO; 
        r_RX_Bit_Count            <= r_RX_Bit_Count - 1'b1;
        if (r_RX_Bit_Count == 3'b000)
        begin
          o_RX_DV   <= 1'b1;  
        end
      end
    end
  end

  
  // Bloque para alinear senales.
  always_ff @(posedge i_Clk or posedge i_Rst)
  begin
    if (i_Rst)
    begin
      o_SPI_Clk  <= i_CPOL;
    end
    else
    begin
      o_SPI_Clk <= r_SPI_Clk;
    end 
  end 
  

endmodule 
