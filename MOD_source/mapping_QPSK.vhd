library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mapping_QPSK is
generic(
			kOutSize : positive := 14
			);
port(
		aReset : in std_logic;
		clk : in std_logic;
		val_in : in std_logic;
		datain : in std_logic_vector(3 downto 0);
		dataout_I0 : out std_logic_vector(kOutSize - 1 downto 0);
		dataout_Q0 : out std_logic_vector(kOutSize - 1 downto 0);
		dataout_I1 : out std_logic_vector(kOutSize - 1 downto 0);
		dataout_Q1 : out std_logic_vector(kOutSize - 1 downto 0)
		);
end entity;

architecture rtl of mapping_QPSK is

signal rdreq : std_logic;
signal dataout_fifo : std_logic_vector(3 downto 0);
signal rdusedw : std_logic_vector(15 downto 0);
type state_t is (state_SP, state_LP, state_UW, state_Data);
signal state, next_state : state_t;
signal counter_SP : integer range 0 to 31;
signal Num_SP : integer range 0 to 65535;
signal data_map0,data_map1 : std_logic_vector(1 downto 0);
signal data_MOD : std_logic;
signal LP_start,LP_end,frame_end,UW_end,Data_end : std_logic;
signal counter_LP : integer range 0 to 1088;
signal counter_UW : integer range 0 to 63;
signal counter_Data : integer range 0 to 479;
signal Num_UW : integer range 0 to 65;
signal PN_15 : std_logic_vector(14 downto 0);
constant cons_threshold1	: positive := 1365; --585*7=4095         
constant cons_threshold2	: positive := cons_threshold1*3;         
constant cons_QPSK : positive :=6000; -- 3052; --1365*sqrt(5)

begin
data_map0 <= datain( 3 downto 2);
data_map1 <= datain( 1 downto 0);

process(aReset,clk)
begin
	if aReset = '1' then
		dataout_I0 <= (others => '0');
		dataout_Q0 <= (others => '0');
		dataout_I1 <= (others => '0');
		dataout_Q1 <= (others => '0');	
	elsif rising_edge(clk) then
			case data_map0 is
				when "00" =>
						dataout_I0 <= std_logic_vector(to_signed(-cons_Qpsk, kOutSize));
						dataout_Q0 <= std_logic_vector(to_signed(-cons_Qpsk, kOutSize));
				when "01" =>
						dataout_I0 <= std_logic_vector(to_signed(cons_Qpsk, kOutSize));
						dataout_Q0 <= std_logic_vector(to_signed(-cons_Qpsk, kOutSize));
				when "10" =>
						dataout_I0 <= std_logic_vector(to_signed(-cons_Qpsk, kOutSize));
						dataout_Q0 <= std_logic_vector(to_signed(cons_Qpsk, kOutSize));
				when others =>
						dataout_I0 <= std_logic_vector(to_signed(cons_Qpsk, kOutSize));
						dataout_Q0 <= std_logic_vector(to_signed(cons_Qpsk, kOutSize));
			end case;
			case data_map1 is
				when "00" =>
						dataout_I1 <= std_logic_vector(to_signed(-cons_Qpsk, kOutSize));
						dataout_Q1 <= std_logic_vector(to_signed(-cons_Qpsk, kOutSize));
				when "01" =>
						dataout_I1 <= std_logic_vector(to_signed(cons_Qpsk, kOutSize));
						dataout_Q1 <= std_logic_vector(to_signed(-cons_Qpsk, kOutSize));
				when "10" =>
						dataout_I1 <= std_logic_vector(to_signed(-cons_Qpsk, kOutSize));
						dataout_Q1 <= std_logic_vector(to_signed(cons_Qpsk, kOutSize));
				when others =>
						dataout_I1 <= std_logic_vector(to_signed(cons_Qpsk, kOutSize));
						dataout_Q1 <= std_logic_vector(to_signed(cons_Qpsk, kOutSize));
			end case;
	end if;
end process;	
end rtl;