///////////////////////////////////////////////////////////////////////////////////
// Afiliacion: UTFSM
// Autor: Felipe Torres
// Nombre del modulo: Seven_Seg_Logic
// Descripcion: 
//				Bloque encargado de recibir la informacion proveniente del acelerometro y
//				generar las senales correspondientes para mostrarla en el display.
// Commentarios adicionales:
//				Base utilizada de los codigos del ramo IPD432, ademas del repositorio
//				https://github.com/gcarvajalb/IPD432-reference-modules
//////////////////////////////////////////////////////////////////////////////////


module Seven_Seg_Logic
	(
    input logic  clk, rst,
    input logic [47:0] Data_Acc,
    output logic [6:0] Segmentos,
    output logic [7:0] AN
    );
    
    ////////////// Bloque del contador ////////////////////
    // Este se encarga de rotar que display se enciende
    logic [2:0] cuenta_3bits;
    
    Contador_segmentos
    Contador_segmentos
    (
    .clk(clk), 
    .reset(rst),
    .cuenta(cuenta_3bits) 
    );
    //////////////////////////////////////////
    
    //////////////////////////////////////////
    
    // Bloques de conversion de binario a bcd
    // conversion informacion en x
    logic [7:0] bcd_x;
    
    unsigned_to_bcd
    unsigned_to_bcd_x
    (
     .bin(Data_Acc[10:7]),
     .bcd_out(bcd_x)
    );
    
    // conversion informacion en y
    logic [7:0] bcd_y;
    
    unsigned_to_bcd
    unsigned_to_bcd_y
    (
     .bin(Data_Acc[26:23]),
     .bcd_out(bcd_y)
    );
    
    // conversion informacion en z
    logic [7:0] bcd_z;
    
    unsigned_to_bcd
    unsigned_to_bcd_z
    (
     .bin(Data_Acc[42:39]),
     .bcd_out(bcd_z)
    );
    
    //////////////////////////////////////////
    
    // Multiplexor que selecciona que informacion se muestra en los 8 displays
    logic [3:0] display_selec;
    
    always_comb begin
       case(cuenta_3bits)
           3'd0 : display_selec = bcd_z[3:0];// z unidad
           3'd1 : display_selec = bcd_z[7:4];// z decena
           3'd2 : display_selec = bcd_y[3:0];// y unidad
           3'd3 : display_selec = bcd_y[7:4];// y decena
           3'd4 : display_selec = bcd_x[3:0];// x unidad
           3'd5 : display_selec = bcd_x[7:4];// x decena
           3'd6 : display_selec =4'b1111;// apagado
           3'd7 : display_selec =4'b1111;// apagado
           default : display_selec = 4'b1111;
       endcase
    end
    //////////////////////////////////////////
    
    // Display negado ////////////////////////
    // La informacion que entra a este modulo es la que se muestra por el display
    
    Display_negado
    Display_negado
    (
    .BCD(display_selec),
    .Seven(Segmentos)
    );
    //////////////////////////////////////////
    
    // Decoder Anodo /////////////////////////
    // Bloque encargado de rotar el cierre del circuito de los display para que enciendan
    
    Decoder_AN
    Decoder_AN
    (
    .cuenta(cuenta_3bits),
    .decoder_out(AN)
    );
    /////////////////////////////////////////
    
endmodule
