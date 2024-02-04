module VGA_NEW(input wire clk,output wire hsync,vsync,output reg  red_monitor,green_monitor,blue_monitor);

wire      px_clk;
wire      activevideo;

Gowin_rPLL your_instance_name(.clkout(px_clk),.clkin(clk));


    // Video structure constants.
    parameter activeHvideo = 640;               // Width of visible pixels.
    parameter activeVvideo =  480;              // Height of visible lines.
    parameter hfp = 24;                         // Horizontal front porch length.
    parameter hpulse = 40;                      // Hsync pulse length.
    parameter hbp = 128;                        // Horizontal back porch length.
    parameter vfp = 9;                          // Vertical front porch length.
    parameter vpulse = 3;                       // Vsync pulse length.
    parameter vbp = 28;                         // Vertical back porch length.
    parameter blackH = hfp + hpulse + hbp;      // Hide pixels in one line.
    parameter blackV = vfp + vpulse + vbp;      // Hide lines in one frame.
    parameter hpixels = blackH + activeHvideo;  // Total horizontal pixels.
    parameter vlines = blackV + activeVvideo;   // Total lines.

    // Registers for storing the horizontal & vertical counters.
    reg [9:0] hc;
    reg [9:0] vc;

   // Initial values.
    initial
    begin
      hc <= 0;
      vc <= 0;
      red_monitor <= 0;
      green_monitor <= 0;
      blue_monitor <= 0;
    end

    // Counting pixels.
    always @(posedge px_clk)
    begin
        if (hc < hpixels - 1)
            hc <= hc + 1;
        else

        begin
            hc <= 0;
            if (vc < vlines - 1)
            vc <= vc + 1;
        else
           vc <= 0;
        end
     end

    // Generate sync pulses (active low) and active video.
    assign hsync = (hc >= 664 && hc < 704) ? 0:1;
    assign vsync = (vc >= 488 && vc < 490) ? 0:1;
    assign activevideo = (hc < 640 && vc < 480) ? 1:0;

    // Generate color.
    always @(posedge px_clk)
    begin
        // First check if we are within vertical active video range.
        if (activevideo)
        begin
            if(hc<320) begin
                red_monitor <= 1;
                green_monitor <= 0;
                blue_monitor <= 0;
            end
            else begin
                red_monitor <= 0;
                green_monitor <= 0;
                blue_monitor <= 1;
            end
        end
        else
        // We are outside active video range so display black.
        begin
            red_monitor <= 0;
            green_monitor <= 0;
            blue_monitor <= 0;

        end
     end
 endmodule