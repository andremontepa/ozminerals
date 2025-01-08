#INCLUDE "PROTHEUS.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "REPORT.CH"
#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} RT06M001
RT06M001 - Rotina Responsavel por realizar a importação dos dados da rotina de Provisores.
@type function 
@author Ricardo Tavares Ferreira
@since 28/06/2021
@history 28/06/2021, Ricardo Tavares Ferreira, Construção Inicial.
@obs Fonte que vai importar dos dados das provisões tabela SZ1
@version 12.1.27
/*/
//=============================================================================================================================
    User Function RT06M001()
//=============================================================================================================================

    Local lConfirm  := .F.
    Private oSay    := Nil 
    Private QbLinha	:= chr(13)+chr(10)

    While .T.
		If GetPerg()
            lConfirm := .T.
            Exit
		Else
			If MsgNoYes("Foi detectado o cancelamento do preechimento dos parametros. Deseja realmente sair da Importação das Provisões (Sim / Não)?","Atenção !!!")
				Return Nil
			EndIf
		EndIf
	End
    If lConfirm 
        FWMsgRun(,{|oSay| ProcArq(oSay)},"Importação das Provisões - Financeiro","Importando Registros Encontrados...") 
    EndIf 
Return Nil

/*/{Protheus.doc} ProcArq
Função que processa o arquivo selecionado. 
@type function
@author Ricardo Tavares Ferreira
@since 28/06/2021
@version 12.1.27
@return logical, Retorna logico se confirmou os paramtros.
@param oSay, object, Objeto da tela de execução.
@history 28/06/2021, Ricardo Tavares Ferreira, Construção Inicial.
/*/
//====================================================================================================
	Static Function ProcArq(oSay)
//====================================================================================================

    Local oFile     := Nil
    Local aCampos   := {}
    Local cCampos   := ""
    Local aLinha    := {}
    Local nLin      := 1
    Local lImport   := .T.
    Local nMaxReg   := 0
    Local aItens    := {}

    DbSelectArea("SZ1")

    oFile := FWFileReader():New(Alltrim(MV_PAR01))
    If oFile:Open()
        nMaxReg := Len(oFile:GetAllLines())
        oFile:Close()
    EndIf

    oFile := FWFileReader():New(Alltrim(MV_PAR01))
	If oFile:Open()
		While oFile:hasLine()
            oSay:cCaption := ("Importando "+ cValToChar(nLin) +" de "+ cValtoChar(nMaxReg) +" Registros...")
            If nLin == 1
			    cCampos := oFile:GetLine()
                aCampos := ValidaCampo("SZ1","",cCampos)
                If Len(aCampos) <= 0
                    MsgInfo("Importação Abortada !!!"+QbLinha+"Corrija o Arquivo <b>"+Alltrim(MV_PAR01)+"</b>, e Importe Novamente.","Atenção")
                    lImport := .F.
                    Exit
                EndIF
                nLin += 1
                Loop
            EndIf
            aLinha := CharToArray(oFile:GetLine(),";")
            aadd(aItens,aLinha)
            nLin += 1
      	End
        If Len(aCampos) > 0 .and. Len(aItens) > 0
            If Len(aCampos) == Len(aItens[1])
                FWMsgRun(,{|oSay| GrvArq(aCampos,aItens)},"Importação das Provisões - Financeiro","Gravando Registros Encontrados na tabela de Provisões ...") 
            EndIf
        EndIf
      	oFile:Close()
    Else
    	MsgInfo(oFile:error():message)
    EndIf
Return 

/*/{Protheus.doc} GrvArq
Função que grava os dados na tabela. 
@type function
@author Ricardo Tavares Ferreira
@since 06/05/2021
@version 12.1.27
@history 21/06/2021, Ricardo Tavares Ferreira, Construção Inicial.
/*/
//====================================================================================================
	Static Function GrvArq(aCampos,aItens)
//====================================================================================================

    Local nX        := 0 
    Local nY        := 0
    Local xCont     := Nil
    Local aDados    := {}
    Local aLinha    := {}

    For nX := 1 To Len(aItens)
        For nY := 1 To Len(aItens[nX])
            If aCampos[nY][4] == "C"
                xCont := Alltrim(Upper(PolyString(aItens[nX][nY])))
            ElseIf aCampos[nY][4] == "D"
                xCont := Stod(aItens[nX][nY])
            ElseIf aCampos[nY][4] == "N"
                xCont := Val(StrTran(aItens[nX][nY],",","."))
            EndIf
            aadd(aLinha,{aCampos[nY][1],xCont,aCampos[nY][5]}) // Campo/Conteudo/Tabela
        Next nY
        If Len(aLinha) > 0 
            aLinha := FWVetByDic(aLinha,"SZ1")
            aadd(aDados,aLinha)
        EndIf 
        aLinha := {}
    Next nX 

    For nX := 1 To Len(aDados)
        cNumsz1 := getnuMsz1(aDados[nX][1][2])
        cFilAnt := aDados[nX][1][2]
        RecLock("SZ1",.T.)
            SZ1->Z1_STATUS  := "1"
            SZ1->Z1_CODIGO  := cNumsz1
            SZ1->Z1_DATAPRO := DDataBase
            SZ1->Z1_CONTABI := "1"
            For nY := 1 To Len(aDados[nX])
                &(aDados[nX][nY][3]+"->"+aDados[nX][nY][1]) := aDados[nX][nY][2]
            Next nY 
        SZ1->(MsUnlock())
        cFilAnt := SZ1->Z1_FILIAL
        GravaSE2()
    Next nX 
Return

static  functiOn getnuMsz1(cfIL)

	Local cQuery	:= ""
	Local QbLinha	:= chr(13)+chr(10)
	Local cAliasY1	:= GetNextAlias()
    local Cnum  := ""

	cQuery := " SELECT MAX(Z1_CODIGO) Z1_CODIGO "+QbLinha
	cQuery += " FROM "
	cQuery +=   RetSqlName("SZ1") + " SZ1 "+QbLinha
	cQuery += " WHERE "+QbLinha 
	cQuery += " SZ1.D_E_L_E_T_ = ' ' "+QbLinha 
	cQuery += " AND SZ1.Z1_FILIAL = '"+cfil+"' "+QbLinha
		     
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasY1,.F.,.T.)
		
	DbSelectArea(cAliasY1)
	(cAliasY1)->(DbGoTop())
	Count To nQtdReg
	(cAliasY1)->(DbGoTop())
		
	If nQtdReg <= 0
		(cAliasY1)->(DbCloseArea())
	Else
		While .not. (cAliasY1)->(Eof())
			cnum := strzERo(val((cAliasY1)->Z1_CODIGO) + 1,9)
			(cAliasY1)->(DbSkip())
		End
		(cAliasY1)->(DbCloseArea())
	EndIf
retuRn cnum

/*/{Protheus.doc} GravaSE2
Funcao responsável por gravar os dados na tabela de contas a pagar.
@type function
@author Ricardo Tavares Ferreira
@since 30/06/2021
@version 12.1.27
@history 21/06/2021, Ricardo Tavares Ferreira, Construção Inicial.
/*/
//===============================================================================================================
    Static Function GravaSE2() 
//===============================================================================================================

    Local aAutoSE2 	:= {}

    AAdd(aAutoSE2, {"E2_PREFIXO"   ,"PRO"				,NIL})
	AAdd(aAutoSE2, {"E2_NUM"   	   ,SZ1->Z1_CODIGO		,NIL}) 
	AAdd(aAutoSE2, {"E2_TIPO"  	   ,"PR"				,NIL})
	AAdd(aAutoSE2, {"E2_NATUREZ"   ,"208017"		 	,NIL})   
	AAdd(aAutoSE2, {"E2_FORNECE"   ,SZ1->Z1_FORNECE	 	,NIL})   		
	AAdd(aAutoSE2, {"E2_LOJA"      ,SZ1->Z1_LOJA	 	,NIL})
	AAdd(aAutoSE2, {"E2_EMISSAO"   ,SZ1->Z1_DATAPRO	 	,NIL}) 
	AAdd(aAutoSE2, {"E2_VENCTO"    ,SZ1->Z1_DTVENC	 	,NIL})
	AAdd(aAutoSE2, {"E2_VENCREA"   ,SZ1->Z1_DTVENC	 	,NIL})  
	AAdd(aAutoSE2, {"E2_VALOR"     ,SZ1->Z1_VALOR	 	,NIL})
	AAdd(aAutoSE2, {"E2_VLCRUZ"    ,SZ1->Z1_VALOR		,NIL}) 
	AAdd(aAutoSE2, {"E2_SALDO"     ,SZ1->Z1_VALOR		,NIL})
	AAdd(aAutoSE2, {"E2_XCONTAB"   ,SZ1->Z1_CONTABI		,NIL})

	lMsErroAuto	:= .F.	
	
	MsExecAuto({|x, y| FINA050(x, y)}, aAutoSE2, 3) //3 = Opcao de inclusao 
			
   	If lMsErroAuto
		MostraErro()
	endif  
Return Nil 

/*/{Protheus.doc} PolyString
Funcao responsável por retirar do conteudo passado como parametro os caracteres especiais.
@type function
@author Ricardo Tavares Ferreira
@since 06/05/2021
@version 12.1.27
@return character, Retorna String Tratado.
@history 21/06/2021, Ricardo Tavares Ferreira, Construção Inicial.
/*/
//===============================================================================================================
    Static Function PolyString(cString) 
//===============================================================================================================
	
    cString := FwNoAccent(AllTrim(cString))       
Return cString

/*/{Protheus.doc} CharToArray
Converte Caracter em Array
@type function
@author Ricardo Tavares Ferreira
@since 28/06/2021
@version 12.1.27
@return array, Array da linha tratada.
@history 21/06/2021, Ricardo Tavares Ferreira, Construção Inicial.
/*/
//====================================================================================================
	Static Function CharToArray(cLinha,cSepar)
//====================================================================================================
    
    Local nPos     := 0
    Local aLinha   := {}

    nPos := At(cSepar,cLinha)
    While !Empty(cLinha)  .And. nPos > 0
        Aadd(aLinha,SubStr(cLinha,1,nPos-1))
        cLinha  := Subs(cLinha,nPos+1,Len(cLinha)-nPos)
        nPos    := At(cSepar,cLinha)
        If nPos = 0 .And. !Empty(cLinha)
            nPos := Len(cLinha)+1
        Endif
    Enddo
Return aLinha

/*/{Protheus.doc} ValidaCampo
Criacao das Perguntas da Rotina tipo Parambox. 
@type function
@author Ricardo Tavares Ferreira
@since 28/06/2021
@version 12.1.27
@param cTabC, character, Alias da Tabela do Cabeçalho.
@param cTabI, character, Alias da Tabela dos Itens.
@param cLinha, character, Linha com os campos do arquivo.
@return array, Array dos dados tratados.
@history 28/06/2021, Ricardo Tavares Ferreira, Construção Inicial.
/*/
//====================================================================================================
	Static Function ValidaCampo(cTabC,cTabI,cLinha)
//====================================================================================================
    
    Local cMens     := ""
    Local nPos      := 0
    Local aCampos   := {}
    Local lExpres   := .F.

    DbSelectArea("SX3")
    SX3->(dbSetOrder(2))
    nPos := At(";",cLinha)
    While !Empty(cLinha)  .And. nPos > 0
        SX3->(dbGoTop())
        If SX3->(dbSeek(Alltrim(Upper(Subs(cLinha,1,nPos-1))))) .and. Alltrim(SX3->X3_CAMPO) == Alltrim(Upper(Subs(cLinha,1,nPos-1)))

            If .not. Empty(cTabC) .and. Empty(cTabI)
                lExpres := !(SX3->X3_ARQUIVO $ cTabC)
            ElseIf .not. Empty(cTabC) .and. .not. Empty(cTabI)
                lExpres := !(SX3->X3_ARQUIVO $ cTabC+"/"+cTabI)
            ElseIf Empty(cTabC) .and. .not. Empty(cTabI)
                lExpres := !(SX3->X3_ARQUIVO $ cTabI)
            EndIf

            If lExpres
                cMens += Alltrim(SX3->X3_CAMPO)+Chr(13)+Chr(10)
            Else
                Aadd(aCampos,{Alltrim(SX3->X3_CAMPO),SX3->X3_ORDEM,Len(aCampos)+1,Alltrim(SX3->X3_TIPO),"SZ1"})
            EndIf
        Else
            cMens += Alltrim(Subs(cLinha,1,nPos-1))+Chr(13)+Chr(10)
        EndIf
        cLinha := Subs(cLinha,nPos+1,Len(cLinha)-nPos)
        nPos  := At(";",cLinha)
        If nPos = 0 .And. !Empty(cLinha)
            nPos := Len(cLinha)+1
        Endif
    Enddo

    If !Empty(cMens)
        Aviso("Campos Inválidos","Os campos abaixo não existem no dicionário de dados ou não pertencem a Rotina de Importação."+Chr(13)+Chr(10)+cMens,{"Sair"},3)
        Return aCampos
    EndIf
Return aCampos

/*/{Protheus.doc} GetPerg
Criacao das Perguntas da Rotina tipo Parambox. 
@type function
@author Ricardo Tavares Ferreira
@since 28/06/2021
@version 12.1.27
@return logical, Retorna logico se confirmou os paramtros.
@history 21/04/2021, Ricardo Tavares Ferreira, Construção Inicial.
/*/
//====================================================================================================
	Static Function GetPerg()
//====================================================================================================

    Local aPergs	    := {}
    Local aRet		    := {}
    Local lRet		    := .T.
    Private cCadastro   := "Perguntas"

    aadd(aPergs,{6,"Local do Arquivo",Padr("",300),"",".T.","",80,.T.,""/*"Arquivos CSV |*.csv"*/,"",GETF_LOCALHARD+GETF_NETWORKDRIVE}) // MV_PAR01

	If .not. ParamBox(aPergs,"Buscar Arquivo",aRet,/*bValid*/,/*aButtons*/,.T.,/*nPosX*/,/*nPosY*/,/*oDialog*/,"RT06M001",.T.,.T.)
		lRet := .F.
	EndIf 
Return lRet
