-- 20151211
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use std.textio.all;
use IEEE.std_logic_textio.all;

ENTITY Demod_Para_rduc_tb  IS 
END ;

architecture rtl_tb of Demod_Para_rduc_tb is

component	Demod_Para_rduc	is
generic	(
			kInSize  : positive :=12
		);
port	(
		aReset          : in  std_logic; 
		--clk_100         : in  std_logic;
		pclk_I			: in  std_logic;  -- 50MHz
		rclk           : in std_logic ; --75MHZ
		rclk_half		: in std_logic; -- 37.5MHz
		
		AD_d0_I			: in std_logic_vector(kInSize-1 downto 0);
		AD_d1_I			: in std_logic_vector(kInSize-1 downto 0);
		AD_d2_I			: in std_logic_vector(kInSize-1 downto 0);
		AD_d3_I           : in std_logic_vector(kInSize-1 downto 0);
		AD_d4_I			: in std_logic_vector(kInSize-1 downto 0);
		AD_d5_I           : in std_logic_vector(kInSize-1 downto 0);
		AD_d6_I           : in std_logic_vector(kInSize-1 downto 0);
		AD_d7_I           : in std_logic_vector(kInSize-1 downto 0);
		AD_d0_Q			: in std_logic_vector(kInSize-1 downto 0);
		AD_d1_Q			: in std_logic_vector(kInSize-1 downto 0);
		AD_d2_Q			: in std_logic_vector(kInSize-1 downto 0);
		AD_d3_Q           : in std_logic_vector(kInSize-1 downto 0);
		AD_d4_Q			: in std_logic_vector(kInSize-1 downto 0);
		AD_d5_Q           : in std_logic_vector(kInSize-1 downto 0);
		AD_d6_Q           : in std_logic_vector(kInSize-1 downto 0);
		AD_d7_Q           : in std_logic_vector(kInSize-1 downto 0);

		with_LDPC		: in std_logic;
		
		--err_test 	: out std_logic;
		--d_toFPGA2	 : out std_logic_vector(5 downto 0)
		dat_mux : out std_logic_vector(3 downto 0) ;
		val_mux : out std_logic
		
		);
end	component;

		constant kInSize : integer := 8;
		signal aReset           :  std_logic; 
		signal pclk_I			:  std_logic;  -- 50MHz
		signal rclk             :  std_logic ; --75MHZ
		signal rclk_half		:  std_logic; -- 37.5MHz
		signal AD_d0_I			:  std_logic_vector(kInSize-1 downto 0);
		signal AD_d1_I			:  std_logic_vector(kInSize-1 downto 0);
		signal AD_d2_I			:  std_logic_vector(kInSize-1 downto 0);
		signal AD_d3_I          :  std_logic_vector(kInSize-1 downto 0);
		signal AD_d4_I			:  std_logic_vector(kInSize-1 downto 0);
		signal AD_d5_I          :  std_logic_vector(kInSize-1 downto 0);
		signal AD_d6_I          :  std_logic_vector(kInSize-1 downto 0);
		signal AD_d7_I          :  std_logic_vector(kInSize-1 downto 0);
		signal AD_d0_Q			:  std_logic_vector(kInSize-1 downto 0);
		signal AD_d1_Q			:  std_logic_vector(kInSize-1 downto 0);
		signal AD_d2_Q			:  std_logic_vector(kInSize-1 downto 0);
		signal AD_d3_Q          :  std_logic_vector(kInSize-1 downto 0);
		signal AD_d4_Q			:  std_logic_vector(kInSize-1 downto 0);
		signal AD_d5_Q          :  std_logic_vector(kInSize-1 downto 0);
		signal AD_d6_Q          :  std_logic_vector(kInSize-1 downto 0);
		signal AD_d7_Q          :  std_logic_vector(kInSize-1 downto 0);
		signal with_LDPC		:  std_logic;
		signal dat_mux 			:  std_logic_vector(3 downto 0) ;
		signal val_mux 			:  std_logic;

begin
  -- 50M
  process
  begin
    pclk_I <= '0';
    wait for 15 ns;
    pclk_I <= '1';
    wait for 15 ns;
  end process;
  -- 75M
  process
  begin
    rclk <= '0';
    wait for 10 ns;
    rclk <= '1';
    wait for 10 ns;
  end process;
  -- 37.5M
  process
  begin
    rclk_half <= '0';
    wait for 20 ns;
    rclk_half <= '1';
    wait for 20 ns;
  end process;

  with_LDPC <= '0' ;

  aReset <= '0', '1' after 5 ns,'0' after 200 ns;

  ReadData: process(aReset, pclk_I)
            
           file infile : text  open read_mode is "e:\work_jl\c_s54\pj051\code\temp\201512\pinglc_QPSK_LDPC_v2.5_IF300_600_pj051_GH\modelsim\MatlabFiles\Mod_add_offset.txt";
            variable dl : line;
            variable f_I0_in, f_Q0_in, f_I1_in, f_Q1_in : integer;
            begin
            if aReset='1' then
              AD_d0_I <= (others => '0');
              AD_d1_I <= (others => '0');
              AD_d2_I <= (others => '0');
              AD_d3_I <= (others => '0');
              AD_d4_I <= (others => '0');
              AD_d5_I <= (others => '0');
              AD_d6_I <= (others => '0');
              AD_d7_I <= (others => '0');
              AD_d0_Q <= (others => '0');
              AD_d1_Q <= (others => '0');
              AD_d2_Q <= (others => '0');
              AD_d3_Q <= (others => '0');
              AD_d4_Q <= (others => '0');
              AD_d5_Q <= (others => '0');
              AD_d6_Q <= (others => '0');
              AD_d7_Q <= (others => '0');
              
            elsif rising_edge(pclk_I) then
              if not endfile(infile) then
                readline(infile, dl);
                read(dl, f_I0_in);
                AD_d0_I <= std_logic_vector(to_signed(f_I0_in,8));
                read(dl, f_Q0_in);
                AD_d0_Q <= std_logic_vector(to_signed(f_Q0_in,8));

				        readline(infile, dl);
                read(dl, f_I0_in);
                AD_d1_I <= std_logic_vector(to_signed(f_I0_in,8));
                read(dl, f_Q0_in);
                AD_d1_Q <= std_logic_vector(to_signed(f_Q0_in,8));

                readline(infile, dl);
                read(dl, f_I0_in);
                AD_d2_I <= std_logic_vector(to_signed(f_I0_in,8));
                read(dl, f_Q0_in);
                AD_d2_Q <= std_logic_vector(to_signed(f_Q0_in,8));

                readline(infile, dl);
                read(dl, f_I0_in);
                AD_d3_I <= std_logic_vector(to_signed(f_I0_in,8));
                read(dl, f_Q0_in);
                AD_d3_Q <= std_logic_vector(to_signed(f_Q0_in,8));

                readline(infile, dl);
                read(dl, f_I0_in);
                AD_d4_I <= std_logic_vector(to_signed(f_I0_in,8));
                read(dl, f_Q0_in);
                AD_d4_Q <= std_logic_vector(to_signed(f_Q0_in,8));

                readline(infile, dl);
                read(dl, f_I0_in);
                AD_d5_I <= std_logic_vector(to_signed(f_I0_in,8));
                read(dl, f_Q0_in);
                AD_d5_Q <= std_logic_vector(to_signed(f_Q0_in,8));

                readline(infile, dl);
                read(dl, f_I0_in);
                AD_d6_I <= std_logic_vector(to_signed(f_I0_in,8));
                read(dl, f_Q0_in);
                AD_d6_Q <= std_logic_vector(to_signed(f_Q0_in,8));

                readline(infile, dl);
                read(dl, f_I0_in);
                AD_d7_I <= std_logic_vector(to_signed(f_I0_in,8));
                read(dl, f_Q0_in);
                AD_d7_Q <= std_logic_vector(to_signed(f_Q0_in,8));
                
              end if;
            end if;
          end process;

Demod_Para_rduc_inst : 	Demod_Para_rduc
generic	map(
			kInSize  => 8
		)
port map (
		aReset          => aReset   ,
		pclk_I			=> pclk_I	,
		rclk           	=> rclk     ,
		rclk_half		=> rclk_half,
		AD_d0_I			=> AD_d0_I,--(13 downto 6)	,
		AD_d1_I			=> AD_d1_I,--(13 downto 6)	,
		AD_d2_I			=> AD_d2_I,--(13 downto 6)	,
		AD_d3_I     => AD_d3_I,--(13 downto 6)  ,
		AD_d4_I			=> AD_d4_I,--(13 downto 6)	,
		AD_d5_I     => AD_d5_I,--(13 downto 6)  ,
		AD_d6_I     => AD_d6_I,--(13 downto 6)  ,
		AD_d7_I     => AD_d7_I,--(13 downto 6)  ,
		AD_d0_Q			=> AD_d0_Q,--(13 downto 6)	,
		AD_d1_Q			=> AD_d1_Q,--(13 downto 6)	,
		AD_d2_Q			=> AD_d2_Q,--(13 downto 6)	,
		AD_d3_Q     => AD_d3_Q,--(13 downto 6)  ,
		AD_d4_Q			=> AD_d4_Q,--(13 downto 6)	,
		AD_d5_Q     => AD_d5_Q,--(13 downto 6)  ,
		AD_d6_Q     => AD_d6_Q,--(13 downto 6)  ,
		AD_d7_Q     => AD_d7_Q,--(13 downto 6)  ,
		with_LDPC		=> with_LDPC,
		dat_mux 		=> dat_mux ,
		val_mux 		=> val_mux 
		
		);

	

end rtl_tb;
