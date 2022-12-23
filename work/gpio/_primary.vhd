library verilog;
use verilog.vl_types.all;
entity gpio is
    port(
        clk             : in     vl_logic;
        rst             : in     vl_logic;
        BUS_W           : out    vl_logic;
        BUS_WDATA       : out    vl_logic_vector(7 downto 0);
        BUS_RDATA       : in     vl_logic_vector(7 downto 0);
        pins            : inout  vl_logic_vector(5 downto 0)
    );
end gpio;
