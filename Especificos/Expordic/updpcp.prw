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
/*/{Protheus.doc} UPDPCP

Função de update de dicionários para compatibilização

@author UPDATE gerado automaticamente
@since  04/12/2023
@obs    Gerado por EXPORDIC - V.7.6.3.4 EFS / Upd. V.6.4.1 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
User Function UPDPCP( cEmpAmb, cFilAmb )
Local   aSay      := {}
Local   aButton   := {}
Local   aMarcadas := {}
Local   cTitulo   := "ATUALIZAÇÃO DE DICIONÁRIOS E TABELAS"
Local   cDesc1    := "Esta rotina tem como função fazer  a atualização  dos dicionários do Sistema "
Local   cDesc2    := "Este processo deve ser executado em modo EXCLUSIVO, ou seja não podem haver outros"
Local   cDesc3    := "Será atualizado as tabelas SF5, SB1, SBZ, SG1, SD3, SC2, PAW, PAV, PAZ!"
Local   cDesc4    := "Executar BACKUP  dos DICIONÁRIOS  e da  BASE DE DADOS antes desta atualização!"
Local   cDesc5    := "Este Processo é para o Projeto de PCP - OZminerals"
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
					MsgInfo( "Atualização realizada.", "UPDPCP" )
				Else
					MsgStop( "Atualização não realizada.", "UPDPCP" )
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
@since  04/12/2023
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
			// Atualiza o dicionário SXA
			//------------------------------------
			oProcess:IncRegua1( "Dicionário de pastas" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			FSAtuSXA()

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
@since  04/12/2023
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
// Tabela PAV
//
aAdd( aSX2, { ;
	'PAV'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'PAV'+cEmpr																, ; //X2_ARQUIVO
	'Lançamentos Contábeis'													, ; //X2_NOME
	'Asientos Contables'													, ; //X2_NOMESPA
	'Accounting Entries'													, ; //X2_NOMEENG
	'E'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	'S'																		, ; //X2_PYME
	''																		, ; //X2_UNICO
	''																		, ; //X2_DISPLAY
	''																		, ; //X2_SYSOBJ
	''																		, ; //X2_USROBJ
	'1'																		, ; //X2_POSLGT
	'2'																		, ; //X2_CLOB
	'2'																		, ; //X2_AUTREC
	'E'																		, ; //X2_MODOEMP
	'E'																		, ; //X2_MODOUN
	0																		} ) //X2_MODULO

//
// Tabela PAW
//
aAdd( aSX2, { ;
	'PAW'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'PAW'+cEmpr																, ; //X2_ARQUIVO
	'Operação Contabil de Estoque'											, ; //X2_NOME
	'Operação Contabil de Estoque'											, ; //X2_NOMESPA
	'Operação Contabil de Estoque'											, ; //X2_NOMEENG
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
// Tabela PAZ
//
aAdd( aSX2, { ;
	'PAZ'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'PAZ'+cEmpr																, ; //X2_ARQUIVO
	'Tabela Centro de Custeio'												, ; //X2_NOME
	'Tabela Centro de Custeio'												, ; //X2_NOMESPA
	'Tabela Centro de Custeio'												, ; //X2_NOMEENG
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
@since  04/12/2023
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
// Campos Tabela PAV
//
aAdd( aSX3, { ;
	'PAV'																	, ; //X3_ARQUIVO
	'01'																	, ; //X3_ORDEM
	'PAV_FILIAL'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	2																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Filial'																, ; //X3_TITULO
	'Sucursal'																, ; //X3_TITSPA
	'Branch'																, ; //X3_TITENG
	'Filial do Sistema'														, ; //X3_DESCRIC
	'Sucursal del Sistema'													, ; //X3_DESCSPA
	'System Branch'															, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	''																		, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	'  x'																	, ; //X3_OBRIGAT
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
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAV'																	, ; //X3_ARQUIVO
	'02'																	, ; //X3_ORDEM
	'PAV_DATA'																, ; //X3_CAMPO
	'D'																		, ; //X3_TIPO
	8																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Data Lcto'																, ; //X3_TITULO
	'Fch.Asiento'															, ; //X3_TITSPA
	'Entry Date'															, ; //X3_TITENG
	'Data do Lancamento Contab'												, ; //X3_DESCRIC
	'Fch.de Asiento Contable'												, ; //X3_DESCSPA
	'Accounting Entry Date'													, ; //X3_DESCENG
	'99/99/9999'															, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	'  x'																	, ; //X3_OBRIGAT
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
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAV'																	, ; //X3_ARQUIVO
	'03'																	, ; //X3_ORDEM
	'PAV_LOTE'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Numero Lote'															, ; //X3_TITULO
	'Numero Lote'															, ; //X3_TITSPA
	'Lot Number'															, ; //X3_TITENG
	'Numero do Lote'														, ; //X3_DESCRIC
	'Numero de Lote'														, ; //X3_DESCSPA
	'Lot Number'															, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	'  x'																	, ; //X3_OBRIGAT
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
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAV'																	, ; //X3_ARQUIVO
	'04'																	, ; //X3_ORDEM
	'PAV_SBLOTE'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	3																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Sub Lote'																, ; //X3_TITULO
	'Sublote'																, ; //X3_TITSPA
	'Sublot'																, ; //X3_TITENG
	'Sub Lote'																, ; //X3_DESCRIC
	'Sublote'																, ; //X3_DESCSPA
	'Sublot'																, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	'SB'																	, ; //X3_F3
	1																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	'  x'																	, ; //X3_OBRIGAT
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
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAV'																	, ; //X3_ARQUIVO
	'05'																	, ; //X3_ORDEM
	'PAV_DOC'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Numero Doc'															, ; //X3_TITULO
	'Numero Doc'															, ; //X3_TITSPA
	'Doc Number'															, ; //X3_TITENG
	'Numero do Documento'													, ; //X3_DESCRIC
	'Numero del Documento'													, ; //X3_DESCSPA
	'Document Number'														, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	'  x'																	, ; //X3_OBRIGAT
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
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAV'																	, ; //X3_ARQUIVO
	'06'																	, ; //X3_ORDEM
	'PAV_LINHA'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	3																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Numero Linha'															, ; //X3_TITULO
	'Numero Linea'															, ; //X3_TITSPA
	'Row Number'															, ; //X3_TITENG
	'Numero da Linha'														, ; //X3_DESCRIC
	'Numero de Linea'														, ; //X3_DESCSPA
	'Row Number'															, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	'  x'																	, ; //X3_OBRIGAT
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
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAV'																	, ; //X3_ARQUIVO
	'07'																	, ; //X3_ORDEM
	'PAV_MOEDLC'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	2																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Moeda Lancto'															, ; //X3_TITULO
	'Moned.Asto.'															, ; //X3_TITSPA
	'Entry Curr.'															, ; //X3_TITENG
	'Moeda do Lancamento'													, ; //X3_DESCRIC
	'Moneda del Asiento'													, ; //X3_DESCSPA
	'Entry Currency'														, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	'"01"'																	, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	'  x'																	, ; //X3_OBRIGAT
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
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAV'																	, ; //X3_ARQUIVO
	'08'																	, ; //X3_ORDEM
	'PAV_DC'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Tipo Lcto'																, ; //X3_TITULO
	'Tipo Asiento'															, ; //X3_TITSPA
	'Entry Type'															, ; //X3_TITENG
	'Tipo do Lancamento'													, ; //X3_DESCRIC
	'Tipo de Asiento'														, ; //X3_DESCSPA
	'Entry Type'															, ; //X3_DESCENG
	'!'																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	'  x'																	, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	'1=Debito;2=Credito;3=Partida Dobrada;4=Cont.Hist;5=Rateio;6=Lcto Padrao'	, ; //X3_CBOX
	'1=Debito;2=Credito;3=Partida Doble;4=Cont.Hist;5=Prorrateo;6=Asto Estandar', ; //X3_CBOXSPA
	'1=Debit;2=Credit;3=Double Entry;4=Acnt.Hist;5=Proration;6=Std Entry'		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAV'																	, ; //X3_ARQUIVO
	'09'																	, ; //X3_ORDEM
	'PAV_DEBITO'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	20																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Cta Debito'															, ; //X3_TITULO
	'Cta Debito'															, ; //X3_TITSPA
	'Debit Acct.'															, ; //X3_TITENG
	'Conta Debito'															, ; //X3_DESCRIC
	'Cuenta Debito'															, ; //X3_DESCSPA
	'Debit Account'															, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	'CT1'																	, ; //X3_F3
	1																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	'  x'																	, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	'003'																	, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAV'																	, ; //X3_ARQUIVO
	'10'																	, ; //X3_ORDEM
	'PAV_CREDIT'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	20																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Cta Credito'															, ; //X3_TITULO
	'Cta Credito'															, ; //X3_TITSPA
	'Credit Acct.'															, ; //X3_TITENG
	'Conta Credito'															, ; //X3_DESCRIC
	'Cuenta Credito'														, ; //X3_DESCSPA
	'Credit Account'														, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	'CT1'																	, ; //X3_F3
	1																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	'  x'																	, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	'003'																	, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAV'																	, ; //X3_ARQUIVO
	'11'																	, ; //X3_ORDEM
	'PAV_DCD'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Dig Cont Deb'															, ; //X3_TITULO
	'Dig Cont Deb'															, ; //X3_TITSPA
	'Deb Cont Dig'															, ; //X3_TITENG
	'Digito Controle Debito'												, ; //X3_DESCRIC
	'Digito Control Debito'													, ; //X3_DESCSPA
	'Debit Control Digit'													, ; //X3_DESCENG
	'!'																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	'  x'																	, ; //X3_OBRIGAT
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
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAV'																	, ; //X3_ARQUIVO
	'12'																	, ; //X3_ORDEM
	'PAV_DCC'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Dig Cont Crd'															, ; //X3_TITULO
	'Dig Cont Crd'															, ; //X3_TITSPA
	'Crd Cont Dig'															, ; //X3_TITENG
	'Digito Controle Credito'												, ; //X3_DESCRIC
	'Digito Control Credito'												, ; //X3_DESCSPA
	'Credit Control Digit'													, ; //X3_DESCENG
	'!'																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	'  x'																	, ; //X3_OBRIGAT
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
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAV'																	, ; //X3_ARQUIVO
	'13'																	, ; //X3_ORDEM
	'PAV_VALOR'																, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	16																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor'																	, ; //X3_TITULO
	'Valor'																	, ; //X3_TITSPA
	'Value'																	, ; //X3_TITENG
	'Valor do Lancamento'													, ; //X3_DESCRIC
	'Valor del asiento'														, ; //X3_DESCSPA
	'Entry Value'															, ; //X3_DESCENG
	'@E 9,999,999,999,999.99'												, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	'  x'																	, ; //X3_OBRIGAT
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
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAV'																	, ; //X3_ARQUIVO
	'14'																	, ; //X3_ORDEM
	'PAV_MOEDAS'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	5																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Moedas Lanca'															, ; //X3_TITULO
	'Moned.Asto.'															, ; //X3_TITSPA
	'Reg.Curr.'																, ; //X3_TITENG
	'Moedas Lancadas'														, ; //X3_DESCRIC
	'Monedas registradas'													, ; //X3_DESCSPA
	'Registered Currencies'													, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	'"11111"'																, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	'  x'																	, ; //X3_OBRIGAT
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
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAV'																	, ; //X3_ARQUIVO
	'15'																	, ; //X3_ORDEM
	'PAV_HP'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	3																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Hist Pad'																, ; //X3_TITULO
	'Hist Estand.'															, ; //X3_TITSPA
	'Stand.Hist.'															, ; //X3_TITENG
	'Historico Padrao'														, ; //X3_DESCRIC
	'Historial Estandar'													, ; //X3_DESCSPA
	'Standard History'														, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	'CT8'																	, ; //X3_F3
	1																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	'  x'																	, ; //X3_OBRIGAT
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
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAV'																	, ; //X3_ARQUIVO
	'16'																	, ; //X3_ORDEM
	'PAV_HIST'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	200																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Hist Lanc'																, ; //X3_TITULO
	'Hist Asiento'															, ; //X3_TITSPA
	'Entry Hist.'															, ; //X3_TITENG
	'Historico Lcto'														, ; //X3_DESCRIC
	'Historial Asiento'														, ; //X3_DESCSPA
	'Entry History'															, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	'  x'																	, ; //X3_OBRIGAT
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
	'S'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAV'																	, ; //X3_ARQUIVO
	'17'																	, ; //X3_ORDEM
	'PAV_CONVER'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	5																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Crit Conv'																, ; //X3_TITULO
	'Crit.Conver.'															, ; //X3_TITSPA
	'Conv.Crit.'															, ; //X3_TITENG
	'Criterio de Conversao'													, ; //X3_DESCRIC
	'Criterio de conversion'												, ; //X3_DESCSPA
	'Conversion Criterion'													, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	'V'																		, ; //X3_CONTEXT
	'  x'																	, ; //X3_OBRIGAT
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
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAV'																	, ; //X3_ARQUIVO
	'18'																	, ; //X3_ORDEM
	'PAV_CCD'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	9																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'C Custo Deb'															, ; //X3_TITULO
	'C Costo Deb'															, ; //X3_TITSPA
	'Deb Cost Cen'															, ; //X3_TITENG
	'Centro de Custo Debito'												, ; //X3_DESCRIC
	'Centro de Costo Debito'												, ; //X3_DESCSPA
	'Debit Cost Center'														, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	'CTT'																	, ; //X3_F3
	1																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	'  x'																	, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	'004'																	, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAV'																	, ; //X3_ARQUIVO
	'19'																	, ; //X3_ORDEM
	'PAV_CCC'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	9																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'C Custo Crd'															, ; //X3_TITULO
	'C Costo Crd'															, ; //X3_TITSPA
	'Crd Cost Cen'															, ; //X3_TITENG
	'Centro de Custo Credor'												, ; //X3_DESCRIC
	'Centro de Costo Acreedor'												, ; //X3_DESCSPA
	'Creditor Cost Center'													, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	'CTT'																	, ; //X3_F3
	1																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	'  x'																	, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	'004'																	, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAV'																	, ; //X3_ARQUIVO
	'20'																	, ; //X3_ORDEM
	'PAV_ITEMD'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	9																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Item Conta D'															, ; //X3_TITULO
	'Item Debito'															, ; //X3_TITSPA
	'Debit Item'															, ; //X3_TITENG
	'Item Debito'															, ; //X3_DESCRIC
	'Item Debito'															, ; //X3_DESCSPA
	'Debit Item'															, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	'CTD'																	, ; //X3_F3
	1																		, ; //X3_NIVEL
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
	'005'																	, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAV'																	, ; //X3_ARQUIVO
	'21'																	, ; //X3_ORDEM
	'PAV_ITEMC'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	9																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Item Conta C'															, ; //X3_TITULO
	'Item Credito'															, ; //X3_TITSPA
	'Credit Item'															, ; //X3_TITENG
	'Item Credito'															, ; //X3_DESCRIC
	'Item Credito'															, ; //X3_DESCSPA
	'Credit Item'															, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	'CTD'																	, ; //X3_F3
	1																		, ; //X3_NIVEL
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
	'005'																	, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAV'																	, ; //X3_ARQUIVO
	'22'																	, ; //X3_ORDEM
	'PAV_CLVLDB'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	9																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Cod Cl Val D'															, ; //X3_TITULO
	'Cl Vlr Deb'															, ; //X3_TITSPA
	'Deb Vl Categ'															, ; //X3_TITENG
	'Classe Valor Debito'													, ; //X3_DESCRIC
	'Clase Valor Debito'													, ; //X3_DESCSPA
	'Debit Value Category'													, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	'CTH'																	, ; //X3_F3
	1																		, ; //X3_NIVEL
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
	'006'																	, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAV'																	, ; //X3_ARQUIVO
	'23'																	, ; //X3_ORDEM
	'PAV_CLVLCR'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	9																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Cod Cl Val C'															, ; //X3_TITULO
	'Cl Vlr Cred'															, ; //X3_TITSPA
	'Crd Vl Categ'															, ; //X3_TITENG
	'Classe Valor Credito'													, ; //X3_DESCRIC
	'Clase Valor Credito'													, ; //X3_DESCSPA
	'Credit Value Category'													, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	'CTH'																	, ; //X3_F3
	1																		, ; //X3_NIVEL
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
	'006'																	, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAV'																	, ; //X3_ARQUIVO
	'24'																	, ; //X3_ORDEM
	'PAV_ATIVDE'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	40																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Ativ Deb'																, ; //X3_TITULO
	'Activ Deb'																, ; //X3_TITSPA
	'Deb Actv'																, ; //X3_TITENG
	'Atividade Debito'														, ; //X3_DESCRIC
	'Actividad Debito'														, ; //X3_DESCSPA
	'Debit Activity'														, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	'  x'																	, ; //X3_OBRIGAT
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
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAV'																	, ; //X3_ARQUIVO
	'25'																	, ; //X3_ORDEM
	'PAV_ATIVCR'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	40																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Ativ Crd'																, ; //X3_TITULO
	'Activ Crd'																, ; //X3_TITSPA
	'Crd Actv'																, ; //X3_TITENG
	'Atividade Credito'														, ; //X3_DESCRIC
	'Actividad Credito'														, ; //X3_DESCSPA
	'Credit Activity'														, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	'  x'																	, ; //X3_OBRIGAT
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
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAV'																	, ; //X3_ARQUIVO
	'26'																	, ; //X3_ORDEM
	'PAV_EMPORI'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	2																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Empresa Orig'															, ; //X3_TITULO
	'Empresa Orig'															, ; //X3_TITSPA
	'Orig.Company'															, ; //X3_TITENG
	'Empresa Original Lcto'													, ; //X3_DESCRIC
	'Empresa Original Asiento'												, ; //X3_DESCSPA
	'Entry Original Company'												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	'Substr(cNumEmp,1,2)'													, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	'  x'																	, ; //X3_OBRIGAT
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
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAV'																	, ; //X3_ARQUIVO
	'27'																	, ; //X3_ORDEM
	'PAV_FILORI'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	2																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Filial Orig'															, ; //X3_TITULO
	'Sucurs. Orig'															, ; //X3_TITSPA
	'Orig.Branch'															, ; //X3_TITENG
	'Filial Original Lancament'												, ; //X3_DESCRIC
	'Sucursal Original Asto.'												, ; //X3_DESCSPA
	'Entry Original Branch'													, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	'  x'																	, ; //X3_OBRIGAT
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
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAV'																	, ; //X3_ARQUIVO
	'28'																	, ; //X3_ORDEM
	'PAV_INTERC'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Intercompany'															, ; //X3_TITULO
	'Intercompany'															, ; //X3_TITSPA
	'Intercompany'															, ; //X3_TITENG
	'Lanc de Intercompany?'													, ; //X3_DESCRIC
	'¿Reg. de Intercompany?'												, ; //X3_DESCSPA
	'Intecompany entry?'													, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	'"1"'																	, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	'  x'																	, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	'1=Sim;2=Nao'															, ; //X3_CBOX
	'1=Si;2=No'																, ; //X3_CBOXSPA
	'1=Yes;2=No'															, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAV'																	, ; //X3_ARQUIVO
	'29'																	, ; //X3_ORDEM
	'PAV_IDENTC'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	50																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Ident IntCp'															, ; //X3_TITULO
	'Ident IntCp'															, ; //X3_TITSPA
	'Intercomp.Id'															, ; //X3_TITENG
	'Ident Lcto Intercp'													, ; //X3_DESCRIC
	'Ident Asto.Intercp'													, ; //X3_DESCSPA
	'Intercomp. Entry Identif.'												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	'  x'																	, ; //X3_OBRIGAT
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
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAV'																	, ; //X3_ARQUIVO
	'30'																	, ; //X3_ORDEM
	'PAV_TPSALD'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Tipo do Sld'															, ; //X3_TITULO
	'Tipo de Sld'															, ; //X3_TITSPA
	'Balance Type'															, ; //X3_TITENG
	'Tipo do Saldo?'														, ; //X3_DESCRIC
	'+Tipo de Saldo          ?'												, ; //X3_DESCSPA
	'Balance Type?'															, ; //X3_DESCENG
	'!'																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	'"1"'																	, ; //X3_RELACAO
	'SLW'																	, ; //X3_F3
	1																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	'  x'																	, ; //X3_OBRIGAT
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
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAV'																	, ; //X3_ARQUIVO
	'31'																	, ; //X3_ORDEM
	'PAV_SEQUEN'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	10																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Seq CTK'																, ; //X3_TITULO
	'Sec CTK'																, ; //X3_TITSPA
	'CTK Sequence'															, ; //X3_TITENG
	'Link entre CTK e CT2'													, ; //X3_DESCRIC
	'Enlace entre CTK y CT2'												, ; //X3_DESCSPA
	'Link Between CTK and CT2'												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	'  x'																	, ; //X3_OBRIGAT
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
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAV'																	, ; //X3_ARQUIVO
	'32'																	, ; //X3_ORDEM
	'PAV_MANUAL'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Lcto Manual'															, ; //X3_TITULO
	'+AstoManual?'															, ; //X3_TITSPA
	'Man.Entry'																, ; //X3_TITENG
	'Eh lcto Manual?'														, ; //X3_DESCRIC
	'+Es Asiento Manual  ?'													, ; //X3_DESCSPA
	'Is it Manual Entry'													, ; //X3_DESCENG
	'!'																		, ; //X3_PICTURE
	'Pertence("12")'														, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	'  x'																	, ; //X3_OBRIGAT
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
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAV'																	, ; //X3_ARQUIVO
	'33'																	, ; //X3_ORDEM
	'PAV_ORIGEM'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	100																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Origem'																, ; //X3_TITULO
	'Origen'																, ; //X3_TITSPA
	'Source'																, ; //X3_TITENG
	'Origem do Lancamento'													, ; //X3_DESCRIC
	'Origen del Asiento'													, ; //X3_DESCSPA
	'Entry Source'															, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	'  x'																	, ; //X3_OBRIGAT
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
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAV'																	, ; //X3_ARQUIVO
	'34'																	, ; //X3_ORDEM
	'PAV_ROTINA'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	10																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Rotina'																, ; //X3_TITULO
	'Rutina'																, ; //X3_TITSPA
	'Routine'																, ; //X3_TITENG
	'Rotina Geradora'														, ; //X3_DESCRIC
	'Rutina Generadora'														, ; //X3_DESCSPA
	'Generator Routine'														, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	'  x'																	, ; //X3_OBRIGAT
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
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAV'																	, ; //X3_ARQUIVO
	'35'																	, ; //X3_ORDEM
	'PAV_AGLUT'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Aglutinado'															, ; //X3_TITULO
	'Aglomerado'															, ; //X3_TITSPA
	'Grouped'																, ; //X3_TITENG
	'Lancamento aglutinado'													, ; //X3_DESCRIC
	'Asiento aglomerado'													, ; //X3_DESCSPA
	'Grouped Entry'															, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	'"2"'																	, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	'  x'																	, ; //X3_OBRIGAT
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
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAV'																	, ; //X3_ARQUIVO
	'36'																	, ; //X3_ORDEM
	'PAV_LP'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	3																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Lanc Padrao'															, ; //X3_TITULO
	'Asien Estand'															, ; //X3_TITSPA
	'Stand. Entry'															, ; //X3_TITENG
	'Lancamento Padrao'														, ; //X3_DESCRIC
	'Asiento Estandar'														, ; //X3_DESCSPA
	'Standard Entry'														, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	'CVA'																	, ; //X3_F3
	1																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	'  x'																	, ; //X3_OBRIGAT
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
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAV'																	, ; //X3_ARQUIVO
	'37'																	, ; //X3_ORDEM
	'PAV_SEQHIS'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	3																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Seq Historic'															, ; //X3_TITULO
	'Sec Histor.'															, ; //X3_TITSPA
	'Hist.Seq.'																, ; //X3_TITENG
	'Sequencia do Historico'												, ; //X3_DESCRIC
	'Secuencia del Historial'												, ; //X3_DESCSPA
	'History Sequence'														, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	'  x'																	, ; //X3_OBRIGAT
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
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAV'																	, ; //X3_ARQUIVO
	'38'																	, ; //X3_ORDEM
	'PAV_SEQLAN'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	3																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Seq Auxiliar'															, ; //X3_TITULO
	'Sec Auxiliar'															, ; //X3_TITSPA
	'Auxil.Seq.'															, ; //X3_TITENG
	'Seq Auxiliar do Lancto'												, ; //X3_DESCRIC
	'Sec Auxiliar de Asiento'												, ; //X3_DESCSPA
	'Entry Auxiliary Sequence'												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	'  x'																	, ; //X3_OBRIGAT
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
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAV'																	, ; //X3_ARQUIVO
	'39'																	, ; //X3_ORDEM
	'PAV_DTVENC'															, ; //X3_CAMPO
	'D'																		, ; //X3_TIPO
	8																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Data Venc'																, ; //X3_TITULO
	'Fecha Venc'															, ; //X3_TITSPA
	'Due Date'																, ; //X3_TITENG
	'Data de Vencimento'													, ; //X3_DESCRIC
	'Fecha de Vencimiento'													, ; //X3_DESCSPA
	'Due Date'																, ; //X3_DESCENG
	'99/99/9999'															, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	'  x'																	, ; //X3_OBRIGAT
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
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAV'																	, ; //X3_ARQUIVO
	'40'																	, ; //X3_ORDEM
	'PAV_SLBASE'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Flag Sld Bas'															, ; //X3_TITULO
	'Flag Sld Bas'															, ; //X3_TITSPA
	'Bas.Blc.Flag'															, ; //X3_TITENG
	'Flag Saldo Basico'														, ; //X3_DESCRIC
	'Flag Saldo Basico'														, ; //X3_DESCSPA
	'Basic Balance Flag'													, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	''																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	'  x'																	, ; //X3_OBRIGAT
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
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAV'																	, ; //X3_ARQUIVO
	'41'																	, ; //X3_ORDEM
	'PAV_DTLP'																, ; //X3_CAMPO
	'D'																		, ; //X3_TIPO
	8																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Dt Apuracao'															, ; //X3_TITULO
	'Fch Calculo'															, ; //X3_TITSPA
	'Calc.Date'																, ; //X3_TITENG
	'Data da apuracao'														, ; //X3_DESCRIC
	'Fecha del calculo'														, ; //X3_DESCSPA
	'Calculation Date'														, ; //X3_DESCENG
	'99/99/9999'															, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	'  x'																	, ; //X3_OBRIGAT
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
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAV'																	, ; //X3_ARQUIVO
	'42'																	, ; //X3_ORDEM
	'PAV_VALR02'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	16																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Moeda2'															, ; //X3_TITULO
	'Vlr Moneda 2'															, ; //X3_TITSPA
	'Curr 2 Value'															, ; //X3_TITENG
	'Valor Moeda 2'															, ; //X3_DESCRIC
	'Valor Moneda 2'														, ; //X3_DESCSPA
	'Currency 2 Entry Value'												, ; //X3_DESCENG
	'@E 9,999,999,999,999.99'												, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	''																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	'V'																		, ; //X3_CONTEXT
	'  x'																	, ; //X3_OBRIGAT
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
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAV'																	, ; //X3_ARQUIVO
	'43'																	, ; //X3_ORDEM
	'PAV_VALR03'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	16																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Moeda3'															, ; //X3_TITULO
	'Vlr Moneda 3'															, ; //X3_TITSPA
	'Curr 3 Value'															, ; //X3_TITENG
	'Valor Moeda 3'															, ; //X3_DESCRIC
	'Valor Moneda 3'														, ; //X3_DESCSPA
	'Currency 3 Entry Value'												, ; //X3_DESCENG
	'@E 9,999,999,999,999.99'												, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	''																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	'V'																		, ; //X3_CONTEXT
	'  x'																	, ; //X3_OBRIGAT
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
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAV'																	, ; //X3_ARQUIVO
	'44'																	, ; //X3_ORDEM
	'PAV_VALR04'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	16																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Moeda4'															, ; //X3_TITULO
	'Vlr Moneda 4'															, ; //X3_TITSPA
	'Curr 4 Value'															, ; //X3_TITENG
	'Valor Moeda 4'															, ; //X3_DESCRIC
	'Valor Moneda 4'														, ; //X3_DESCSPA
	'Currency 4 Entry Value'												, ; //X3_DESCENG
	'@E 9,999,999,999,999.99'												, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	'V'																		, ; //X3_CONTEXT
	'  x'																	, ; //X3_OBRIGAT
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
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAV'																	, ; //X3_ARQUIVO
	'45'																	, ; //X3_ORDEM
	'PAV_VALR05'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	16																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Moeda5'															, ; //X3_TITULO
	'Vlr Moneda 5'															, ; //X3_TITSPA
	'Curr 5 Value'															, ; //X3_TITENG
	'Valor Moeda 5'															, ; //X3_DESCRIC
	'Valor Moneda 5'														, ; //X3_DESCSPA
	'Currency 5 Entry Value'												, ; //X3_DESCENG
	'@E 9,999,999,999,999.99'												, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	''																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	'V'																		, ; //X3_CONTEXT
	'  x'																	, ; //X3_OBRIGAT
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
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAV'																	, ; //X3_ARQUIVO
	'46'																	, ; //X3_ORDEM
	'PAV_DATATX'															, ; //X3_CAMPO
	'D'																		, ; //X3_TIPO
	8																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Data Conv.'															, ; //X3_TITULO
	'Fecha Conver'															, ; //X3_TITSPA
	'Conv.Date'																, ; //X3_TITENG
	'Data de Conversao'														, ; //X3_DESCRIC
	'Fecha de conversion'													, ; //X3_DESCSPA
	'Conversion Date'														, ; //X3_DESCENG
	'99/99/9999'															, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	''																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	'  x'																	, ; //X3_OBRIGAT
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
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAV'																	, ; //X3_ARQUIVO
	'47'																	, ; //X3_ORDEM
	'PAV_TAXA'																, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	8																		, ; //X3_TAMANHO
	4																		, ; //X3_DECIMAL
	'Taxa Conv.'															, ; //X3_TITULO
	'Tasa Convers'															, ; //X3_TITSPA
	'Conv.Rate'																, ; //X3_TITENG
	'Taxa Conversao'														, ; //X3_DESCRIC
	'Tasa de conversion'													, ; //X3_DESCSPA
	'Conversion Rate'														, ; //X3_DESCENG
	'@E 999.9999'															, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	''																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	'  x'																	, ; //X3_OBRIGAT
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
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAV'																	, ; //X3_ARQUIVO
	'48'																	, ; //X3_ORDEM
	'PAV_VLR01'																, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	16																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Moeda1'															, ; //X3_TITULO
	'Vlr Moneda 1'															, ; //X3_TITSPA
	'Curr 1 Value'															, ; //X3_TITENG
	'Valor Lancamento Moeda 1'												, ; //X3_DESCRIC
	'Valor Asiento Moneda 1'												, ; //X3_DESCSPA
	'Currency 1 Entry Value'												, ; //X3_DESCENG
	'@E 9,999,999,999,999.99'												, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	'  x'																	, ; //X3_OBRIGAT
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
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAV'																	, ; //X3_ARQUIVO
	'49'																	, ; //X3_ORDEM
	'PAV_VLR02'																, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	16																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Moeda2'															, ; //X3_TITULO
	'Vlr Moneda 2'															, ; //X3_TITSPA
	'Curr 2 Value'															, ; //X3_TITENG
	'Valor Moeda 2'															, ; //X3_DESCRIC
	'Valor Moneda 2'														, ; //X3_DESCSPA
	'Currency 2 Entry Value'												, ; //X3_DESCENG
	'@E 9,999,999,999,999.99'												, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	'  x'																	, ; //X3_OBRIGAT
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
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAV'																	, ; //X3_ARQUIVO
	'50'																	, ; //X3_ORDEM
	'PAV_VLR03'																, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	16																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Moeda3'															, ; //X3_TITULO
	'Vlr Moneda 3'															, ; //X3_TITSPA
	'Curr 3 Value'															, ; //X3_TITENG
	'Valor Moeda 3'															, ; //X3_DESCRIC
	'Valor Moneda 3'														, ; //X3_DESCSPA
	'Currency 3 Entry Value'												, ; //X3_DESCENG
	'@E 9,999,999,999,999.99'												, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	'  x'																	, ; //X3_OBRIGAT
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
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAV'																	, ; //X3_ARQUIVO
	'51'																	, ; //X3_ORDEM
	'PAV_VLR04'																, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	16																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Moeda4'															, ; //X3_TITULO
	'Vlr Moneda 4'															, ; //X3_TITSPA
	'Curr 4 Value'															, ; //X3_TITENG
	'Valor Moeda 4'															, ; //X3_DESCRIC
	'Valor Moneda 4'														, ; //X3_DESCSPA
	'Currency 4 Entry Value'												, ; //X3_DESCENG
	'@E 9,999,999,999,999.99'												, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	'  x'																	, ; //X3_OBRIGAT
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
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAV'																	, ; //X3_ARQUIVO
	'52'																	, ; //X3_ORDEM
	'PAV_VLR05'																, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	16																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Moeda5'															, ; //X3_TITULO
	'Vlr Moneda 5'															, ; //X3_TITSPA
	'Curr 5 Value'															, ; //X3_TITENG
	'Valor Moeda 5'															, ; //X3_DESCRIC
	'Valor Moneda 5'														, ; //X3_DESCSPA
	'Currency 5 Entry Value'												, ; //X3_DESCENG
	'@E 9,999,999,999,999.99'												, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	'  x'																	, ; //X3_OBRIGAT
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
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAV'																	, ; //X3_ARQUIVO
	'53'																	, ; //X3_ORDEM
	'PAV_DTTX02'															, ; //X3_CAMPO
	'D'																		, ; //X3_TIPO
	8																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Data Conv.02'															, ; //X3_TITULO
	'Fch.Conv. 2'															, ; //X3_TITSPA
	'Conv.Date 2'															, ; //X3_TITENG
	'Data Conversao Moeda 02'												, ; //X3_DESCRIC
	'Fch. conversion moneda 2'												, ; //X3_DESCSPA
	'Currency 2 Conv.Date'													, ; //X3_DESCENG
	'99/99/9999'															, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	''																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	'V'																		, ; //X3_CONTEXT
	'  x'																	, ; //X3_OBRIGAT
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
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAV'																	, ; //X3_ARQUIVO
	'54'																	, ; //X3_ORDEM
	'PAV_TAXA02'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	8																		, ; //X3_TAMANHO
	4																		, ; //X3_DECIMAL
	'Taxa Conv.02'															, ; //X3_TITULO
	'Tasa Conv. 2'															, ; //X3_TITSPA
	'Conv.Rate 2'															, ; //X3_TITENG
	'Taxa Conversao Moeda 02'												, ; //X3_DESCRIC
	'Tasa conver. moneda 2'													, ; //X3_DESCSPA
	'Currency 2 Conv.Rate'													, ; //X3_DESCENG
	'@E 999.9999'															, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	''																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	'V'																		, ; //X3_CONTEXT
	'  x'																	, ; //X3_OBRIGAT
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
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAV'																	, ; //X3_ARQUIVO
	'55'																	, ; //X3_ORDEM
	'PAV_DTTX03'															, ; //X3_CAMPO
	'D'																		, ; //X3_TIPO
	8																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Data Conv.03'															, ; //X3_TITULO
	'Fch. conv. 3'															, ; //X3_TITSPA
	'Conv.Date 3'															, ; //X3_TITENG
	'Data Conversao Moeda 03'												, ; //X3_DESCRIC
	'Fch. conver. moneda 3'													, ; //X3_DESCSPA
	'Currency 3 Conv.Date'													, ; //X3_DESCENG
	'99/99/9999'															, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	'V'																		, ; //X3_CONTEXT
	'  x'																	, ; //X3_OBRIGAT
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
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAV'																	, ; //X3_ARQUIVO
	'56'																	, ; //X3_ORDEM
	'PAV_TAXA03'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	8																		, ; //X3_TAMANHO
	4																		, ; //X3_DECIMAL
	'Taxa Conv.03'															, ; //X3_TITULO
	'Tasa conv. 3'															, ; //X3_TITSPA
	'Conv.Rate 3'															, ; //X3_TITENG
	'Taxa Conversao Moeda 03'												, ; //X3_DESCRIC
	'Tasa conversion moneda 3'												, ; //X3_DESCSPA
	'Currency 3 Conv.Rate'													, ; //X3_DESCENG
	'@E 999.9999'															, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	'V'																		, ; //X3_CONTEXT
	'  x'																	, ; //X3_OBRIGAT
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
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAV'																	, ; //X3_ARQUIVO
	'57'																	, ; //X3_ORDEM
	'PAV_DTTX04'															, ; //X3_CAMPO
	'D'																		, ; //X3_TIPO
	8																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Data Conv.04'															, ; //X3_TITULO
	'Fch.Conver 4'															, ; //X3_TITSPA
	'Conv.Date 4'															, ; //X3_TITENG
	'Data Conversao Moeda 04'												, ; //X3_DESCRIC
	'Fch. conversion moneda 4'												, ; //X3_DESCSPA
	'Currency 4 Conv.Date'													, ; //X3_DESCENG
	'99/99/9999'															, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	'V'																		, ; //X3_CONTEXT
	'  x'																	, ; //X3_OBRIGAT
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
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAV'																	, ; //X3_ARQUIVO
	'58'																	, ; //X3_ORDEM
	'PAV_TAXA04'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	8																		, ; //X3_TAMANHO
	4																		, ; //X3_DECIMAL
	'Taxa Conv.04'															, ; //X3_TITULO
	'Ts. conver 4'															, ; //X3_TITSPA
	'Conv.Rate 4'															, ; //X3_TITENG
	'Taxa Conversao Moeda 04'												, ; //X3_DESCRIC
	'Tasa conversion moneda 4'												, ; //X3_DESCSPA
	'Currency 4 Conv.Rate'													, ; //X3_DESCENG
	'@E 999.9999'															, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	'V'																		, ; //X3_CONTEXT
	'  x'																	, ; //X3_OBRIGAT
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
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAV'																	, ; //X3_ARQUIVO
	'59'																	, ; //X3_ORDEM
	'PAV_DTTX05'															, ; //X3_CAMPO
	'D'																		, ; //X3_TIPO
	8																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Data Conv.05'															, ; //X3_TITULO
	'Fch.conver 5'															, ; //X3_TITSPA
	'Conv.Date 5'															, ; //X3_TITENG
	'Data Conversao Moeda 05'												, ; //X3_DESCRIC
	'Fch. conversion moneda 5'												, ; //X3_DESCSPA
	'Currency 5 Conv.Date'													, ; //X3_DESCENG
	'99/99/9999'															, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	'V'																		, ; //X3_CONTEXT
	'  x'																	, ; //X3_OBRIGAT
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
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAV'																	, ; //X3_ARQUIVO
	'60'																	, ; //X3_ORDEM
	'PAV_TAXA05'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	8																		, ; //X3_TAMANHO
	4																		, ; //X3_DECIMAL
	'Taxa Conv.05'															, ; //X3_TITULO
	'Ts.conver. 5'															, ; //X3_TITSPA
	'Conv.Rate 5'															, ; //X3_TITENG
	'Taxa Conversao Moeda 05'												, ; //X3_DESCRIC
	'Tasa conversion moneda 5'												, ; //X3_DESCSPA
	'Currency 5 Conv.Rate'													, ; //X3_DESCENG
	'@E 999.9999'															, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	'V'																		, ; //X3_CONTEXT
	'  x'																	, ; //X3_OBRIGAT
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
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAV'																	, ; //X3_ARQUIVO
	'61'																	, ; //X3_ORDEM
	'PAV_CRCONV'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Crit. Conver'															, ; //X3_TITULO
	'Crit. Conv.'															, ; //X3_TITSPA
	'Conv.Crit.'															, ; //X3_TITENG
	'Criterio de Conversao'													, ; //X3_DESCRIC
	'Criterios de conversion'												, ; //X3_DESCSPA
	'Conversion Criterion'													, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	'  x'																	, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	'1=Diaria;2=Media;3=Mensal;4=Informada;5=Nao tem Conversao;6=Fixo;7=Mensal Historica;8=Media Historica;9=Vencimento;A=Nao Ajusta', ; //X3_CBOX
	'1=Diaria;2=Promedio;3=Mensual;4=Informada;5=No tiene conversion;6=Fijo;7=Mensual Histor.;8=Promedio Histor.;9=Vencim.;A=No ajust', ; //X3_CBOXSPA
	'1=Daily;2=Average;3=Monthly;4=Informed;5=No Conversion;6=Fixed;7=HIstory Monthly;8=HIstory Average;9=Expiration;A=Do not Adj', ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAV'																	, ; //X3_ARQUIVO
	'62'																	, ; //X3_ORDEM
	'PAV_CRITER'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	4																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Crit Conv'																, ; //X3_TITULO
	'Crit. Conv.'															, ; //X3_TITSPA
	'Conv.Criter.'															, ; //X3_TITENG
	'Criterio de Conversao'													, ; //X3_DESCRIC
	'Criterio de Conversion'												, ; //X3_DESCSPA
	'Conversion Criterion'													, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	'  x'																	, ; //X3_OBRIGAT
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
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAV'																	, ; //X3_ARQUIVO
	'63'																	, ; //X3_ORDEM
	'PAV_KEY'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	200																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Key'																	, ; //X3_TITULO
	'Clave'																	, ; //X3_TITSPA
	'Key'																	, ; //X3_TITENG
	'Key'																	, ; //X3_DESCRIC
	'Clave'																	, ; //X3_DESCSPA
	'Key'																	, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	'  x'																	, ; //X3_OBRIGAT
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
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAV'																	, ; //X3_ARQUIVO
	'64'																	, ; //X3_ORDEM
	'PAV_SEGOFI'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	10																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Correlativo'															, ; //X3_TITULO
	'Correlativo'															, ; //X3_TITSPA
	'Correlative'															, ; //X3_TITENG
	'Numero Correlativo'													, ; //X3_DESCRIC
	'Numero Correlativo'													, ; //X3_DESCSPA
	'Correlative Number'													, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	'  x'																	, ; //X3_OBRIGAT
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
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAV'																	, ; //X3_ARQUIVO
	'65'																	, ; //X3_ORDEM
	'PAV_DTCV3'																, ; //X3_CAMPO
	'D'																		, ; //X3_TIPO
	8																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Data Rastrea'															, ; //X3_TITULO
	'Fecha Trazab'															, ; //X3_TITSPA
	'Track. Date'															, ; //X3_TITENG
	'Data para Rastreamento'												, ; //X3_DESCRIC
	'Fecha para Rastreo'													, ; //X3_DESCSPA
	'Date for Trackability'													, ; //X3_DESCENG
	'99/99/9999'															, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	'  x'																	, ; //X3_OBRIGAT
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
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAV'																	, ; //X3_ARQUIVO
	'66'																	, ; //X3_ORDEM
	'PAV_SEQIDX'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	5																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Seq Chv Unic'															, ; //X3_TITULO
	'Seq Clv Unic'															, ; //X3_TITSPA
	'Uni.Seq.Key'															, ; //X3_TITENG
	'Sequencial Chave Unica'												, ; //X3_DESCRIC
	'Alternativa habilitada'												, ; //X3_DESCSPA
	'Unique Sequential Key'													, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	'  x'																	, ; //X3_OBRIGAT
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
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAV'																	, ; //X3_ARQUIVO
	'67'																	, ; //X3_ORDEM
	'PAV_CONFST'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Status Conf.'															, ; //X3_TITULO
	'Est. verif.'															, ; //X3_TITSPA
	'Chec. Status'															, ; //X3_TITENG
	'Status Conferência'													, ; //X3_DESCRIC
	'Estatus verificacion'													, ; //X3_DESCSPA
	'Status of Checking'													, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	'  x'																	, ; //X3_OBRIGAT
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
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAV'																	, ; //X3_ARQUIVO
	'68'																	, ; //X3_ORDEM
	'PAV_OBSCNF'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	40																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Obs Conf'																, ; //X3_TITULO
	'Obs Conf'																, ; //X3_TITSPA
	'Chec. Notes'															, ; //X3_TITENG
	'Observação'															, ; //X3_DESCRIC
	'Observacion'															, ; //X3_DESCSPA
	'Notes'																	, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	'  x'																	, ; //X3_OBRIGAT
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
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAV'																	, ; //X3_ARQUIVO
	'69'																	, ; //X3_ORDEM
	'PAV_USRCNF'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	15																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Usuario Conf'															, ; //X3_TITULO
	'Usuario Ver.'															, ; //X3_TITSPA
	'User Check'															, ; //X3_TITENG
	'Usuario conferente'													, ; //X3_DESCRIC
	'Usuario verificador'													, ; //X3_DESCSPA
	'Checking User'															, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	'  x'																	, ; //X3_OBRIGAT
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
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAV'																	, ; //X3_ARQUIVO
	'70'																	, ; //X3_ORDEM
	'PAV_DTCONF'															, ; //X3_CAMPO
	'D'																		, ; //X3_TIPO
	8																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Data Conf'																, ; //X3_TITULO
	'Fecha Verif.'															, ; //X3_TITSPA
	'Check date'															, ; //X3_TITENG
	'Daa Conferencia'														, ; //X3_DESCRIC
	'Fecha verificacion'													, ; //X3_DESCSPA
	'Check date'															, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	'  x'																	, ; //X3_OBRIGAT
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
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAV'																	, ; //X3_ARQUIVO
	'71'																	, ; //X3_ORDEM
	'PAV_HRCONF'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	10																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Hora Conf'																, ; //X3_TITULO
	'Hora Verif.'															, ; //X3_TITSPA
	'Check. Time'															, ; //X3_TITENG
	'Hora Confenrecia'														, ; //X3_DESCRIC
	'Hora de verificacion'													, ; //X3_DESCSPA
	'Time for Checking'														, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	'  x'																	, ; //X3_OBRIGAT
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
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAV'																	, ; //X3_ARQUIVO
	'72'																	, ; //X3_ORDEM
	'PAV_MLTSLD'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	20																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Tps Saldos'															, ; //X3_TITULO
	'Tps Saldos'															, ; //X3_TITSPA
	'Balance Tps.'															, ; //X3_TITENG
	'Tps Saldos'															, ; //X3_DESCRIC
	'Tipos Saldos'															, ; //X3_DESCSPA
	'Balance Types'															, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	'  x'																	, ; //X3_OBRIGAT
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
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAV'																	, ; //X3_ARQUIVO
	'73'																	, ; //X3_ORDEM
	'PAV_CTLSLD'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Status Copia'															, ; //X3_TITULO
	'Estat. Copia'															, ; //X3_TITSPA
	'Copy Status'															, ; //X3_TITENG
	'Status Copia'															, ; //X3_DESCRIC
	'Estatus Copia'															, ; //X3_DESCSPA
	'Copy Status'															, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	'  x'																	, ; //X3_OBRIGAT
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
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAV'																	, ; //X3_ARQUIVO
	'74'																	, ; //X3_ORDEM
	'PAV_CODPAR'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Cod.Partic.'															, ; //X3_TITULO
	'Cod.Partic.'															, ; //X3_TITSPA
	'Empl.Code'																, ; //X3_TITENG
	'Codigo do Participante'												, ; //X3_DESCRIC
	'Codigo del Participante'												, ; //X3_DESCSPA
	'Employee Code'															, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	'ExistCPO("CVC")'														, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	'CVC'																	, ; //X3_F3
	1																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	''																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	'  x'																	, ; //X3_OBRIGAT
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
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAV'																	, ; //X3_ARQUIVO
	'75'																	, ; //X3_ORDEM
	'PAV_NODIA'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	10																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Nro Diario'															, ; //X3_TITULO
	'Nº Diario'																, ; //X3_TITSPA
	'T.Rec.No.'																, ; //X3_TITENG
	'Numero do seq do diario'												, ; //X3_DESCRIC
	'Numero de sec del diario'												, ; //X3_DESCSPA
	'Tax Record S.Number'													, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	'  x'																	, ; //X3_OBRIGAT
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
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAV'																	, ; //X3_ARQUIVO
	'76'																	, ; //X3_ORDEM
	'PAV_DIACTB'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	2																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Cod. Diario'															, ; //X3_TITULO
	'Cod. Diario'															, ; //X3_TITSPA
	'Journal Code'															, ; //X3_TITENG
	'Código do Diario'														, ; //X3_DESCRIC
	'Codigo del Diario'														, ; //X3_DESCSPA
	'Journal Code'															, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	''																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	'  x'																	, ; //X3_OBRIGAT
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
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAV'																	, ; //X3_ARQUIVO
	'77'																	, ; //X3_ORDEM
	'PAV_MOEFDB'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	2																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Moed fato DB'															, ; //X3_TITULO
	'Mon hecho DB'															, ; //X3_TITSPA
	'DB fact Curr'															, ; //X3_TITENG
	'Moeda do fato p/ a ent DB'												, ; //X3_DESCRIC
	'Moneda Hecho para ente DB'												, ; //X3_DESCSPA
	'Fact curr for DB inflow'												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	"Vazio() .Or. ExistCpo('CTO')"											, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	'CTO'																	, ; //X3_F3
	1																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	'  x'																	, ; //X3_OBRIGAT
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
	'N'																		, ; //X3_IDXSRV
	''																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAV'																	, ; //X3_ARQUIVO
	'78'																	, ; //X3_ORDEM
	'PAV_MOEFCR'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	2																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Moed fato CR'															, ; //X3_TITULO
	'Mon hecho CR'															, ; //X3_TITSPA
	'CR fact Curr'															, ; //X3_TITENG
	'Moeda do fato p/ a ent CR'												, ; //X3_DESCRIC
	'Moneda Hecho para ente CR'												, ; //X3_DESCSPA
	'Fact curr for CR inflow'												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	"Vazio() .Or. ExistCpo('CTO')"											, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	'CTO'																	, ; //X3_F3
	1																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	'  x'																	, ; //X3_OBRIGAT
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
	'N'																		, ; //X3_IDXSRV
	''																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAV'																	, ; //X3_ARQUIVO
	'79'																	, ; //X3_ORDEM
	'PAV_USERGI'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	17																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Log de Inclu'															, ; //X3_TITULO
	'Log de Inclu'															, ; //X3_TITSPA
	'Add Log'																, ; //X3_TITENG
	'Log de Inclusão'														, ; //X3_DESCRIC
	'Log de inclusion'														, ; //X3_DESCSPA
	'Inclusion Log'															, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	'  x'																	, ; //X3_OBRIGAT
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
	'N'																		, ; //X3_IDXSRV
	''																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAV'																	, ; //X3_ARQUIVO
	'80'																	, ; //X3_ORDEM
	'PAV_USERGA'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	17																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Log de Alter'															, ; //X3_TITULO
	'Log de Mod'															, ; //X3_TITSPA
	'Change Log'															, ; //X3_TITENG
	'Log de Alteração'														, ; //X3_DESCRIC
	'Log de modificacion'													, ; //X3_DESCSPA
	'Change Log'															, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	'  x'																	, ; //X3_OBRIGAT
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
	'N'																		, ; //X3_IDXSRV
	''																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAV'																	, ; //X3_ARQUIVO
	'81'																	, ; //X3_ORDEM
	'PAV_AT01DB'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	20																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Ativ.01 DB'															, ; //X3_TITULO
	'Activ.01 DB'															, ; //X3_TITSPA
	'DB Act 01'																, ; //X3_TITENG
	'Atividade 01 DB'														, ; //X3_DESCRIC
	'Actividad 01 DB'														, ; //X3_DESCSPA
	'DB Activity 01'														, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	'  x'																	, ; //X3_OBRIGAT
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
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAV'																	, ; //X3_ARQUIVO
	'82'																	, ; //X3_ORDEM
	'PAV_AT01CR'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	20																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Ativ.01 CR'															, ; //X3_TITULO
	'Activ.01 CR'															, ; //X3_TITSPA
	'CR Act 01'																, ; //X3_TITENG
	'Atividade 01 CR'														, ; //X3_DESCRIC
	'Actividad 01 CR'														, ; //X3_DESCSPA
	'CR Activity 01'														, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	'  x'																	, ; //X3_OBRIGAT
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
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAV'																	, ; //X3_ARQUIVO
	'83'																	, ; //X3_ORDEM
	'PAV_AT02DB'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	20																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Ativ.02 DB'															, ; //X3_TITULO
	'Activ.02 DB'															, ; //X3_TITSPA
	'DB Act 02'																, ; //X3_TITENG
	'Atividade 02 DB'														, ; //X3_DESCRIC
	'Actividad 02 DB'														, ; //X3_DESCSPA
	'DB Activity 02'														, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	'  x'																	, ; //X3_OBRIGAT
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
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAV'																	, ; //X3_ARQUIVO
	'84'																	, ; //X3_ORDEM
	'PAV_AT02CR'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	20																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Ativ.02 CR'															, ; //X3_TITULO
	'Activ.02 CR'															, ; //X3_TITSPA
	'CR Act 02'																, ; //X3_TITENG
	'Atividade 02 CR'														, ; //X3_DESCRIC
	'Actividad 02 CR'														, ; //X3_DESCSPA
	'CR Activity 02'														, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	'  x'																	, ; //X3_OBRIGAT
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
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAV'																	, ; //X3_ARQUIVO
	'85'																	, ; //X3_ORDEM
	'PAV_AT03DB'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	20																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Ativ.03 DB'															, ; //X3_TITULO
	'Activ.03 DB'															, ; //X3_TITSPA
	'DB Act 03'																, ; //X3_TITENG
	'Atividade 03 DB'														, ; //X3_DESCRIC
	'Actividad 03 DB'														, ; //X3_DESCSPA
	'DB Activity 03'														, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	'  x'																	, ; //X3_OBRIGAT
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
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAV'																	, ; //X3_ARQUIVO
	'86'																	, ; //X3_ORDEM
	'PAV_AT03CR'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	20																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Ativ.03 CR'															, ; //X3_TITULO
	'Activ.03 CR'															, ; //X3_TITSPA
	'CR Act 03'																, ; //X3_TITENG
	'Atividade 03 CR'														, ; //X3_DESCRIC
	'Actividad 03 CR'														, ; //X3_DESCSPA
	'CR Activity 03'														, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	'  x'																	, ; //X3_OBRIGAT
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
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAV'																	, ; //X3_ARQUIVO
	'87'																	, ; //X3_ORDEM
	'PAV_AT04DB'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	20																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Ativ.04 DB'															, ; //X3_TITULO
	'Activ.04 DB'															, ; //X3_TITSPA
	'DB Act 04'																, ; //X3_TITENG
	'Atividade 04 DB'														, ; //X3_DESCRIC
	'Actividad 04 DB'														, ; //X3_DESCSPA
	'DB Activity 04'														, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	'  x'																	, ; //X3_OBRIGAT
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
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAV'																	, ; //X3_ARQUIVO
	'88'																	, ; //X3_ORDEM
	'PAV_AT04CR'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	20																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Ativ.04 CR'															, ; //X3_TITULO
	'Activ.04 CR'															, ; //X3_TITSPA
	'CR Act 04'																, ; //X3_TITENG
	'Atividade 04 CR'														, ; //X3_DESCRIC
	'Actividad 04 CR'														, ; //X3_DESCSPA
	'CR Activity 04'														, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	'  x'																	, ; //X3_OBRIGAT
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
	'N'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAV'																	, ; //X3_ARQUIVO
	'89'																	, ; //X3_ORDEM
	'PAV_LANCSU'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	3																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Sequencial'															, ; //X3_TITULO
	'Secuencial'															, ; //X3_TITSPA
	'Sequential'															, ; //X3_TITENG
	'Código sequencial'														, ; //X3_DESCRIC
	'Codigo secuencial'														, ; //X3_DESCSPA
	'Sequential code'														, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	'  x'																	, ; //X3_OBRIGAT
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
	'N'																		, ; //X3_IDXSRV
	''																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAV'																	, ; //X3_ARQUIVO
	'90'																	, ; //X3_ORDEM
	'PAV_GRPDIA'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	3																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Grupo'																	, ; //X3_TITULO
	'Grupo'																	, ; //X3_TITSPA
	'Group'																	, ; //X3_TITENG
	'Código do Grupo'														, ; //X3_DESCRIC
	'Codigo del Grupo'														, ; //X3_DESCSPA
	'Group Code'															, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	'  x'																	, ; //X3_OBRIGAT
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
	'N'																		, ; //X3_IDXSRV
	''																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAV'																	, ; //X3_ARQUIVO
	'91'																	, ; //X3_ORDEM
	'PAV_CODCLI'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Cód. Cliente'															, ; //X3_TITULO
	'Cod. Cliente'															, ; //X3_TITSPA
	'Client Code'															, ; //X3_TITENG
	'Código do Cliente da Cont'												, ; //X3_DESCRIC
	'Codigo cliente de la cuen'												, ; //X3_DESCSPA
	'Cont. Client Code'														, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	''																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	'  x'																	, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	'001'																	, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	'S'																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAV'																	, ; //X3_ARQUIVO
	'92'																	, ; //X3_ORDEM
	'PAV_CODFOR'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Cód. Fornec.'															, ; //X3_TITULO
	'Cod. Proveed'															, ; //X3_TITSPA
	'Supplier Cod'															, ; //X3_TITENG
	'Código do Fornecedor'													, ; //X3_DESCRIC
	'Codigo de Proveedor'													, ; //X3_DESCSPA
	'Supplier Code'															, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	''																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	'  x'																	, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	'001'																	, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	'N'																		, ; //X3_IDXSRV
	''																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAV'																	, ; //X3_ARQUIVO
	'93'																	, ; //X3_ORDEM
	'PAV_LANC'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	15																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Lanc'																	, ; //X3_TITULO
	'Asiento'																, ; //X3_TITSPA
	'Entry'																	, ; //X3_TITENG
	'Sequencia'																, ; //X3_DESCRIC
	'Secuencia'																, ; //X3_DESCSPA
	'Sequence'																, ; //X3_DESCENG
	'@'																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	'  x'																	, ; //X3_OBRIGAT
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
	'N'																		, ; //X3_IDXSRV
	''																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAV'																	, ; //X3_ARQUIVO
	'94'																	, ; //X3_ORDEM
	'PAV_CTRLSD'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Control.Sald'															, ; //X3_TITULO
	'Contr.Saldos'															, ; //X3_TITSPA
	'Bal Control'															, ; //X3_TITENG
	'Controle de Saldos'													, ; //X3_DESCRIC
	'Control de saldos'														, ; //X3_DESCSPA
	'Balances Control'														, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	'  x'																	, ; //X3_OBRIGAT
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
	'N'																		, ; //X3_IDXSRV
	''																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAV'																	, ; //X3_ARQUIVO
	'95'																	, ; //X3_ORDEM
	'PAV_ESTCAN'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Estorno/Canc'															, ; //X3_TITULO
	'Revers/Anul'															, ; //X3_TITSPA
	'Revers/Canc'															, ; //X3_TITENG
	'Estorno/Cancelamento'													, ; //X3_DESCRIC
	'Reversión/Anulación'													, ; //X3_DESCSPA
	'Reversal/Cancelation'													, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
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
	'N'																		, ; //X3_IDXSRV
	''																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAV'																	, ; //X3_ARQUIVO
	'96'																	, ; //X3_ORDEM
	'PAV_IDCONC'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	23																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Id. Concilia'															, ; //X3_TITULO
	'Id. Concilia'															, ; //X3_TITSPA
	'Concil. ID'															, ; //X3_TITENG
	'Id. Conciliaçao'														, ; //X3_DESCRIC
	'Id. Conciliacion'														, ; //X3_DESCSPA
	'Conciliation ID'														, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
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
	'N'																		, ; //X3_IDXSRV
	''																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAV'																	, ; //X3_ARQUIVO
	'97'																	, ; //X3_ORDEM
	'PAV_INCONS'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Incons. Cont'															, ; //X3_TITULO
	'Incons. Cont'															, ; //X3_TITSPA
	'Account. Inc'															, ; //X3_TITENG
	'Inconsistência na Contab'												, ; //X3_DESCRIC
	'Inconsistencia en Contab'												, ; //X3_DESCSPA
	'Accounting Inconsistency'												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	'Pertence("12")'														, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
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
	'N'																		, ; //X3_IDXSRV
	''																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAV'																	, ; //X3_ARQUIVO
	'98'																	, ; //X3_ORDEM
	'PAV_INCDET'															, ; //X3_CAMPO
	'M'																		, ; //X3_TIPO
	10																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Det. Incons.'															, ; //X3_TITULO
	'Det. Incons.'															, ; //X3_TITSPA
	'Det. Incons.'															, ; //X3_TITENG
	'Detalhes Inconsistencias'												, ; //X3_DESCRIC
	'Detalles inconsistencias'												, ; //X3_DESCSPA
	'Details of Inconsistencie'												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
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
	'N'																		, ; //X3_IDXSRV
	''																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'PAV'																	, ; //X3_ARQUIVO
	'99'																	, ; //X3_ORDEM
	'PAV_PROCES'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	32																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Cod Processo'															, ; //X3_TITULO
	'Cód Proceso'															, ; //X3_TITSPA
	'Process Cd.'															, ; //X3_TITENG
	'Cod processo Contabiliz.'												, ; //X3_DESCRIC
	'Cód proceso Contab.'													, ; //X3_DESCSPA
	'Account. process Code'													, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
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
	'N'																		, ; //X3_IDXSRV
	''																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	'1'																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'2'																		, ; //X3_MODAL
	'S'																		} ) //X3_PYME

//
// Campos Tabela PAW
//
aAdd( aSX3, { ;
	'PAW'																	, ; //X3_ARQUIVO
	'01'																	, ; //X3_ORDEM
	'PAW_FILIAL'															, ; //X3_CAMPO
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
	'PAW'																	, ; //X3_ARQUIVO
	'02'																	, ; //X3_ORDEM
	'PAW_COD'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	2																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Cod. Oper.'															, ; //X3_TITULO
	'Cod. Oper.'															, ; //X3_TITSPA
	'Cod. Oper.'															, ; //X3_TITENG
	'Codigo da Operação'													, ; //X3_DESCRIC
	'Codigo da Operação'													, ; //X3_DESCSPA
	'Codigo da Operação'													, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	'ExistChav( "PAW" ) .And. NaoVazio()'									, ; //X3_VALID
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
	'PAW'																	, ; //X3_ARQUIVO
	'03'																	, ; //X3_ORDEM
	'PAW_DESC'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	20																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Desc.OPerac.'															, ; //X3_TITULO
	'Desc.OPerac.'															, ; //X3_TITSPA
	'Desc.OPerac.'															, ; //X3_TITENG
	'Descrição Operação'													, ; //X3_DESCRIC
	'Descrição Operação'													, ; //X3_DESCSPA
	'Descrição Operação'													, ; //X3_DESCENG
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
	'PAW'																	, ; //X3_ARQUIVO
	'04'																	, ; //X3_ORDEM
	'PAW_USERGA'															, ; //X3_CAMPO
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
	'PAW'																	, ; //X3_ARQUIVO
	'05'																	, ; //X3_ORDEM
	'PAW_USERGI'															, ; //X3_CAMPO
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
	'PAW'																	, ; //X3_ARQUIVO
	'06'																	, ; //X3_ORDEM
	'PAW_MSBLQL'															, ; //X3_CAMPO
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
// Campos Tabela PAZ
//
aAdd( aSX3, { ;
	'PAZ'																	, ; //X3_ARQUIVO
	'01'																	, ; //X3_ORDEM
	'PAZ_FILIAL'															, ; //X3_CAMPO
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
	'PAZ'																	, ; //X3_ARQUIVO
	'02'																	, ; //X3_ORDEM
	'PAZ_ITEM'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Sequencia'																, ; //X3_TITULO
	'Sequencia'																, ; //X3_TITSPA
	'Sequencia'																, ; //X3_TITENG
	'Sequencia'																, ; //X3_DESCRIC
	'Sequencia'																, ; //X3_DESCSPA
	'Sequencia'																, ; //X3_DESCENG
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
	'PAZ'																	, ; //X3_ARQUIVO
	'03'																	, ; //X3_ORDEM
	'PAZ_COD'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	15																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Cod. Produto'															, ; //X3_TITULO
	'Cod. Produto'															, ; //X3_TITSPA
	'Cod. Produto'															, ; //X3_TITENG
	'Codigo do Produto'														, ; //X3_DESCRIC
	'Codigo do Produto'														, ; //X3_DESCSPA
	'Codigo do Produto'														, ; //X3_DESCENG
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
	'PAZ'																	, ; //X3_ARQUIVO
	'04'																	, ; //X3_ORDEM
	'PAZ_CC'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	9																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Centro Custo'															, ; //X3_TITULO
	'Centro Custo'															, ; //X3_TITSPA
	'Centro Custo'															, ; //X3_TITENG
	'Centro Custo'															, ; //X3_DESCRIC
	'Centro Custo'															, ; //X3_DESCSPA
	'Centro Custo'															, ; //X3_DESCENG
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
	'PAZ'																	, ; //X3_ARQUIVO
	'05'																	, ; //X3_ORDEM
	'PAZ_ITEMCT'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	9																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Item Contabi'															, ; //X3_TITULO
	'Item Contabi'															, ; //X3_TITSPA
	'Item Contabi'															, ; //X3_TITENG
	'Item Contabil'															, ; //X3_DESCRIC
	'Item Contabil'															, ; //X3_DESCSPA
	'Item Contabil'															, ; //X3_DESCENG
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
	'PAZ'																	, ; //X3_ARQUIVO
	'06'																	, ; //X3_ORDEM
	'PAZ_FLAG'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Status'																, ; //X3_TITULO
	'Status'																, ; //X3_TITSPA
	'Status'																, ; //X3_TITENG
	'Status  centro custo'													, ; //X3_DESCRIC
	'Status  centro custo'													, ; //X3_DESCSPA
	'Status  centro custo'													, ; //X3_DESCENG
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
	'PAZ'																	, ; //X3_ARQUIVO
	'07'																	, ; //X3_ORDEM
	'PAZ_DATA'																, ; //X3_CAMPO
	'D'																		, ; //X3_TIPO
	8																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Data Proc.'															, ; //X3_TITULO
	'Data Proc.'															, ; //X3_TITSPA
	'Data Proc.'															, ; //X3_TITENG
	'Data Processamento'													, ; //X3_DESCRIC
	'Data Processamento'													, ; //X3_DESCSPA
	'Data Processamento'													, ; //X3_DESCENG
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
	'PAZ'																	, ; //X3_ARQUIVO
	'08'																	, ; //X3_ORDEM
	'PAZ_HORA'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	8																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Hora proc.'															, ; //X3_TITULO
	'Hora proc.'															, ; //X3_TITSPA
	'Hora proc.'															, ; //X3_TITENG
	'Hora processamento'													, ; //X3_DESCRIC
	'Hora processamento'													, ; //X3_DESCSPA
	'Hora processamento'													, ; //X3_DESCENG
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
// Campos Tabela SB1
//
aAdd( aSX3, { ;
	'SB1'																	, ; //X3_ARQUIVO
	'F2'																	, ; //X3_ORDEM
	'B1_XTPCTBA'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Tp.Cta.Custo'															, ; //X3_TITULO
	'Tp.Cta.Custo'															, ; //X3_TITSPA
	'Tp.Cta.Custo'															, ; //X3_TITENG
	'Tipo de Conta Custo'													, ; //X3_DESCRIC
	'Tipo de Conta Custo'													, ; //X3_DESCSPA
	'Tipo de Conta Custo'													, ; //X3_DESCENG
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
	'6=Conta Caixa;7=Conta Depreciação'										, ; //X3_CBOX
	'6=Conta Caixa;7=Conta Depreciação'										, ; //X3_CBOXSPA
	'6=Conta Caixa;7=Conta Depreciação'										, ; //X3_CBOXENG
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
// Campos Tabela SBZ
//
aAdd( aSX3, { ;
	'SBZ'																	, ; //X3_ARQUIVO
	'03'																	, ; //X3_ORDEM
	'BZ_XDESC'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	55																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Desc.Produto'															, ; //X3_TITULO
	'Desc.Produto'															, ; //X3_TITSPA
	'Desc.Produto'															, ; //X3_TITENG
	'Desc.Produto'															, ; //X3_DESCRIC
	'Desc.Produto'															, ; //X3_DESCSPA
	'Desc.Produto'															, ; //X3_DESCENG
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
	'SBZ'																	, ; //X3_ARQUIVO
	'04'																	, ; //X3_ORDEM
	'BZ_XCTACXA'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	20																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Cta.Cxa.Ctb'															, ; //X3_TITULO
	'Cta.Cxa.Ctb'															, ; //X3_TITSPA
	'Cta.Cxa.Ctb'															, ; //X3_TITENG
	'Conta Caixa Contabil'													, ; //X3_DESCRIC
	'Conta Caixa Contabil'													, ; //X3_DESCSPA
	'Conta Caixa Contabil'													, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	'vazio().or. Ctb105Cta()'												, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	'CT1'																	, ; //X3_F3
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
	'003'																	, ; //X3_GRPSXG
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
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SBZ'																	, ; //X3_ARQUIVO
	'05'																	, ; //X3_ORDEM
	'BZ_XCTADPR'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	20																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Cta.Dpr.Ctb'															, ; //X3_TITULO
	'Cta.Dpr.Ctb'															, ; //X3_TITSPA
	'Cta.Dpr.Ctb'															, ; //X3_TITENG
	'Cta Depreciacao Contabil'												, ; //X3_DESCRIC
	'Cta Depreciacao Contabil'												, ; //X3_DESCSPA
	'Cta Depreciacao Contabil'												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	'vazio().or. Ctb105Cta()'												, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	'CT1'																	, ; //X3_F3
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
	'003'																	, ; //X3_GRPSXG
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
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SBZ'																	, ; //X3_ARQUIVO
	'06'																	, ; //X3_ORDEM
	'BZ_XCTADIR'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	20																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Cta.Tran.Cxa'															, ; //X3_TITULO
	'Cta.Tran.Cxa'															, ; //X3_TITSPA
	'Cta.Tran.Cxa'															, ; //X3_TITENG
	'Cta Transitoria Caixa'													, ; //X3_DESCRIC
	'Cta Transitoria Caixa'													, ; //X3_DESCSPA
	'Cta Transitoria Caixa'													, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	'vazio().or. Ctb105Cta()'												, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	'"610201999"'															, ; //X3_RELACAO
	'CT1'																	, ; //X3_F3
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
	'003'																	, ; //X3_GRPSXG
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
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SBZ'																	, ; //X3_ARQUIVO
	'07'																	, ; //X3_ORDEM
	'BZ_XCTAIND'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	20																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Cta.Tran.Dpr'															, ; //X3_TITULO
	'Cta.Tran.Dpr'															, ; //X3_TITSPA
	'Cta.Tran.Dpr'															, ; //X3_TITENG
	'Cta Transitoria Deprec.'												, ; //X3_DESCRIC
	'Cta Transitoria Deprec.'												, ; //X3_DESCSPA
	'Cta Transitoria Deprec.'												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	'vazio().or. Ctb105Cta()'												, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	'"710389999"'															, ; //X3_RELACAO
	'CT1'																	, ; //X3_F3
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
	'003'																	, ; //X3_GRPSXG
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
	'S'																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SBZ'																	, ; //X3_ARQUIVO
	'08'																	, ; //X3_ORDEM
	'BZ_XCPVCXA'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	20																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Cta.Cpv.Cxa'															, ; //X3_TITULO
	'Cta.Cpv.Cxa'															, ; //X3_TITSPA
	'Cta.Cpv.Cxa'															, ; //X3_TITENG
	'Cta Contabil Cpv - Caixa'												, ; //X3_DESCRIC
	'Cta Contabil Cpv - Caixa'												, ; //X3_DESCSPA
	'Cta Contabil Cpv - Caixa'												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	'CT1'																	, ; //X3_F3
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
	'SBZ'																	, ; //X3_ARQUIVO
	'09'																	, ; //X3_ORDEM
	'BZ_XCPVDPR'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	20																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Cta.Cpv.Depr'															, ; //X3_TITULO
	'Cta.Cpv.Depr'															, ; //X3_TITSPA
	'Cta.Cpv.Depr'															, ; //X3_TITENG
	'Cta.Contabil Cpv - Deprec'												, ; //X3_DESCRIC
	'Cta.Contabil Cpv - Deprec'												, ; //X3_DESCSPA
	'Cta.Contabil Cpv - Deprec'												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	'CT1'																	, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
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
	'SBZ'																	, ; //X3_ARQUIVO
	'14'																	, ; //X3_ORDEM
	'BZ_XTRFCXA'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	20																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Cta.Cxa.Orig'															, ; //X3_TITULO
	'Cta.Cxa.Orig'															, ; //X3_TITSPA
	'Cta.Cxa.Orig'															, ; //X3_TITENG
	'Conta Transf.Caixa Origem'												, ; //X3_DESCRIC
	'Conta Transf.Caixa Origem'												, ; //X3_DESCSPA
	'Conta Transf.Caixa Origem'												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	'CT1'																	, ; //X3_F3
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
	'SBZ'																	, ; //X3_ARQUIVO
	'15'																	, ; //X3_ORDEM
	'BZ_XTRFDPR'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	20																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Cta.Dep.Orig'															, ; //X3_TITULO
	'Cta.Dep.Orig'															, ; //X3_TITSPA
	'Cta.Dep.Orig'															, ; //X3_TITENG
	'Cta.Transf.Deprec. Origem'												, ; //X3_DESCRIC
	'Cta.Transf.Deprec. Origem'												, ; //X3_DESCSPA
	'Cta.Transf.Deprec. Origem'												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	'CT1'																	, ; //X3_F3
	0																		, ; //X3_NIVEL
	'xxxxxx x'																, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
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
	'SBZ'																	, ; //X3_ARQUIVO
	'16'																	, ; //X3_ORDEM
	'BZ_XTRDDPR'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	20																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Cta.Dpr.Dest'															, ; //X3_TITULO
	'Cta.Dpr.Dest'															, ; //X3_TITSPA
	'Cta.Dpr.Dest'															, ; //X3_TITENG
	'Cta.Deprec Transf.Destino'												, ; //X3_DESCRIC
	'Cta.Deprec Transf.Destino'												, ; //X3_DESCSPA
	'Cta.Deprec Transf.Destino'												, ; //X3_DESCENG
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
	'SBZ'																	, ; //X3_ARQUIVO
	'17'																	, ; //X3_ORDEM
	'BZ_XTRDCXA'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	20																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Cta.Cxa.Dest'															, ; //X3_TITULO
	'Cta.Cxa.Dest'															, ; //X3_TITSPA
	'Cta.Cxa.Dest'															, ; //X3_TITENG
	'Cta Caixa Transf. Destino'												, ; //X3_DESCRIC
	'Cta Caixa Transf. Destino'												, ; //X3_DESCSPA
	'Cta Caixa Transf. Destino'												, ; //X3_DESCENG
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

//
// Campos Tabela SC2
//
aAdd( aSX3, { ;
	'SC2'																	, ; //X3_ARQUIVO
	'06'																	, ; //X3_ORDEM
	'C2_XDESC'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	55																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Desc.Produto'															, ; //X3_TITULO
	'Desc.Produto'															, ; //X3_TITSPA
	'Desc.Produto'															, ; //X3_TITENG
	'Descricao do Produto'													, ; //X3_DESCRIC
	'Descricao do Produto'													, ; //X3_DESCSPA
	'Descricao do Produto'													, ; //X3_DESCENG
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
	'SC2'																	, ; //X3_ARQUIVO
	'07'																	, ; //X3_ORDEM
	'C2_XALTEMP'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Alt.Empenho'															, ; //X3_TITULO
	'Alt.Empenho'															, ; //X3_TITSPA
	'Alt.Empenho'															, ; //X3_TITENG
	'Permite Alterar Empenho'												, ; //X3_DESCRIC
	'Permite Alterar Empenho'												, ; //X3_DESCSPA
	'Permite Alterar Empenho'												, ; //X3_DESCENG
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
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	'x'																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	'1=Sim;2=Não'															, ; //X3_CBOX
	'1=Sim;2=Não'															, ; //X3_CBOXSPA
	'1=Sim;2=Não'															, ; //X3_CBOXENG
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
	'SC2'																	, ; //X3_ARQUIVO
	'08'																	, ; //X3_ORDEM
	'C2_XCONTA'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	20																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Cta.Contabil'															, ; //X3_TITULO
	'Cta.Contabil'															, ; //X3_TITSPA
	'Cta.Contabil'															, ; //X3_TITENG
	'Conta Contabil Producao'												, ; //X3_DESCRIC
	'Conta Contabil Producao'												, ; //X3_DESCSPA
	'Conta Contabil Producao'												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	'CT1'																	, ; //X3_F3
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
	'S'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	'1'																		, ; //X3_MODAL
	''																		} ) //X3_PYME

//
// Campos Tabela SD3
//
aAdd( aSX3, { ;
	'SD3'																	, ; //X3_ARQUIVO
	'11'																	, ; //X3_ORDEM
	'D3_XOPER'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	2																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Op. Contabil'															, ; //X3_TITULO
	'Op. Contabil'															, ; //X3_TITSPA
	'Op. Contabil'															, ; //X3_TITENG
	'Operacao Contabil'														, ; //X3_DESCRIC
	'Operacao Contabil'														, ; //X3_DESCSPA
	'Operacao Contabil'														, ; //X3_DESCENG
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
	'SD3'																	, ; //X3_ARQUIVO
	'13'																	, ; //X3_ORDEM
	'D3_XCCCUST'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	10																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'C.Custo Cust'															, ; //X3_TITULO
	'C.Custo Cust'															, ; //X3_TITSPA
	'C.Custo Cust'															, ; //X3_TITENG
	'Centro Custo de Custeio'												, ; //X3_DESCRIC
	'Centro Custo de Custeio'												, ; //X3_DESCSPA
	'Centro Custo de Custeio'												, ; //X3_DESCENG
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
	'SD3'																	, ; //X3_ARQUIVO
	'15'																	, ; //X3_ORDEM
	'D3_XVLRCXA'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Vlr.Cxa M01'															, ; //X3_TITULO
	'Vlr.Cxa M01'															, ; //X3_TITSPA
	'Vlr.Cxa M01'															, ; //X3_TITENG
	'Valor Caixa Moeda 01'													, ; //X3_DESCRIC
	'Valor Caixa Moeda 01'													, ; //X3_DESCSPA
	'Valor Caixa Moeda 01'													, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
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
	'SD3'																	, ; //X3_ARQUIVO
	'17'																	, ; //X3_ORDEM
	'D3_XVLRDPR'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Vlr.Depr.M01'															, ; //X3_TITULO
	'Vlr.Depr.M01'															, ; //X3_TITSPA
	'Vlr.Depr.M01'															, ; //X3_TITENG
	'Vlr Depreciação Moeda 01'												, ; //X3_DESCRIC
	'Vlr Depreciação Moeda 01'												, ; //X3_DESCSPA
	'Vlr Depreciação Moeda 01'												, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
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
	'SD3'																	, ; //X3_ARQUIVO
	'19'																	, ; //X3_ORDEM
	'D3_XDLRCXA'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Vlr.Cxa M02'															, ; //X3_TITULO
	'Vlr.Cxa M02'															, ; //X3_TITSPA
	'Vlr.Cxa M02'															, ; //X3_TITENG
	'Valor Caixa Moeda 02'													, ; //X3_DESCRIC
	'Valor Caixa Moeda 02'													, ; //X3_DESCSPA
	'Valor Caixa Moeda 02'													, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
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
	'SD3'																	, ; //X3_ARQUIVO
	'21'																	, ; //X3_ORDEM
	'D3_XDLRDPR'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Vlr.Depr.M02'															, ; //X3_TITULO
	'Vlr.Depr.M02'															, ; //X3_TITSPA
	'Vlr.Depr.M02'															, ; //X3_TITENG
	'Vlr. Depreciação Moeda 02'												, ; //X3_DESCRIC
	'Vlr. Depreciação Moeda 02'												, ; //X3_DESCSPA
	'Vlr. Depreciação Moeda 02'												, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
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
// Campos Tabela SF5
//
aAdd( aSX3, { ;
	'SF5'																	, ; //X3_ARQUIVO
	'20'																	, ; //X3_ORDEM
	'F5_XOPER'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	2																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Oper. Ctb'																, ; //X3_TITULO
	'Oper. Ctb'																, ; //X3_TITSPA
	'Oper. Ctb'																, ; //X3_TITENG
	'Operação Contabil'														, ; //X3_DESCRIC
	'Operação Contabil'														, ; //X3_DESCSPA
	'Operação Contabil'														, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	''																		, ; //X3_RELACAO
	'PAW'																	, ; //X3_F3
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
	'1'																		, ; //X3_FOLDER
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
	'SF5'																	, ; //X3_ARQUIVO
	'21'																	, ; //X3_ORDEM
	'F5_XDESC'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	20																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Desc.Op.Ctb'															, ; //X3_TITULO
	'Desc.Op.Ctb'															, ; //X3_TITSPA
	'Desc.Op.Ctb'															, ; //X3_TITENG
	'Descrição Op Contabil'													, ; //X3_DESCRIC
	'Descrição Op Contabil'													, ; //X3_DESCSPA
	'Descrição Op Contabil'													, ; //X3_DESCENG
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
	'1'																		, ; //X3_FOLDER
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
// Campos Tabela SG1
//
aAdd( aSX3, { ;
	'SG1'																	, ; //X3_ARQUIVO
	'07'																	, ; //X3_ORDEM
	'G1_XPERC'																, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	12																		, ; //X3_TAMANHO
	6																		, ; //X3_DECIMAL
	'% Rateio'																, ; //X3_TITULO
	'% Rateio'																, ; //X3_TITSPA
	'% Rateio'																, ; //X3_TITENG
	'% Rateio para Custeio'													, ; //X3_DESCRIC
	'% Rateio para Custeio'													, ; //X3_DESCSPA
	'% Rateio para Custeio'													, ; //X3_DESCENG
	'@E 99,999.999999'														, ; //X3_PICTURE
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
	'SG1'																	, ; //X3_ARQUIVO
	'08'																	, ; //X3_ORDEM
	'G1_FILDEST'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	2																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Filial Desti'															, ; //X3_TITULO
	'Filial Desti'															, ; //X3_TITSPA
	'Filial Desti'															, ; //X3_TITENG
	'Filial Destino Custeio'												, ; //X3_DESCRIC
	'Filial Destino Custeio'												, ; //X3_DESCSPA
	'Filial Destino Custeio'												, ; //X3_DESCENG
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
	'SG1'																	, ; //X3_ARQUIVO
	'09'																	, ; //X3_ORDEM
	'G1_XALTEMP'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Autoriza Alt'															, ; //X3_TITULO
	'Autoriza Alt'															, ; //X3_TITSPA
	'Autoriza Alt'															, ; //X3_TITENG
	'Autoriza Alterar Empenho'												, ; //X3_DESCRIC
	'Autoriza Alterar Empenho'												, ; //X3_DESCSPA
	'Autoriza Alterar Empenho'												, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x', ; //X3_USADO
	'"2"'																	, ; //X3_RELACAO
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
	'1=Sim;2=Não'															, ; //X3_CBOX
	'1=Sim;2=Não'															, ; //X3_CBOXSPA
	'1=Sim;2=Não'															, ; //X3_CBOXENG
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
@since  04/12/2023
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
// Tabela PAV
//
aAdd( aSIX, { ;
	'PAV'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'PAV_FILIAL+DTOS(PAV_DATA)+PAV_LOTE+PAV_SBLOTE+PAV_DOC+PAV_LINHA+PAV_TPSALD+PAV_EMPORI+PAV_FILORI+PAV_MOEDLC', ; //CHAVE
	'Data Lcto + Numero Lote + Sub Lote + Numero Doc + Numero Linha + Tipo'		, ; //DESCRICAO
	'Fch.Asiento + Numero Lote + Sublote + Numero Doc + Numero Linea + Tipo'	, ; //DESCSPA
	'Entry Date + Lot Number + Sublot + Doc Number + Row Number + Balance T'	, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'PAV'																	, ; //INDICE
	'2'																		, ; //ORDEM
	'PAV_FILIAL+PAV_DEBITO+DTOS(PAV_DATA)'									, ; //CHAVE
	'Cta Debito + Data Lcto'												, ; //DESCRICAO
	'Cta Debito + Fch.Asiento'												, ; //DESCSPA
	'Debit Acct. + Entry Date'												, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'PAV'																	, ; //INDICE
	'3'																		, ; //ORDEM
	'PAV_FILIAL+PAV_CREDIT+DTOS(PAV_DATA)'									, ; //CHAVE
	'Cta Credito + Data Lcto'												, ; //DESCRICAO
	'Cta Credito + Fch.Asiento'												, ; //DESCSPA
	'Credit Acct. + Entry Date'												, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'PAV'																	, ; //INDICE
	'4'																		, ; //ORDEM
	'PAV_FILIAL+PAV_CCD+DTOS(PAV_DATA)'										, ; //CHAVE
	'C Custo Deb + Data Lcto'												, ; //DESCRICAO
	'C Costo Deb + Fch.Asiento'												, ; //DESCSPA
	'Deb Cost Cen + Entry Date'												, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'PAV'																	, ; //INDICE
	'5'																		, ; //ORDEM
	'PAV_FILIAL+PAV_CCC+DTOS(PAV_DATA)'										, ; //CHAVE
	'C Custo Crd + Data Lcto'												, ; //DESCRICAO
	'C Costo Crd + Fch.Asiento'												, ; //DESCSPA
	'Crd Cost Cen + Entry Date'												, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'PAV'																	, ; //INDICE
	'6'																		, ; //ORDEM
	'PAV_FILIAL+PAV_ITEMD+DTOS(PAV_DATA)'									, ; //CHAVE
	'Item Debito + Data Lcto'												, ; //DESCRICAO
	'Item Debito + Fch.Asiento'												, ; //DESCSPA
	'Debit Item + Entry Date'												, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'PAV'																	, ; //INDICE
	'7'																		, ; //ORDEM
	'PAV_FILIAL+PAV_ITEMC+DTOS(PAV_DATA)'									, ; //CHAVE
	'Item Credito + Data Lcto'												, ; //DESCRICAO
	'Item Credito + Fch.Asiento'											, ; //DESCSPA
	'Credit Item + Entry Date'												, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'PAV'																	, ; //INDICE
	'8'																		, ; //ORDEM
	'PAV_FILIAL+PAV_CLVLDB+DTOS(PAV_DATA)'									, ; //CHAVE
	'Cl Vlr Deb + Data Lcto'												, ; //DESCRICAO
	'Cl Vlr Deb + Fch.Asiento'												, ; //DESCSPA
	'Deb Vl Categ + Entry Date'												, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'PAV'																	, ; //INDICE
	'9'																		, ; //ORDEM
	'PAV_FILIAL+PAV_CLVLCR+DTOS(PAV_DATA)'									, ; //CHAVE
	'Cl Vlr Cred + Data Lcto'												, ; //DESCRICAO
	'Cl Vlr Cred + Fch.Asiento'												, ; //DESCSPA
	'Crd Vl Categ + Entry Date'												, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'PAV'																	, ; //INDICE
	'A'																		, ; //ORDEM
	'PAV_FILIAL+DTOS(PAV_DATA)+PAV_LOTE+PAV_SBLOTE+PAV_DOC+PAV_SEQLAN+PAV_EMPORI+PAV_FILORI+PAV_MOEDLC+PAV_SEQHIS', ; //CHAVE
	'Data Lcto + Numero Lote + Sub Lote + Numero Doc + Seq Auxiliar + Empre'	, ; //DESCRICAO
	'Fch.Asiento + Numero Lote + Sublote + Numero Doc + Sec Auxiliar + Empr'	, ; //DESCSPA
	'Entry Date + Lot Number + Sublot + Doc Number + Auxil.Seq. + Orig.Comp'	, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'PAV'																	, ; //INDICE
	'B'																		, ; //ORDEM
	'PAV_FILIAL+DTOS(PAV_DATA)+PAV_LOTE+PAV_SBLOTE+PAV_DOC+PAV_SEQLAN+PAV_MOEDLC+PAV_SEQHIS+PAV_EMPORI+PAV_FILORI', ; //CHAVE
	'Data Lcto + Numero Lote + Sub Lote + Numero Doc + Seq Auxiliar + Moeda'	, ; //DESCRICAO
	'Fch.Asiento + Numero Lote + Sublote + Numero Doc + Sec Auxiliar + Mone'	, ; //DESCSPA
	'Entry Date + Lot Number + Sublot + Doc Number + Auxil.Seq. + Entry Cur'	, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'PAV'																	, ; //INDICE
	'C'																		, ; //ORDEM
	'PAV_FILIAL+PAV_SEGOFI+PAV_SBLOTE+DTOS(PAV_DATA)'						, ; //CHAVE
	'Correlativo + Sub Lote + Data Lcto'									, ; //DESCRICAO
	'Correlativo + Sublote + Fch.Asiento'									, ; //DESCSPA
	'Correlative + Sublot + Entry Date'										, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'PAV'																	, ; //INDICE
	'D'																		, ; //ORDEM
	'PAV_FILIAL+PAV_ORIGEM'													, ; //CHAVE
	'Origem'																, ; //DESCRICAO
	'Origen'																, ; //DESCSPA
	'Source'																, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'PAV'																	, ; //INDICE
	'E'																		, ; //ORDEM
	'PAV_FILIAL+PAV_NODIA+DTOS(PAV_DATA)+PAV_LOTE+PAV_SBLOTE+PAV_DOC+PAV_LINHA+PAV_EMPORI+PAV_FILORI+PAV_MOEDLC+PAV_SEQIDX', ; //CHAVE
	'Nro Diario + Data Lcto + Numero Lote + Sub Lote + Numero Doc + Numero'		, ; //DESCRICAO
	'Nº Diario + Fch.Asiento + Numero Lote + Sublote + Numero Doc + Numero'		, ; //DESCSPA
	'T.Rec.No. + Entry Date + Lot Number + Sublot + Doc Number + Row Number'	, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'PAV'																	, ; //INDICE
	'F'																		, ; //ORDEM
	'PAV_FILIAL+PAV_DIACTB+PAV_NODIA'										, ; //CHAVE
	'Cod. Diario + Nro Diario'												, ; //DESCRICAO
	'Cod. Diario + Nº Diario'												, ; //DESCSPA
	'Journal Code + T.Rec.No.'												, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'PAV'																	, ; //INDICE
	'G'																		, ; //ORDEM
	'PAV_FILIAL+PAV_NODIA+PAV_MLTSLD'										, ; //CHAVE
	'Nro Diario + Tps Saldos'												, ; //DESCRICAO
	'Nº Diario + Tps Saldos'												, ; //DESCSPA
	'T.Rec.No. + Balance Tps.'												, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'PAV'																	, ; //INDICE
	'I'																		, ; //ORDEM
	'PAV_FILIAL+PAV_PROCES'													, ; //CHAVE
	'Cod Processo'															, ; //DESCRICAO
	'Cód Proceso'															, ; //DESCSPA
	'Process Cd.'															, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

//
// Tabela PAW
//
aAdd( aSIX, { ;
	'PAW'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'PAW_FILIAL+PAW_COD'													, ; //CHAVE
	'Cod. Oper.'															, ; //DESCRICAO
	'Cod. Oper.'															, ; //DESCSPA
	'Cod. Oper.'															, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	'PAW001'																, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

//
// Tabela PAZ
//
aAdd( aSIX, { ;
	'PAZ'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'PAZ_FILIAL+PAZ_COD+PAZ_CC+PAZ_ITEMCT'									, ; //CHAVE
	'Cod. Produto+Centro Custo+Item Contabi'								, ; //DESCRICAO
	'Cod. Produto+Centro Custo+Item Contabi'								, ; //DESCSPA
	'Cod. Produto+Centro Custo+Item Contabi'								, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'N'																		} ) //SHOWPESQ

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
@since  04/12/2023
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
	'OZ_ARMAZEN'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Armazen Utilizado rotina OZ04M03.prw'									, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'10'																	, ; //X6_CONTEUD
	'10'																	, ; //X6_CONTSPA
	'10'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'01'																	, ; //X6_FIL
	'OZ_CHNQRY'																, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Centralizada para Gravação e Tratamento QUERY'							, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.T.'																	, ; //X6_CONTEUD
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
	'OZ_CONQRY'																, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Centralizada para Gravação e Tratamento QUERY'							, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.T.'																	, ; //X6_CONTEUD
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
	'OZ_DELIMIT'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Delimitador Utilizado na rotina OZ04M02.prw'							, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	';'																		, ; //X6_CONTEUD
	';'																		, ; //X6_CONTSPA
	';'																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'01'																	, ; //X6_FIL
	'OZ_DETLOGS'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Apresenta a Mensagem detalhe do LOG'									, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.F.'																	, ; //X6_CONTSPA
	'.F.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'01'																	, ; //X6_FIL
	'OZ_LOGS'																, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Apresenta a Mensagem no Console do Protheus'							, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.F.'																	, ; //X6_CONTSPA
	'.F.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'01'																	, ; //X6_FIL
	'OZ_LOTECTB'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'lote que será realizado o back-up tabela PAV'							, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'008840'																, ; //X6_CONTEUD
	'008840'																, ; //X6_CONTSPA
	'008840'																, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'01'																	, ; //X6_FIL
	'OZ_MA330CP'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita uso ponto de entrada MA330CP'									, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.F.'																	, ; //X6_CONTSPA
	'.F.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'01'																	, ; //X6_FIL
	'OZ_MA330FI'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita uso ponto de entrada MA330FIM'								, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.F.'																	, ; //X6_CONTSPA
	'.F.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'01'																	, ; //X6_FIL
	'OZ_MA330MO'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita uso ponto de entrada MA330MOD'								, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.F.'																	, ; //X6_CONTSPA
	'.F.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'01'																	, ; //X6_FIL
	'OZ_MA330OK'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita uso ponto de entrada MA330OK'									, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.F.'																	, ; //X6_CONTSPA
	'.F.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'01'																	, ; //X6_FIL
	'OZ_MA330PG'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita uso ponto de entrada MA330PGI'								, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.F.'																	, ; //X6_CONTSPA
	'.F.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'01'																	, ; //X6_FIL
	'OZ_MA650MN'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita uso ponto de entrada MA650MNU'								, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.F.'																	, ; //X6_CONTSPA
	'.F.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'01'																	, ; //X6_FIL
	'OZ_MT250MN'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita uso ponto de entrada MT250MNU'								, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.F.'																	, ; //X6_CONTSPA
	'.F.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'01'																	, ; //X6_FIL
	'OZ_MT261TD'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita uso ponto de entrada MT261TDOK'								, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.F.'																	, ; //X6_CONTSPA
	'.F.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'01'																	, ; //X6_FIL
	'OZ_PRODTP'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Lista tipo de produto CX/DP - MA330MOD'								, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'CX/DP'																	, ; //X6_CONTEUD
	'CX/DP'																	, ; //X6_CONTSPA
	'CX/DP'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'01'																	, ; //X6_FIL
	'OZ_RLMOD03'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Salvar os Dados do Cadastro usando MVC'								, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.T.'																	, ; //X6_CONTEUD
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
	'OZ_SAVQRY'																, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Centralizada para Gravação e Tratamento QUERY'							, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.T.'																	, ; //X6_CONTEUD
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
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.F.'																	, ; //X6_CONTSPA
	'.F.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'01'																	, ; //X6_FIL
	'OZ_SD3250I'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita uso ponto de entrada SD3250I'									, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.F.'																	, ; //X6_CONTSPA
	'.F.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'01'																	, ; //X6_FIL
	'OZ_TIPOCF'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Codigos CF que não serão utilizados'									, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'RE3/DE3/RE5/DE5/RE7/DE7/RE8/DE8'										, ; //X6_CONTEUD
	'RE3/DE3/RE5/DE5/RE7/DE7/RE8/DE8'										, ; //X6_CONTSPA
	'RE3/DE3/RE5/DE5/RE7/DE7/RE8/DE8'										, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'01'																	, ; //X6_FIL
	'OZ_TMENTRA'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Tipo de Movimentação de entrada OZ04M02.prw'							, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
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
	'OZ_TMSAIDA'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Tipo de Movimentação de entrada OZ04M02.prw'							, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'510'																	, ; //X6_CONTEUD
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
	'OZ_ARMAZEN'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Armazen Utilizado rotina OZ04M03.prw'									, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'10'																	, ; //X6_CONTEUD
	'10'																	, ; //X6_CONTSPA
	'10'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'02'																	, ; //X6_FIL
	'OZ_CHNQRY'																, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Centralizada para Gravação e Tratamento QUERY'							, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.T.'																	, ; //X6_CONTEUD
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
	'OZ_CONQRY'																, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Centralizada para Gravação e Tratamento QUERY'							, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.T.'																	, ; //X6_CONTEUD
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
	'OZ_DELIMIT'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Delimitador Utilizado na rotina OZ04M02.prw'							, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	';'																		, ; //X6_CONTEUD
	';'																		, ; //X6_CONTSPA
	';'																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'02'																	, ; //X6_FIL
	'OZ_DETLOGS'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Apresenta a Mensagem detalhe do LOG'									, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.F.'																	, ; //X6_CONTSPA
	'.F.'																	, ; //X6_CONTENG
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
	'Filial Permitida na Rotina OZ04M04.prw'								, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'02/06'																	, ; //X6_CONTEUD
	'02/06'																	, ; //X6_CONTSPA
	'02/06'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'02'																	, ; //X6_FIL
	'OZ_LOGS'																, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Apresenta a Mensagem no Console do Protheus'							, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.F.'																	, ; //X6_CONTSPA
	'.F.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'02'																	, ; //X6_FIL
	'OZ_LOTECTB'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'lote que será realizado o back-up tabela PAV'							, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'008840'																, ; //X6_CONTEUD
	'008840'																, ; //X6_CONTSPA
	'008840'																, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'02'																	, ; //X6_FIL
	'OZ_MA330CP'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita uso ponto de entrada MA330CP'									, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.T.'																	, ; //X6_CONTEUD
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
	'OZ_MA330FI'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita uso ponto de entrada MA330FIM'								, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.T.'																	, ; //X6_CONTEUD
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
	'OZ_MA330MO'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita uso ponto de entrada MA330MOD'								, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.T.'																	, ; //X6_CONTEUD
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
	'OZ_MA330OK'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita uso ponto de entrada MA330OK'									, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.T.'																	, ; //X6_CONTEUD
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
	'OZ_MA330PG'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita uso ponto de entrada MA330PGI'								, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.T.'																	, ; //X6_CONTEUD
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
	'OZ_MA650EM'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita uso ponto de entrada MA650EMP'								, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.F.'																	, ; //X6_CONTSPA
	'.F.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'02'																	, ; //X6_FIL
	'OZ_MA650MN'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita uso ponto de entrada MA650MNU'								, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.T.'																	, ; //X6_CONTEUD
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
	'OZ_MOVDEST'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Tipo Movimento Destino da Transferencia'								, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'188'																	, ; //X6_CONTEUD
	'188'																	, ; //X6_CONTSPA
	'188'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'02'																	, ; //X6_FIL
	'OZ_MOVORIG'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Tipo Movimento Origem da Transferencia'								, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'588'																	, ; //X6_CONTEUD
	'588'																	, ; //X6_CONTSPA
	'588'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'02'																	, ; //X6_FIL
	'OZ_MT241D3'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita uso ponto de entrada MT241SD3'								, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.T.'																	, ; //X6_CONTEUD
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
	'OZ_MT241ES'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita uso ponto de entrada MT241EST'								, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.T.'																	, ; //X6_CONTEUD
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
	'OZ_MT250MN'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita uso ponto de entrada MT250MNU'								, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.T.'																	, ; //X6_CONTEUD
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
	'OZ_MT261TD'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita uso ponto de entrada MT261TDOK'								, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.T.'																	, ; //X6_CONTEUD
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
	'OZ_PRODTP'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Lista tipo de produto CX/DP - MA330MOD'								, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'CX/DP'																	, ; //X6_CONTEUD
	'CX/DP'																	, ; //X6_CONTSPA
	'CX/DP'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'02'																	, ; //X6_FIL
	'OZ_RLMOD03'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Salvar os Dados do Cadastro usando MVC'								, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.T.'																	, ; //X6_CONTEUD
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
	'OZ_SAVQRY'																, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Centralizada para Gravação e Tratamento QUERY'							, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.T.'																	, ; //X6_CONTEUD
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
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.T.'																	, ; //X6_CONTEUD
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
	'OZ_SD3250I'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita uso ponto de entrada SD3250I'									, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.T.'																	, ; //X6_CONTEUD
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
	'OZ_TIPOCF'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Codigos CF que não serão utilizados'									, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'RE3/DE3/RE5/DE5/RE7/DE7/RE8/DE8'										, ; //X6_CONTEUD
	'RE3/DE3/RE5/DE5/RE7/DE7/RE8/DE8'										, ; //X6_CONTSPA
	'RE3/DE3/RE5/DE5/RE7/DE7/RE8/DE8'										, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'02'																	, ; //X6_FIL
	'OZ_TMENTRA'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Tipo de Movimentação de entrada OZ04M02.prw'							, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
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
	'OZ_TMSAIDA'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Tipo de Movimentação de entrada OZ04M02.prw'							, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'510'																	, ; //X6_CONTEUD
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
	'OZ_TPMVTM'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Tipo Movimento para Ajustar Custo'										, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'188/588'																, ; //X6_CONTEUD
	'188/588'																, ; //X6_CONTSPA
	'188/588'																, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'03'																	, ; //X6_FIL
	'OZ_ARMAZEN'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Armazen Utilizado rotina OZ04M03.prw'									, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'10'																	, ; //X6_CONTEUD
	'10'																	, ; //X6_CONTSPA
	'10'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'03'																	, ; //X6_FIL
	'OZ_CHNQRY'																, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Centralizada para Gravação e Tratamento QUERY'							, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.T.'																	, ; //X6_CONTEUD
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
	'OZ_CONQRY'																, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Centralizada para Gravação e Tratamento QUERY'							, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.T.'																	, ; //X6_CONTEUD
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
	'OZ_DELIMIT'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Delimitador Utilizado na rotina OZ04M02.prw'							, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	';'																		, ; //X6_CONTEUD
	';'																		, ; //X6_CONTSPA
	';'																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'03'																	, ; //X6_FIL
	'OZ_DETLOGS'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Apresenta a Mensagem detalhe do LOG'									, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.F.'																	, ; //X6_CONTSPA
	'.F.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'03'																	, ; //X6_FIL
	'OZ_LOGS'																, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Apresenta a Mensagem no Console do Protheus'							, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.F.'																	, ; //X6_CONTSPA
	'.F.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'03'																	, ; //X6_FIL
	'OZ_LOTECTB'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'lote que será realizado o back-up tabela PAV'							, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'008840'																, ; //X6_CONTEUD
	'008840'																, ; //X6_CONTSPA
	'008840'																, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'03'																	, ; //X6_FIL
	'OZ_MA330CP'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita uso ponto de entrada MA330CP'									, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
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
	'OZ_MA330FI'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita uso ponto de entrada MA330FIM'								, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.F.'																	, ; //X6_CONTSPA
	'.F.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'03'																	, ; //X6_FIL
	'OZ_MA330MO'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita uso ponto de entrada MA330MOD'								, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
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
	'OZ_MA330OK'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita uso ponto de entrada MA330OK'									, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
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
	'OZ_MA330PG'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita uso ponto de entrada MA330PGI'								, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
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
	'OZ_MA650EM'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita uso ponto de entrada MA650EMP'								, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.F.'																	, ; //X6_CONTSPA
	'.F.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'03'																	, ; //X6_FIL
	'OZ_MA650MN'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita uso ponto de entrada MA650MNU'								, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
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
	'OZ_MT241D3'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita uso ponto de entrada MT241SD3'								, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.F.'																	, ; //X6_CONTSPA
	'.F.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'03'																	, ; //X6_FIL
	'OZ_MT241ES'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita uso ponto de entrada MT241EST'								, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.F.'																	, ; //X6_CONTSPA
	'.F.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'03'																	, ; //X6_FIL
	'OZ_MT250MN'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita uso ponto de entrada MT250MNU'								, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
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
	'OZ_MT261TD'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita uso ponto de entrada MT261TDOK'								, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.F.'																	, ; //X6_CONTSPA
	'.F.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'03'																	, ; //X6_FIL
	'OZ_PRODTP'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Lista tipo de produto CX/DP - MA330MOD'								, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'CX/DP'																	, ; //X6_CONTEUD
	'CX/DP'																	, ; //X6_CONTSPA
	'CX/DP'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'03'																	, ; //X6_FIL
	'OZ_RLMOD03'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Salvar os Dados do Cadastro usando MVC'								, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.T.'																	, ; //X6_CONTEUD
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
	'OZ_SAVQRY'																, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Centralizada para Gravação e Tratamento QUERY'							, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.T.'																	, ; //X6_CONTEUD
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
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.F.'																	, ; //X6_CONTSPA
	'.F.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'03'																	, ; //X6_FIL
	'OZ_SD3250I'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita uso ponto de entrada SD3250I'									, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
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
	'OZ_TIPOCF'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Codigos CF que não serão utilizados'									, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'RE3/DE3/RE5/DE5/RE7/DE7/RE8/DE8'										, ; //X6_CONTEUD
	'RE3/DE3/RE5/DE5/RE7/DE7/RE8/DE8'										, ; //X6_CONTSPA
	'RE3/DE3/RE5/DE5/RE7/DE7/RE8/DE8'										, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'03'																	, ; //X6_FIL
	'OZ_TMENTRA'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Tipo de Movimentação de entrada OZ04M02.prw'							, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
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
	'OZ_TMSAIDA'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Tipo de Movimentação de entrada OZ04M02.prw'							, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'510'																	, ; //X6_CONTEUD
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
	'OZ_ARMAZEN'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Armazen Utilizado rotina OZ04M03.prw'									, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'10'																	, ; //X6_CONTEUD
	'10'																	, ; //X6_CONTSPA
	'10'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'05'																	, ; //X6_FIL
	'OZ_CHNQRY'																, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Centralizada para Gravação e Tratamento QUERY'							, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.T.'																	, ; //X6_CONTEUD
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
	'OZ_CONQRY'																, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Centralizada para Gravação e Tratamento QUERY'							, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.T.'																	, ; //X6_CONTEUD
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
	'OZ_DELIMIT'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Delimitador Utilizado na rotina OZ04M02.prw'							, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	';'																		, ; //X6_CONTEUD
	';'																		, ; //X6_CONTSPA
	';'																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'05'																	, ; //X6_FIL
	'OZ_DETLOGS'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Apresenta a Mensagem detalhe do LOG'									, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.F.'																	, ; //X6_CONTSPA
	'.F.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'05'																	, ; //X6_FIL
	'OZ_LOGS'																, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Apresenta a Mensagem no Console do Protheus'							, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.F.'																	, ; //X6_CONTSPA
	'.F.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'05'																	, ; //X6_FIL
	'OZ_LOTECTB'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'lote que será realizado o back-up tabela PAV'							, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'008840'																, ; //X6_CONTEUD
	'008840'																, ; //X6_CONTSPA
	'008840'																, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'05'																	, ; //X6_FIL
	'OZ_MA330CP'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita uso ponto de entrada MA330CP'									, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.F.'																	, ; //X6_CONTSPA
	'.F.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'05'																	, ; //X6_FIL
	'OZ_MA330FI'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita uso ponto de entrada MA330FIM'								, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.F.'																	, ; //X6_CONTSPA
	'.F.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'05'																	, ; //X6_FIL
	'OZ_MA330MO'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita uso ponto de entrada MA330MOD'								, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.F.'																	, ; //X6_CONTSPA
	'.F.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'05'																	, ; //X6_FIL
	'OZ_MA330OK'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita uso ponto de entrada MA330OK'									, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.F.'																	, ; //X6_CONTSPA
	'.F.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'05'																	, ; //X6_FIL
	'OZ_MA330PG'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita uso ponto de entrada MA330PGI'								, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.F.'																	, ; //X6_CONTSPA
	'.F.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'05'																	, ; //X6_FIL
	'OZ_MA650EM'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita uso ponto de entrada MA650EMP'								, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.F.'																	, ; //X6_CONTSPA
	'.F.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'05'																	, ; //X6_FIL
	'OZ_MA650MN'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita uso ponto de entrada MA650MNU'								, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.F.'																	, ; //X6_CONTSPA
	'.F.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'05'																	, ; //X6_FIL
	'OZ_MT241D3'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita uso ponto de entrada MT241SD3'								, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.F.'																	, ; //X6_CONTSPA
	'.F.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'05'																	, ; //X6_FIL
	'OZ_MT241ES'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita uso ponto de entrada MT241EST'								, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.F.'																	, ; //X6_CONTSPA
	'.F.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'05'																	, ; //X6_FIL
	'OZ_MT250MN'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita uso ponto de entrada MT250MNU'								, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.F.'																	, ; //X6_CONTSPA
	'.F.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'05'																	, ; //X6_FIL
	'OZ_MT261TD'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita uso ponto de entrada MT261TDOK'								, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.F.'																	, ; //X6_CONTSPA
	'.F.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'05'																	, ; //X6_FIL
	'OZ_PRODTP'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Lista tipo de produto CX/DP - MA330MOD'								, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'CX/DP'																	, ; //X6_CONTEUD
	'CX/DP'																	, ; //X6_CONTSPA
	'CX/DP'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'05'																	, ; //X6_FIL
	'OZ_RLMOD03'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Salvar os Dados do Cadastro usando MVC'								, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.T.'																	, ; //X6_CONTEUD
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
	'OZ_SAVQRY'																, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Centralizada para Gravação e Tratamento QUERY'							, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.T.'																	, ; //X6_CONTEUD
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
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.F.'																	, ; //X6_CONTSPA
	'.F.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'05'																	, ; //X6_FIL
	'OZ_SD3250I'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita uso ponto de entrada SD3250I'									, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.F.'																	, ; //X6_CONTSPA
	'.F.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'05'																	, ; //X6_FIL
	'OZ_TIPOCF'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Codigos CF que não serão utilizados'									, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'RE3/DE3/RE5/DE5/RE7/DE7/RE8/DE8'										, ; //X6_CONTEUD
	'RE3/DE3/RE5/DE5/RE7/DE7/RE8/DE8'										, ; //X6_CONTSPA
	'RE3/DE3/RE5/DE5/RE7/DE7/RE8/DE8'										, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'05'																	, ; //X6_FIL
	'OZ_TMENTRA'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Tipo de Movimentação de entrada OZ04M02.prw'							, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
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
	'OZ_TMSAIDA'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Tipo de Movimentação de entrada OZ04M02.prw'							, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'510'																	, ; //X6_CONTEUD
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
	'OZ_ARMAZEN'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Armazen Utilizado rotina OZ04M03.prw'									, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'10'																	, ; //X6_CONTEUD
	'10'																	, ; //X6_CONTSPA
	'10'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'06'																	, ; //X6_FIL
	'OZ_CHNQRY'																, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Centralizada para Gravação e Tratamento QUERY'							, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.T.'																	, ; //X6_CONTEUD
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
	'OZ_CONQRY'																, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Centralizada para Gravação e Tratamento QUERY'							, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.T.'																	, ; //X6_CONTEUD
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
	'OZ_DELIMIT'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Delimitador Utilizado na rotina OZ04M02.prw'							, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	';'																		, ; //X6_CONTEUD
	';'																		, ; //X6_CONTSPA
	';'																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'06'																	, ; //X6_FIL
	'OZ_DETLOGS'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Apresenta a Mensagem detalhe do LOG'									, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.F.'																	, ; //X6_CONTSPA
	'.F.'																	, ; //X6_CONTENG
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
	'Filial Permitida na Rotina OZ04M04.prw'								, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'02/06'																	, ; //X6_CONTEUD
	'02/06'																	, ; //X6_CONTSPA
	'02/06'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'06'																	, ; //X6_FIL
	'OZ_LOGS'																, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Apresenta a Mensagem no Console do Protheus'							, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.F.'																	, ; //X6_CONTSPA
	'.F.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'06'																	, ; //X6_FIL
	'OZ_LOTECTB'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'lote que será realizado o back-up tabela PAV'							, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'008840'																, ; //X6_CONTEUD
	'008840'																, ; //X6_CONTSPA
	'008840'																, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'06'																	, ; //X6_FIL
	'OZ_MA330CP'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita uso ponto de entrada MA330CP'									, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.T.'																	, ; //X6_CONTEUD
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
	'OZ_MA330FI'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita uso ponto de entrada MA330FIM'								, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.T.'																	, ; //X6_CONTEUD
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
	'OZ_MA330MO'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita uso ponto de entrada MA330MOD'								, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.T.'																	, ; //X6_CONTEUD
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
	'OZ_MA330OK'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita uso ponto de entrada MA330OK'									, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.T.'																	, ; //X6_CONTEUD
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
	'OZ_MA330PG'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita uso ponto de entrada MA330PGI'								, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.T.'																	, ; //X6_CONTEUD
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
	'OZ_MA650EM'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita uso ponto de entrada MA650EMP'								, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.F.'																	, ; //X6_CONTSPA
	'.F.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'06'																	, ; //X6_FIL
	'OZ_MA650MN'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita uso ponto de entrada MA650MNU'								, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.T.'																	, ; //X6_CONTEUD
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
	'OZ_MOVDEST'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Tipo Movimento Destino da Transferencia'								, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'188'																	, ; //X6_CONTEUD
	'188'																	, ; //X6_CONTSPA
	'188'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'06'																	, ; //X6_FIL
	'OZ_MOVORIG'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Tipo Movimento Origem da Transferencia'								, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'588'																	, ; //X6_CONTEUD
	'588'																	, ; //X6_CONTSPA
	'588'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'06'																	, ; //X6_FIL
	'OZ_MT241D3'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita uso ponto de entrada MT241SD3'								, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.T.'																	, ; //X6_CONTEUD
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
	'OZ_MT241ES'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita uso ponto de entrada MT241EST'								, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.T.'																	, ; //X6_CONTEUD
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
	'OZ_MT250MN'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita uso ponto de entrada MT250MNU'								, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.T.'																	, ; //X6_CONTEUD
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
	'OZ_MT261TD'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita uso ponto de entrada MT261TDOK'								, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.T.'																	, ; //X6_CONTEUD
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
	'OZ_PRODTP'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Lista tipo de produto CX/DP - MA330MOD'								, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'CX/DP'																	, ; //X6_CONTEUD
	'CX/DP'																	, ; //X6_CONTSPA
	'CX/DP'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'06'																	, ; //X6_FIL
	'OZ_RLMOD03'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Salvar os Dados do Cadastro usando MVC'								, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.T.'																	, ; //X6_CONTEUD
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
	'OZ_SAVQRY'																, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Centralizada para Gravação e Tratamento QUERY'							, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.T.'																	, ; //X6_CONTEUD
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
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.T.'																	, ; //X6_CONTEUD
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
	'OZ_SD3250I'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita uso ponto de entrada SD3250I'									, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.T.'																	, ; //X6_CONTEUD
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
	'OZ_TIPOCF'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Codigos CF que não serão utilizados'									, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'RE3/DE3/RE5/DE5/RE7/DE7/RE8/DE8'										, ; //X6_CONTEUD
	'RE3/DE3/RE5/DE5/RE7/DE7/RE8/DE8'										, ; //X6_CONTSPA
	'RE3/DE3/RE5/DE5/RE7/DE7/RE8/DE8'										, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'06'																	, ; //X6_FIL
	'OZ_TMENTRA'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Tipo de Movimentação de entrada OZ04M02.prw'							, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
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
	'OZ_TMSAIDA'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Tipo de Movimentação de entrada OZ04M02.prw'							, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'510'																	, ; //X6_CONTEUD
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
	'OZ_TPMVTM'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Tipo Movimento para Ajustar Custo'										, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'188/588'																, ; //X6_CONTEUD
	'188/588'																, ; //X6_CONTSPA
	'188/588'																, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'07'																	, ; //X6_FIL
	'OZ_ARMAZEN'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Armazen Utilizado rotina OZ04M03.prw'									, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'10'																	, ; //X6_CONTEUD
	'10'																	, ; //X6_CONTSPA
	'10'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'07'																	, ; //X6_FIL
	'OZ_CHNQRY'																, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Centralizada para Gravação e Tratamento QUERY'							, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.T.'																	, ; //X6_CONTEUD
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
	'OZ_CONQRY'																, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Centralizada para Gravação e Tratamento QUERY'							, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.T.'																	, ; //X6_CONTEUD
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
	'OZ_DELIMIT'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Delimitador Utilizado na rotina OZ04M02.prw'							, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	';'																		, ; //X6_CONTEUD
	';'																		, ; //X6_CONTSPA
	';'																		, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'07'																	, ; //X6_FIL
	'OZ_DETLOGS'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Apresenta a Mensagem detalhe do LOG'									, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.F.'																	, ; //X6_CONTSPA
	'.F.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'07'																	, ; //X6_FIL
	'OZ_LOGS'																, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Apresenta a Mensagem no Console do Protheus'							, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.F.'																	, ; //X6_CONTSPA
	'.F.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'07'																	, ; //X6_FIL
	'OZ_LOTECTB'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'lote que será realizado o back-up tabela PAV'							, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'008840'																, ; //X6_CONTEUD
	'008840'																, ; //X6_CONTSPA
	'008840'																, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'07'																	, ; //X6_FIL
	'OZ_MA330CP'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita uso ponto de entrada MA330CP'									, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.F.'																	, ; //X6_CONTSPA
	'.F.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'07'																	, ; //X6_FIL
	'OZ_MA330FI'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita uso ponto de entrada MA330FIM'								, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.F.'																	, ; //X6_CONTSPA
	'.F.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'07'																	, ; //X6_FIL
	'OZ_MA330MO'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita uso ponto de entrada MA330MOD'								, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.F.'																	, ; //X6_CONTSPA
	'.F.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'07'																	, ; //X6_FIL
	'OZ_MA330OK'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita uso ponto de entrada MA330OK'									, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.F.'																	, ; //X6_CONTSPA
	'.F.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'07'																	, ; //X6_FIL
	'OZ_MA330PG'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita uso ponto de entrada MA330PGI'								, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.F.'																	, ; //X6_CONTSPA
	'.F.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'07'																	, ; //X6_FIL
	'OZ_MA650EM'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita uso ponto de entrada MA650EMP'								, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.F.'																	, ; //X6_CONTSPA
	'.F.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'07'																	, ; //X6_FIL
	'OZ_MA650MN'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita uso ponto de entrada MA650MNU'								, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.F.'																	, ; //X6_CONTSPA
	'.F.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'07'																	, ; //X6_FIL
	'OZ_MT241D3'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita uso ponto de entrada MT241SD3'								, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.F.'																	, ; //X6_CONTSPA
	'.F.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'07'																	, ; //X6_FIL
	'OZ_MT241ES'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita uso ponto de entrada MT241EST'								, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.F.'																	, ; //X6_CONTSPA
	'.F.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'07'																	, ; //X6_FIL
	'OZ_MT250MN'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita uso ponto de entrada MT250MNU'								, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.F.'																	, ; //X6_CONTSPA
	'.F.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'07'																	, ; //X6_FIL
	'OZ_MT261TD'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita uso ponto de entrada MT261TDOK'								, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.F.'																	, ; //X6_CONTSPA
	'.F.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'07'																	, ; //X6_FIL
	'OZ_PRODTP'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Lista tipo de produto CX/DP - MA330MOD'								, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'CX/DP'																	, ; //X6_CONTEUD
	'CX/DP'																	, ; //X6_CONTSPA
	'CX/DP'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'07'																	, ; //X6_FIL
	'OZ_RLMOD03'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Salvar os Dados do Cadastro usando MVC'								, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.T.'																	, ; //X6_CONTEUD
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
	'OZ_SAVQRY'																, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Centralizada para Gravação e Tratamento QUERY'							, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.T.'																	, ; //X6_CONTEUD
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
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.F.'																	, ; //X6_CONTSPA
	'.F.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'07'																	, ; //X6_FIL
	'OZ_SD3250I'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Habilita uso ponto de entrada SD3250I'									, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.F.'																	, ; //X6_CONTSPA
	'.F.'																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'07'																	, ; //X6_FIL
	'OZ_TIPOCF'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Codigos CF que não serão utilizados'									, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'RE3/DE3/RE5/DE5/RE7/DE7/RE8/DE8'										, ; //X6_CONTEUD
	'RE3/DE3/RE5/DE5/RE7/DE7/RE8/DE8'										, ; //X6_CONTSPA
	'RE3/DE3/RE5/DE5/RE7/DE7/RE8/DE8'										, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		, ; //X6_VALID
	''																		, ; //X6_INIT
	''																		, ; //X6_DEFPOR
	''																		, ; //X6_DEFSPA
	''																		, ; //X6_DEFENG
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	'07'																	, ; //X6_FIL
	'OZ_TMENTRA'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Tipo de Movimentação de entrada OZ04M02.prw'							, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
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
	'OZ_TMSAIDA'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Tipo de Movimentação de entrada OZ04M02.prw'							, ; //X6_DESCRIC
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG
	'Projeto PCP OzMInerals'												, ; //X6_DESC1
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA1
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG1
	'Projeto PCP OzMInerals'												, ; //X6_DESC2
	'Projeto PCP OzMInerals'												, ; //X6_DSCSPA2
	'Projeto PCP OzMInerals'												, ; //X6_DSCENG2
	'510'																	, ; //X6_CONTEUD
	'510'																	, ; //X6_CONTSPA
	'510'																	, ; //X6_CONTENG
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
@since  04/12/2023
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
// Campo BZ_COD
//
aAdd( aSX7, { ;
	'BZ_COD'																, ; //X7_CAMPO
	'501'																	, ; //X7_SEQUENC
	'SB1->B1_DESC'															, ; //X7_REGRA
	'BZ_XDESC'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'S'																		, ; //X7_SEEK
	'SB1'																	, ; //X7_ALIAS
	1																		, ; //X7_ORDEM
	'Xfilial("SB1")+M->BZ_COD'												, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

//
// Campo C2_PRODUTO
//
aAdd( aSX7, { ;
	'C2_PRODUTO'															, ; //X7_CAMPO
	'501'																	, ; //X7_SEQUENC
	'SB1->B1_CONTA'															, ; //X7_REGRA
	'C2_XCONTA'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'S'																		, ; //X7_SEEK
	'SB1'																	, ; //X7_ALIAS
	1																		, ; //X7_ORDEM
	'xFilial("SB1")+M->C2_PRODUTO'											, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

aAdd( aSX7, { ;
	'C2_PRODUTO'															, ; //X7_CAMPO
	'502'																	, ; //X7_SEQUENC
	'SB1->B1_ITEMCC'														, ; //X7_REGRA
	'C2_ITEMCTA'															, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'S'																		, ; //X7_SEEK
	'SB1'																	, ; //X7_ALIAS
	1																		, ; //X7_ORDEM
	'xFilial("SB1")+M->C2_PRODUTO'											, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

aAdd( aSX7, { ;
	'C2_PRODUTO'															, ; //X7_CAMPO
	'503'																	, ; //X7_SEQUENC
	'SB1->B1_DESC'															, ; //X7_REGRA
	'C2_XDESC'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'S'																		, ; //X7_SEEK
	'SB1'																	, ; //X7_ALIAS
	1																		, ; //X7_ORDEM
	'Xfilial("SB1")+M->C2_PRODUTO'											, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

//
// Campo F5_XOPER
//
aAdd( aSX7, { ;
	'F5_XOPER'																, ; //X7_CAMPO
	'501'																	, ; //X7_SEQUENC
	'PAW->PAW_DESC'															, ; //X7_REGRA
	'F5_XDESC'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'S'																		, ; //X7_SEEK
	'PAW'																	, ; //X7_ALIAS
	1																		, ; //X7_ORDEM
	'xFilial("PAW")+M->F5_XOPER'											, ; //X7_CHAVE
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
/*/{Protheus.doc} FSAtuSXA

Função de processamento da gravação do SXA - Pastas

@author UPDATE gerado automaticamente
@since  04/12/2023
@obs    Gerado por EXPORDIC - V.7.6.3.4 EFS / Upd. V.6.4.1 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuSXA()
Local aEstrut   := {}
Local aSXA      := {}
Local nI        := 0
Local nJ        := 0
Local nPosAgr   := 0
Local lAlterou  := .F.

AutoGrLog( "Ínicio da Atualização" + " SXA" + CRLF )

aEstrut := { "XA_ALIAS"  , "XA_ORDEM"  , "XA_DESCRIC", "XA_DESCSPA", "XA_DESCENG", "XA_AGRUP"  , "XA_TIPO"   , ;
             "XA_PROPRI" }


//
// Tabela SB1
//
aAdd( aSXA, { ;
	'SB1'																	, ; //XA_ALIAS
	'9'																		, ; //XA_ORDEM
	'Contabilidade'															, ; //XA_DESCRIC
	'Contabilidade'															, ; //XA_DESCSPA
	'Contabilidade'															, ; //XA_DESCENG
	''																		, ; //XA_AGRUP
	''																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

nPosAgr := aScan( aEstrut, { |x| AllTrim( x ) == "XA_AGRUP" } )

//
// Atualizando dicionário
//
oProcess:SetRegua2( Len( aSXA ) )

dbSelectArea( "SXA" )
dbSetOrder( 1 )

For nI := 1 To Len( aSXA )

	If SXA->( dbSeek( aSXA[nI][1] + aSXA[nI][2] ) )

		lAlterou := .F.

		While !SXA->( EOF() ).AND.  SXA->( XA_ALIAS + XA_ORDEM ) == aSXA[nI][1] + aSXA[nI][2]

			If SXA->XA_AGRUP == aSXA[nI][nPosAgr]
				RecLock( "SXA", .F. )
				For nJ := 1 To Len( aSXA[nI] )
					If FieldPos( aEstrut[nJ] ) > 0 .AND. Alltrim(AllToChar(SXA->( FieldGet( nJ ) ))) <> Alltrim(AllToChar(aSXA[nI][nJ]))
						FieldPut( FieldPos( aEstrut[nJ] ), aSXA[nI][nJ] )
						lAlterou := .T.
					EndIf
				Next nJ
				dbCommit()
				MsUnLock()
			EndIf

			SXA->( dbSkip() )

		End

		If lAlterou
			AutoGrLog( "Foi alterada a pasta " + aSXA[nI][1] + "/" + aSXA[nI][2] + "  " + aSXA[nI][3] )
		EndIf

	Else

		RecLock( "SXA", .T. )
		For nJ := 1 To Len( aSXA[nI] )
			If FieldPos( aEstrut[nJ] ) > 0
				FieldPut( FieldPos( aEstrut[nJ] ), aSXA[nI][nJ] )
			EndIf
		Next nJ
		dbCommit()
		MsUnLock()

		AutoGrLog( "Foi incluída a pasta " + aSXA[nI][1] + "/" + aSXA[nI][2] + "  " + aSXA[nI][3] )

	EndIf

oProcess:IncRegua2( "Atualizando Arquivos (SXA) ..." )

Next nI

AutoGrLog( CRLF + "Final da Atualização" + " SXA" + CRLF + Replicate( "-", 128 ) + CRLF )

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuSXB

Função de processamento da gravação do SXB - Consultas Padrao

@author UPDATE gerado automaticamente
@since  04/12/2023
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
// Consulta PAW
//
aAdd( aSXB, { ;
	'PAW'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Operação Contabil'														, ; //XB_DESCRI
	'Operação Contabil'														, ; //XB_DESCSPA
	'Operação Contabil'														, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'PAW'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'PAW'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cod. Oper.'															, ; //XB_DESCRI
	'Cod. Oper.'															, ; //XB_DESCSPA
	'Cod. Oper.'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'PAW001'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'PAW'																	, ; //XB_ALIAS
	'3'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cadastra Novo'															, ; //XB_DESCRI
	'Incluye Nuevo'															, ; //XB_DESCSPA
	'Add New'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'01'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'PAW'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cod. Oper.'															, ; //XB_DESCRI
	'Cod. Oper.'															, ; //XB_DESCSPA
	'Cod. Oper.'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'PAW_COD'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'PAW'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Desc.OPerac.'															, ; //XB_DESCRI
	'Desc.OPerac.'															, ; //XB_DESCSPA
	'Desc.OPerac.'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'PAW_DESC'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'PAW'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'PAW->PAW_COD'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'PAW'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'PAW->PAW_DESC'															} ) //XB_CONTEM

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
@since  04/12/2023
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
// Helps Tabela PAV
//
//
// Helps Tabela PAW
//
aHlpPor := {}
aAdd( aHlpPor, 'Codigo da Operação' )

aHlpEng := {}
aAdd( aHlpEng, 'Codigo da Operação' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Codigo da Operação' )

PutSX1Help( "PPAW_COD   ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "PAW_COD" )

aHlpPor := {}
aAdd( aHlpPor, 'Descrição Operação' )

aHlpEng := {}
aAdd( aHlpEng, 'Descrição Operação' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Descrição Operação' )

PutSX1Help( "PPAW_DESC  ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "PAW_DESC" )
//
// Helps Tabela SB1
//
aHlpPor := {}
aAdd( aHlpPor, 'Tipo de Conta Custo' )

aHlpEng := {}
aAdd( aHlpEng, 'Tipo de Conta Custo' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Tipo de Conta Custo' )

PutSX1Help( "PB1_XTPCTBA", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "B1_XTPCTBA" )

//
// Helps Tabela SBZ
//
aHlpPor := {}
aAdd( aHlpPor, 'Desc.Produto' )

aHlpEng := {}
aAdd( aHlpEng, 'Desc.Produto' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Desc.Produto' )

PutSX1Help( "PBZ_XDESC  ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "BZ_XDESC" )

aHlpPor := {}
aAdd( aHlpPor, 'Conta Caixa Contabil' )

aHlpEng := {}
aAdd( aHlpEng, 'Conta Caixa Contabil' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Conta Caixa Contabil' )

PutSX1Help( "PBZ_XCTACXA", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "BZ_XCTACXA" )

aHlpPor := {}
aAdd( aHlpPor, 'Cta Depreciacao Contabil' )

aHlpEng := {}
aAdd( aHlpEng, 'Cta Depreciacao Contabil' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Cta Depreciacao Contabil' )

PutSX1Help( "PBZ_XCTADPR", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "BZ_XCTADPR" )

aHlpPor := {}
aAdd( aHlpPor, 'Cta Transitoria C.Direto' )

aHlpEng := {}
aAdd( aHlpEng, 'Cta Transitoria C.Direto' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Cta Transitoria C.Direto' )

PutSX1Help( "PBZ_XCTADIR", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "BZ_XCTADIR" )

aHlpPor := {}
aAdd( aHlpPor, 'Cta Transitoria C.Indireto' )

aHlpEng := {}
aAdd( aHlpEng, 'Cta Transitoria C.Indireto' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Cta Transitoria C.Indireto' )

PutSX1Help( "PBZ_XCTAIND", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "BZ_XCTAIND" )

aHlpPor := {}
aAdd( aHlpPor, 'Cta Contabil Cpv - Caixa' )

aHlpEng := {}
aAdd( aHlpEng, 'Cta Contabil Cpv - Caixa' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Cta Contabil Cpv - Caixa' )

PutSX1Help( "PBZ_XCPVCXA", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "BZ_XCPVCXA" )

aHlpPor := {}
aAdd( aHlpPor, 'Cta.Contabil Cpv - Depreciação' )

aHlpEng := {}
aAdd( aHlpEng, 'Cta.Contabil Cpv - Depreciação' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Cta.Contabil Cpv - Depreciação' )

PutSX1Help( "PBZ_XCPVDPR", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "BZ_XCPVDPR" )

aHlpPor := {}
aAdd( aHlpPor, 'Conta Transf.Caixa Origem' )

aHlpEng := {}
aAdd( aHlpEng, 'Conta Transf.Caixa Origem' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Conta Transf.Caixa Origem' )

PutSX1Help( "PBZ_XTRFCXA", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "BZ_XTRFCXA" )

aHlpPor := {}
aAdd( aHlpPor, 'Cta.Transferencia Deprecicação Origem' )

aHlpEng := {}
aAdd( aHlpEng, 'Cta.Transferencia Deprecicação Origem' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Cta.Transferencia Deprecicação Origem' )

PutSX1Help( "PBZ_XTRFDPR", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "BZ_XTRFDPR" )

aHlpPor := {}
aAdd( aHlpPor, 'Cta.Deprec Transf.Destino' )

aHlpEng := {}
aAdd( aHlpEng, 'Cta.Deprec Transf.Destino' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Cta.Deprec Transf.Destino' )

PutSX1Help( "PBZ_XTRDDPR", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "BZ_XTRDDPR" )

aHlpPor := {}
aAdd( aHlpPor, 'Cta Caixa Transf. Destino' )

aHlpEng := {}
aAdd( aHlpEng, 'Cta Caixa Transf. Destino' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Cta Caixa Transf. Destino' )

PutSX1Help( "PBZ_XTRDCXA", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "BZ_XTRDCXA" )

//
// Helps Tabela SC2
//
aHlpPor := {}
aAdd( aHlpPor, 'Descricao do Produto' )

aHlpEng := {}
aAdd( aHlpEng, 'Descricao do Produto' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Descricao do Produto' )

PutSX1Help( "PC2_XDESC  ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "C2_XDESC" )

aHlpPor := {}
aAdd( aHlpPor, 'Permite Alterar Empenho' )

aHlpEng := {}
aAdd( aHlpEng, 'Permite Alterar Empenho' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Permite Alterar Empenho' )

PutSX1Help( "PC2_XALTEMP", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "C2_XALTEMP" )

aHlpPor := {}
aAdd( aHlpPor, 'Conta Contabil Producao' )

aHlpEng := {}
aAdd( aHlpEng, 'Conta Contabil Producao' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Conta Contabil Producao' )

PutSX1Help( "PC2_XCONTA ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "C2_XCONTA" )

//
// Helps Tabela SD3
//
aHlpPor := {}
aAdd( aHlpPor, 'Operacao Contabil' )

aHlpEng := {}
aAdd( aHlpEng, 'Operacao Contabil' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Operacao Contabil' )

PutSX1Help( "PD3_XOPER  ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "D3_XOPER" )

aHlpPor := {}
aAdd( aHlpPor, 'Centro Custo de Custeio' )

aHlpEng := {}
aAdd( aHlpEng, 'Centro Custo de Custeio' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Centro Custo de Custeio' )

PutSX1Help( "PD3_XCCCUST", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "D3_XCCCUST" )

aHlpPor := {}
aAdd( aHlpPor, 'Valor Caixa Moeda 01' )

aHlpEng := {}
aAdd( aHlpEng, 'Valor Caixa Moeda 01' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Valor Caixa Moeda 01' )

PutSX1Help( "PD3_XVLRCXA", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "D3_XVLRCXA" )

aHlpPor := {}
aAdd( aHlpPor, 'Vlr Depreciação Moeda 01' )

aHlpEng := {}
aAdd( aHlpEng, 'Vlr Depreciação Moeda 01' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Vlr Depreciação Moeda 01' )

PutSX1Help( "PD3_XVLRDPR", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "D3_XVLRDPR" )

aHlpPor := {}
aAdd( aHlpPor, 'Valor Caixa Moeda 02' )

aHlpEng := {}
aAdd( aHlpEng, 'Valor Caixa Moeda 02' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Valor Caixa Moeda 02' )

PutSX1Help( "PD3_XDLRCXA", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "D3_XDLRCXA" )

aHlpPor := {}
aAdd( aHlpPor, 'Vlr. Depreciação Moeda 02' )

aHlpEng := {}
aAdd( aHlpEng, 'Vlr. Depreciação Moeda 02' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Vlr. Depreciação Moeda 02' )

PutSX1Help( "PD3_XDLRDPR", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "D3_XDLRDPR" )

//
// Helps Tabela SF5
//
aHlpPor := {}
aAdd( aHlpPor, 'Operação Contabil' )

aHlpEng := {}
aAdd( aHlpEng, 'Operação Contabil' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Operação Contabil' )

PutSX1Help( "PF5_XOPER  ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "F5_XOPER" )

aHlpPor := {}
aAdd( aHlpPor, 'Descrição Op Contabil' )

aHlpEng := {}
aAdd( aHlpEng, 'Descrição Op Contabil' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Descrição Op Contabil' )

PutSX1Help( "PF5_XDESC  ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "F5_XDESC" )

//
// Helps Tabela SG1
//
aHlpPor := {}
aAdd( aHlpPor, '% Rateio para Custeio' )

aHlpEng := {}
aAdd( aHlpEng, '% Rateio para Custeio' )

aHlpSpa := {}
aAdd( aHlpSpa, '% Rateio para Custeio' )

PutSX1Help( "PG1_XPERC  ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "G1_XPERC" )

aHlpPor := {}
aAdd( aHlpPor, 'Autoriza Alterar Empenho' )

aHlpEng := {}
aAdd( aHlpEng, 'Autoriza Alterar Empenho' )

aHlpSpa := {}
aAdd( aHlpSpa, 'Autoriza Alterar Empenho' )

PutSX1Help( "PG1_XALTEMP", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
AutoGrLog( "Atualizado o Help do campo " + "G1_XALTEMP" )

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
@ 112, 157  Button oButOk   Prompt "Processar"  Size 32, 12 Pixel Action (  RetSelecao( @aRet, aVetor ), IIf( Len( aRet ) > 0, oDlg:End(), MsgStop( "Ao menos um grupo deve ser selecionado", "UPDPCP" ) ) ) ;
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
@since  04/12/2023
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
@since  04/12/2023
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
