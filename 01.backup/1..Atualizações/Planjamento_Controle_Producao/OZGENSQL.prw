#include "Protheus.Ch"
#include "TopConn.Ch"
#include "TbiConn.Ch"
#include "totvs.ch"

/*/{Protheus.doc} OZGENSQL

	Rotina Centralizada para Gravação e Tratamento de Queries OZminerals
	Pode ser chamada também como u_saveQuery() ou u_changeQuery()

@type function
@author Fabio Santos - CRM Service
@since 03/10/2023
@version P12
@database MSSQL,Oracle

@param cFile, character, Arquivo para gravação da Query
@param cQuery, character, Conteúdo da Query a ser Gravada
@param [lSaveQuery], logical, Indica se deve salvar a Query. Padrão: .T.
@param [lClearQuery], logical, Indica se deve realizar a limpeza de espaços da Query para otimização da execução da Query pelo DBACCESS. Padrão = .T.

@return character, cQuery - Query Convertida

@see MA330MOD()
@see MA330FIM()
@see SD3250I()
@see SD3250E()
@see MA330OK()
@see u_OZ04M01()
@see u_OZ04M04()
@see u_OZ04M05()
@see u_OZ04M28()
@see u_JobGravaInformacaoContabil()
@see u_CalculoCustoMaoDeObra()
@see u_GravaInformacaoContabil()
@see u_ManutencaoTabelaTemporaria()
@see u_EstornaMovimentoEstoque()
@see u_GravaLoteContabilDoCusteio()

@nested-tags:Frameworks/OZminerals
/*/

User Function OZGENSQL(cFile,cQuery,lSaveQuery,lClearQuery,lSaveCompany)
	Local lModify		   := GetNewPar("OZ_CHNQRY",.T.)
	Local lAllSaveQuery	   := GetNewPar("OZ_SAVQRY",.T.)
	Local lConoutQuery	   := GetNewPar("OZ_CONQRY",.F.)
	Local cFileName		   := ""
	Local cExtension	   := ""
	Local cFolder		   := ""
	
	Default cFile		   := ""
	Default cQuery		   := ""
	Default lSaveQuery	   := .T.
	Default lClearQuery	   := .T.
	Default lSaveCompany   := .T.	

	Private cSintaxeRotina := ""  as character

	cSintaxeRotina         := ProcName(0)

	If ( !Empty(cFile) .And. !Empty(cQuery) )
		
		SplitPath(cFile, ,@cFolder, @cFileName, @cExtension)
		
		If ( lSaveCompany )
			If ( Right(AllTrim(cFolder),01) $ "\/" )
				cFolder += cEmpAnt + "\" + cFilAnt + "\"
			EndIf
			
			cFile := cFolder + cFileName + cExtension
		EndIf
		
		MontaDir(cFolder)
		
		If ( lModify )
			u_modifyQuery(@cQuery)
		EndIf
		
		If ( lAllSaveQuery .And. lSaveQuery )
			MemoWrite(cFile,cQuery)
			If ( lConoutQuery )
				ShowLogInConsole(cQuery)
			EndIf
		EndIf
	EndIf

Return cQuery

/*
	Rotina alternativa chamadora para Salvar e Modifcar Queries de Forma Centralizada
*/
User Function changeQuery(cFile,cQuery,lSaveQuery,lClearQuery)

	u_OZGENSQL(cFile,@cQuery,lSaveQuery,lClearQuery)

Return cQuery

/*
	Rotina alternativa chamadora para Salvar Queries de Forma Centralizada
*/
User Function saveQuery(cFile,cQuery,lSaveQuery)

	u_OZGENSQL(cFile,@cQuery,lSaveQuery)

Return cQuery

/*
	Modifica a Sintaxe da Query
*/
User Function modifyQuery(cQuery)
	Local lSQLServer 	:= IIF( Type("lMsSQLBD") == "L", lMsSQLBD, u_isMSSQL() )
	
	Default cQuery := ""

	If ( !Empty(cQuery) )
		If ( lSQLServer )
			If ( "||" $ cQuery )
				cQuery := StrTran(cQuery,"||","+")
			EndIf
			
			If ( "SUBSTR" $ cQuery )
				cQuery := StrTran(cQuery,"SUBSTR","SUBSTRING")
				cQuery := StrTran(cQuery,"SUBSTRINGING","SUBSTRING")
			EndIf
			
			If ( "substr" $ cQuery )
				cQuery := StrTran(cQuery,"substr","substring")
				cQuery := StrTran(cQuery,"substringing","substring")
			EndIf
			
			If ( "FROM DUAL" $ cQuery )
				cQuery := StrTran(cQuery,"FROM DUAL","")
			EndIf
		Else
			If ( Upper("dbo.") $ Upper(cQuery) )
				cQuery := StrTran(cQuery,"dbo.","")
				cQuery := StrTran(cQuery,"Dbo.","")
				cQuery := StrTran(cQuery,"DBo.","")
				cQuery := StrTran(cQuery,"DBO.","")				
			EndIf
		
			If ( Upper("WITH(NOLOCK)") $ Upper(cQuery) )
				cQuery := StrTran(cQuery,"WITH(NOLOCK)","")
				cQuery := StrTran(cQuery,"wITH(NOLOCK)","")
				cQuery := StrTran(cQuery,"With(NOLOCK)","")
				cQuery := StrTran(cQuery,"with(nolock)","")
			EndIf
		
			If ( Upper("WITH (NOLOCK)") $ Upper(cQuery) )
				cQuery := StrTran(cQuery,"WITH (NOLOCK)","")
				cQuery := StrTran(cQuery,"wITH (NOLOCK)","")
				cQuery := StrTran(cQuery,"With (NOLOCK)","")
				cQuery := StrTran(cQuery,"with (nolock)","")
			EndIf
			
			If ( Upper("(NOLOCK)") $ Upper(cQuery) )
				cQuery := StrTran(cQuery,"(NOLOCK)","")
				cQuery := StrTran(cQuery,"(nolock)","")
			EndIf
						
			If ( "EXCEPT" $ cQuery )
				cQuery := StrTran(cQuery,"EXCEPT","MINUS")
			EndIf
			
			If ( Upper("SUBSTRING") $ Upper(cQuery) )
				cQuery := StrTran(cQuery,"SUBSTRING","SUBSTR")
				cQuery := StrTran(cQuery,"substring","SUBSTR")
			EndIf
			
			If ( Upper(") AS") $ Upper(cQuery) )
				cQuery := StrTran(cQuery,") AS",") ")
				cQuery := StrTran(cQuery,") as",") ")
			EndIf
			
			If ( Upper("ISNULL") $ Upper(cQuery) )
				cQuery := StrTran(cQuery,"ISNULL(","NVL(")
				cQuery := StrTran(cQuery,"isnull(","NVL(")
			EndIf
			
			If ( Upper("D_E_L_E_T_ = ''") $ Upper(cQuery) )
				cQuery := StrTran(cQuery,"D_E_L_E_T_ = ''","D_E_L_E_T_ = ' '")
				cQuery := StrTran(cQuery,"d_e_l_e_t_ = ''","D_E_L_E_T_ = ' '")
			EndIf
			
			If ( Upper("D_E_L_E_T_=''") $ Upper(cQuery) )
				cQuery := StrTran(cQuery,"D_E_L_E_T_=''","D_E_L_E_T_ = ' '")
				cQuery := StrTran(cQuery,"d_e_l_e_t_=''","D_E_L_E_T_ = ' '")
			EndIf
			
			If ( Upper("CONVERT(VARCHAR,") $ Upper(cQuery) )
				cQuery := StrTran(cQuery,"CONVERT(VARCHAR,","TO_CHAR(")
				cQuery := StrTran(cQuery,"convert(varchar,","TO_CHAR(")				
			EndIf
			
			If ( Upper("CHAR(13) || CHAR(10)") $ Upper(cQuery) )
				cQuery := StrTran(cQuery,"CHAR(13) || CHAR(10)","CHR(13) || CHR(10)")
				cQuery := StrTran(cQuery,"Char(13) || Char(10)","CHR(13) || CHR(10)")
				cQuery := StrTran(cQuery,"char(13) || char(10)","CHR(13) || CHR(10)")
			EndIf
						
			If !( Upper("FROM") $ Upper(cQuery) ) .And. ( Upper("SELECT") $ Upper(cQuery) )
				If !( Upper("CREATE SEQUENCE") $ Upper(cQuery) ) ;				
					.And. !( Upper("INSERT INTO") $ Upper(cQuery) );
					.And. !( Upper("CREATE OR REPLACE FORCE VIEW") $ Upper(cQuery) );
					.And. !( Upper("CREATE OR REPLACE VIEW") $ Upper(cQuery) );
					.And. !( Upper("CREATE VIEW") $ Upper(cQuery) );
					.And. !( Upper("UPDATE") $ Upper(cQuery) );
					.And. !( FwIsInCallStack("PARSERVBSCRIPT") )
					
					cQuery += " FROM DUAL "
				EndIf
			EndIf
			
			If ( Upper("COLLATE") $ Upper(cQuery) )
				cQuery := StrTran(cQuery,"COLLATE","")							
			EndIf
			
			If ( Upper("DATABASE_DEFAULT") $ Upper(cQuery) )
				cQuery := StrTran(cQuery,"DATABASE_DEFAULT","")							
			EndIf
			
		EndIf
	EndIf
	
Return cQuery

/*
	Busca versão do banco de dados 
*/
User Function isMSSQL()
	Local cBD	:= AllTrim(Upper(TCGetDB()))
	Local lRet 	:= .F.	
	
	If cBD $ "MSSQL7"
		lRet:= .T.
	Else
		lRet:= .F.
	Endif

Return lRet

/*
	Apresenta a Mensagem no Console do Protheus
*/
Static Function showLogInConsole(cMsg)

	libOzminerals.u_showLogInConsole(cMsg,cSintaxeRotina)

Return
