// --========================================================================--
//  This confidential and proprietary software may be used only as
//  authorised by a licensing agreement from ARM Limited
//    (C) COPYRIGHT 2002 ARM Limited
//        ALL RIGHTS RESERVED
//  The entire notice above must be reproduced on all authorised
//  copies and copies may only be made to the extent permitted
//  by a licensing agreement from ARM Limited.
//
// ----------------------------------------------------------------------------
//  Version and Release Control Information:
//
//  File Name           : FileRdMaster32.v,v
//  File Revision       : 1.3
//
//  Release Information : BP010-AC-18005-r0p0-00rel2
//
// ----------------------------------------------------------------------------
//  Purpose             : This entity ties together the sub blocks that
//                        form the File Reader Bus Master, namely an AHB-Lite
//                        File Reader Core, Funnel and AHB-Lite to AHB wrapper.
// --========================================================================--

`timescale 1ns/1ps

module MasterSlave_TRI  (
  // system ports
  input          HCLK,          //  system clock
  input          HRESETn,       //  system reset

  input          HGRANT,        //  granted the bus
  output         HREADYS,        //  slave ready signal
  input          HREADYM,
  output         HBUSREQ,       //  AHB request signal

  input          HSEL,
  inout  [1:0]   HRESPtri,         //  slave response bus
 // inout port 
  inout  [31:0]  HADDRtri,
  inout  [2:0]   HBURSTtri,        //  burst type
  inout  [3:0]   HPROTtri,         //  transfer protection
  inout  [2:0]   HSIZEtri,         //  transfer size
  
  inout          HWRITEtri,        //  transfer direction
  inout  [1:0]   HTRANStri,        //  transfer type
  inout  [31:0]  HRWDATAtri,
  output         HLOCKtri ,         //  transfer is locked
  output         interrupttri,
  output [2:0]   Mem_wen_hydra,
  input          Mem_dft_mode
	
  );

wire					MAPSn;
wire					MDPSn;
wire                    SRSn;
wire                    DENn;
wire SDPSn;



//commmon 
	wire     iHCLK;
	wire     iHRESETn;
//Slave Port
	wire    [31:0] iHADDRS;
	wire           iHWRITES;
	wire    [1:0]  iHTRANSS;
	wire    [2:0]  iHSIZES;
	wire    [31:0] iHWDATAS;
	wire           iHSEL;
	wire           iHREADYS;
	wire    [31:0] iHRDATAS;
	wire    [1:0]  iHRESPS;
//	wire           Mem_dft_mode;
//	wire    [2:0]  Mem_wen_hydra;
//Master Port

//Inputs
wire         iHGRANT;
wire  [1:0]  iHRESPM;
wire         iHREADYM;
wire  [31:0] iHRDATAM;
wire  [31:0] iHADDRM;
wire   [1:0] iHTRANSM;
wire         iHWRITEM;
wire   [1:0] iHSIZEM;
wire  [31:0] iHWDATAM;
wire   [2:0] iHBURSTM;
wire   [3:0] iHPROTM;
wire         iHLOCKM;
wire         iHBUSREQ;
wire  [31:0] oHRWDATA;

assign iHCLK=HCLK;
assign iHRESETn=HRESETn;
//------------------------------------------------------------------------------
// tri-state Bus I/O    
//------------------------------------------------------------------------------
//
assign HREADYS=iHREADYS;
assign iHREADYM=HREADYM;
assign HBUSREQ=iHBUSREQ;
assign iHSEL=HSEL;
assign iHGRANT=HGRANT;
// Tri-State Input
assign iHRESPM=HRESPtri;
assign iHWRITES=HWRITEtri;
assign iHLOCKS=HLOCKtri;
assign iHTRANSS=HTRANStri;
assign iHSIZES=HSIZEtri;
assign iHBURSTS=HBURSTtri;
assign iHPROTS=HPROTtri;
assign iHADDRS=HADDRtri;
assign iHRDATAM= (MDPSn)?(HRWDATAtri):(32'h00000000);
assign iHWDATAS= (SDPSn)?(HRWDATAtri):(32'h00000000);

// HRWDATA Sel
assign oHRWDATA    = (MDPSn)?iHRDATAS:iHWDATAM;
// Tri-state Output  
assign HADDRtri    = (MAPSn)?(32'hzzzz_zzzz):(iHADDRM);
assign HTRANStri   = (MAPSn)?(2'bzz):(iHTRANSM);
assign HBURSTtri   = (MAPSn)?(3'bzzz):(iHBURSTM);
assign HWRITEtri   = (MAPSn)?(1'bz):(iHWRITEM);
assign HSIZEtri    = (MAPSn)?(3'bzzz):(iHSIZEM);
assign HPROTtri    = (MAPSn)?(4'bzzzz):(iHPROTM);
assign HRESPtri    = (SRSn)?2'bzz:(iHRESPS);
assign HRWDATAtri    = (DENn)? (32'hzzzz_zzzz):(oHRWDATA);
//------------------------------------------------------------------------------
// Tri-State Bus Control Logic    
//------------------------------------------------------------------------------
TBCTRL TriBusControlLogic(
.HRESETn  (iHRESETn),  
.HCLK     (iHCLK),
//input
.HREADYin (HREADYM),   
.HREADYout(iHREADYS),    
.HWRITEin (iHWRITES),   
.HWRITEout(iHWRITEM),    
.HSEL     (HSEL),
//.HMASTER  (HMASTER),  
//output
.MAPSn    (MAPSn),
.MDPSn    (MDPSn),
.DENn     (DENn),  
.SDPSn    (SDPSn),
.SRSn     (SRSn) 
);

//------------------------------------------------------------------------------
// EDU IPs    
//------------------------------------------------------------------------------

MYIP_WRAPPER uMasterSlave(
//commmon 
        .HCLK        (iHCLK     ),  
        .HRESETn     (iHRESETn  ),  
//Slave Port           
        .S_HADDR      (iHADDRS   ),       
        .S_HWRITE     (iHWRITES  ),       
        .S_HTRANS     (iHTRANSS  ),      
        .S_HSIZE      (iHSIZES   ),       
        .S_HWDATA     (iHWDATAS  ),       
        .S_HSELx      (iHSEL     ),      
        .S_HREADYin   (iHREADYM  ),       
        .S_HRDATA     (iHRDATAS  ),    
        .S_HREADYout  (iHREADYS  ),      
        .S_HRESP      (iHRESPS   ),    
//Master Port                              
//Inputs               
        .M_HGRANT     (iHGRANT   ),   
        .M_HRESP      (iHRESPM   ),   
        .M_HREADY     (iHREADYM  ),   
        .M_HRDATA     (iHRDATAM  ),  
        .M_HADDR      (iHADDRM   ),  
        .M_HTRANS     (iHTRANSM  ),    
        .M_HWRITE     (iHWRITEM  ),  
        .M_HSIZE      (iHSIZEM   ),   
        .M_HWDATA     (iHWDATAM  ),  
        .M_HBURST     (iHBURSTM  ),   
        .M_HPROT      (iHPROTM   ),  
        .M_HLOCK      (iHLOCKM   ),   
        .M_HBUSREQ    (iHBUSREQ  ),
				.interrupt    (interrupttri ) , 
				.Mem_dft_mode (Mem_dft_mode), 
				.Mem_wen_hydra(Mem_wen_hydra)
		);
endmodule
// --================================ End ==================================--