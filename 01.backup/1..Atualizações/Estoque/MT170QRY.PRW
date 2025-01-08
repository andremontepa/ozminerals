/*
Ponto de Entrada para nova query do relatório do MRP OREST001.PRW
RELATÓRIO ORIGINAL: MATR440
Autor: S GEDOLIN TEC
Data: 12/2021

*/

User Function MT170QRY( )
    Local cNewQry := ParamIXB[1]
    //-- Manipulação da query/filtro para condição do usuário

    cNewQry := "SELECT SB1.B1_FILIAL, SB1.B1_COD, SZD.ZD_LOCAL, SB1.B1_DESC, SB1.B1_TIPO, SB1.B1_GRUPO, "
    cNewQry += "SB1.B1_UM, SZD.ZD_EMIN B1_EMIN, SZD.ZD_LE B1_LE, SB1.B1_TOLER, SB1.B1_QE, SB1.B1_ESTFOR,
    cNewQry += "SZD.ZD_ESTSEG B1_ESTSEG, SB1.B1_PE, SB1.B1_UCOM, SB1.B1_DATREF, SB1.B1_CUSTD, SZD.ZD_FILIAL, "
    cNewQry += "SZD.ZD_EMAX B1_EMAX, SZD.ZD_FILIAL,SB1.B1_UPRC, SB1.B1_UCOM "
    cNewQry += "FROM "+retSqlName("SB1") + " SB1 "
    cNewQry += "INNER JOIN "+retSqlName("SZD") + " SZD ON (SZD.D_E_L_E_T_ = ' ' "
    cNewQry += "AND SZD.ZD_COD = SB1.B1_COD AND SZD.ZD_FILIAL ='"+xFilial("SZD")+"' ) "
    cNewQry += "WHERE SB1.B1_FILIAL ='"+xFilial("SB1")+"' AND "
	cNewQry += "SB1.B1_COD    >='" +mv_Par01+"' AND SB1.B1_COD <='"   +mv_Par02+"' AND "
	cNewQry += "SB1.B1_GRUPO  >='" +mv_Par03+"' AND SB1.B1_GRUPO <='" +mv_Par04+"' AND "
	cNewQry += "SB1.B1_TIPO   >='" +mv_Par05+"' AND SB1.B1_TIPO <='"  +mv_Par06+"' AND "
    cNewQry += 	"SZD.ZD_LOCAL >='" +mv_Par07+"' AND SZD.ZD_LOCAL <= '"+mv_Par08+"' "
    cNewQry += "AND SB1.B1_MSBLQL <>'1' AND SB1.B1_CONTRAT <> 'S' "
    cNewQry += "AND SB1.B1_TIPO <> 'BN' AND SB1.D_E_L_E_T_ = ' ' "

Return (cNewQry)
