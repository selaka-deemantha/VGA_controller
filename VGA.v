
// Revision 0.04 - Change for 640x480@72Hz and output signals 'activevideo'
//                 and 'px_clk'.

module vga_controller (
            input wire       clk,           // Input clock: 12MHz
                  // Color RGB (8 colors) for actual pixel.
            output wire      hsync,         // Horizontal sync out
            output wire      vsync,         // Vertical sync out
            output reg       red_monitor,   // RED vga outputapio --board icezum
            output reg       green_monitor, // GREEN vga output
            output reg       blue_monitor);
    wire      px_clk;
    reg [9:0] x_px;      // X position for actual pixel.
    reg [9:0] y_px;
    wire      activevideo;
//                         red green blue
    wire [2:0] color_px=3'b111;

    Gowin_rPLL your_instance_name(
        .clkout(px_clk), //output clkout
        .clkin(clk) //input clkin
    );

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
      x_px <= 0;
      y_px <= 0;
      hc <= 0;
      vc <= 0;
      red_monitor <= 0;
      green_monitor <= 0;
      blue_monitor <= 0;
    end

    // Counting pixels.
    always @(posedge px_clk)
    begin
        // Keep counting until the end of the line.
        if (hc < hpixels - 1)
            hc <= hc + 1;
        else
        // When we hit the end of the line, reset the horizontal
        // counter and increment the vertical counter.
        // If vertical counter is at the end of the frame, then
        // reset that one too.
        begin
            hc <= 0;
            if (vc < vlines - 1)
            vc <= vc + 1;
        else
           vc <= 0;
        end
     end

    // Generate sync pulses (active low) and active video.
    assign hsync = (hc >= hfp && hc < hfp + hpulse) ? 0:1;
    assign vsync = (vc >= vfp && vc < vfp + vpulse) ? 0:1;
    assign activevideo = (hc >= blackH && vc >= blackV) ? 1:0;

    // Generate color.
    always @(posedge px_clk)
    begin
        // First check if we are within vertical active video range.
        if (activevideo)
        begin
            red_monitor <= color_px[2];
            green_monitor <= color_px[1];
            blue_monitor <= color_px[0];
            x_px <= hc - blackH;
            y_px <= vc - blackV;
        end
        else
        // We are outside active video range so display black.
        begin
            red_monitor <= 0;
            green_monitor <= 0;
            blue_monitor <= 0;
            x_px <= 0;
            y_px <= 0;
        end
     end
 endmodule