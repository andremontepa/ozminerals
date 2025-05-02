#INCLUDE "protheus.ch"

#DEFINE SIMPLES Char( 39 )
#DEFINE DUPLAS  Char( 34 )

#DEFINE CSSBOTAO	"QPushButton { color: #024670; "+;
"    border-image: url(rpo:fwstd_btn_nml.png) 3 3 3 3 stretch; "+;
"    border-top-width: 3px; "+;
"    border-left-width: 3px; "+;
"    border-right-width: 3px; "+;
"    border-bottom-width: 3px }"+;
"QPushButton:pressed {	color: #FFFFFF; "+;
"    border-image: url(rpo:fwstd_btn_prd.png) 3 3 3 3 stretch; "+;
"    border-top-width: 3px; "+;
"    border-left-width: 3px; "+;
"    border-right-width: 3px; "+;
"    border-bottom-width: 3px }"

//--------------------------------------------------------------------
/*/{Protheus.doc} UPDOZPCP

Função de update de dicionários para compatibilização

@author UPDATE gerado automaticamente
@since  18/12/2023
@obs    Gerado por EXPORDIC - V.7.6.3.4 EFS / Upd. V.6.4.1 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
User Function UPDOZPCP( cEmpAmb, cFilAmb )
Local   aSay      := {}
Local   aButton   := {}
Local   aMarcadas := {}
Local   cTitulo   := "ATUALIZAÇÃO DE DICIONÁRIOS E TABELAS - OZMINERALS"
Local   cDesc1    := "Esta rotina tem como função fazer  a atualização  dos dicionários do Sistema !"
Local   cDesc2    := "Será Atualizado as tabelas PA0 / PA1 / PAX / PAY para 2 FASE PROJETO PCP"
Local   cDesc3    := "usuários  ou  jobs utilizando  o sistema.  É EXTREMAMENTE recomendavél  que  se  faça"
Local   cDesc4    := "um BACKUP  dos DICIONÁRIOS  e da  BASE DE DADOS antes desta atualização, para"
Local   cDesc5    := "que caso ocorram eventuais falhas, esse backup possa ser restaurado."
Local   cMsg      := ""
Local   lOk       := .F.
Local   lAuto     := ( cEmpAmb <> NIL .or. cFilAmb <> NIL )

Private oMainWnd  := NIL
Private oProcess  := NIL

#IFDEF TOP
    TCInternal( 5, "*OFF" ) // Desliga Refresh no Lock do Top
#ENDIF

__cInterNet := NIL
__lPYME     := .F.

Set Dele On

// Mensagens de Tela Inicial
aAdd( aSay, cDesc1 )
aAdd( aSay, cDesc2 )
aAdd( aSay, cDesc3 )
aAdd( aSay, cDesc4 )
aAdd( aSay, cDesc5 )
//aAdd( aSay, cDesc6 )
//aAdd( aSay, cDesc7 )

// Botoes Tela Inicial
aAdd(  aButton, {  1, .T., { || lOk := .T., FechaBatch() } } )
aAdd(  aButton, {  2, .T., { || lOk := .F., FechaBatch() } } )

If lAuto
	lOk := .T.
Else
	FormBatch(  cTitulo,  aSay,  aButton )
EndIf

If lOk

	If GetVersao(.F.) < "12" .OR. ( FindFunction( "MPDicInDB" ) .AND. !MPDicInDB() )
		cMsg := "Este update NÃO PODE ser executado neste Ambiente." + CRLF + CRLF + ;
				"Os arquivos de dicionários se encontram em formato ISAM" + " (" + GetDbExtension() + ") " + "Os arquivos de dicionários se encontram em formato ISAM" + " " + ;
				"para atualizar apenas ambientes com dicionários no Banco de Dados."

		If lAuto
			AutoGrLog( Replicate( "-", 128 ) )
			AutoGrLog( Replicate( " ", 128 ) )
			AutoGrLog( "LOG DA ATUALIZAÇÃO DOS DICIONÁRIOS" )
			AutoGrLog( Replicate( " ", 128 ) )
			AutoGrLog( Replicate( "-", 128 ) )
			AutoGrLog( Replicate( " ", 128 ) )
			AutoGrLog( cMsg )
			ConOut( DToC(Date()) + "|" + Time() + cMsg )
		Else
			MsgInfo( cMsg )
		EndIf

		Return NIL
	EndIf

	If lAuto
		aMarcadas :={{ cEmpAmb, cFilAmb, "" }}
	Else
		aMarcadas := EscEmpresa()
	EndIf

	If !Empty( aMarcadas )
		If lAuto .OR. MsgNoYes( "Confirma a atualização dos dicionários ?", cTitulo )
			oProcess := MsNewProcess():New( { | lEnd | lOk := FSTProc( @lEnd, aMarcadas, lAuto ) }, "Atualizando", "Aguarde, atualizando ...", .F. )
			oProcess:Activate()

			If lAuto
				If lOk
					MsgInfo( "Atualização realizada.", "UPDOZPCP" )
				Else
					MsgStop( "Atualização não realizada.", "UPDOZPCP" )
				EndIf
				dbCloseAll()
			Else
				If lOk
					Final( "Atualização realizada." )
				Else
					Final( "Atualização não realizada." )
				EndIf
			EndIf

		Else
			Final( "Atualização não realizada." )

		EndIf

	Else
		Final( "Atualização não realizada." )

	EndIf

EndIf

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} FSTProc

Função de processamento da gravação dos arquivos

@author UPDATE gerado automaticamente
@since  18/12/2023
@obs    Gerado por EXPORDIC - V.7.6.3.4 EFS / Upd. V.6.4.1 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSTProc( lEnd, aMarcadas, lAuto )
Local   aInfo     := {}
Local   aRecnoSM0 := {}
Local   cFile     := ""
Local   cMask     := "Arquivos Texto" + "(*.TXT)|*.txt|"
Local   cTCBuild  := "TCGetBuild"
Local   cTexto    := ""
Local   cTopBuild := ""
Local   lOpen     := .F.
Local   lRet      := .T.
Local   nI        := 0
Local   nPos      := 0
Local   nX        := 0
Local   oDlg      := NIL
Local   oFont     := NIL
Local   oMemo     := NIL

Private aArqUpd   := {}

If ( lOpen := MyOpenSm0(.T.) )

	dbSelectArea( "SM0" )
	dbGoTop()

	While !SM0->( EOF() )
		// Só adiciona no aRecnoSM0 se a empresa for diferente
		If aScan( aRecnoSM0, { |x| x[2] == SM0->M0_CODIGO } ) == 0 ;
		   .AND. aScan( aMarcadas, { |x| x[1] == SM0->M0_CODIGO } ) > 0
			aAdd( aRecnoSM0, { Recno(), SM0->M0_CODIGO } )
		EndIf
		SM0->( dbSkip() )
	End

	SM0->( dbCloseArea() )

	If lOpen

		For nI := 1 To Len( aRecnoSM0 )

			If !( lOpen := MyOpenSm0(.F.) )
				MsgStop( "Atualização da empresa " + aRecnoSM0[nI][2] + " não efetuada." )
				Exit
			EndIf

			SM0->( dbGoTo( aRecnoSM0[nI][1] ) )

			RpcSetEnv( SM0->M0_CODIGO, SM0->M0_CODFIL )

			lMsFinalAuto := .F.
			lMsHelpAuto  := .F.

			AutoGrLog( Replicate( "-", 128 ) )
			AutoGrLog( Replicate( " ", 128 ) )
			AutoGrLog( "LOG DA ATUALIZAÇÃO DOS DICIONÁRIOS" )
			AutoGrLog( Replicate( " ", 128 ) )
			AutoGrLog( Replicate( "-", 128 ) )
			AutoGrLog( " " )
			AutoGrLog( " Dados Ambiente" )
			AutoGrLog( " --------------------" )
			AutoGrLog( " Empresa / Filial...: " + cEmpAnt + "/" + cFilAnt )
			AutoGrLog( " Nome Empresa.......: " + Capital( AllTrim( GetAdvFVal( "SM0", "M0_NOMECOM", cEmpAnt + cFilAnt, 1, "" ) ) ) )
			AutoGrLog( " Nome Filial........: " + Capital( AllTrim( GetAdvFVal( "SM0", "M0_FILIAL" , cEmpAnt + cFilAnt, 1, "" ) ) ) )
			AutoGrLog( " DataBase...........: " + DtoC( dDataBase ) )
			AutoGrLog( " Data / Hora Ínicio.: " + DtoC( Date() )  + " / " + Time() )
			AutoGrLog( " Environment........: " + GetEnvServer()  )
			AutoGrLog( " StartPath..........: " + GetSrvProfString( "StartPath", "" ) )
			AutoGrLog( " RootPath...........: " + GetSrvProfString( "RootPath" , "" ) )
			AutoGrLog( " Versão.............: " + GetVersao(.T.) )
			AutoGrLog( " Usuário TOTVS .....: " + __cUserId + " " +  cUserName )
			AutoGrLog( " Computer Name......: " + GetComputerName() )

			aInfo   := GetUserInfo()
			If ( nPos    := aScan( aInfo,{ |x,y| x[3] == ThreadId() } ) ) > 0
				AutoGrLog( " " )
				AutoGrLog( " Dados Thread" )
				AutoGrLog( " --------------------" )
				AutoGrLog( " Usuário da Rede....: " + aInfo[nPos][1] )
				AutoGrLog( " Estação............: " + aInfo[nPos][2] )
				AutoGrLog( " Programa Inicial...: " + aInfo[nPos][5] )
				AutoGrLog( " Environment........: " + aInfo[nPos][6] )
				AutoGrLog( " Conexão............: " + AllTrim( StrTran( StrTran( aInfo[nPos][7], Chr( 13 ), "" ), Chr( 10 ), "" ) ) )
			EndIf
			AutoGrLog( Replicate( "-", 128 ) )
			AutoGrLog( " " )

			If !lAuto
				AutoGrLog( Replicate( "-", 128 ) )
				AutoGrLog( "Empresa : " + SM0->M0_CODIGO + "/" + SM0->M0_NOME + CRLF )
			EndIf

			oProcess:SetRegua1( 8 )

			//------------------------------------
			// Atualiza o dicionário SX2
			//------------------------------------
			oProcess:IncRegua1( "Dicionário de arquivos" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			FSAtuSX2()

			//------------------------------------
			// Atualiza o dicionário SX3
			//------------------------------------
			FSAtuSX3()

			//------------------------------------
			// Atualiza o dicionário SIX
			//------------------------------------
			oProcess:IncRegua1( "Dicionário de índices" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			FSAtuSIX()

			oProcess:IncRegua1( "Dicionário de dados" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			oProcess:IncRegua2( "Atualizando campos/índices" )

			// Alteração física dos arquivos
			__SetX31Mode( .F. )

			If FindFunction(cTCBuild)
				cTopBuild := &cTCBuild.()
			EndIf

			For nX := 1 To Len( aArqUpd )

				If cTopBuild >= "20090811" .AND. TcInternal( 89 ) == "CLOB_SUPPORTED"
					If ( ( aArqUpd[nX] >= "NQ " .AND. aArqUpd[nX] <= "NZZ" ) .OR. ( aArqUpd[nX] >= "O0 " .AND. aArqUpd[nX] <= "NZZ" ) ) .AND.;
						!aArqUpd[nX] $ "NQD,NQF,NQP,NQT"
						TcInternal( 25, "CLOB" )
					EndIf
				EndIf

				If Select( aArqUpd[nX] ) > 0
					dbSelectArea( aArqUpd[nX] )
					dbCloseArea()
				EndIf

				X31UpdTable( aArqUpd[nX] )

				If __GetX31Error()
					Alert( __GetX31Trace() )
					MsgStop( "Ocorreu um erro desconhecido durante a atualização da tabela : " + aArqUpd[nX] + ". Verifique a integridade do dicionário e da tabela.", "ATENÇÃO" )
					AutoGrLog( "Ocorreu um erro desconhecido durante a atualização da estrutura da tabela : " + aArqUpd[nX] )
				EndIf

				If cTopBuild >= "20090811" .AND. TcInternal( 89 ) == "CLOB_SUPPORTED"
					TcInternal( 25, "OFF" )
				EndIf

			Next nX

			//------------------------------------
			// Atualiza o dicionário SX6
			//------------------------------------
			oProcess:IncRegua1( "Dicionário de parâmetros" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			FSAtuSX6()

			//------------------------------------
			// Atualiza o dicionário SX7
			//------------------------------------
			oProcess:IncRegua1( "Dicionário de gatilhos" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			FSAtuSX7()

			//------------------------------------
			// Atualiza o dicionário SXB
			//------------------------------------
			oProcess:IncRegua1( "Dicionário de consultas padrão" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			FSAtuSXB()

			//------------------------------------
			// Atualiza os helps
			//------------------------------------
			oProcess:IncRegua1( "Helps de Campo" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			FSAtuHlp()

			AutoGrLog( Replicate( "-", 128 ) )
			AutoGrLog( " Data / Hora Final.: " + DtoC( Date() ) + " / " + Time() )
			AutoGrLog( Replicate( "-", 128 ) )

			RpcClearEnv()

		Next nI

		If !lAuto

			cTexto := LeLog()

			Define Font oFont Name "Mono AS" Size 5, 12

			Define MsDialog oDlg Title "Atualização concluida." From 3, 0 to 340, 417 Pixel

			@ 5, 5 Get oMemo Var cTexto Memo Size 200, 145 Of oDlg Pixel
			oMemo:bRClicked := { || AllwaysTrue() }
			oMemo:oFont     := oFont

			Define SButton From 153, 175 Type  1 Action oDlg:End() Enable Of oDlg Pixel // Apaga
			Define SButton From 153, 145 Type 13 Action ( cFile := cGetFile( cMask, "" ), If( cFile == "", .T., ;
			MemoWrite( cFile, cTexto ) ) ) Enable Of oDlg Pixel

			Activate MsDialog oDlg Center

		EndIf

	EndIf

Else

	lRet := .F.

EndIf

Return lRet


//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuSX2

Função de processamento da gravação do SX2 - Arquivos

@author UPDATE gerado automaticamente
@since  18/12/2023
@obs    Gerado por EXPORDIC - V.7.6.3.4 EFS / Upd. V.6.4.1 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuSX2()
Local aEstrut   := {}
Local aSX2      := {}
Local cAlias    := ""
Local cCpoUpd   := "X2_ROTINA /X2_UNICO  /X2_DISPLAY/X2_SYSOBJ /X2_USROBJ /X2_POSLGT /"
Local cEmpr     := ""
Local cPath     := ""
Local nI        := 0
Local nJ        := 0

AutoGrLog( "Ínicio da Atualização" + " SX2" + CRLF )

aEstrut := { "X2_CHAVE"  , "X2_PATH"   , "X2_ARQUIVO", "X2_NOME"   , "X2_NOMESPA", "X2_NOMEENG", "X2_MODO"   , ;
             "X2_TTS"    , "X2_ROTINA" , "X2_PYME"   , "X2_UNICO"  , "X2_DISPLAY", "X2_SYSOBJ" , "X2_USROBJ" , ;
             "X2_POSLGT" , "X2_CLOB"   , "X2_AUTREC" , "X2_MODOEMP", "X2_MODOUN" , "X2_MODULO" }


dbSelectArea( "SX2" )
SX2->( dbSetOrder( 1 ) )
SX2->( dbGoTop() )
cPath := SX2->X2_PATH
cPath := IIf( Right( AllTrim( cPath ), 1 ) <> "\", PadR( AllTrim( cPath ) + "\", Len( cPath ) ), cPath )
cEmpr := Substr( SX2->X2_ARQUIVO, 4 )

//
// Tabela PA0
//
aAdd( aSX2, { ;
	'PA0'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'PA0'+cEmpr																, ; //X2_ARQUIVO
	'Cabeçalho da Tabela'													, ; //X2_NOME
	'Cabeçalho da Tabela'													, ; //X2_NOMESPA
	'Cabeçalho da Tabela'													, ; //X2_NOMEENG
	'C'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	''																		, ; //X2_PYME
	''																		, ; //X2_UNICO
	''																		, ; //X2_DISPLAY
	''																		, ; //X2_SYSOBJ
	''																		, ; //X2_USROBJ
	'1'																		, ; //X2_POSLGT
	'1'																		, ; //X2_CLOB
	''																		, ; //X2_AUTREC
	'C'																		, ; //X2_MODOEMP
	'C'																		, ; //X2_MODOUN
	0																		} ) //X2_MODULO

//
// Tabela PA1
//
aAdd( aSX2, { ;
	'PA1'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'PA1'+cEmpr																, ; //X2_ARQUIVO
	'Itens Tabela Produção'													, ; //X2_NOME
	'Itens Tabela Produção'													, ; //X2_NOMESPA
	'Itens Tabela Produção'													, ; //X2_NOMEENG
	'C'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	''																		, ; //X2_PYME
	''																		, ; //X2_UNICO
	''																		, ; //X2_DISPLAY
	''																		, ; //X2_SYSOBJ
	''																		, ; //X2_USROBJ
	'1'																		, ; //X2_POSLGT
	'1'																		, ; //X2_CLOB
	''																		, ; //X2_AUTREC
	'C'																		, ; //X2_MODOEMP
	'C'																		, ; //X2_MODOUN
	0																		} ) //X2_MODULO

//
// Tabela PAX
//
aAdd( aSX2, { ;
	'PAX'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'PAX'+cEmpr																, ; //X2_ARQUIVO
	'Transferencia Filais Cab.'												, ; //X2_NOME
	'Transferencia Filais Cab.'												, ; //X2_NOMESPA
	'Transferencia Filais Cab.'												, ; //X2_NOMEENG
	'E'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	'S'																		, ; //X2_PYME
	''																		, ; //X2_UNICO
	''																		, ; //X2_DISPLAY
	''																		, ; //X2_SYSOBJ
	''																		, ; //X2_USROBJ
	'1'																		, ; //X2_POSLGT
	'1'																		, ; //X2_CLOB
	'1'																		, ; //X2_AUTREC
	'E'																		, ; //X2_MODOEMP
	'E'																		, ; //X2_MODOUN
	0																		} ) //X2_MODULO

//
// Tabela PAY
//
aAdd( aSX2, { ;
	'PAY'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'PAY'+cEmpr																, ; //X2_ARQUIVO
	'Transferencia Filais Itens'											, ; //X2_NOME
	'Transferencia Filais Itens'											, ; //X2_NOMESPA
	'Transferencia Filais Itens'											, ; //X2_NOMEENG
	'E'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	'S'																		, ; //X2_PYME
	''																		, ; //X2_UNICO
	''																		, ; //X2_DISPLAY
	''																		, ; //X2_SYSOBJ
	''																		, ; //X2_USROBJ
	'1'																		, ; //X2_POSLGT
	'1'																		, ; //X2_CLOB
	'1'																		, ; //X2_AUTREC
	'E'																		, ; //X2_MODOEMP
	'E'																		, ; //X2_MODOUN
	0																		} ) //X2_MODULO

//
// Atualizando dicionário
//
oProcess:SetRegua2( Len( aSX2 ) )

dbSelectArea( "SX2" )
dbSetOrder( 1 )

For nI := 1 To Len( aSX2 )

	oProcess:IncRegua2( "Atualizando Arquivos (SX2) ..." )

	If !SX2->( dbSeek( aSX2[nI][1] ) )

		If !( aSX2[nI][1] $ cAlias )
			cAlias += aSX2[nI][1] + "/"
			AutoGrLog( "Foi incluída a tabela " + aSX2[nI][1] )
		EndIf

		RecLock( "SX2", .T. )
		For nJ := 1 To Len( aSX2[nI] )
			If FieldPos( aEstrut[nJ] ) > 0
				If AllTrim( aEstrut[nJ] ) == "X2_ARQUIVO"
					FieldPut( FieldPos( aEstrut[nJ] ), SubStr( aSX2[nI][nJ], 1, 3 ) + cEmpAnt +  "0" )
				Else
					FieldPut( FieldPos( aEstrut[nJ] ), aSX2[nI][nJ] )
				EndIf
			EndIf
		Next nJ
		MsUnLock()

	Else

		If  !( StrTran( Upper( AllTrim( SX2->X2_UNICO ) ), " ", "" ) == StrTran( Upper( AllTrim( aSX2[nI][12]  ) ), " ", "" ) )
			RecLock( "SX2", .F. )
			SX2->X2_UNICO := aSX2[nI][12]
			MsUnlock()

			If MSFILE( RetSqlName( aSX2[nI][1] ),RetSqlName( aSX2[nI][1] ) + "_UNQ"  )
				TcInternal( 60, RetSqlName( aSX2[nI][1] ) + "|" + RetSqlName( aSX2[nI][1] ) + "_UNQ" )
			EndIf

			AutoGrLog( "Foi alterada a chave única da tabela " + aSX2[nI][1] )
		EndIf

		RecLock( "SX2", .F. )
		For nJ := 1 To Len( aSX2[nI] )
			If FieldPos( aEstrut[nJ] ) > 0
				If PadR( aEstrut[nJ], 10 ) $ cCpoUpd
					FieldPut( FieldPos( aEstrut[nJ] ), aSX2[nI][nJ] )
				EndIf

			EndIf
		Next nJ
		MsUnLock()

	EndIf

Next nI

AutoGrLog( CRLF + "Final da Atualização" + " SX2" + CRLF + Replicate( "-", 128 ) + CRLF )

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuSX3

Função de processamento da gravação do SX3 - Campos

@author UPDATE gerado automaticamente
@since  18/12/2023
@obs    Gerado por EXPORDIC - V.7.6.3.4 EFS / Upd. V.6.4.1 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuSX3()
Local aEstrut   := {}
Local aSX3      := {}
Local cAlias    := ""
Local cAliasAtu := ""
Local cSeqAtu   := ""
Local nI        := 0
Local nJ        := 0
Local nPosArq   := 0
Local nPosCpo   := 0
Local nPosOrd   := 0
Local nPosSXG   := 0
Local nPosTam   := 0
Local nPosVld   := 0
Local nSeqAtu   := 0
Local nTamSeek  := Len( SX3->X3_CAMPO )

AutoGrLog( "Ínicio da Atualização" + " SX3" + CRLF )

aEstrut := { { "X3_ARQUIVO", 0 }, { "X3_ORDEM"  , 0 }, { "X3_CAMPO"  , 0 }, { "X3_TIPO"   , 0 }, { "X3_TAMANHO", 0 }, { "X3_DECIMAL", 0 }, { "X3_TITULO" , 0 }, ;
             { "X3_TITSPA" , 0 }, { "X3_TITENG" , 0 }, { "X3_DESCRIC", 0 }, { "X3_DESCSPA", 0 }, { "X3_DESCENG", 0 }, { "X3_PICTURE", 0 }, { "X3_VALID"  , 0 }, ;
             { "X3_USADO"  , 0 }, { "X3_RELACAO", 0 }, { "X3_F3"     , 0 }, { "X3_NIVEL"  , 0 }, { "X3_RESERV" , 0 }, { "X3_CHECK"  , 0 }, { "X3_TRIGGER", 0 }, ;
             { "X3_PROPRI" , 0 }, { "X3_BROWSE" , 0 }, { "X3_VISUAL" , 0 }, { "X3_CONTEXT", 0 }, { "X3_OBRIGAT", 0 }, { "X3_VLDUSER", 0 }, { "X3_CBOX"   , 0 }, ;
             { "X3_CBOXSPA", 0 }, { "X3_CBOXENG", 0 }, { "X3_PICTVAR", 0 }, { "X3_WHEN"   , 0 }, { "X3_INIBRW" , 0 }, { "X3_GRPSXG" , 0 }, { "X3_FOLDER" , 0 }, ;
             { "X3_CONDSQL", 0 }, { "X3_CHKSQL" , 0 }, { "X3_IDXSRV" , 0 }, { "X3_ORTOGRA", 0 }, { "X3_TELA"   , 0 }, { "X3_POSLGT" , 0 }, { "X3_IDXFLD" , 0 }, ;
             { "X3_AGRUP"  , 0 }, { "X3_MODAL"  , 0 }, { "X3_PYME"   , 0 } }

aEval( aEstrut, { |x| x[2] := SX3->( FieldPos( x[1] ) ) } )


//
// Campos Tabela PA0
//
aAdd( aSX3, { ;
	'PA0'																	, ; //X3_ARQUIVO
	'01'																	, ; //X3_ORDEM
	'PA0_FILIAL'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	2																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Filial'																, ; //X3_TITULO
	'Sucursal'																, ; //X3_TITSPA
	'Branch'																, ; //X3_TITENG
	'Filial do Sistema'														, ; //X3_DESCRIC
	'Sucursal'																, ; //X3_DESCSPA
	'Branch of the System'													, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'XXXXXX X'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	'033'																	, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	''																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	''																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PA0'																	, ; //X3_ARQUIVO
	'02'																	, ; //X3_ORDEM
	'PA0_TAB'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	3																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Cod. Tabela'															, ; //X3_TITULO
	'Cod. Tabela'															, ; //X3_TITSPA
	'Cod. Tabela'															, ; //X3_TITENG
	'Codigo de Tabela'														, ; //X3_DESCRIC
	'Codigo de Tabela'														, ; //X3_DESCSPA
	'Codigo de Tabela'														, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	'GETSX8NUM("PA0","PA0_TAB")'											, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	'x'																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PA0'																	, ; //X3_ARQUIVO
	'03'																	, ; //X3_ORDEM
	'PA0_DESC'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	50																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Desc. Tabela'															, ; //X3_TITULO
	'Desc. Tabela'															, ; //X3_TITSPA
	'Desc. Tabela'															, ; //X3_TITENG
	'Descrição da tabela'													, ; //X3_DESCRIC
	'Descrição da tabela'													, ; //X3_DESCSPA
	'Descrição da tabela'													, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	'x'																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PA0'																	, ; //X3_ARQUIVO
	'04'																	, ; //X3_ORDEM
	'PA0_DATA'																, ; //X3_CAMPO
	'D'																		, ; //X3_TIPO
	8																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Data Tabela'															, ; //X3_TITULO
	'Data Tabela'															, ; //X3_TITSPA
	'Data Tabela'															, ; //X3_TITENG
	'Data criação da tabela'												, ; //X3_DESCRIC
	'Data criação da tabela'												, ; //X3_DESCSPA
	'Data criação da tabela'												, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	'DDATABASE'																, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	'x'																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PA0'																	, ; //X3_ARQUIVO
	'05'																	, ; //X3_ORDEM
	'PA0_HORA'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	8																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Hora Tabela'															, ; //X3_TITULO
	'Hora Tabela'															, ; //X3_TITSPA
	'Hora Tabela'															, ; //X3_TITENG
	'Hora de Criação da Tabela'												, ; //X3_DESCRIC
	'Hora de Criação da Tabela'												, ; //X3_DESCSPA
	'Hora de Criação da Tabela'												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	'TIME()'																, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	'x'																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PA0'																	, ; //X3_ARQUIVO
	'06'																	, ; //X3_ORDEM
	'PA0_RETLOG'															, ; //X3_CAMPO
	'M'																		, ; //X3_TIPO
	10																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Observação'															, ; //X3_TITULO
	'Observação'															, ; //X3_TITSPA
	'Observação'															, ; //X3_TITENG
	'Observação'															, ; //X3_DESCRIC
	'Observação'															, ; //X3_DESCSPA
	'Observação'															, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PA0'																	, ; //X3_ARQUIVO
	'07'																	, ; //X3_ORDEM
	'PA0_USERGA'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	17																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Log de Alter'															, ; //X3_TITULO
	'Log de Alter'															, ; //X3_TITSPA
	'Log de Alter'															, ; //X3_TITENG
	'Log de Alteracao'														, ; //X3_DESCRIC
	'Log de Alteracao'														, ; //X3_DESCSPA
	'Log de Alteracao'														, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	9																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'L'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PA0'																	, ; //X3_ARQUIVO
	'08'																	, ; //X3_ORDEM
	'PA0_USERGI'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	17																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Log de Inclu'															, ; //X3_TITULO
	'Log de Inclu'															, ; //X3_TITSPA
	'Log de Inclu'															, ; //X3_TITENG
	'Log de Inclusao'														, ; //X3_DESCRIC
	'Log de Inclusao'														, ; //X3_DESCSPA
	'Log de Inclusao'														, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	9																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'L'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PA0'																	, ; //X3_ARQUIVO
	'09'																	, ; //X3_ORDEM
	'PA0_MSBLQL'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Bloqueado?'															, ; //X3_TITULO
	'Bloqueado?'															, ; //X3_TITSPA
	'Bloqueado?'															, ; //X3_TITENG
	'Registro bloqueado'													, ; //X3_DESCRIC
	'Registro bloqueado'													, ; //X3_DESCSPA
	'Registro bloqueado'													, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	"'2'"																	, ; //X3_RELACAO
	''																		, ; //X3_F3
	9																		, ; //X3_NIVEL
	'     x x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'L'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	'1=Sim;2=Não'															, ; //X3_CBOX
	'1=Si;2=No'																, ; //X3_CBOXSPA
	'1=Yes;2=No'															, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

//
// Campos Tabela PA1
//
aAdd( aSX3, { ;
	'PA1'																	, ; //X3_ARQUIVO
	'01'																	, ; //X3_ORDEM
	'PA1_FILIAL'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	2																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Filial'																, ; //X3_TITULO
	'Sucursal'																, ; //X3_TITSPA
	'Branch'																, ; //X3_TITENG
	'Filial do Sistema'														, ; //X3_DESCRIC
	'Sucursal'																, ; //X3_DESCSPA
	'Branch of the System'													, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'XXXXXX X'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	'033'																	, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	''																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	''																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PA1'																	, ; //X3_ARQUIVO
	'02'																	, ; //X3_ORDEM
	'PA1_ITEM'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	3																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Sequencia'																, ; //X3_TITULO
	'Sequencia'																, ; //X3_TITSPA
	'Sequencia'																, ; //X3_TITENG
	'Sequencia de Item'														, ; //X3_DESCRIC
	'Sequencia de Item'														, ; //X3_DESCSPA
	'Sequencia de Item'														, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	'x'																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PA1'																	, ; //X3_ARQUIVO
	'03'																	, ; //X3_ORDEM
	'PA1_COD'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	15																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Cod.Produto'															, ; //X3_TITULO
	'Cod.Produto'															, ; //X3_TITSPA
	'Cod.Produto'															, ; //X3_TITENG
	'Codigo do Produto'														, ; //X3_DESCRIC
	'Codigo do Produto'														, ; //X3_DESCSPA
	'Codigo do Produto'														, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	'ExistCpo("SB1")'														, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	'SB1'																	, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	'S'																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	'x'																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PA1'																	, ; //X3_ARQUIVO
	'04'																	, ; //X3_ORDEM
	'PA1_DESC'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	55																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Desc.Produto'															, ; //X3_TITULO
	'Desc.Produto'															, ; //X3_TITSPA
	'Desc.Produto'															, ; //X3_TITENG
	'Descrição do produto'													, ; //X3_DESCRIC
	'Descrição do produto'													, ; //X3_DESCSPA
	'Descrição do produto'													, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	'x'																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PA1'																	, ; //X3_ARQUIVO
	'05'																	, ; //X3_ORDEM
	'PA1_TIPO'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	2																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Tipo Protudo'															, ; //X3_TITULO
	'Tipo Protudo'															, ; //X3_TITSPA
	'Tipo Protudo'															, ; //X3_TITENG
	'Tipo Protudo'															, ; //X3_DESCRIC
	'Tipo Protudo'															, ; //X3_DESCSPA
	'Tipo Protudo'															, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	'A010Tipo()'															, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	'02'																	, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	'x'																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PA1'																	, ; //X3_ARQUIVO
	'06'																	, ; //X3_ORDEM
	'PA1_TMMOV'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Tp.Movmento'															, ; //X3_TITULO
	'Tp.Movmento'															, ; //X3_TITSPA
	'Tp.Movmento'															, ; //X3_TITENG
	'Tipo de Movimento'														, ; //X3_DESCRIC
	'Tipo de Movimento'														, ; //X3_DESCSPA
	'Tipo de Movimento'														, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	'x'																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	'1=Produção;2=Transferencia;3=Baixa Requisicao;4=Venda CPV'				, ; //X3_CBOX
	'1=Produção;2=Transferencia;3=Baixa Requisicao;4=Venda CPV'				, ; //X3_CBOXSPA
	'1=Produção;2=Transferencia;3=Baixa Requisicao;4=Venda CPV'				, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PA1'																	, ; //X3_ARQUIVO
	'07'																	, ; //X3_ORDEM
	'PA1_TMORIG'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	3																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Tp.Movimento'															, ; //X3_TITULO
	'Tp.Movimento'															, ; //X3_TITSPA
	'Tp.Movimento'															, ; //X3_TITENG
	'Tipo de Movimento'														, ; //X3_DESCRIC
	'Tipo de Movimento'														, ; //X3_DESCSPA
	'Tipo de Movimento'														, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	'ExistCpo("SF5")'														, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	'SF5'																	, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	'x'																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PA1'																	, ; //X3_ARQUIVO
	'08'																	, ; //X3_ORDEM
	'PA1_TES'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	3																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Tes p/ CPV'															, ; //X3_TITULO
	'Tes p/ CPV'															, ; //X3_TITSPA
	'Tes p/ CPV'															, ; //X3_TITENG
	'Tes para Venda do CPV'													, ; //X3_DESCRIC
	'Tes para Venda do CPV'													, ; //X3_DESCSPA
	'Tes para Venda do CPV'													, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	'SF4'																	, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'S'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PA1'																	, ; //X3_ARQUIVO
	'09'																	, ; //X3_ORDEM
	'PA1_FILDES'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	2																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Fil.Movim.'															, ; //X3_TITULO
	'Fil.Movim.'															, ; //X3_TITSPA
	'Fil.Movim.'															, ; //X3_TITENG
	'Filial de Movimentação'												, ; //X3_DESCRIC
	'Filial de Movimentação'												, ; //X3_DESCSPA
	'Filial de Movimentação'												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	'SM0'																	, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	'x'																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PA1'																	, ; //X3_ARQUIVO
	'10'																	, ; //X3_ORDEM
	'PA1_LOCDES'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	2																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Arm. Destino'															, ; //X3_TITULO
	'Arm. Destino'															, ; //X3_TITSPA
	'Arm. Destino'															, ; //X3_TITENG
	'Armazen de Destino'													, ; //X3_DESCRIC
	'Armazen de Destino'													, ; //X3_DESCSPA
	'Armazen de Destino'													, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	'ExistCpo("NNR")'														, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	'NNR'																	, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	'x'																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PA1'																	, ; //X3_ARQUIVO
	'11'																	, ; //X3_ORDEM
	'PA1_MSBLQL'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Bloqueado?'															, ; //X3_TITULO
	'Bloqueado?'															, ; //X3_TITSPA
	'Bloqueado?'															, ; //X3_TITENG
	'Registro bloqueado'													, ; //X3_DESCRIC
	'Registro bloqueado'													, ; //X3_DESCSPA
	'Registro bloqueado'													, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	"'2'"																	, ; //X3_RELACAO
	''																		, ; //X3_F3
	9																		, ; //X3_NIVEL
	'     x x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'L'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	'1=Sim;2=Não'															, ; //X3_CBOX
	'1=Si;2=No'																, ; //X3_CBOXSPA
	'1=Yes;2=No'															, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PA1'																	, ; //X3_ARQUIVO
	'12'																	, ; //X3_ORDEM
	'PA1_USERGI'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	17																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Log de Inclu'															, ; //X3_TITULO
	'Log de Inclu'															, ; //X3_TITSPA
	'Log de Inclu'															, ; //X3_TITENG
	'Log de Inclusao'														, ; //X3_DESCRIC
	'Log de Inclusao'														, ; //X3_DESCSPA
	'Log de Inclusao'														, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	9																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'L'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PA1'																	, ; //X3_ARQUIVO
	'13'																	, ; //X3_ORDEM
	'PA1_USERGA'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	17																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Log de Alter'															, ; //X3_TITULO
	'Log de Alter'															, ; //X3_TITSPA
	'Log de Alter'															, ; //X3_TITENG
	'Log de Alteracao'														, ; //X3_DESCRIC
	'Log de Alteracao'														, ; //X3_DESCSPA
	'Log de Alteracao'														, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	9																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'L'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PA1'																	, ; //X3_ARQUIVO
	'14'																	, ; //X3_ORDEM
	'PA1_TAB'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	3																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Cod. Tabela'															, ; //X3_TITULO
	'Cod. Tabela'															, ; //X3_TITSPA
	'Cod. Tabela'															, ; //X3_TITENG
	'Codigo da tabela'														, ; //X3_DESCRIC
	'Codigo da tabela'														, ; //X3_DESCSPA
	'Codigo da tabela'														, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	'FWFLDGET("PA0_TAB")'													, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	'x'																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

//
// Campos Tabela PAX
//
aAdd( aSX3, { ;
	'PAX'																	, ; //X3_ARQUIVO
	'01'																	, ; //X3_ORDEM
	'PAX_FILIAL'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	2																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Filial'																, ; //X3_TITULO
	'Sucursal'																, ; //X3_TITSPA
	'Branch'																, ; //X3_TITENG
	'Filial do Sistema'														, ; //X3_DESCRIC
	'Sucursal'																, ; //X3_DESCSPA
	'Branch of the System'													, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'XXXXXX X'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	'033'																	, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	''																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	''																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAX'																	, ; //X3_ARQUIVO
	'02'																	, ; //X3_ORDEM
	'PAX_DOC'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Doc.Moviment'															, ; //X3_TITULO
	'Doc.Moviment'															, ; //X3_TITSPA
	'Doc.Moviment'															, ; //X3_TITENG
	'Documento Movimento'													, ; //X3_DESCRIC
	'Documento Movimento'													, ; //X3_DESCSPA
	'Documento Movimento'													, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	'GETSX8NUM("PAX","PAX_DOC")'											, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	'x'																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'S'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAX'																	, ; //X3_ARQUIVO
	'03'																	, ; //X3_ORDEM
	'PAX_STATUS'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Status'																, ; //X3_TITULO
	'Status'																, ; //X3_TITSPA
	'Status'																, ; //X3_TITENG
	'Status'																, ; //X3_DESCRIC
	'Status'																, ; //X3_DESCSPA
	'Status'																, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	'"1"'																	, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	'1=Aguardando Geração da Movimentação;2=Movimentação Gerado Com Sucesso'	, ; //X3_CBOX
	'1=Aguardando Geração da Movimentação;2=Movimentação Gerado Com Sucesso'	, ; //X3_CBOXSPA
	'1=Aguardando Geração da Movimentação;2=Movimentação Gerado Com Sucesso'	, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAX'																	, ; //X3_ARQUIVO
	'04'																	, ; //X3_ORDEM
	'PAX_DATA'																, ; //X3_CAMPO
	'D'																		, ; //X3_TIPO
	8																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Dt.Movimento'															, ; //X3_TITULO
	'Dt.Movimento'															, ; //X3_TITSPA
	'Dt.Movimento'															, ; //X3_TITENG
	'Data do Movimento'														, ; //X3_DESCRIC
	'Data do Movimento'														, ; //X3_DESCSPA
	'Data do Movimento'														, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	'DDATABASE'																, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAX'																	, ; //X3_ARQUIVO
	'05'																	, ; //X3_ORDEM
	'PAX_HORA'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	8																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Hora Trasnf.'															, ; //X3_TITULO
	'Hora Trasnf.'															, ; //X3_TITSPA
	'Hora Trasnf.'															, ; //X3_TITENG
	'Hora Trasnferencia'													, ; //X3_DESCRIC
	'Hora Trasnferencia'													, ; //X3_DESCSPA
	'Hora Trasnferencia'													, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	'TIME()'																, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAX'																	, ; //X3_ARQUIVO
	'06'																	, ; //X3_ORDEM
	'PAX_USER'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	30																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Usuario'																, ; //X3_TITULO
	'Usuario'																, ; //X3_TITSPA
	'Usuario'																, ; //X3_TITENG
	'Usuario Responsavel'													, ; //X3_DESCRIC
	'Usuario Responsavel'													, ; //X3_DESCSPA
	'Usuario Responsavel'													, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAX'																	, ; //X3_ARQUIVO
	'07'																	, ; //X3_ORDEM
	'PAX_CRIAOP'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Gera Ab.Op'															, ; //X3_TITULO
	'Gera Ab.Op'															, ; //X3_TITSPA
	'Gera Ab.Op'															, ; //X3_TITENG
	'Gera Abertura Ordem Prod.'												, ; //X3_DESCRIC
	'Gera Abertura Ordem Prod.'												, ; //X3_DESCSPA
	'Gera Abertura Ordem Prod.'												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	'"3"'																	, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	'1=Aguardando a geração;2=Gerado com Sucesso;3=Não Aplicavel'			, ; //X3_CBOX
	'1=Aguardando a geração;2=Gerado com Sucesso;3=Não Aplicavel'			, ; //X3_CBOXSPA
	'1=Aguardando a geração;2=Gerado com Sucesso;3=Não Aplicavel'			, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAX'																	, ; //X3_ARQUIVO
	'08'																	, ; //X3_ORDEM
	'PAX_APTOOP'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Gera Apont.'															, ; //X3_TITULO
	'Gera Apont.'															, ; //X3_TITSPA
	'Gera Apont.'															, ; //X3_TITENG
	'Gera Apontamento Op'													, ; //X3_DESCRIC
	'Gera Apontamento Op'													, ; //X3_DESCSPA
	'Gera Apontamento Op'													, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	'"3"'																	, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	'1=Aguardando a geração;2=Gerado com Sucesso;3=Não Aplicavel'			, ; //X3_CBOX
	'1=Aguardando a geração;2=Gerado com Sucesso;3=Não Aplicavel'			, ; //X3_CBOXSPA
	'1=Aguardando a geração;2=Gerado com Sucesso;3=Não Aplicavel'			, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAX'																	, ; //X3_ARQUIVO
	'09'																	, ; //X3_ORDEM
	'PAX_REQUIS'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Gera Requis.'															, ; //X3_TITULO
	'Gera Requis.'															, ; //X3_TITSPA
	'Gera Requis.'															, ; //X3_TITENG
	'Gera Requisição'														, ; //X3_DESCRIC
	'Gera Requisição'														, ; //X3_DESCSPA
	'Gera Requisição'														, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	'"3"'																	, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	'1=Aguardando a geração;2=Gerado com Sucesso;3=Não Aplicavel'			, ; //X3_CBOX
	'1=Aguardando a geração;2=Gerado com Sucesso;3=Não Aplicavel'			, ; //X3_CBOXSPA
	'1=Aguardando a geração;2=Gerado com Sucesso;3=Não Aplicavel'			, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAX'																	, ; //X3_ARQUIVO
	'10'																	, ; //X3_ORDEM
	'PAX_TRANSF'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Gera Transf.'															, ; //X3_TITULO
	'Gera Transf.'															, ; //X3_TITSPA
	'Gera Transf.'															, ; //X3_TITENG
	'Gera Transferencia'													, ; //X3_DESCRIC
	'Gera Transferencia'													, ; //X3_DESCSPA
	'Gera Transferencia'													, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	'"3"'																	, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	'1=Aguardando a geração;2=Gerado com Sucesso;3=Não Aplicavel'			, ; //X3_CBOX
	'1=Aguardando a geração;2=Gerado com Sucesso;3=Não Aplicavel'			, ; //X3_CBOXSPA
	'1=Aguardando a geração;2=Gerado com Sucesso;3=Não Aplicavel'			, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAX'																	, ; //X3_ARQUIVO
	'11'																	, ; //X3_ORDEM
	'PAX_PVENDA'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Gera P.Venda'															, ; //X3_TITULO
	'Gera P.Venda'															, ; //X3_TITSPA
	'Gera P.Venda'															, ; //X3_TITENG
	'Gera Pedido de venda'													, ; //X3_DESCRIC
	'Gera Pedido de venda'													, ; //X3_DESCSPA
	'Gera Pedido de venda'													, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	'"3"'																	, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	'1=Aguardando a geração;2=Gerado com Sucesso;3=Não Aplicavel'			, ; //X3_CBOX
	'1=Aguardando a geração;2=Gerado com Sucesso;3=Não Aplicavel'			, ; //X3_CBOXSPA
	'1=Aguardando a geração;2=Gerado com Sucesso;3=Não Aplicavel'			, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAX'																	, ; //X3_ARQUIVO
	'12'																	, ; //X3_ORDEM
	'PAX_GERNF'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Gera Doc.Cpv'															, ; //X3_TITULO
	'Gera Doc.Cpv'															, ; //X3_TITSPA
	'Gera Doc.Cpv'															, ; //X3_TITENG
	'Gera Documento Cpv'													, ; //X3_DESCRIC
	'Gera Documento Cpv'													, ; //X3_DESCSPA
	'Gera Documento Cpv'													, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	'"3"'																	, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	'1=Aguardando a geração;2=Gerado com Sucesso;3=Não Aplicavel'			, ; //X3_CBOX
	'1=Aguardando a geração;2=Gerado com Sucesso;3=Não Aplicavel'			, ; //X3_CBOXSPA
	'1=Aguardando a geração;2=Gerado com Sucesso;3=Não Aplicavel'			, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAX'																	, ; //X3_ARQUIVO
	'13'																	, ; //X3_ORDEM
	'PAX_RETLOG'															, ; //X3_CAMPO
	'M'																		, ; //X3_TIPO
	10																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Log. Transf.'															, ; //X3_TITULO
	'Log. Transf.'															, ; //X3_TITSPA
	'Log. Transf.'															, ; //X3_TITENG
	'Log de Transferencia'													, ; //X3_DESCRIC
	'Log de Transferencia'													, ; //X3_DESCSPA
	'Log de Transferencia'													, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

//
// Campos Tabela PAY
//
aAdd( aSX3, { ;
	'PAY'																	, ; //X3_ARQUIVO
	'01'																	, ; //X3_ORDEM
	'PAY_FILIAL'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	2																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Filial'																, ; //X3_TITULO
	'Sucursal'																, ; //X3_TITSPA
	'Branch'																, ; //X3_TITENG
	'Filial do Sistema'														, ; //X3_DESCRIC
	'Sucursal'																, ; //X3_DESCSPA
	'Branch of the System'													, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'XXXXXX X'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	'033'																	, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	''																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	''																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAY'																	, ; //X3_ARQUIVO
	'02'																	, ; //X3_ORDEM
	'PAY_ITEM'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	3																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Item'																	, ; //X3_TITULO
	'Item'																	, ; //X3_TITSPA
	'Item'																	, ; //X3_TITENG
	'Item'																	, ; //X3_DESCRIC
	'Item'																	, ; //X3_DESCSPA
	'Item'																	, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	'x'																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAY'																	, ; //X3_ARQUIVO
	'03'																	, ; //X3_ORDEM
	'PAY_STATUS'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Status Mov.'															, ; //X3_TITULO
	'Status Mov.'															, ; //X3_TITSPA
	'Status Mov.'															, ; //X3_TITENG
	'Status Geração Movimento'												, ; //X3_DESCRIC
	'Status Geração Movimento'												, ; //X3_DESCSPA
	'Status Geração Movimento'												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	'"1"'																	, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	'1=Aguardando Geração;2=Gerado com Sucesso'								, ; //X3_CBOX
	'1=Aguardando Geração;2=Gerado com Sucesso'								, ; //X3_CBOXSPA
	'1=Aguardando Geração;2=Gerado com Sucesso'								, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAY'																	, ; //X3_ARQUIVO
	'04'																	, ; //X3_ORDEM
	'PAY_COD'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	15																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Cod.Produto'															, ; //X3_TITULO
	'Cod.Produto'															, ; //X3_TITSPA
	'Cod.Produto'															, ; //X3_TITENG
	'Codigo do Produto'														, ; //X3_DESCRIC
	'Codigo do Produto'														, ; //X3_DESCSPA
	'Codigo do Produto'														, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	'ExistCpo("SB1")'														, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	'SB1'																	, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	'S'																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	'x'																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAY'																	, ; //X3_ARQUIVO
	'05'																	, ; //X3_ORDEM
	'PAY_DESC'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	55																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Desc.Produto'															, ; //X3_TITULO
	'Desc.Produto'															, ; //X3_TITSPA
	'Desc.Produto'															, ; //X3_TITENG
	'Descrição do produto'													, ; //X3_DESCRIC
	'Descrição do produto'													, ; //X3_DESCSPA
	'Descrição do produto'													, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAY'																	, ; //X3_ARQUIVO
	'06'																	, ; //X3_ORDEM
	'PAY_TIPO'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	2																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Tipo Produto'															, ; //X3_TITULO
	'Tipo Produto'															, ; //X3_TITSPA
	'Tipo Produto'															, ; //X3_TITENG
	'Tipo Produto'															, ; //X3_DESCRIC
	'Tipo Produto'															, ; //X3_DESCSPA
	'Tipo Produto'															, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	'A010Tipo()'															, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAY'																	, ; //X3_ARQUIVO
	'07'																	, ; //X3_ORDEM
	'PAY_UM'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	2																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Unid.Medida'															, ; //X3_TITULO
	'Unid.Medida'															, ; //X3_TITSPA
	'Unid.Medida'															, ; //X3_TITENG
	'Unidade de Medida'														, ; //X3_DESCRIC
	'Unidade de Medida'														, ; //X3_DESCSPA
	'Unidade de Medida'														, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	'SAH'																	, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'S'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAY'																	, ; //X3_ARQUIVO
	'08'																	, ; //X3_ORDEM
	'PAY_TM'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	3																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Cd.Mov.Inter'															, ; //X3_TITULO
	'Cd.Mov.Inter'															, ; //X3_TITSPA
	'Cd.Mov.Inter'															, ; //X3_TITENG
	'Cod. Movimentação Interna'												, ; //X3_DESCRIC
	'Cod. Movimentação Interna'												, ; //X3_DESCSPA
	'Cod. Movimentação Interna'												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	'ExistCpo("SF5")'														, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	'SF5'																	, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'S'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAY'																	, ; //X3_ARQUIVO
	'09'																	, ; //X3_ORDEM
	'PAY_TES'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	3																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Tes p/ CPV'															, ; //X3_TITULO
	'Tes p/ CPV'															, ; //X3_TITSPA
	'Tes p/ CPV'															, ; //X3_TITENG
	'Tes Para Mov. CPV'														, ; //X3_DESCRIC
	'Tes Para Mov. CPV'														, ; //X3_DESCSPA
	'Tes Para Mov. CPV'														, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	'ExistCpo("SF4")'														, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	'SF4'																	, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'S'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAY'																	, ; //X3_ARQUIVO
	'10'																	, ; //X3_ORDEM
	'PAY_TPMOV'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Tp.Movimento'															, ; //X3_TITULO
	'Tp.Movimento'															, ; //X3_TITSPA
	'Tp.Movimento'															, ; //X3_TITENG
	'Tipo de Movimento Estoque'												, ; //X3_DESCRIC
	'Tipo de Movimento Estoque'												, ; //X3_DESCSPA
	'Tipo de Movimento Estoque'												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	'x'																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	'1=Produção;2=Transferencia;3=Baixa Requisicao;4=Venda CPV'				, ; //X3_CBOX
	'1=Produção;2=Transferencia;3=Baixa Requisicao;4=Venda CPV'				, ; //X3_CBOXSPA
	'1=Produção;2=Transferencia;3=Baixa Requisicao;4=Venda CPV'				, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAY'																	, ; //X3_ARQUIVO
	'11'																	, ; //X3_ORDEM
	'PAY_FILMOV'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	2																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Filial Movim'															, ; //X3_TITULO
	'Filial Movim'															, ; //X3_TITSPA
	'Filial Movim'															, ; //X3_TITENG
	'Filial Movimento Estoque'												, ; //X3_DESCRIC
	'Filial Movimento Estoque'												, ; //X3_DESCSPA
	'Filial Movimento Estoque'												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	'SM0'																	, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	'x'																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAY'																	, ; //X3_ARQUIVO
	'12'																	, ; //X3_ORDEM
	'PAY_LOCAL'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	2																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Arm.Mov.Est.'															, ; //X3_TITULO
	'Arm.Mov.Est.'															, ; //X3_TITSPA
	'Arm.Mov.Est.'															, ; //X3_TITENG
	'Armazen de Movimentacao'												, ; //X3_DESCRIC
	'Armazen de Movimentacao'												, ; //X3_DESCSPA
	'Armazen de Movimentacao'												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	'ExistCpo("NNR")'														, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	'NNR'																	, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	'x'																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'S'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAY'																	, ; //X3_ARQUIVO
	'13'																	, ; //X3_ORDEM
	'PAY_QTD'																, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	16																		, ; //X3_TAMANHO
	4																		, ; //X3_DECIMAL
	'Qt.Movimento'															, ; //X3_TITULO
	'Qt.Movimento'															, ; //X3_TITSPA
	'Qt.Movimento'															, ; //X3_TITENG
	'Quantidade Movimentacao'												, ; //X3_DESCRIC
	'Quantidade Movimentacao'												, ; //X3_DESCSPA
	'Quantidade Movimentacao'												, ; //X3_DESCENG
	'@E 99,999,999,999.9999'												, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAY'																	, ; //X3_ARQUIVO
	'14'																	, ; //X3_ORDEM
	'PAY_COMP'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	15																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Prod.Empenho'															, ; //X3_TITULO
	'Prod.Empenho'															, ; //X3_TITSPA
	'Prod.Empenho'															, ; //X3_TITENG
	'Produto Ajuste de Empenho'												, ; //X3_DESCRIC
	'Produto Ajuste de Empenho'												, ; //X3_DESCSPA
	'Produto Ajuste de Empenho'												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	'ExistCpo("SB1")'														, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	'S'																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAY'																	, ; //X3_ARQUIVO
	'15'																	, ; //X3_ORDEM
	'PAY_DSCEMP'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	55																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Desc.Prod.Ep'															, ; //X3_TITULO
	'Desc.Prod.Ep'															, ; //X3_TITSPA
	'Desc.Prod.Ep'															, ; //X3_TITENG
	'Descrição Produto Empenho'												, ; //X3_DESCRIC
	'Descrição Produto Empenho'												, ; //X3_DESCSPA
	'Descrição Produto Empenho'												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAY'																	, ; //X3_ARQUIVO
	'16'																	, ; //X3_ORDEM
	'PAY_QTDEMP'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	16																		, ; //X3_TAMANHO
	4																		, ; //X3_DECIMAL
	'Qtd.Empenho'															, ; //X3_TITULO
	'Qtd.Empenho'															, ; //X3_TITSPA
	'Qtd.Empenho'															, ; //X3_TITENG
	'Quantidade do Empenho'													, ; //X3_DESCRIC
	'Quantidade do Empenho'													, ; //X3_DESCSPA
	'Quantidade do Empenho'													, ; //X3_DESCENG
	'@E 99,999,999,999.9999'												, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAY'																	, ; //X3_ARQUIVO
	'17'																	, ; //X3_ORDEM
	'PAY_AVANCO'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Sts Geracao'															, ; //X3_TITULO
	'Sts Geracao'															, ; //X3_TITSPA
	'Sts Geracao'															, ; //X3_TITENG
	'Status Geração Movimento'												, ; //X3_DESCRIC
	'Status Geração Movimento'												, ; //X3_DESCSPA
	'Status Geração Movimento'												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	'"1"'																	, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	'1=Aguardando Geração;2=OP Criada;3=OP Apontada;4=Transferencia;5=Baixa Requisicao;6=Pedido Venda;7=Doc. Gerado', ; //X3_CBOX
	'1=Aguardando Geração;2=OP Criada;3=OP Apontada;4=Transferencia;5=Baixa Requisicao;6=Pedido Venda;7=Doc. Gerado', ; //X3_CBOXSPA
	'1=Aguardando Geração;2=OP Criada;3=OP Apontada;4=Transferencia;5=Baixa Requisicao;6=Pedido Venda;7=Doc. Gerado', ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAY'																	, ; //X3_ARQUIVO
	'18'																	, ; //X3_ORDEM
	'PAY_DOC'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Doc.Moviment'															, ; //X3_TITULO
	'Doc.Moviment'															, ; //X3_TITSPA
	'Doc.Moviment'															, ; //X3_TITENG
	'Documento Movimento'													, ; //X3_DESCRIC
	'Documento Movimento'													, ; //X3_DESCSPA
	'Documento Movimento'													, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	'FWFLDGET("PAX_DOC")'													, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	'x'																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAY'																	, ; //X3_ARQUIVO
	'19'																	, ; //X3_ORDEM
	'PAY_DATA'																, ; //X3_CAMPO
	'D'																		, ; //X3_TIPO
	8																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Data Geração'															, ; //X3_TITULO
	'Data Geração'															, ; //X3_TITSPA
	'Data Geração'															, ; //X3_TITENG
	'Data Geração do Movimento'												, ; //X3_DESCRIC
	'Data Geração do Movimento'												, ; //X3_DESCSPA
	'Data Geração do Movimento'												, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAY'																	, ; //X3_ARQUIVO
	'20'																	, ; //X3_ORDEM
	'PAY_HORA'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	8																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Hora Movim.'															, ; //X3_TITULO
	'Hora Movim.'															, ; //X3_TITSPA
	'Hora Movim.'															, ; //X3_TITENG
	'Hora Geração Movimento'												, ; //X3_DESCRIC
	'Hora Geração Movimento'												, ; //X3_DESCSPA
	'Hora Geração Movimento'												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAY'																	, ; //X3_ARQUIVO
	'21'																	, ; //X3_ORDEM
	'PAY_NUMDOC'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	9																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Num.Mov.Est.'															, ; //X3_TITULO
	'Num.Mov.Est.'															, ; //X3_TITSPA
	'Num.Mov.Est.'															, ; //X3_TITENG
	'Numero Doc. Mov. Estoque'												, ; //X3_DESCRIC
	'Numero Doc. Mov. Estoque'												, ; //X3_DESCSPA
	'Numero Doc. Mov. Estoque'												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAY'																	, ; //X3_ARQUIVO
	'22'																	, ; //X3_ORDEM
	'PAY_OP'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Ordem Produc'															, ; //X3_TITULO
	'Ordem Produc'															, ; //X3_TITSPA
	'Ordem Produc'															, ; //X3_TITENG
	'Ordem Produção Gerada'													, ; //X3_DESCRIC
	'Ordem Produção Gerada'													, ; //X3_DESCSPA
	'Ordem Produção Gerada'													, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAY'																	, ; //X3_ARQUIVO
	'23'																	, ; //X3_ORDEM
	'PAY_NUMPED'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Num. Pedido'															, ; //X3_TITULO
	'Num. Pedido'															, ; //X3_TITSPA
	'Num. Pedido'															, ; //X3_TITENG
	'Numero de Pedido Vendas'												, ; //X3_DESCRIC
	'Numero de Pedido Vendas'												, ; //X3_DESCSPA
	'Numero de Pedido Vendas'												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAY'																	, ; //X3_ARQUIVO
	'24'																	, ; //X3_ORDEM
	'PAY_NUMNF'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	9																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Num. Doc.Cpv'															, ; //X3_TITULO
	'Num. Doc.Cpv'															, ; //X3_TITSPA
	'Num. Doc.Cpv'															, ; //X3_TITENG
	'Numero do Documento CPV'												, ; //X3_DESCRIC
	'Numero do Documento CPV'												, ; //X3_DESCSPA
	'Numero do Documento CPV'												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAY'																	, ; //X3_ARQUIVO
	'25'																	, ; //X3_ORDEM
	'PAY_SERIE'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	3																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Serie Doc.'															, ; //X3_TITULO
	'Serie Doc.'															, ; //X3_TITSPA
	'Serie Doc.'															, ; //X3_TITENG
	'Serie Documento CPV'													, ; //X3_DESCRIC
	'Serie Documento CPV'													, ; //X3_DESCSPA
	'Serie Documento CPV'													, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAY'																	, ; //X3_ARQUIVO
	'26'																	, ; //X3_ORDEM
	'PAY_DTANF'																, ; //X3_CAMPO
	'D'																		, ; //X3_TIPO
	8																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Dta. Nf.Cpv'															, ; //X3_TITULO
	'Dta. Nf.Cpv'															, ; //X3_TITSPA
	'Dta. Nf.Cpv'															, ; //X3_TITENG
	'Data Documento CPV'													, ; //X3_DESCRIC
	'Data Documento CPV'													, ; //X3_DESCSPA
	'Data Documento CPV'													, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME


//
// Atualizando dicionário
//
nPosArq := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_ARQUIVO" } )
nPosOrd := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_ORDEM"   } )
nPosCpo := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_CAMPO"   } )
nPosTam := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_TAMANHO" } )
nPosSXG := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_GRPSXG"  } )
nPosVld := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_VALID"   } )

aSort( aSX3,,, { |x,y| x[nPosArq]+x[nPosOrd]+x[nPosCpo] < y[nPosArq]+y[nPosOrd]+y[nPosCpo] } )

oProcess:SetRegua2( Len( aSX3 ) )

dbSelectArea( "SX3" )
dbSetOrder( 2 )
cAliasAtu := ""

For nI := 1 To Len( aSX3 )

	//
	// Verifica se o campo faz parte de um grupo e ajusta tamanho
	//
	If !Empty( aSX3[nI][nPosSXG] )
		SXG->( dbSetOrder( 1 ) )
		If SXG->( MSSeek( aSX3[nI][nPosSXG] ) )
			If aSX3[nI][nPosTam] <> SXG->XG_SIZE
				aSX3[nI][nPosTam] := SXG->XG_SIZE
				AutoGrLog( "O tamanho do campo " + aSX3[nI][nPosCpo] + " NÃO atualizado e foi mantido em [" + ;
				AllTrim( Str( SXG->XG_SIZE ) ) + "]" + CRLF + ;
				" por pertencer ao grupo de campos [" + SXG->XG_GRUPO + "]" + CRLF )
			EndIf
		EndIf
	EndIf

	SX3->( dbSetOrder( 2 ) )

	If !( aSX3[nI][nPosArq] $ cAlias )
		cAlias += aSX3[nI][nPosArq] + "/"
		aAdd( aArqUpd, aSX3[nI][nPosArq] )
	EndIf

	If !SX3->( dbSeek( PadR( aSX3[nI][nPosCpo], nTamSeek ) ) )

		//
		// Busca ultima ocorrencia do alias
		//
		If ( aSX3[nI][nPosArq] <> cAliasAtu )
			cSeqAtu   := "00"
			cAliasAtu := aSX3[nI][nPosArq]

			dbSetOrder( 1 )
			SX3->( dbSeek( cAliasAtu + "ZZ", .T. ) )
			dbSkip( -1 )

			If ( SX3->X3_ARQUIVO == cAliasAtu )
				cSeqAtu := SX3->X3_ORDEM
			EndIf

			nSeqAtu := Val( RetAsc( cSeqAtu, 3, .F. ) )
		EndIf

		nSeqAtu++
		cSeqAtu := RetAsc( Str( nSeqAtu ), 2, .T. )

		RecLock( "SX3", .T. )
		For nJ := 1 To Len( aSX3[nI] )
			If     nJ == nPosOrd  // Ordem
				SX3->( FieldPut( FieldPos( aEstrut[nJ][1] ), cSeqAtu ) )

			ElseIf aEstrut[nJ][2] > 0
				SX3->( FieldPut( FieldPos( aEstrut[nJ][1] ), aSX3[nI][nJ] ) )

			EndIf
		Next nJ

		dbCommit()
		MsUnLock()

		AutoGrLog( "Criado campo " + aSX3[nI][nPosCpo] )

	EndIf

	oProcess:IncRegua2( "Atualizando Campos de Tabelas (SX3) ..." )

Next nI

AutoGrLog( CRLF + "Final da Atualização" + " SX3" + CRLF + Replicate( "-", 128 ) + CRLF )

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuSIX

Função de processamento da gravação do SIX - Indices

@author UPDATE gerado automaticamente
@since  18/12/2023
@obs    Gerado por EXPORDIC - V.7.6.3.4 EFS / Upd. V.6.4.1 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuSIX()
Local aEstrut   := {}
Local aSIX      := {}
Local lAlt      := .F.
Local lDelInd   := .F.
Local nI        := 0
Local nJ        := 0

AutoGrLog( "Ínicio da Atualização" + " SIX" + CRLF )

aEstrut := { "INDICE" , "ORDEM" , "CHAVE", "DESCRICAO", "DESCSPA"  , ;
             "DESCENG", "PROPRI", "F3"   , "NICKNAME" , "SHOWPESQ" }

//
// Tabela PA0
//
aAdd( aSIX, { ;
	'PA0'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'PA0_FILIAL+PA0_TAB'													, ; //CHAVE
	'Cod. Tabela'															, ; //DESCRICAO
	'Cod. Tabela'															, ; //DESCSPA
	'Cod. Tabela'															, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

//
// Tabela PA1
//
aAdd( aSIX, { ;
	'PA1'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'PA1_FILIAL+PA1_TAB'													, ; //CHAVE
	'Cod. Tabela'															, ; //DESCRICAO
	'Cod. Tabela'															, ; //DESCSPA
	'Cod. Tabela'															, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'PA1'																	, ; //INDICE
	'2'																		, ; //ORDEM
	'PA1_FILIAL+PA1_COD+PA1_TMMOV+PA1_TAB+PA1_LOCDES+PA1_FILDES'			, ; //CHAVE
	'Cod.Produto+Tp.Movmento+Cod. Tabela+Arm. Destino+Fil.Movim.'			, ; //DESCRICAO
	'Cod.Produto+Tp.Movmento+Cod. Tabela+Arm. Destino+Fil.Movim.'			, ; //DESCSPA
	'Cod.Produto+Tp.Movmento+Cod. Tabela+Arm. Destino+Fil.Movim.'			, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'PA1'																	, ; //INDICE
	'3'																		, ; //ORDEM
	'PA1_FILIAL+PA1_COD+PA1_ITEM'											, ; //CHAVE
	'Cod.Produto+Sequencia'													, ; //DESCRICAO
	'Cod.Produto+Sequencia'													, ; //DESCSPA
	'Cod.Produto+Sequencia'													, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

//
// Tabela PAX
//
aAdd( aSIX, { ;
	'PAX'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'PAX_FILIAL+PAX_DOC'													, ; //CHAVE
	'Cod.Documento'															, ; //DESCRICAO
	'Cod.Documento'															, ; //DESCSPA
	'Cod.Documento'															, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

//
// Tabela PAY
//
aAdd( aSIX, { ;
	'PAY'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'PAY_FILIAL+PAY_DOC'													, ; //CHAVE
	'Cod.Documento'															, ; //DESCRICAO
	'Cod.Documento'															, ; //DESCSPA
	'Cod.Documento'															, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'PAY'																	, ; //INDICE
	'2'																		, ; //ORDEM
	'PAY_FILIAL+PAY_COD+PAY_DOC+PAY_ITEM'									, ; //CHAVE
	'Cod.produto+Doc.Moviment+Item'											, ; //DESCRICAO
	'Cod.produto+Doc.Moviment+Item'											, ; //DESCSPA
	'Cod.produto+Doc.Moviment+Item'											, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'PAY'																	, ; //INDICE
	'3'																		, ; //ORDEM
	'PAY_FILIAL+PAY_COD+PAY_TPMOV+PAY_FILMOV+PAY_LOCAL'						, ; //CHAVE
	'Cod.Prod+Tp.Movimento+Filial Movim+Arm.Mov.Est.'						, ; //DESCRICAO
	'Cod.Prod+Tp.Movimento+Filial Movim+Arm.Mov.Est.'						, ; //DESCSPA
	'Cod.Prod+Tp.Movimento+Filial Movim+Arm.Mov.Est.'						, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'PAY'																	, ; //INDICE
	'4'																		, ; //ORDEM
	'PAY_FILIAL+PAY_NUMDOC+PAY_TPMOV'										, ; //CHAVE
	'Num.Mov.Est.+Tp.Movimento'												, ; //DESCRICAO
	'Num.Mov.Est.+Tp.Movimento'												, ; //DESCSPA
	'Num.Mov.Est.+Tp.Movimento'												, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'PAY'																	, ; //INDICE
	'5'																		, ; //ORDEM
	'PAY_FILIAL+PAY_OP+PAY_TPMOV'											, ; //CHAVE
	'Ordem Produc+Tp.Movimento'												, ; //DESCRICAO
	'Ordem Produc+Tp.Movimento'												, ; //DESCSPA
	'Ordem Produc+Tp.Movimento'												, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'PAY'																	, ; //INDICE
	'6'																		, ; //ORDEM
	'PAY_FILIAL+PAY_NUMPED+PAY_TPMOV'										, ; //CHAVE
	'Num. Pedido+Tp.Movimento'												, ; //DESCRICAO
	'Num. Pedido+Tp.Movimento'												, ; //DESCSPA
	'Num. Pedido+Tp.Movimento'												, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'PAY'																	, ; //INDICE
	'7'																		, ; //ORDEM
	'PAY_FILIAL+PAY_NUMNF+PAY_SERIE+PAY_TPMOV'								, ; //CHAVE
	'Num. Doc.Cpv+Serie Doc.+Tp.Movimento'									, ; //DESCRICAO
	'Num. Doc.Cpv+Serie Doc.+Tp.Movimento'									, ; //DESCSPA
	'Num. Doc.Cpv+Serie Doc.+Tp.Movimento'									, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

//
// Atualizando dicionário
//
oProcess:SetRegua2( Len( aSIX ) )

dbSelectArea( "SIX" )
SIX->( dbSetOrder( 1 ) )

For nI := 1 To Len( aSIX )

	lAlt    := .F.
	lDelInd := .F.

	If !SIX->( dbSeek( aSIX[nI][1] + aSIX[nI][2] ) )
		AutoGrLog( "Índice criado " + aSIX[nI][1] + "/" + aSIX[nI][2] + " - " + aSIX[nI][3] )
	Else
		lAlt := .T.
		aAdd( aArqUpd, aSIX[nI][1] )
		If !StrTran( Upper( AllTrim( CHAVE )       ), " ", "" ) == ;
		    StrTran( Upper( AllTrim( aSIX[nI][3] ) ), " ", "" )
			AutoGrLog( "Chave do índice alterado " + aSIX[nI][1] + "/" + aSIX[nI][2] + " - " + aSIX[nI][3] )
			lDelInd := .T. // Se for alteração precisa apagar o indice do banco
		EndIf
	EndIf

	RecLock( "SIX", !lAlt )
	For nJ := 1 To Len( aSIX[nI] )
		If FieldPos( aEstrut[nJ] ) > 0
			FieldPut( FieldPos( aEstrut[nJ] ), aSIX[nI][nJ] )
		EndIf
	Next nJ
	MsUnLock()

	dbCommit()

	If lDelInd
		TcInternal( 60, RetSqlName( aSIX[nI][1] ) + "|" + RetSqlName( aSIX[nI][1] ) + aSIX[nI][2] )
	EndIf

	oProcess:IncRegua2( "Atualizando índices ..." )

Next nI

AutoGrLog( CRLF + "Final da Atualização" + " SIX" + CRLF + Replicate( "-", 128 ) + CRLF )

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuSX6

Função de processamento da gravação do SX6 - Parâmetros

@author UPDATE gerado automaticamente
@since  18/12/2023
@obs    Gerado por EXPORDIC - V.7.6.3.4 EFS / Upd. V.6.4.1 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuSX6()
Local aEstrut   := {}
Local aSX6      := {}
Local cAlias    := ""
Local lContinua := .T.
Local lReclock  := .T.
Local nI        := 0
Local nJ        := 0
Local nTamFil   := Len( SX6->X6_FIL )
Local nTamVar   := Len( SX6->X6_VAR )

AutoGrLog( "Ínicio da Atualização" + " SX6" + CRLF )

aEstrut := { "X6_FIL"    , "X6_VAR"    , "X6_TIPO"   , "X6_DESCRIC", "X6_DSCSPA" , "X6_DSCENG" , "X6_DESC1"  , ;
             "X6_DSCSPA1", "X6_DSCENG1", "X6_DESC2"  , "X6_DSCSPA2", "X6_DSCENG2", "X6_CONTEUD", "X6_CONTSPA", ;
             "X6_CONTENG", "X6_PROPRI" , "X6_VALID"  , "X6_INIT"   , "X6_DEFPOR" , "X6_DEFSPA" , "X6_DEFENG" , ;
             "X6_PYME"   }

aAdd( aSX6, { ;
	'01'																	, ; //X6_FIL
	'OZ_CLIENT'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Codigo Cliente Utilizado Rotina OZ04M05.prw'							, ; //X6_DESCRIC
	'Projeto PCP OzMInerals 2 FASE'											, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'000083'																, ; //X6_CONTEUD
	'000083'																, ; //X6_CONTSPA
	'000083'																, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'01'																	, ; //X6_FIL
	'OZ_CLLOJA'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Cod Loja Cliente Utilizado Rotina OZ04M05.prw'							, ; //X6_DESCRIC
	'Projeto PCP OzMInerals 2 FASE'											, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'01'																	, ; //X6_CONTEUD
	'01'																	, ; //X6_CONTSPA
	'01'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'01'																	, ; //X6_FIL
	'OZ_CONPGTO'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Condição Pgto Utilizada OZ04M05.prw'									, ; //X6_DESCRIC
	'Projeto PCP OzMInerals 2 FASE'											, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'003'																	, ; //X6_CONTEUD
	'003'																	, ; //X6_CONTSPA
	'003'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'01'																	, ; //X6_FIL
	'OZ_LIBEMP'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'EmpresaLIberada na Rotina  OZ04M05.prw'								, ; //X6_DESCRIC
	'Projeto PCP OzMInerals 2 FASE'											, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'01'																	, ; //X6_CONTEUD
	'003'																	, ; //X6_CONTSPA
	'003'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'01'																	, ; //X6_FIL
	'OZ_LIBFIL'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Filial LIberada na Rotina  OZ04M05.prw'								, ; //X6_DESCRIC
	'Projeto PCP OzMInerals 2 FASE'											, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'02/06'																	, ; //X6_CONTEUD
	'510'																	, ; //X6_CONTSPA
	'510'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'01'																	, ; //X6_FIL
	'OZ_LIBSER'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Serie Utilizada P.E SX5NOTA.prw'										, ; //X6_DESCRIC
	'Projeto PCP OzMInerals 2 FASE'											, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'CST'																	, ; //X6_CONTEUD
	'CST'																	, ; //X6_CONTSPA
	'V'																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'01'																	, ; //X6_FIL
	'OZ_MA261EX'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita uso ponto de entrada MA261EST'								, ; //X6_DESCRIC
	'Projeto PCP OzMInerals 2 FASE'											, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.F.'																	, ; //X6_CONTSPA
	'.T.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'01'																	, ; //X6_FIL
	'OZ_MT241EX'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita uso ponto de entrada MT241EST'								, ; //X6_DESCRIC
	'Projeto PCP OzMInerals 2 FASE'											, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.T.'																	, ; //X6_CONTSPA
	'.T.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'01'																	, ; //X6_FIL
	'OZ_MT650EX'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita uso ponto de entrada MT650AE'									, ; //X6_DESCRIC
	'Projeto PCP OzMInerals 2 FASE'											, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.T.'																	, ; //X6_CONTSPA
	'.T.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'01'																	, ; //X6_FIL
	'OZ_MTA410E'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita uso ponto de entrada MTA410E'									, ; //X6_DESCRIC
	'Projeto PCP OzMInerals 2 FASE'											, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.T.'																	, ; //X6_CONTSPA
	'.T.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'01'																	, ; //X6_FIL
	'OZ_SD3250E'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita uso ponto de entrada SD3250E'									, ; //X6_DESCRIC
	'Projeto PCP OzMInerals 2 FASE'											, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.T.'																	, ; //X6_CONTSPA
	'.T.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'01'																	, ; //X6_FIL
	'OZ_SF2520E'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita uso ponto de entrada SF2520E'									, ; //X6_DESCRIC
	'Projeto PCP OzMInerals 2 FASE'											, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.T.'																	, ; //X6_CONTSPA
	'.T.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'01'																	, ; //X6_FIL
	'OZ_SX5NOTA'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita uso ponto de entrada SX5NOTA'									, ; //X6_DESCRIC
	'Projeto PCP OzMInerals 2 FASE'											, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.T.'																	, ; //X6_CONTSPA
	'.T.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'02'																	, ; //X6_FIL
	'OZ_CLIENT'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Codigo Cliente Utilizado Rotina OZ04M05.prw'							, ; //X6_DESCRIC
	'Projeto PCP OzMInerals 2 FASE'											, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'000083'																, ; //X6_CONTEUD
	'000083'																, ; //X6_CONTSPA
	'000083'																, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'02'																	, ; //X6_FIL
	'OZ_CLLOJA'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Cod Loja Cliente Utilizado Rotina OZ04M05.prw'							, ; //X6_DESCRIC
	'Projeto PCP OzMInerals 2 FASE'											, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'0001'																	, ; //X6_CONTEUD
	'0001'																	, ; //X6_CONTSPA
	'0001'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'02'																	, ; //X6_FIL
	'OZ_CONPGTO'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Condição Pgto Utilizada OZ04M05.prw'									, ; //X6_DESCRIC
	'Projeto PCP OzMInerals 2 FASE'											, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'003'																	, ; //X6_CONTEUD
	'003'																	, ; //X6_CONTSPA
	'003'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'02'																	, ; //X6_FIL
	'OZ_LIBEMP'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'EmpresaLIberada na Rotina  OZ04M05.prw'								, ; //X6_DESCRIC
	'Projeto PCP OzMInerals 2 FASE'											, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'01'																	, ; //X6_CONTEUD
	'003'																	, ; //X6_CONTSPA
	'003'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'02'																	, ; //X6_FIL
	'OZ_LIBFIL'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Filial LIberada na Rotina  OZ04M05.prw'								, ; //X6_DESCRIC
	'Projeto PCP OzMInerals 2 FASE'											, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'02/06'																	, ; //X6_CONTEUD
	'510'																	, ; //X6_CONTSPA
	'510'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'02'																	, ; //X6_FIL
	'OZ_LIBSER'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Serie Utilizada P.E SX5NOTA.prw'										, ; //X6_DESCRIC
	'Projeto PCP OzMInerals 2 FASE'											, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'CST'																	, ; //X6_CONTEUD
	'CST'																	, ; //X6_CONTSPA
	'V'																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'02'																	, ; //X6_FIL
	'OZ_MA261EX'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita uso ponto de entrada MA261EST'								, ; //X6_DESCRIC
	'Projeto PCP OzMInerals 2 FASE'											, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.F.'																	, ; //X6_CONTSPA
	'.T.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'02'																	, ; //X6_FIL
	'OZ_MT241EX'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita uso ponto de entrada MT241EST'								, ; //X6_DESCRIC
	'Projeto PCP OzMInerals 2 FASE'											, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.T.'																	, ; //X6_CONTSPA
	'.T.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'02'																	, ; //X6_FIL
	'OZ_MT650EX'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita uso ponto de entrada MT650AE'									, ; //X6_DESCRIC
	'Projeto PCP OzMInerals 2 FASE'											, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.T.'																	, ; //X6_CONTSPA
	'.T.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'02'																	, ; //X6_FIL
	'OZ_MTA410E'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita uso ponto de entrada MTA410E'									, ; //X6_DESCRIC
	'Projeto PCP OzMInerals 2 FASE'											, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.T.'																	, ; //X6_CONTSPA
	'.T.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'02'																	, ; //X6_FIL
	'OZ_SD3250E'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita uso ponto de entrada SD3250E'									, ; //X6_DESCRIC
	'Projeto PCP OzMInerals 2 FASE'											, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.T.'																	, ; //X6_CONTSPA
	'.T.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'02'																	, ; //X6_FIL
	'OZ_SF2520E'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita uso ponto de entrada SF2520E'									, ; //X6_DESCRIC
	'Projeto PCP OzMInerals 2 FASE'											, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.T.'																	, ; //X6_CONTSPA
	'.T.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'02'																	, ; //X6_FIL
	'OZ_SX5NOTA'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita uso ponto de entrada SX5NOTA'									, ; //X6_DESCRIC
	'Projeto PCP OzMInerals 2 FASE'											, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.T.'																	, ; //X6_CONTSPA
	'.T.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'03'																	, ; //X6_FIL
	'OZ_CLIENT'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Codigo Cliente Utilizado Rotina OZ04M05.prw'							, ; //X6_DESCRIC
	'Projeto PCP OzMInerals 2 FASE'											, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'000083'																, ; //X6_CONTEUD
	'000083'																, ; //X6_CONTSPA
	'000083'																, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'03'																	, ; //X6_FIL
	'OZ_CLLOJA'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Cod Loja Cliente Utilizado Rotina OZ04M05.prw'							, ; //X6_DESCRIC
	'Projeto PCP OzMInerals 2 FASE'											, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'0001'																	, ; //X6_CONTEUD
	'0001'																	, ; //X6_CONTSPA
	'0001'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'03'																	, ; //X6_FIL
	'OZ_CONPGTO'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Condição Pgto Utilizada OZ04M05.prw'									, ; //X6_DESCRIC
	'Projeto PCP OzMInerals 2 FASE'											, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'003'																	, ; //X6_CONTEUD
	'003'																	, ; //X6_CONTSPA
	'003'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'03'																	, ; //X6_FIL
	'OZ_LIBEMP'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'EmpresaLIberada na Rotina  OZ04M05.prw'								, ; //X6_DESCRIC
	'Projeto PCP OzMInerals 2 FASE'											, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'01'																	, ; //X6_CONTEUD
	'003'																	, ; //X6_CONTSPA
	'003'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'03'																	, ; //X6_FIL
	'OZ_LIBFIL'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Filial LIberada na Rotina  OZ04M05.prw'								, ; //X6_DESCRIC
	'Projeto PCP OzMInerals 2 FASE'											, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'02/06'																	, ; //X6_CONTEUD
	'510'																	, ; //X6_CONTSPA
	'510'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'03'																	, ; //X6_FIL
	'OZ_LIBSER'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Serie Utilizada P.E SX5NOTA.prw'										, ; //X6_DESCRIC
	'Projeto PCP OzMInerals 2 FASE'											, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'CST'																	, ; //X6_CONTEUD
	'CST'																	, ; //X6_CONTSPA
	'V'																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'03'																	, ; //X6_FIL
	'OZ_MA261EX'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita uso ponto de entrada MA261EST'								, ; //X6_DESCRIC
	'Projeto PCP OzMInerals 2 FASE'											, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.F.'																	, ; //X6_CONTSPA
	'.T.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'03'																	, ; //X6_FIL
	'OZ_MT241EX'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita uso ponto de entrada MT241EST'								, ; //X6_DESCRIC
	'Projeto PCP OzMInerals 2 FASE'											, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.T.'																	, ; //X6_CONTSPA
	'.T.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'03'																	, ; //X6_FIL
	'OZ_MT650EX'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita uso ponto de entrada MT650AE'									, ; //X6_DESCRIC
	'Projeto PCP OzMInerals 2 FASE'											, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.T.'																	, ; //X6_CONTSPA
	'.T.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'03'																	, ; //X6_FIL
	'OZ_MTA410E'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita uso ponto de entrada MTA410E'									, ; //X6_DESCRIC
	'Projeto PCP OzMInerals 2 FASE'											, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.T.'																	, ; //X6_CONTSPA
	'.T.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'03'																	, ; //X6_FIL
	'OZ_SD3250E'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita uso ponto de entrada SD3250E'									, ; //X6_DESCRIC
	'Projeto PCP OzMInerals 2 FASE'											, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.T.'																	, ; //X6_CONTSPA
	'.T.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'03'																	, ; //X6_FIL
	'OZ_SF2520E'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita uso ponto de entrada SF2520E'									, ; //X6_DESCRIC
	'Projeto PCP OzMInerals 2 FASE'											, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.T.'																	, ; //X6_CONTSPA
	'.T.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'03'																	, ; //X6_FIL
	'OZ_SX5NOTA'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita uso ponto de entrada SX5NOTA'									, ; //X6_DESCRIC
	'Projeto PCP OzMInerals 2 FASE'											, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.T.'																	, ; //X6_CONTSPA
	'.T.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'04'																	, ; //X6_FIL
	'OZ_CLIENT'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Codigo Cliente Utilizado Rotina OZ04M05.prw'							, ; //X6_DESCRIC
	'Projeto PCP OzMInerals 2 FASE'											, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'000083'																, ; //X6_CONTEUD
	'000083'																, ; //X6_CONTSPA
	'000083'																, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'04'																	, ; //X6_FIL
	'OZ_CLLOJA'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Cod Loja Cliente Utilizado Rotina OZ04M05.prw'							, ; //X6_DESCRIC
	'Projeto PCP OzMInerals 2 FASE'											, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'0001'																	, ; //X6_CONTEUD
	'0001'																	, ; //X6_CONTSPA
	'0001'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'04'																	, ; //X6_FIL
	'OZ_CONPGTO'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Condição Pgto Utilizada OZ04M05.prw'									, ; //X6_DESCRIC
	'Projeto PCP OzMInerals 2 FASE'											, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'003'																	, ; //X6_CONTEUD
	'003'																	, ; //X6_CONTSPA
	'003'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'04'																	, ; //X6_FIL
	'OZ_LIBEMP'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'EmpresaLIberada na Rotina  OZ04M05.prw'								, ; //X6_DESCRIC
	'Projeto PCP OzMInerals 2 FASE'											, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'01'																	, ; //X6_CONTEUD
	'003'																	, ; //X6_CONTSPA
	'003'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'04'																	, ; //X6_FIL
	'OZ_LIBFIL'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Filial LIberada na Rotina  OZ04M05.prw'								, ; //X6_DESCRIC
	'Projeto PCP OzMInerals 2 FASE'											, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'02/06'																	, ; //X6_CONTEUD
	'510'																	, ; //X6_CONTSPA
	'510'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'04'																	, ; //X6_FIL
	'OZ_LIBSER'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Serie Utilizada P.E SX5NOTA.prw'										, ; //X6_DESCRIC
	'Projeto PCP OzMInerals 2 FASE'											, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'CST'																	, ; //X6_CONTEUD
	'CST'																	, ; //X6_CONTSPA
	'V'																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'04'																	, ; //X6_FIL
	'OZ_MA261EX'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita uso ponto de entrada MA261EST'								, ; //X6_DESCRIC
	'Projeto PCP OzMInerals 2 FASE'											, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.F.'																	, ; //X6_CONTSPA
	'.T.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'04'																	, ; //X6_FIL
	'OZ_MT241EX'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita uso ponto de entrada MT241EST'								, ; //X6_DESCRIC
	'Projeto PCP OzMInerals 2 FASE'											, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.T.'																	, ; //X6_CONTSPA
	'.T.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'04'																	, ; //X6_FIL
	'OZ_MT650EX'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita uso ponto de entrada MT650AE'									, ; //X6_DESCRIC
	'Projeto PCP OzMInerals 2 FASE'											, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.T.'																	, ; //X6_CONTSPA
	'.T.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'04'																	, ; //X6_FIL
	'OZ_MTA410E'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita uso ponto de entrada MTA410E'									, ; //X6_DESCRIC
	'Projeto PCP OzMInerals 2 FASE'											, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.T.'																	, ; //X6_CONTSPA
	'.T.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'04'																	, ; //X6_FIL
	'OZ_SD3250E'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita uso ponto de entrada SD3250E'									, ; //X6_DESCRIC
	'Projeto PCP OzMInerals 2 FASE'											, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.T.'																	, ; //X6_CONTSPA
	'.T.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'04'																	, ; //X6_FIL
	'OZ_SF2520E'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita uso ponto de entrada SF2520E'									, ; //X6_DESCRIC
	'Projeto PCP OzMInerals 2 FASE'											, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.T.'																	, ; //X6_CONTSPA
	'.T.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'04'																	, ; //X6_FIL
	'OZ_SX5NOTA'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita uso ponto de entrada SX5NOTA'									, ; //X6_DESCRIC
	'Projeto PCP OzMInerals 2 FASE'											, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.T.'																	, ; //X6_CONTSPA
	'.T.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'05'																	, ; //X6_FIL
	'OZ_CLIENT'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Codigo Cliente Utilizado Rotina OZ04M05.prw'							, ; //X6_DESCRIC
	'Projeto PCP OzMInerals 2 FASE'											, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'000083'																, ; //X6_CONTEUD
	'000083'																, ; //X6_CONTSPA
	'000083'																, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'05'																	, ; //X6_FIL
	'OZ_CLLOJA'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Cod Loja Cliente Utilizado Rotina OZ04M05.prw'							, ; //X6_DESCRIC
	'Projeto PCP OzMInerals 2 FASE'											, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'0001'																	, ; //X6_CONTEUD
	'0001'																	, ; //X6_CONTSPA
	'0001'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'05'																	, ; //X6_FIL
	'OZ_CONPGTO'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Condição Pgto Utilizada OZ04M05.prw'									, ; //X6_DESCRIC
	'Projeto PCP OzMInerals 2 FASE'											, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'003'																	, ; //X6_CONTEUD
	'003'																	, ; //X6_CONTSPA
	'003'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'05'																	, ; //X6_FIL
	'OZ_LIBEMP'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'EmpresaLIberada na Rotina  OZ04M05.prw'								, ; //X6_DESCRIC
	'Projeto PCP OzMInerals 2 FASE'											, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'01'																	, ; //X6_CONTEUD
	'003'																	, ; //X6_CONTSPA
	'003'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'05'																	, ; //X6_FIL
	'OZ_LIBFIL'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Filial LIberada na Rotina  OZ04M05.prw'								, ; //X6_DESCRIC
	'Projeto PCP OzMInerals 2 FASE'											, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'02/06'																	, ; //X6_CONTEUD
	'510'																	, ; //X6_CONTSPA
	'510'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'05'																	, ; //X6_FIL
	'OZ_LIBSER'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Serie Utilizada P.E SX5NOTA.prw'										, ; //X6_DESCRIC
	'Projeto PCP OzMInerals 2 FASE'											, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'CST'																	, ; //X6_CONTEUD
	'CST'																	, ; //X6_CONTSPA
	'V'																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'05'																	, ; //X6_FIL
	'OZ_MA261EX'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita uso ponto de entrada MA261EST'								, ; //X6_DESCRIC
	'Projeto PCP OzMInerals 2 FASE'											, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.F.'																	, ; //X6_CONTSPA
	'.T.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'05'																	, ; //X6_FIL
	'OZ_MT241EX'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita uso ponto de entrada MT241EST'								, ; //X6_DESCRIC
	'Projeto PCP OzMInerals 2 FASE'											, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.T.'																	, ; //X6_CONTSPA
	'.T.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'05'																	, ; //X6_FIL
	'OZ_MT650EX'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita uso ponto de entrada MT650AE'									, ; //X6_DESCRIC
	'Projeto PCP OzMInerals 2 FASE'											, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.T.'																	, ; //X6_CONTSPA
	'.T.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'05'																	, ; //X6_FIL
	'OZ_MTA410E'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita uso ponto de entrada MTA410E'									, ; //X6_DESCRIC
	'Projeto PCP OzMInerals 2 FASE'											, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.T.'																	, ; //X6_CONTSPA
	'.T.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'05'																	, ; //X6_FIL
	'OZ_SD3250E'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita uso ponto de entrada SD3250E'									, ; //X6_DESCRIC
	'Projeto PCP OzMInerals 2 FASE'											, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.T.'																	, ; //X6_CONTSPA
	'.T.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'05'																	, ; //X6_FIL
	'OZ_SF2520E'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita uso ponto de entrada SF2520E'									, ; //X6_DESCRIC
	'Projeto PCP OzMInerals 2 FASE'											, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.T.'																	, ; //X6_CONTSPA
	'.T.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'05'																	, ; //X6_FIL
	'OZ_SX5NOTA'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita uso ponto de entrada SX5NOTA'									, ; //X6_DESCRIC
	'Projeto PCP OzMInerals 2 FASE'											, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.T.'																	, ; //X6_CONTSPA
	'.T.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'06'																	, ; //X6_FIL
	'OZ_CLIENT'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Codigo Cliente Utilizado Rotina OZ04M05.prw'							, ; //X6_DESCRIC
	'Projeto PCP OzMInerals 2 FASE'											, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'000083'																, ; //X6_CONTEUD
	'000083'																, ; //X6_CONTSPA
	'000083'																, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'06'																	, ; //X6_FIL
	'OZ_CLLOJA'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Cod Loja Cliente Utilizado Rotina OZ04M05.prw'							, ; //X6_DESCRIC
	'Projeto PCP OzMInerals 2 FASE'											, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'0001'																	, ; //X6_CONTEUD
	'0001'																	, ; //X6_CONTSPA
	'0001'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'06'																	, ; //X6_FIL
	'OZ_CONPGTO'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Condição Pgto Utilizada OZ04M05.prw'									, ; //X6_DESCRIC
	'Projeto PCP OzMInerals 2 FASE'											, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'003'																	, ; //X6_CONTEUD
	'003'																	, ; //X6_CONTSPA
	'003'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'06'																	, ; //X6_FIL
	'OZ_LIBEMP'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'EmpresaLIberada na Rotina  OZ04M05.prw'								, ; //X6_DESCRIC
	'Projeto PCP OzMInerals 2 FASE'											, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'01'																	, ; //X6_CONTEUD
	'003'																	, ; //X6_CONTSPA
	'003'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'06'																	, ; //X6_FIL
	'OZ_LIBFIL'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Filial LIberada na Rotina  OZ04M05.prw'								, ; //X6_DESCRIC
	'Projeto PCP OzMInerals 2 FASE'											, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'02/06'																	, ; //X6_CONTEUD
	'510'																	, ; //X6_CONTSPA
	'510'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'06'																	, ; //X6_FIL
	'OZ_LIBSER'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Serie Utilizada P.E SX5NOTA.prw'										, ; //X6_DESCRIC
	'Projeto PCP OzMInerals 2 FASE'											, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'CST'																	, ; //X6_CONTEUD
	'CST'																	, ; //X6_CONTSPA
	'V'																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'06'																	, ; //X6_FIL
	'OZ_MA261EX'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita uso ponto de entrada MA261EST'								, ; //X6_DESCRIC
	'Projeto PCP OzMInerals 2 FASE'											, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.F.'																	, ; //X6_CONTSPA
	'.T.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'06'																	, ; //X6_FIL
	'OZ_MT241EX'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita uso ponto de entrada MT241EST'								, ; //X6_DESCRIC
	'Projeto PCP OzMInerals 2 FASE'											, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.T.'																	, ; //X6_CONTSPA
	'.T.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'06'																	, ; //X6_FIL
	'OZ_MT650EX'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita uso ponto de entrada MT650AE'									, ; //X6_DESCRIC
	'Projeto PCP OzMInerals 2 FASE'											, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.T.'																	, ; //X6_CONTSPA
	'.T.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'06'																	, ; //X6_FIL
	'OZ_MTA410E'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita uso ponto de entrada MTA410E'									, ; //X6_DESCRIC
	'Projeto PCP OzMInerals 2 FASE'											, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.T.'																	, ; //X6_CONTSPA
	'.T.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'06'																	, ; //X6_FIL
	'OZ_SD3250E'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita uso ponto de entrada SD3250E'									, ; //X6_DESCRIC
	'Projeto PCP OzMInerals 2 FASE'											, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.T.'																	, ; //X6_CONTSPA
	'.T.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'06'																	, ; //X6_FIL
	'OZ_SF2520E'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita uso ponto de entrada SF2520E'									, ; //X6_DESCRIC
	'Projeto PCP OzMInerals 2 FASE'											, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.T.'																	, ; //X6_CONTSPA
	'.T.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'06'																	, ; //X6_FIL
	'OZ_SX5NOTA'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita uso ponto de entrada SX5NOTA'									, ; //X6_DESCRIC
	'Projeto PCP OzMInerals 2 FASE'											, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.T.'																	, ; //X6_CONTSPA
	'.T.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'07'																	, ; //X6_FIL
	'OZ_CLIENT'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Codigo Cliente Utilizado Rotina OZ04M05.prw'							, ; //X6_DESCRIC
	'Projeto PCP OzMInerals 2 FASE'											, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'000083'																, ; //X6_CONTEUD
	'000083'																, ; //X6_CONTSPA
	'000083'																, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'07'																	, ; //X6_FIL
	'OZ_CLLOJA'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Cod Loja Cliente Utilizado Rotina OZ04M05.prw'							, ; //X6_DESCRIC
	'Projeto PCP OzMInerals 2 FASE'											, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'0001'																	, ; //X6_CONTEUD
	'0001'																	, ; //X6_CONTSPA
	'0001'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'07'																	, ; //X6_FIL
	'OZ_CONPGTO'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Condição Pgto Utilizada OZ04M05.prw'									, ; //X6_DESCRIC
	'Projeto PCP OzMInerals 2 FASE'											, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'003'																	, ; //X6_CONTEUD
	'003'																	, ; //X6_CONTSPA
	'003'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'07'																	, ; //X6_FIL
	'OZ_LIBEMP'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'EmpresaLIberada na Rotina  OZ04M05.prw'								, ; //X6_DESCRIC
	'Projeto PCP OzMInerals 2 FASE'											, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'01'																	, ; //X6_CONTEUD
	'003'																	, ; //X6_CONTSPA
	'003'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'07'																	, ; //X6_FIL
	'OZ_LIBFIL'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Filial LIberada na Rotina  OZ04M05.prw'								, ; //X6_DESCRIC
	'Projeto PCP OzMInerals 2 FASE'											, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'02/06'																	, ; //X6_CONTEUD
	'510'																	, ; //X6_CONTSPA
	'510'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'07'																	, ; //X6_FIL
	'OZ_LIBSER'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Serie Utilizada P.E SX5NOTA.prw'										, ; //X6_DESCRIC
	'Projeto PCP OzMInerals 2 FASE'											, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'CST'																	, ; //X6_CONTEUD
	'CST'																	, ; //X6_CONTSPA
	'V'																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'07'																	, ; //X6_FIL
	'OZ_MA261EX'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita uso ponto de entrada MA261EST'								, ; //X6_DESCRIC
	'Projeto PCP OzMInerals 2 FASE'											, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.F.'																	, ; //X6_CONTSPA
	'.T.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'07'																	, ; //X6_FIL
	'OZ_MT241EX'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita uso ponto de entrada MT241EST'								, ; //X6_DESCRIC
	'Projeto PCP OzMInerals 2 FASE'											, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.T.'																	, ; //X6_CONTSPA
	'.T.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'07'																	, ; //X6_FIL
	'OZ_MT650EX'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita uso ponto de entrada MT650AE'									, ; //X6_DESCRIC
	'Projeto PCP OzMInerals 2 FASE'											, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.T.'																	, ; //X6_CONTSPA
	'.T.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'07'																	, ; //X6_FIL
	'OZ_MTA410E'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita uso ponto de entrada MTA410E'									, ; //X6_DESCRIC
	'Projeto PCP OzMInerals 2 FASE'											, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.T.'																	, ; //X6_CONTSPA
	'.T.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'07'																	, ; //X6_FIL
	'OZ_SD3250E'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita uso ponto de entrada SD3250E'									, ; //X6_DESCRIC
	'Projeto PCP OzMInerals 2 FASE'											, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.T.'																	, ; //X6_CONTSPA
	'.T.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'07'																	, ; //X6_FIL
	'OZ_SF2520E'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita uso ponto de entrada SF2520E'									, ; //X6_DESCRIC
	'Projeto PCP OzMInerals 2 FASE'											, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.T.'																	, ; //X6_CONTSPA
	'.T.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'07'																	, ; //X6_FIL
	'OZ_SX5NOTA'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita uso ponto de entrada SX5NOTA'									, ; //X6_DESCRIC
	'Projeto PCP OzMInerals 2 FASE'											, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.T.'																	, ; //X6_CONTSPA
	'.T.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

//
// Atualizando dicionário
//
oProcess:SetRegua2( Len( aSX6 ) )

dbSelectArea( "SX6" )
dbSetOrder( 1 )

For nI := 1 To Len( aSX6 )
	lContinua := .F.
	lReclock  := .F.

	If !SX6->( dbSeek( PadR( aSX6[nI][1], nTamFil ) + PadR( aSX6[nI][2], nTamVar ) ) )
		lContinua := .T.
		lReclock  := .T.
		AutoGrLog( "Foi incluído o parâmetro " + aSX6[nI][1] + aSX6[nI][2] + " Conteúdo [" + AllTrim( aSX6[nI][13] ) + "]" )
	EndIf

	If lContinua
		If !( aSX6[nI][1] $ cAlias )
			cAlias += aSX6[nI][1] + "/"
		EndIf

		RecLock( "SX6", lReclock )
		For nJ := 1 To Len( aSX6[nI] )
			If FieldPos( aEstrut[nJ] ) > 0
				FieldPut( FieldPos( aEstrut[nJ] ), aSX6[nI][nJ] )
			EndIf
		Next nJ
		dbCommit()
		MsUnLock()
	EndIf

	oProcess:IncRegua2( "Atualizando Arquivos (SX6) ..." )

Next nI

AutoGrLog( CRLF + "Final da Atualização" + " SX6" + CRLF + Replicate( "-", 128 ) + CRLF )

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuSX7

Função de processamento da gravação do SX7 - Gatilhos

@author UPDATE gerado automaticamente
@since  18/12/2023
@obs    Gerado por EXPORDIC - V.7.6.3.4 EFS / Upd. V.6.4.1 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuSX7()
Local aEstrut   := {}
Local aAreaSX3  := SX3->( GetArea() )
Local aSX7      := {}
Local nI        := 0
Local nJ        := 0
Local nTamSeek  := Len( SX7->X7_CAMPO )

AutoGrLog( "Ínicio da Atualização" + " SX7" + CRLF )

aEstrut := { "X7_CAMPO", "X7_SEQUENC", "X7_REGRA", "X7_CDOMIN", "X7_TIPO", "X7_SEEK", ;
             "X7_ALIAS", "X7_ORDEM"  , "X7_CHAVE", "X7_PROPRI", "X7_CONDIC" }

//
// Campo PA1_COD
//
aAdd( aSX7, { ;
	'PA1_COD'																, ; //X7_CAMPO
	'001'																	, ; //X7_SEQUENC
	'SB1->B1_DESC'															, ; //X7_REGRA
	'PA1_DESC'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'S'																		, ; //X7_SEEK
	'SB1'																	, ; //X7_ALIAS
	1																		, ; //X7_ORDEM
	'xFilial("SB1")+M->PA1_COD'												, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

aAdd( aSX7, { ;
	'PA1_COD'																, ; //X7_CAMPO
	'002'																	, ; //X7_SEQUENC
	'SB1->B1_TIPO'															, ; //X7_REGRA
	'PA1_TIPO'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'S'																		, ; //X7_SEEK
	'SB1'																	, ; //X7_ALIAS
	1																		, ; //X7_ORDEM
	'xFilial("SB1")+M->PA1_COD'												, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

aAdd( aSX7, { ;
	'PA1_COD'																, ; //X7_CAMPO
	'003'																	, ; //X7_SEQUENC
	'SBZ->BZ_LOCPAD'														, ; //X7_REGRA
	'PA1_LOCORI'															, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'S'																		, ; //X7_SEEK
	'SBZ'																	, ; //X7_ALIAS
	1																		, ; //X7_ORDEM
	'xFilial("SBZ")+M->PA1_COD'												, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

//
// Campo PAX_TAB
//
aAdd( aSX7, { ;
	'PAX_TAB'																, ; //X7_CAMPO
	'001'																	, ; //X7_SEQUENC
	'PA2->PA2_DESC'															, ; //X7_REGRA
	'PAX_DSCTAB'															, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'S'																		, ; //X7_SEEK
	'PA2'																	, ; //X7_ALIAS
	1																		, ; //X7_ORDEM
	'XFilial("PA2")+M->PAX_TAB'												, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

//
// Campo PAY_COD
//
aAdd( aSX7, { ;
	'PAY_COD'																, ; //X7_CAMPO
	'001'																	, ; //X7_SEQUENC
	'SB1->B1_DESC'															, ; //X7_REGRA
	'PAY_DESC'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'S'																		, ; //X7_SEEK
	'SB1'																	, ; //X7_ALIAS
	1																		, ; //X7_ORDEM
	'XFilial("SB1")+M->PAY_COD'												, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

aAdd( aSX7, { ;
	'PAY_COD'																, ; //X7_CAMPO
	'002'																	, ; //X7_SEQUENC
	'SB1->B1_TIPO'															, ; //X7_REGRA
	'PAY_TIPO'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'S'																		, ; //X7_SEEK
	'SB1'																	, ; //X7_ALIAS
	1																		, ; //X7_ORDEM
	'XFilial("SB1")+M->PAY_COD'												, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

aAdd( aSX7, { ;
	'PAY_COD'																, ; //X7_CAMPO
	'003'																	, ; //X7_SEQUENC
	'SB1->B1_UM'															, ; //X7_REGRA
	'PAY_UM'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'S'																		, ; //X7_SEEK
	'SB1'																	, ; //X7_ALIAS
	1																		, ; //X7_ORDEM
	'XFilial("SB1")+M->PAY_COD'												, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

aAdd( aSX7, { ;
	'PAY_COD'																, ; //X7_CAMPO
	'004'																	, ; //X7_SEQUENC
	'SBZ->BZ_LOCPAD'														, ; //X7_REGRA
	'PAY_LOCAL'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'S'																		, ; //X7_SEEK
	'SBZ'																	, ; //X7_ALIAS
	1																		, ; //X7_ORDEM
	'XFilial("SBZ")+M->PAY_COD'												, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

aAdd( aSX7, { ;
	'PAY_COD'																, ; //X7_CAMPO
	'005'																	, ; //X7_SEQUENC
	'SBZ->BZ_XTM'															, ; //X7_REGRA
	'PAY_TM'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'S'																		, ; //X7_SEEK
	'SBZ'																	, ; //X7_ALIAS
	1																		, ; //X7_ORDEM
	'XFilial("SBZ")+M->PAY_COD'												, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

//
// Campo PAY_COMP
//
aAdd( aSX7, { ;
	'PAY_COMP'																, ; //X7_CAMPO
	'001'																	, ; //X7_SEQUENC
	'SB1->B1_DESC'															, ; //X7_REGRA
	'PAY_DSCEMP'															, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'S'																		, ; //X7_SEEK
	'SB1'																	, ; //X7_ALIAS
	1																		, ; //X7_ORDEM
	'XFILIAL("SB1")+M->PAY_COMP'											, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

//
// Atualizando dicionário
//
oProcess:SetRegua2( Len( aSX7 ) )

dbSelectArea( "SX3" )
dbSetOrder( 2 )

dbSelectArea( "SX7" )
dbSetOrder( 1 )

For nI := 1 To Len( aSX7 )

	If !SX7->( dbSeek( PadR( aSX7[nI][1], nTamSeek ) + aSX7[nI][2] ) )

		AutoGrLog( "Foi incluído o gatilho " + aSX7[nI][1] + "/" + aSX7[nI][2] )

		RecLock( "SX7", .T. )
		For nJ := 1 To Len( aSX7[nI] )
			If FieldPos( aEstrut[nJ] ) > 0
				FieldPut( FieldPos( aEstrut[nJ] ), aSX7[nI][nJ] )
			EndIf
		Next nJ

		dbCommit()
		MsUnLock()

		If SX3->( dbSeek( SX7->X7_CAMPO ) )
			RecLock( "SX3", .F. )
			SX3->X3_TRIGGER := "S"
			MsUnLock()
		EndIf

	EndIf
	oProcess:IncRegua2( "Atualizando Arquivos (SX7) ..." )

Next nI

RestArea( aAreaSX3 )

AutoGrLog( CRLF + "Final da Atualização" + " SX7" + CRLF + Replicate( "-", 128 ) + CRLF )

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuSXB

Função de processamento da gravação do SXB - Consultas Padrao

@author UPDATE gerado automaticamente
@since  18/12/2023
@obs    Gerado por EXPORDIC - V.7.6.3.4 EFS / Upd. V.6.4.1 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuSXB()
Local aEstrut   := {}
Local aSXB      := {}
Local cAlias    := ""
Local cMsg      := ""
Local lTodosNao := .F.
Local lTodosSim := .F.
Local nI        := 0
Local nJ        := 0
Local nOpcA     := 0

AutoGrLog( "Ínicio da Atualização" + " SXB" + CRLF )

aEstrut := { "XB_ALIAS"  , "XB_TIPO"   , "XB_SEQ"    , "XB_COLUNA" , "XB_DESCRI" , "XB_DESCSPA", "XB_DESCENG", ;
             "XB_WCONTEM", "XB_CONTEM" }


//
// Consulta PA0
//
aAdd( aSXB, { ;
	'PA0'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Pre cad producao'														, ; //XB_DESCRI
	'Pre cad producao'														, ; //XB_DESCSPA
	'Pre cad producao'														, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'PA0'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'PA0'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cod. Tabela'															, ; //XB_DESCRI
	'Cod. Tabela'															, ; //XB_DESCSPA
	'Cod. Tabela'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'PA0'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cod. Tabela'															, ; //XB_DESCRI
	'Cod. Tabela'															, ; //XB_DESCSPA
	'Cod. Tabela'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'PA0_TAB'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'PA0'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Desc. Tabela'															, ; //XB_DESCRI
	'Desc. Tabela'															, ; //XB_DESCSPA
	'Desc. Tabela'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'PA0_DESC'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'PA0'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'PA0->PA0_TAB'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'PA0'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'PA0->PA0_DESC'															} ) //XB_CONTEM

//
// Atualizando dicionário
//
oProcess:SetRegua2( Len( aSXB ) )

dbSelectArea( "SXB" )
dbSetOrder( 1 )

For nI := 1 To Len( aSXB )

	If !Empty( aSXB[nI][1] )

		If !SXB->( dbSeek( PadR( aSXB[nI][1], Len( SXB->XB_ALIAS ) ) + aSXB[nI][2] + aSXB[nI][3] + aSXB[nI][4] ) )

			If !( aSXB[nI][1] $ cAlias )
				cAlias += aSXB[nI][1] + "/"
				AutoGrLog( "Foi incluída a consulta padrão " + aSXB[nI][1] )
			EndIf

			RecLock( "SXB", .T. )

			For nJ := 1 To Len( aSXB[nI] )
				If FieldPos( aEstrut[nJ] ) > 0
					FieldPut( FieldPos( aEstrut[nJ] ), aSXB[nI][nJ] )
				EndIf
			Next nJ

			dbCommit()
			MsUnLock()

		Else

			//
			// Verifica todos os campos
			//
			For nJ := 1 To Len( aSXB[nI] )

				//
				// Se o campo estiver diferente da estrutura
				//
				If !StrTran( AllToChar( SXB->( FieldGet( FieldPos( aEstrut[nJ] ) ) ) ), " ", "" ) == ;
					StrTran( AllToChar( aSXB[nI][nJ] ), " ", "" )

					cMsg := "A consulta padrão " + aSXB[nI][1] + " está com o " + SXB->( FieldName( FieldPos( aEstrut[nJ] ) ) ) + ;
					" com o conteúdo" + CRLF + ;
					"[" + RTrim( AllToChar( SXB->( FieldGet( FieldPos( aEstrut[nJ] ) ) ) ) ) + "]" + CRLF + ;
					", e este é diferente do conteúdo" + CRLF + ;
					"[" + RTrim( AllToChar( aSXB[nI][nJ] ) ) + "]" + CRLF +;
					"Deseja substituir ? "

					If      lTodosSim
						nOpcA := 1
					ElseIf  lTodosNao
						nOpcA := 2
					Else
						nOpcA := Aviso( "ATUALIZAÇÃO DE DICIONÁRIOS E TABELAS", cMsg, { "Sim", "Não", "Sim p/Todos", "Não p/Todos" }, 3, "Diferença de conteúdo - SXB" )
						lTodosSim := ( nOpcA == 3 )
						lTodosNao := ( nOpcA == 4 )

						If lTodosSim
							nOpcA := 1
							lTodosSim := MsgNoYes( "Foi selecionada a opção de REALIZAR TODAS alterações no SXB e NÃO MOSTRAR mais a tela de aviso." + CRLF + "Confirma a ação [Sim p/Todos] ?" )
						EndIf

						If lTodosNao
							nOpcA := 2
							lTodosNao := MsgNoYes( "Foi selecionada a opção de NÃO REALIZAR nenhuma alteração no SXB que esteja diferente da base e NÃO MOSTRAR mais a tela de aviso." + CRLF + "Confirma esta ação [Não p/Todos]?" )
						EndIf

					EndIf

					If nOpcA == 1
						RecLock( "SXB", .F. )
						FieldPut( FieldPos( aEstrut[nJ] ), aSXB[nI][nJ] )
						dbCommit()
						MsUnLock()

						If !( aSXB[nI][1] $ cAlias )
							cAlias += aSXB[nI][1] + "/"
							AutoGrLog( "Foi alterada a consulta padrão " + aSXB[nI][1] )
						EndIf

					EndIf

				EndIf

			Next

		EndIf

	EndIf

	oProcess:IncRegua2( "Atualizando Consultas Padrões (SXB) ..." )

Next nI

AutoGrLog( CRLF + "Final da Atualização" + " SXB" + CRLF + Replicate( "-", 128 ) + CRLF )

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuHlp

Função de processamento da gravação dos Helps de Campos

@author UPDATE gerado automaticamente
@since  18/12/2023
@obs    Gerado por EXPORDIC - V.7.6.3.4 EFS / Upd. V.6.4.1 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuHlp()
Local aHlpPor   := {}
Local aHlpEng   := {}
Local aHlpSpa   := {}

AutoGrLog( "Ínicio da Atualização" + " " + "Helps de Campos" + CRLF )


oProcess:IncRegua2( "Atualizando Helps de Campos ..." )

//
// Helps Tabela PA0
//
//
// Helps Tabela PA1
//
aHlpPor := {}
aAdd( aHlpPor, 'Sequencia de Item' )

aHlpEng := {}
aAdd( aHlpEng, 'Sequencia de Item' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Sequencia de Item' )

PutSX1Help( "PPA1_ITEM  ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "PA1_ITEM" )

aHlpPor := {}
aAdd( aHlpPor, 'Codigo do Produto' )

aHlpEng := {}
aAdd( aHlpEng, 'Codigo do Produto' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Codigo do Produto' )

PutSX1Help( "PPA1_COD   ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "PA1_COD" )

aHlpPor := {}
aAdd( aHlpPor, 'Descrição do produto' )

aHlpEng := {}
aAdd( aHlpEng, 'Descrição do produto' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Descrição do produto' )

PutSX1Help( "PPA1_DESC  ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "PA1_DESC" )

aHlpPor := {}
aAdd( aHlpPor, 'Tipo de Movimento' )

aHlpEng := {}
aAdd( aHlpEng, 'Tipo de Movimento' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Tipo de Movimento' )

PutSX1Help( "PPA1_TMORIG", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "PA1_TMORIG" )

aHlpPor := {}
aAdd( aHlpPor, 'Tes para Venda do CPV' )

aHlpEng := {}
aAdd( aHlpEng, 'Tes para Venda do CPV' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Tes para Venda do CPV' )

PutSX1Help( "PPA1_TES   ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "PA1_TES" )

aHlpPor := {}
aAdd( aHlpPor, 'Filial de Movimentação' )

aHlpEng := {}
aAdd( aHlpEng, 'Filial de Movimentação' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Filial de Movimentação' )

PutSX1Help( "PPA1_FILDES", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "PA1_FILDES" )

aHlpPor := {}
aAdd( aHlpPor, 'Codigo da tabela' )

aHlpEng := {}
aAdd( aHlpEng, 'Codigo da tabela' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Codigo da tabela' )

PutSX1Help( "PPA1_TAB   ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "PA1_TAB" )

//
// Helps Tabela PAX
//
aHlpPor := {}
aAdd( aHlpPor, '1=Aguardando Geração da Movimentação' )
aAdd( aHlpPor, '2=Movimentação Gerado Com Sucesso' )

aHlpEng := {}
aAdd( aHlpEng, '1=Aguardando Geração da Movimentação' )
aAdd( aHlpEng, '2=Movimentação Gerado Com Sucesso' )

aHlpSpa := {}
aAdd( aHlpSpa, '1=Aguardando Geração da Movimentação' )
aAdd( aHlpSpa, '2=Movimentação Gerado Com Sucesso' )

PutSX1Help( "PPAX_STATUS", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "PAX_STATUS" )

aHlpPor := {}
aAdd( aHlpPor, 'Data do Movimento' )

aHlpEng := {}
aAdd( aHlpEng, 'Data do Movimento' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Data do Movimento' )

PutSX1Help( "PPAX_DATA  ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "PAX_DATA" )

aHlpPor := {}
aAdd( aHlpPor, 'Usuario Responsavel' )

aHlpEng := {}
aAdd( aHlpEng, 'Usuario Responsavel' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Usuario Responsavel' )

PutSX1Help( "PPAX_USER  ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "PAX_USER" )

aHlpPor := {}
aAdd( aHlpPor, 'Gera Abertura Ordem Prod.' )

aHlpEng := {}
aAdd( aHlpEng, 'Gera Abertura Ordem Prod.' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Gera Abertura Ordem Prod.' )

PutSX1Help( "PPAX_CRIAOP", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "PAX_CRIAOP" )

aHlpPor := {}
aAdd( aHlpPor, 'Gera Apontamento Op' )

aHlpEng := {}
aAdd( aHlpEng, 'Gera Apontamento Op' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Gera Apontamento Op' )

PutSX1Help( "PPAX_APTOOP", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "PAX_APTOOP" )

aHlpPor := {}
aAdd( aHlpPor, 'Gera Requisição' )

aHlpEng := {}
aAdd( aHlpEng, 'Gera Requisição' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Gera Requisição' )

PutSX1Help( "PPAX_REQUIS", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "PAX_REQUIS" )

aHlpPor := {}
aAdd( aHlpPor, 'Gera Transferencia' )

aHlpEng := {}
aAdd( aHlpEng, 'Gera Transferencia' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Gera Transferencia' )

PutSX1Help( "PPAX_TRANSF", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "PAX_TRANSF" )

aHlpPor := {}
aAdd( aHlpPor, 'Gera Pedido de venda' )

aHlpEng := {}
aAdd( aHlpEng, 'Gera Pedido de venda' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Gera Pedido de venda' )

PutSX1Help( "PPAX_PVENDA", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "PAX_PVENDA" )

aHlpPor := {}
aAdd( aHlpPor, 'Gera Documento Cpv' )

aHlpEng := {}
aAdd( aHlpEng, 'Gera Documento Cpv' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Gera Documento Cpv' )

PutSX1Help( "PPAX_GERNF ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "PAX_GERNF" )

aHlpPor := {}
aAdd( aHlpPor, 'Log de Transferencia' )

aHlpEng := {}
aAdd( aHlpEng, 'Log de Transferencia' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Log de Transferencia' )

PutSX1Help( "PPAX_RETLOG", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "PAX_RETLOG" )

//
// Helps Tabela PAY
//
aHlpPor := {}
aAdd( aHlpPor, 'Status Geração Movimento' )

aHlpEng := {}
aAdd( aHlpEng, 'Status Geração Movimento' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Status Geração Movimento' )

PutSX1Help( "PPAY_STATUS", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "PAY_STATUS" )

aHlpPor := {}
aAdd( aHlpPor, 'Tipo de Movimento Estoque' )

aHlpEng := {}
aAdd( aHlpEng, 'Tipo de Movimento Estoque' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Tipo de Movimento Estoque' )

PutSX1Help( "PPAY_TPMOV ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "PAY_TPMOV" )

aHlpPor := {}
aAdd( aHlpPor, 'Produto Ajuste de Empenho' )

aHlpEng := {}
aAdd( aHlpEng, 'Produto Ajuste de Empenho' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Produto Ajuste de Empenho' )

PutSX1Help( "PPAY_COMP  ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "PAY_COMP" )

aHlpPor := {}
aAdd( aHlpPor, 'Descrição Produto Empenho' )

aHlpEng := {}
aAdd( aHlpEng, 'Descrição Produto Empenho' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Descrição Produto Empenho' )

PutSX1Help( "PPAY_DSCEMP", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "PAY_DSCEMP" )

aHlpPor := {}
aAdd( aHlpPor, 'Quantidade do Empenho' )

aHlpEng := {}
aAdd( aHlpEng, 'Quantidade do Empenho' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Quantidade do Empenho' )

PutSX1Help( "PPAY_QTDEMP", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "PAY_QTDEMP" )

aHlpPor := {}
aAdd( aHlpPor, 'Status Geração Movimento' )

aHlpEng := {}
aAdd( aHlpEng, 'Status Geração Movimento' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Status Geração Movimento' )

PutSX1Help( "PPAY_AVANCO", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "PAY_AVANCO" )

aHlpPor := {}
aAdd( aHlpPor, 'Data Geração do Movimento' )

aHlpEng := {}
aAdd( aHlpEng, 'Data Geração do Movimento' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Data Geração do Movimento' )

PutSX1Help( "PPAY_DATA  ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "PAY_DATA" )

aHlpPor := {}
aAdd( aHlpPor, 'Hora Geração Movimento' )

aHlpEng := {}
aAdd( aHlpEng, 'Hora Geração Movimento' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Hora Geração Movimento' )

PutSX1Help( "PPAY_HORA  ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "PAY_HORA" )

aHlpPor := {}
aAdd( aHlpPor, 'Numero Doc. Mov. Estoque' )

aHlpEng := {}
aAdd( aHlpEng, 'Numero Doc. Mov. Estoque' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Numero Doc. Mov. Estoque' )

PutSX1Help( "PPAY_NUMDOC", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "PAY_NUMDOC" )

aHlpPor := {}
aAdd( aHlpPor, 'Ordem Produção Gerada' )

aHlpEng := {}
aAdd( aHlpEng, 'Ordem Produção Gerada' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Ordem Produção Gerada' )

PutSX1Help( "PPAY_OP    ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "PAY_OP" )

aHlpPor := {}
aAdd( aHlpPor, 'Numero de Pedido Vendas' )

aHlpEng := {}
aAdd( aHlpEng, 'Numero de Pedido Vendas' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Numero de Pedido Vendas' )

PutSX1Help( "PPAY_NUMPED", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "PAY_NUMPED" )

aHlpPor := {}
aAdd( aHlpPor, 'Numero do Documento CPV' )

aHlpEng := {}
aAdd( aHlpEng, 'Numero do Documento CPV' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Numero do Documento CPV' )

PutSX1Help( "PPAY_NUMNF ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "PAY_NUMNF" )

aHlpPor := {}
aAdd( aHlpPor, 'Serie Documento CPV' )

aHlpEng := {}
aAdd( aHlpEng, 'Serie Documento CPV' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Serie Documento CPV' )

PutSX1Help( "PPAY_SERIE ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "PAY_SERIE" )

aHlpPor := {}
aAdd( aHlpPor, 'Data Documento CPV' )

aHlpEng := {}
aAdd( aHlpEng, 'Data Documento CPV' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Data Documento CPV' )

PutSX1Help( "PPAY_DTANF ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "PAY_DTANF" )

AutoGrLog( CRLF + "Final da Atualização" + " " + "Helps de Campos" + CRLF + Replicate( "-", 128 ) + CRLF )

Return {}


//--------------------------------------------------------------------
/*/{Protheus.doc} EscEmpresa
Função genérica para escolha de Empresa, montada pelo SM0

@return aRet Vetor contendo as seleções feitas.
             Se não for marcada nenhuma o vetor volta vazio

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function EscEmpresa()

//---------------------------------------------
// Parâmetro  nTipo
// 1 - Monta com Todas Empresas/Filiais
// 2 - Monta só com Empresas
// 3 - Monta só com Filiais de uma Empresa
//
// Parâmetro  aMarcadas
// Vetor com Empresas/Filiais pré marcadas
//
// Parâmetro  cEmpSel
// Empresa que será usada para montar seleção
//---------------------------------------------
Local   aRet      := {}
Local   aSalvAmb  := GetArea()
Local   aSalvSM0  := {}
Local   aVetor    := {}
Local   cMascEmp  := "??"
Local   cVar      := ""
Local   lChk      := .F.
Local   lTeveMarc := .F.
Local   oNo       := LoadBitmap( GetResources(), "LBNO" )
Local   oOk       := LoadBitmap( GetResources(), "LBOK" )
Local   oDlg, oChkMar, oLbx, oMascEmp, oSay
Local   oButDMar, oButInv, oButMarc, oButOk, oButCanc

Local   aMarcadas := {}


If !MyOpenSm0(.F.)
	Return aRet
EndIf


dbSelectArea( "SM0" )
aSalvSM0 := SM0->( GetArea() )
dbSetOrder( 1 )
dbGoTop()

While !SM0->( EOF() )

	If aScan( aVetor, {|x| x[2] == SM0->M0_CODIGO} ) == 0
		aAdd(  aVetor, { aScan( aMarcadas, {|x| x[1] == SM0->M0_CODIGO .and. x[2] == SM0->M0_CODFIL} ) > 0, SM0->M0_CODIGO, SM0->M0_CODFIL, SM0->M0_NOME, SM0->M0_FILIAL } )
	EndIf

	dbSkip()
End

RestArea( aSalvSM0 )

Define MSDialog  oDlg Title "" From 0, 0 To 280, 395 Pixel

oDlg:cToolTip := "Tela para Múltiplas Seleções de Empresas/Filiais"

oDlg:cTitle   := "Selecione a(s) Empresa(s) para Atualização"

@ 10, 10 Listbox  oLbx Var  cVar Fields Header " ", " ", "Empresa" Size 178, 095 Of oDlg Pixel
oLbx:SetArray(  aVetor )
oLbx:bLine := {|| {IIf( aVetor[oLbx:nAt, 1], oOk, oNo ), ;
aVetor[oLbx:nAt, 2], ;
aVetor[oLbx:nAt, 4]}}
oLbx:BlDblClick := { || aVetor[oLbx:nAt, 1] := !aVetor[oLbx:nAt, 1], VerTodos( aVetor, @lChk, oChkMar ), oChkMar:Refresh(), oLbx:Refresh()}
oLbx:cToolTip   :=  oDlg:cTitle
oLbx:lHScroll   := .F. // NoScroll

@ 112, 10 CheckBox oChkMar Var  lChk Prompt "Todos" Message "Marca / Desmarca"+ CRLF + "Todos" Size 40, 007 Pixel Of oDlg;
on Click MarcaTodos( lChk, @aVetor, oLbx )

// Marca/Desmarca por mascara
@ 113, 51 Say   oSay Prompt "Empresa" Size  40, 08 Of oDlg Pixel
@ 112, 80 MSGet oMascEmp Var  cMascEmp Size  05, 05 Pixel Picture "@!"  Valid (  cMascEmp := StrTran( cMascEmp, " ", "?" ), oMascEmp:Refresh(), .T. ) ;
Message "Máscara Empresa ( ?? )"  Of oDlg
oSay:cToolTip := oMascEmp:cToolTip

@ 128, 10 Button oButInv    Prompt "&Inverter"  Size 32, 12 Pixel Action ( InvSelecao( @aVetor, oLbx ), VerTodos( aVetor, @lChk, oChkMar ) ) ;
Message "Inverter Seleção" Of oDlg
oButInv:SetCss( CSSBOTAO )
@ 128, 50 Button oButMarc   Prompt "&Marcar"    Size 32, 12 Pixel Action ( MarcaMas( oLbx, aVetor, cMascEmp, .T. ), VerTodos( aVetor, @lChk, oChkMar ) ) ;
Message "Marcar usando" + CRLF + "máscara ( ?? )"    Of oDlg
oButMarc:SetCss( CSSBOTAO )
@ 128, 80 Button oButDMar   Prompt "&Desmarcar" Size 32, 12 Pixel Action ( MarcaMas( oLbx, aVetor, cMascEmp, .F. ), VerTodos( aVetor, @lChk, oChkMar ) ) ;
Message "Desmarcar usando" + CRLF + "máscara ( ?? )" Of oDlg
oButDMar:SetCss( CSSBOTAO )
@ 112, 157  Button oButOk   Prompt "Processar"  Size 32, 12 Pixel Action (  RetSelecao( @aRet, aVetor ), IIf( Len( aRet ) > 0, oDlg:End(), MsgStop( "Ao menos um grupo deve ser selecionado", "UPDOZPCP" ) ) ) ;
Message "Confirma a seleção e efetua" + CRLF + "o processamento" Of oDlg
oButOk:SetCss( CSSBOTAO )
@ 128, 157  Button oButCanc Prompt "Cancelar"   Size 32, 12 Pixel Action ( IIf( lTeveMarc, aRet :=  aMarcadas, .T. ), oDlg:End() ) ;
Message "Cancela o processamento" + CRLF + "e abandona a aplicação" Of oDlg
oButCanc:SetCss( CSSBOTAO )

Activate MSDialog  oDlg Center

RestArea( aSalvAmb )
dbSelectArea( "SM0" )
dbCloseArea()

Return  aRet


//--------------------------------------------------------------------
/*/{Protheus.doc} MarcaTodos
Função auxiliar para marcar/desmarcar todos os ítens do ListBox ativo

@param lMarca  Contéudo para marca .T./.F.
@param aVetor  Vetor do ListBox
@param oLbx    Objeto do ListBox

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function MarcaTodos( lMarca, aVetor, oLbx )
Local  nI := 0

For nI := 1 To Len( aVetor )
	aVetor[nI][1] := lMarca
Next nI

oLbx:Refresh()

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} InvSelecao
Função auxiliar para inverter a seleção do ListBox ativo

@param aVetor  Vetor do ListBox
@param oLbx    Objeto do ListBox

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function InvSelecao( aVetor, oLbx )
Local  nI := 0

For nI := 1 To Len( aVetor )
	aVetor[nI][1] := !aVetor[nI][1]
Next nI

oLbx:Refresh()

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} RetSelecao
Função auxiliar que monta o retorno com as seleções

@param aRet    Array que terá o retorno das seleções (é alterado internamente)
@param aVetor  Vetor do ListBox

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function RetSelecao( aRet, aVetor )
Local  nI    := 0

aRet := {}
For nI := 1 To Len( aVetor )
	If aVetor[nI][1]
		aAdd( aRet, { aVetor[nI][2] , aVetor[nI][3], aVetor[nI][2] +  aVetor[nI][3] } )
	EndIf
Next nI

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} MarcaMas
Função para marcar/desmarcar usando máscaras

@param oLbx     Objeto do ListBox
@param aVetor   Vetor do ListBox
@param cMascEmp Campo com a máscara (???)
@param lMarDes  Marca a ser atribuída .T./.F.

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function MarcaMas( oLbx, aVetor, cMascEmp, lMarDes )
Local cPos1 := SubStr( cMascEmp, 1, 1 )
Local cPos2 := SubStr( cMascEmp, 2, 1 )
Local nPos  := oLbx:nAt
Local nZ    := 0

For nZ := 1 To Len( aVetor )
	If cPos1 == "?" .or. SubStr( aVetor[nZ][2], 1, 1 ) == cPos1
		If cPos2 == "?" .or. SubStr( aVetor[nZ][2], 2, 1 ) == cPos2
			aVetor[nZ][1] := lMarDes
		EndIf
	EndIf
Next

oLbx:nAt := nPos
oLbx:Refresh()

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} VerTodos
Função auxiliar para verificar se estão todos marcados ou não

@param aVetor   Vetor do ListBox
@param lChk     Marca do CheckBox do marca todos (referncia)
@param oChkMar  Objeto de CheckBox do marca todos

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function VerTodos( aVetor, lChk, oChkMar )
Local lTTrue := .T.
Local nI     := 0

For nI := 1 To Len( aVetor )
	lTTrue := IIf( !aVetor[nI][1], .F., lTTrue )
Next nI

lChk := IIf( lTTrue, .T., .F. )
oChkMar:Refresh()

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} MyOpenSM0

Função de processamento abertura do SM0 modo exclusivo

@author UPDATE gerado automaticamente
@since  18/12/2023
@obs    Gerado por EXPORDIC - V.7.6.3.4 EFS / Upd. V.6.4.1 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function MyOpenSM0( lShared )
Local lOpen := .F.
Local nLoop := 0

If FindFunction( "OpenSM0Excl" )
	For nLoop := 1 To 20
		If OpenSM0Excl(,.F.)
			lOpen := .T.
			Exit
		EndIf
		Sleep( 500 )
	Next nLoop
Else
	For nLoop := 1 To 20
		dbUseArea( .T., , "SIGAMAT.EMP", "SM0", lShared, .F. )

		If !Empty( Select( "SM0" ) )
			lOpen := .T.
			dbSetIndex( "SIGAMAT.IND" )
			Exit
		EndIf
		Sleep( 500 )
	Next nLoop
EndIf

If !lOpen
	MsgStop( "Não foi possível a abertura da tabela " + ;
	IIf( lShared, "de empresas (SM0).", "de empresas (SM0) de forma exclusiva." ), "ATENÇÃO" )
EndIf

Return lOpen


//--------------------------------------------------------------------
/*/{Protheus.doc} LeLog

Função de leitura do LOG gerado com limitacao de string

@author UPDATE gerado automaticamente
@since  18/12/2023
@obs    Gerado por EXPORDIC - V.7.6.3.4 EFS / Upd. V.6.4.1 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function LeLog()
Local cRet  := ""
Local cFile := NomeAutoLog()
Local cAux  := ""

FT_FUSE( cFile )
FT_FGOTOP()

While !FT_FEOF()

	cAux := FT_FREADLN()

	If Len( cRet ) + Len( cAux ) < 1048000
		cRet += cAux + CRLF
	Else
		cRet += CRLF
		cRet += Replicate( "=" , 128 ) + CRLF
		cRet += "Tamanho de exibição maxima do LOG alcançado." + CRLF
		cRet += "LOG Completo no arquivo " + cFile + CRLF
		cRet += Replicate( "=" , 128 ) + CRLF
		Exit
	EndIf

	FT_FSKIP()
End

FT_FUSE()

Return cRet


/////////////////////////////////////////////////////////////////////////////
