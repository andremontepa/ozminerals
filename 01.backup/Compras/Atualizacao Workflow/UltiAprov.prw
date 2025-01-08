#INCLUDE "rwmake.ch"
#INCLUDE "TbiConn.ch"
#INCLUDE "TbiCode.ch"
#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณUltiAprov  บAutor  Sangelles           บ Data ณ  06/05/17   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณControlador de Fun็๕es Apos Ponto de Entrada na Rotina do   บฑฑ
ฑฑบ          ณModulo Compras. 											  บฑฑ
ฑฑบDesc.     ณFun็ใo para Buscar o Proximo Aprovador que nใo liberou oped.บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/                                                                           
User function UltiAprov(cFil,cpedido,ctipodoc)
Local cNivelWF 		:= '00'
Local cIDAprov 		:= ''
Local cIDUser  		:= ''
Local cMailApr 		:= ''
Local cPulaLinha	:= Chr(13)+Chr(10)
Local cNomeUsr 		:= ''
Local cStatus  		:= ''
Local cOBSApr  		:= ''
Local aRet 			:= {}

cQry:= " SELECT CR_NIVEL,CR_APROV,CR_USER,CR_NUM,CR_FILIAL,CR_STATUS  FROM "+RetSqlName("SCR")+" "+cPulaLinha
cQry+= " 	WHERE D_E_L_E_T_ <> '*' "+cPulaLinha
cQry+= " 		AND CR_FILIAL = '"+cFil+"'    "+cPulaLinha
cQry+= " 		AND CR_NUM    = '"+cpedido+"'    "+cPulaLinha
cQry+= " 		AND CR_TIPO   = '"+ctipodoc+"'   "+cPulaLinha
cQry+= " 		AND CR_NIVEL  =  (SELECT MIN(CR_NIVEL)  FROM "+RetSqlName("SCR")+" "+cPulaLinha
cQry+= "   							WHERE D_E_L_E_T_ <> '*'        	   "+cPulaLinha
cQry+= " 								AND CR_FILIAL = '"+cFil+"'     "+cPulaLinha
cQry+= " 	   							AND CR_NUM    = '"+cpedido+"'  "+cPulaLinha
cQry+= " 	   							AND CR_TIPO   = '"+ctipodoc+"' "+cPulaLinha
cQry+= "								AND ( CR_USERLIB = '   ' OR CR_USERLIB <> '  ' AND CR_STATUS = '04') )       "+cPulaLinha
cQry+= " 		AND (CR_USERLIB = '   ' OR CR_USERLIB <> '  ' AND CR_STATUS = '04')   "+cPulaLinha

TcQuery cQry New Alias "QRYSCR"

cNivelWF := QRYSCR->CR_NIVEL
cIDAprov := QRYSCR->CR_APROV
cIDUser  := QRYSCR->CR_USER
cMailApr := UsrRetMail(cIDUser)
cNomeUsr := UsrRetName(cIDUser)
cStatus  := QRYSCR->CR_STATUS

if Empty(cNivelWF)
	cNivelWF := '01'
EndIf

Aadd(aRet,{cNivelWF,cIDAprov,cIDUser,cMailApr,cNomeUsr,cStatus})

QRYSCR->(DbCloseArea())

Return(aRet)

