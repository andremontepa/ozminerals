#include "totvs.ch"
#include "topconn.ch"
#include "ozminerals.ch"

/*/{Protheus.doc} OZAGEN29

Rotina para retornar o Owner Atual do BD ORACLE conectado ao BD Protheus

@type function
@author Fabio Santos 
@since 08/08/2024
@version P12
@database MSSQL, ORACLE


@see u_getDBOwner()

/*/
User Function OZAGEN29()
	Local cTypeBD		:= TCGetDB()
	Local lSqlServer	:= ( cTypeBD $ "MSSQL" )	
	Local cAlias		:= ""
	Local cQuery		:= ""
	Local cOwner		:= ""

	If ( lSqlServer )
		cQuery	:= getQryDBName()
	Else
		cQuery	:= getQryOwner()
	EndIf
	
	TcQuery cQuery New Alias (cAlias:=GetNextAlias())
	If (cAlias)->(!EOF())
		cOwner := AllTrim((cAlias)->OWNER)
	Endif
	(cAlias)->(dbCloseArea())

Return cOwner

/*
	Monta a Query para retornar do Owner Atual - ORACLE
*/
Static Function getQryOwner()
	Local cQuery := ""
	
	cQuery += " SELECT " + CRLF
	cQuery += "		USER AS OWNER " + CRLF
	cQuery += "	FROM " + CRLF
	cQuery += "		DUAL " + CRLF
	
Return cQuery

/*
	Monta a Query para retornar o Nome do BD Atual - SQL SERVER
*/
Static Function getQryDBName()
	Local cQuery := ""
	
	cQuery += " SELECT " + CRLF
	cQuery += "		DB_NAME() AS OWNER " + CRLF
	
Return cQuery

/*
	Rotina para retornar o Owner atual do BD
*/
User Function getDBOwner()
	Local cOwner := ""
	
	cOwner := u_OZAGEN29()
	
Return cOwner
