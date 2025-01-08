#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'

//Variáveis Estáticas
Static cTitulo := "Acompanhamento das NF-e"

User Function zModel3()
	Local aArea   := GetArea()
	Local oBrowse
	Local cFunBkp := FunName()

	SetFunName("zModel3")
	
	//Instânciando FWMBrowse - Somente com dicionário de dados
	oBrowse := FWMBrowse():New()
	
	//Setando a tabela de cadastro de Autor/Interprete
	oBrowse:SetAlias("Z01")

	//Setando a descrição da rotina
	oBrowse:SetDescription(cTitulo)
	
	//Legendas
	oBrowse:AddLegend( "Z01->Z01_STATUS == 'G'", "GREEN",	"Gerado a NF-e" )
	oBrowse:AddLegend( "Z01->Z01_STATUS !=  'G'", "RED",	"Nao Gerado a NF-e" )
	
	//Filtrando
	//oBrowse:SetFilterDefault("ZZ1->ZZ1_COD >= '000000' .And. ZZ1->ZZ1_COD <= 'ZZZZZZ'")
	
	//Ativa a Browse
	oBrowse:Activate()
	
	SetFunName(cFunBkp)
	RestArea(aArea)
Return Nil


Static Function MenuDef()
	Local aRot := {}
	
	//Adicionando opções
   	//Adicionando opções
    ADD OPTION aRot TITLE 'Gera Pedido'   ACTION 'u_OZGERPED'      OPERATION 6                      ACCESS 0
	ADD OPTION aRot TITLE 'Integra Nfe'   ACTION 'u_GRVNFE495'      OPERATION 3                     ACCESS 0
	ADD OPTION aRot TITLE 'Visualizar'    ACTION 'VIEWDEF.zModel3' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
	ADD OPTION aRot TITLE 'Legenda'       ACTION 'u_zMod1Leg'      OPERATION 6                      ACCESS 0 //OPERATION X
	//ADD OPTION aRot TITLE 'Gera Pedido'   ACTION 'u_OZGERPED'      OPERATION 6                      ACCESS 5 //OPERATION X
//	ADD OPTION aRot TITLE 'Incluir'       ACTION 'VIEWDEF.zModel3' OPERATION MODEL_OPERATION_INSERT ACCESS 5 //OPERATION 3
//	ADD OPTION aRot TITLE 'Alterar'       ACTION 'VIEWDEF.zModel3' OPERATION MODEL_OPERATION_UPDATE ACCESS 5 //OPERATION 4
	ADD OPTION aRot TITLE 'Excluir'       ACTION 'VIEWDEF.zModel3' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5

	
Return aRot


Static Function ModelDef()
	//Criação do objeto do modelo de dados
	Local oModel := Nil
	
	//Criação da estrutura de dados utilizada na interface
	Local oStZ01 := FWFormStruct(1, "Z01")
	
	//Editando características do dicionário
	oStZ01:SetProperty('Z01_ORDEM',   MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,    '.F.'))                                 //Modo de Edição
	//oStZ01:SetProperty('ZZ1_COD',   MODEL_FIELD_INIT,    FwBuildFeature(STRUCT_FEATURE_INIPAD,  'GetSXENum("ZZ1", "ZZ1_COD")'))         //Ini Padrão
	oStZ01:SetProperty('Z01_DTEMIS',  MODEL_FIELD_VALID,   FwBuildFeature(STRUCT_FEATURE_VALID,   'Iif(Empty(M->Z01_DTEMIS), .F., .T.)'))   //Validação de Campo
	oStZ01:SetProperty('Z01_DTEMIS',  MODEL_FIELD_OBRIGAT, Iif(RetCodUsr()!='000000', .T., .F.) )                                         //Campo Obrigatório
	
	//Instanciando o modelo, não é recomendado colocar nome da user function (por causa do u_), respeitando 10 caracteres
	oModel := MPFormModel():New("zModel3M",/*bPre*/, /*bPos*/,/*bCommit*/,/*bCancel*/) 
	
	//Atribuindo formulários para o modelo
	oModel:AddFields("FORMZ01",/*cOwner*/,oStZ01)
	
	//Setando a chave primária da rotina
	oModel:SetPrimaryKey({'Z01_FILIAL','Z01_ORDEM'})
	
	//Adicionando descrição ao modelo
	oModel:SetDescription("Modelo de Dados do Cadastro "+cTitulo)
	
	//Setando a descrição do formulário
	oModel:GetModel("FORMZ01"):SetDescription("Formulário "+cTitulo)
Return oModel

/*---------------------------------------------------------------------*
 | Func:  ViewDef                                                      |
 | Autor: Daniel Atilio                                                |
 | Data:  31/07/2016                                                   |
 | Desc:  Criação da visão MVC                                         |
 *---------------------------------------------------------------------*/

Static Function ViewDef()
	//Local aStruZZ1	:= Z01->(DbStruct())
	
	//Criação do objeto do modelo de dados da Interface do Cadastro de Autor/Interprete
	Local oModel := FWLoadModel("zModel3")
	
	//Criação da estrutura de dados utilizada na interface do cadastro de Autor
	Local oStZ01 := FWFormStruct(2, "Z01")  //pode se usar um terceiro parâmetro para filtrar os campos exibidos { |cCampo| cCampo $ 'SZZ1_NOME|SZZ1_DTAFAL|'}
	
	//Criando oView como nulo
	Local oView := Nil

	//Criando a view que será o retorno da função e setando o modelo da rotina
	oView := FWFormView():New()
	oView:SetModel(oModel)
	
	//Atribuindo formulários para interface
	oView:AddField("VIEW_Z01", oStZ01, "FORMZ01")
	
	//Criando um container com nome tela com 100%
	oView:CreateHorizontalBox("TELA",100)
	
	//Colocando título do formulário
	oView:EnableTitleView('VIEW_Z01', 'Dados - '+cTitulo )  
	
	//Força o fechamento da janela na confirmação
	oView:SetCloseOnOk({||.T.})
	
	//O formulário da interface será colocado dentro do container
	oView:SetOwnerView("VIEW_Z01","TELA")
	
	/*
	//Tratativa para remover campos da visualização
	For nAtual := 1 To Len(aStruZZ1)
		cCampoAux := Alltrim(aStruZZ1[nAtual][01])
		
		//Se o campo atual não estiver nos que forem considerados
		If Alltrim(cCampoAux) $ "ZZ1_COD;"
			oStZZ1:RemoveField(cCampoAux)
		EndIf
	Next
	*/
Return oView

/*/{Protheus.doc} zMod1Leg
Função para mostrar a legenda
@author Atilio
@since 31/07/2016
@version 1.0
	@example
	u_zMod1Leg()
/*/

User Function zMod1Leg()
	Local aLegenda := {}
	
	//Monta as cores
	AADD(aLegenda,{"BR_VERDE",		"Gerado Pedido Vendas"})
	AADD(aLegenda,{"BR_VERMELHO",	"Não Gerado Pedido Vendas"})
	
	BrwLegenda(cTitulo, "Status", aLegenda)
Return

User Function OZGERPED()
    Local aArea    := GetArea()
	//Local cMarca   := oMark:Mark()
	//Local lInverte := oMark:IsInvert()
	Local nCt      := 0
    //Local adSC5 := {}
	//Local adSC6 := {}
    local nPliqui := 0
    Local nPbruto := 0
    lOCAL aChave  := {}
    Local cProduto := ''
    lOCAL CdESC    := ''
    Local cCliente := '000001'
    Local cLoja := '00'
    Local cTransp := '001'
    Local cTabela := '001'
    Local cMoeda  := '001'
    Local nQuant  := 0
    local nPreco  := 0
    Local cPerg    := "OZZ0101"

    Pergunte(cPerg,.T.)
	Local rParam := MV_PAR01
	Public rPara1 := MV_PAR02
	Public rPara2 := MV_PAR03

    if rPara1 >0 .and. !Empty(MV_PAR03)
	//Percorrendo os registros da Z01
	DBSELECTAREA("Z01")
    Z01->(DbSetOrder(1))
	Z01->(DbGoTop())
	If Z01->( dbSeek(xFilial("Z01")+"000009"+"01"+rParam+"1"))
    IF Z01->Z01_STATUS<>'G'
    
	While !Z01->(EoF()) .AND. Z01->Z01_DOC=rParam
      IF Z01->Z01_STATUS<>'G'  
            nCt++
            nPliqui += Z01->Z01_PLQUI
            nPbruto += Z01->Z01_PBRUT
            nQuant += Z01->Z01_QTDVEN
            
            DBSELECTAREA("SD2")
            SD2->(DbSetOrder(3))
            iF SD2->( dbSeek(Z01->Z01_FILIAL+Z01->Z01_NFORI+Z01->Z01_SERIOR))
                cProduto := SD2->D2_COD
                cDesc := SD2->D2_DESC
                Aadd(aChave,Z01->Z01_CHAVE)
            else
                cProduto := z01->Z01_PRODUT
            EndIF 
     ENDIF           
        
        Z01->(DbSkip())
	EndDo

    if nCt > 0    
        U_OZ_GERPED(cCliente, cLoja,cTransp, cTabela,cMoeda,nPbruto,nPliqui,cProduto,cDesc,nQuant,nPreco,aChave)
   		 If lRet := .T.

		 DBSELECTAREA("Z01")
   		 Z01->(DbSetOrder(1))
			Z01->(DbGoTop())
			If Z01->( dbSeek(xFilial("Z01")+"000009"+"01"+rParam+"1"))
    			While !Z01->(EoF()) .AND. Z01->Z01_DOC=rParam
				             			RecLock('Z01', .F.)
			            Z01->Z01_STATUS := 'G'
						Z01->Z01_PEDIDO := cDoc
		    			Z01->(MsUnlock())
             			Z01->(DbSkip())
				EndDo
			ENDIF
		endif
	EndIF
	else
	 MSGINFO( ("Pedido de Vendas "+Z01->Z01_PEDIDO+" já gerado para Nfe " +rParam ))	
    Endif
	Endif
	else
	
	MSGINFO( ("Dados Inválidos, verificar parâmetros ! "+str(rPara1,12,4)+" "+rPara2 ))		
	endif
RestArea(aArea)
Return

user function GRVNFE495()
#Include "Rwmake.ch"
#Include "Protheus.ch"
#Include "Topconn.ch"
#include "rwmake.ch"
#include "fileio.ch"
#include "TbiConn.ch"
#include "TbiCode.ch"
#include "protheus.ch"
#INCLUDE "FWMVCDEF.CH"

	Local az01Are := GetArea()
    local nOrdem := 1
    local cCHVNFE := ''
	local nF2_PLQUI := 0
	local nF2_PBRUTO := 0
	Local notasg :=0
  

    // GERA A TELA DE PROCESSAMENTO
    MsgRun("Integrando Dados...aguarde", "Integra Nfe")
  //  if nOpcao == 3 .and. nConfirma == 1
		 dbSelectArea('SD1')
		 SD1->(dbGoTop())
        cQuery := "  select *  "
        cQuery += "  from " + RetSQLName("SD1") + " SD1 "  
        cQuery += "  WHERE D_E_L_E_T_ = '' "
   		cQuery += "    AND D1_TES = '495' "
		cQuery += "    AND D1_EMISSAO>='20220101' "
		
		


        //TCQUERY cQuery NEW ALIAS TRC

        If Select('TZ3') <> 0
		    dbSelectArea('TZ3')
		    TZ3->(dbCloseArea())
	    EndIf
	
	    dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),'TZ3',.F.,.F.)


        DBSELECTAREA("TZ3")
        TZ3->(dbGoTop())

        WHILE TZ3->(!EOF())	 
            if TZ3->D1_FILIAL = cFilant
            nOrdem := U_Pegaseq()
            DBSELECTAREA("SF2")
            SF2->(DbSetOrder(1))
            iF SF2->( dbSeek(TZ3->D1_FILIAL+TZ3->D1_NFORI+TZ3->D1_SERIORI))
                cCHVNFE  := SF2->F2_CHVNFE
                nF2_PLQUI := SF2->F2_PLIQUI
                nF2_PBRUTO := SF2->F2_PBRUTO
            EndIF 
            DBSELECTAREA("Z01")
            Z01->(DbSetOrder(2))
	        
			If !Z01->( dbSeek(xFilial("Z01")+TZ3->D1_FORNECE+TZ3->D1_LOJA+TZ3->D1_DOC+TZ3->D1_SERIE+TZ3->D1_NFORI+TZ3->D1_SERIORI+TZ3->D1_ITEMORI))
			           
                RecLock( "Z01", .T. )
                    Z01->Z01_FILIAL  := TZ3->D1_FILIAL
                    Z01->Z01_SERIE   := TZ3->D1_SERIE
					Z01->Z01_CLIENT  := TZ3->D1_FORNECE
					Z01->Z01_LOJCLI  := TZ3->D1_LOJA
                    Z01->Z01_DOC     := TZ3->D1_DOC
                    Z01->Z01_FORNEC  := TZ3->D1_FORNECE
                    Z01->Z01_LOJA    := TZ3->D1_LOJA
                    Z01->Z01_DTEMIS  := CTOD(TZ3->D1_EMISSAO)
                    Z01->Z01_ORDEM   := nOrdem  
                    //Z01->Z01_NLACRE  := TZ3->D1_XLACRE
                    Z01->Z01_NFORI   := TZ3->D1_NFORI
                    Z01->Z01_SERIORI := TZ3->D1_SERIORI
                    Z01->Z01_ITEMOR  := TZ3->D1_ITEMORI
                    Z01->Z01_CHAVE   := cCHVNFE
                    Z01->Z01_PLQUI   := nF2_PLQUI
                    Z01->Z01_PBRUT   := nF2_PBRUTO
                    Z01->Z01_PRODUT  := TZ3->D1_COD
                    Z01->Z01_QTDVEN  := TZ3->D1_QUANT 
					Z01->Z01_STATUS  :="N"
                Z01->( MsUnlock() )
				notasg := notasg +1
			EndIF
        	endif
			TZ3->(DBSKIP())
       ENDDO

	   if notasg>0
			MSGINFO( ( strzero(notasg,6,0)+" Notas / Itens Integrados! " ))
	   else
		    MSGINFO( ( "Não foram localizadas notas para integração!" ))
       endif
RestArea(az01Are)
Return



user function Pegaseq()
Local az01Are := GetArea()
Local cQuery := ''
local nOrdem1 := 1
Local nLOte  := SUPERGETMV("OZ_LOTE")

        cQuery := "  select MAX(Z01_ORDEM) MAXoRDE  "
        cQuery += "  from " + RetSQLName("Z01") + " Z01  
        cQuery += "  WHERE Z01.D_E_L_E_T_ = '' "
        cQuery += "    AND Z01.Z01_FILIAL = '"+cFilAnt+"' "

		If SELECT("TZ2") > 0
			("TZ2")->(DbCloseArea())
		Endif
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TZ2",.T.,.T.)

        DBSELECTAREA("TZ2")

        iF nLOte <= TZ2->MAXoRDE 
            nOrdem1 := TZ2->MAXoRDE+1
        Else 
            nOrdem1  := nLOte 
        ENDIF

        DBCLOSEAREA()
RestArea(az01Are)

Return(nOrdem1)

