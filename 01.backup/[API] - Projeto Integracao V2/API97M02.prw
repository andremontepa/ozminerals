#Include "Protheus.ch"
#Include "TopConn.ch"

/*/{Protheus.doc} API97M02
Rotina que gera a chave de validacao para as rotinas solicitadas
@type function 
@author Ricardo Tavares Ferreira
@since 15/05/2020
@version 12.1.27
@history 15/05/2020, Ricardo Tavares Ferreira, Constru��o Inicial.
/*/
//==========================================================================================================
	User Function API97M02()
//==========================================================================================================  
	
	Local oPanel 		:= Nil
	Local oNewPag		:= Nil
	Local oStepWiz 		:= Nil
    Local oPanelBkg		:= Nil
    local oDlg 			:= Nil
    
    Private cNomeFonte	:= Space(8)
	Private cCNPJ		:= Space(14)
	Private cLocalArq	:= Space(80)
    Private cDataAtu	:= DToc(dDataBase)
    Private cDataFim	:= cTod("  /  /    ")
	Private cCNPJFOR	:= Transform("23545485000102", "@R 99.999.999/9999-99")
    
    DEFINE DIALOG oDlg TITLE "Gerador de Chave" PIXEL STYLE nOR(WS_VISIBLE,WS_POPUP)
    oDlg:nWidth 	:= 800
    oDlg:nHeight	:= 620
    
    oPanelBkg:= TPanel():New(0,0,"",oDlg,,,,,,300,300)
    oPanelBkg:Align := CONTROL_ALIGN_ALLCLIENT
    
    //Instancia a classe FWWizard
    oStepWiz:= FWWizardControl():New(oPanelBkg)
    oStepWiz:ActiveUISteps()   
    
    // Pagina 1
    oNewPag := oStepWiz:AddStep("1")
    //Altera a descri��o do step
    oNewPag:SetStepDescription("1� Passo")
    //Define o bloco de constru��o
    oNewPag:SetConstruction({|oPanel| NewPag1(oPanel)})
    //Define o bloco ao clicar no bot�o Pr�ximo
    oNewPag:SetNextAction({|| .T.})
    //Define o bloco ao clicar no bot�o Cancelar
    oNewPag:SetCancelAction({||, .T., oDlg:End()})
    
    // Pagina 2 
    oNewPag := oStepWiz:AddStep("2",{|oPanel| NewPag2(oPanel,@cNomeFonte,@cCNPJ,@cLocalArq,@cDataFim)})
    //Altera a descri��o do step
    oNewPag:SetStepDescription("2� Passo")
    //Define o bloco ao clicar no bot�o Pr�ximo
    oNewPag:SetNextAction({|| ValNewPag2(@cNomeFonte,@cCNPJ,@cLocalArq)})
    //Define o bloco ao clicar no bot�o Voltar
    oNewPag:SetCancelAction({|| , .T., oDlg:End()})
    //Ser na propriedade acima (SetCancelAction) o segundo parametro estiver com .F., n�o ser� poss�vel voltar para a p�gina anterior
    oNewPag:SetPrevAction({|| .T.})
    //Seta O Titulo do Botao Voltar
    oNewPag:SetPrevTitle("Voltar")
    
    // Pagina 3 
    oNewPag := oStepWiz:AddStep("3",{|oPanel| NewPag3(oPanel)})
    //Altera a descri��o do step
    oNewPag:SetStepDescription("3� Passo")
    //Define o bloco ao clicar no bot�o Pr�ximo
    oNewPag:SetNextAction({|| FGerArq(), .T., oDlg:End()})
    //Define o bloco ao clicar no bot�o Voltar
    oNewPag:SetCancelAction({|| , .T., oDlg:End()})
    //Ser na propriedade acima (SetCancelAction) o segundo parametro estiver com .F., n�o ser� poss�vel voltar para a p�gina anterior
    oNewPag:SetPrevAction({|| .T.})
    //Seta O Titulo do Botao Voltar
    oNewPag:SetPrevTitle("Voltar")
	
	oStepWiz:Activate()
    ACTIVATE DIALOG oDlg CENTER
    oStepWiz:Destroy()
Return

/*/{Protheus.doc} NewPag1
Fun��o que cria o conteudo da tela 1.
@type function 
@author Ricardo Tavares Ferreira
@since 15/05/2020
@version 12.1.27
@history 15/05/2020, Ricardo Tavares Ferreira, Constru��o Inicial.
/*/
//==========================================================================================================
	Static Function NewPag1(oPanel)
//==========================================================================================================

	Local oFonte	:= Nil
	Local oSay1		:= Nil
	Local oSay2		:= Nil
	Local oSay3		:= Nil
	Local oSay4		:= Nil
	Local cTitulo	:= "BEM VINDO AO ASSISTENTE DE GERA��O DE CHAVES CRIPTOGRAFADAS..."
	Local cCorpo	:= "ESTA SOLU��O, TEM A FUN��O DE GERAR UM ARQUIVO DE DADOS CRIPTOGRAFADO QUE SER� UTILIZADO NAS VALIDA��ES DE C�DIGOS FONTE COMERCIALIZADOS."
	Local cCorpo2	:= "AP�S A GERA��O DO ARQUIVO, SER� NECESS�RIO COPIAR O ARQUIVO PARA A PASTA CONFIGURADA NO PARAMETRO AP_DIRCHV A PASTA DEVE ESTAR NO DIRETORIO DO PROTHEUS_DATA PARA QUE OS FONTES COMERCIALIZADOS VALIDE A CHAVE GERADA, DESTA FORMA, SER� POSSIVEL EXECUTAR A SOLU��O COM SUCESSO CASO A EMPRESA TENHA A CHAVE VALIDADA."
	Local cCorpo3	:= "CLIQUE EM AVAN�AR PARA PROSSEGUIR COM A GERA��O DO ARQUIVO...
				       
	oFonte := TFONT():NEW( " COURIER NEW ",,18,,.T.) // FONTE ARIAL NARROW, TAM. 18, NEGRITO
	
	oSay1:= TSay():New(10,10,{|| Capital(cTitulo)},oPanel,,oFonte,,,,.T.,CLR_BLUE,CLR_WHITE,300,20)
	
	oSay2:= TSay():New(50,10,{|| Capital(cCorpo)},oPanel,,oFonte,,,,.T.,CLR_BLUE,CLR_WHITE,370,70)
	
	oSay3:= TSay():New(90,10,{|| Capital(cCorpo2)},oPanel,,oFonte,,,,.T.,CLR_BLUE,CLR_WHITE,370,50)
	
	oSay4:= TSay():New(180,10,{|| Capital(cCorpo3)},oPanel,,oFonte,,,,.T.,CLR_BLUE,CLR_WHITE,370,50)
Return

/*/{Protheus.doc} NewPag2
Fun��o que cria o conteudo da tela 2.
@type function 
@author Ricardo Tavares Ferreira
@since 15/05/2020
@version 12.1.27
@history 15/05/2020, Ricardo Tavares Ferreira, Constru��o Inicial.
/*/
//==========================================================================================================
	Static Function NewPag2(oPanel,cNomeFonte,cCNPJ,cLocalArq,cDataFim)
//==========================================================================================================

	Local oFonte	:= Nil
	Local oSay1		:= Nil
	Local oSay2		:= Nil
	Local oGet2		:= Nil
	Local oSay3		:= Nil
	Local oGet3		:= Nil
	Local oSay4		:= Nil
	Local oGet4		:= Nil
	Local oSay5		:= Nil
	Local oGet5		:= Nil
	Local oSay6		:= Nil
	Local cCorpo3	:= "AP�S DIGITAR TODOS OS DADOS, CLIQUE EM AVAN�AR PARA PROSSEGUIR COM A GERA��O DO ARQUIVO...
					       
	oFonte := TFONT():NEW( " COURIER NEW ",,18,,.T.) // FONTE ARIAL NARROW, TAM. 18, NEGRITO
	
	oSay1  := TSay():New(10,10,{||"Empresa Geradora da Chave: RTF Consulsystem"},oPanel,,oFonte,,,,.T.,CLR_BLUE,CLR_WHITE,200,20)
	oSay1  := TSay():New(10,280,{||"CNPJ: "+cCNPJFOR},oPanel,,oFonte,,,,.T.,CLR_BLUE,CLR_WHITE,370,20)

	oSay2  := TSay():New(20,10,{||"Data da Gera��o: "+cDataAtu},oPanel,,oFonte,,,,.T.,CLR_BLUE,CLR_WHITE,200,20)
	
	oSay2  := TSay():New(35,10,{||"Data de Validade: "},oPanel,,oFonte,,,,.T.,CLR_HRED,CLR_WHITE,370,20)
    oGet2  := TGet():New(45,10,{|u| If( PCount() == 0, cDataFim, cDataFim := u )},oPanel,060,015,"@D",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,"cDataFim",,,,)
	
	oSay3  := TSay():New(70,10,{||"C�digo Fonte: "},oPanel,,oFonte,,,,.T.,CLR_HRED,CLR_WHITE,200,20)	
    oGet3  := TGet():New(80,10,{|u| If( PCount() > 0, cNomeFonte := u, cNomeFonte ) } ,oPanel,060,015,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,"cNomeFonte",,,, )

	oSay4  := TSay():New(105,10,{||"CNPJ do Cliente: "},oPanel,,oFonte,,,,.T.,CLR_HRED,CLR_WHITE,200,20)	
    oGet4  := TGet():New(115,10,{|u| If( PCount() > 0, cCNPJ := u, cCNPJ ) } ,oPanel,080,015,"@R 99.999.999/9999-99",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,"cCNPJ",,,, )

    oSay5  := TSay():New(140,10,{||"Salvar Arquivo Em: "},oPanel,,oFonte,,,,.T.,CLR_HRED,CLR_WHITE,200,20)	
    oGet5  := TGet():New(150,10,{|u| If( PCount() > 0, cLocalArq := u, cLocalArq ) } ,oPanel,370,015,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,"cLocalArq",,,, )
	
	oSay6  := TSay():New(180,10,{|| Capital(cCorpo3)},oPanel,,oFonte,,,,.T.,CLR_BLUE,CLR_WHITE,370,50)
Return

/*/{Protheus.doc} ValNewPag2
Fun��o que cria o conteudo da tela 2.
@type function 
@author Ricardo Tavares Ferreira
@since 15/05/2020
@version 12.1.27
@return logical, Retorn verdadeiro se validou a pagina.
@history 15/05/2020, Ricardo Tavares Ferreira, Constru��o Inicial.
/*/
//==========================================================================================================
	Static Function ValNewPag2(cNomeFonte,cCNPJ,cLocalArq,cDataFim)
//==========================================================================================================
	
	Local lRet := .T.
	
	If Empty(cNomeFonte)
		 Aviso("Aten��o","O Campo (Nome no Fonte), n�o pode ficar em branco!!!" + CRLF + "Preencha o campo para Prosseguir.",{"Continuar"},1)
		 lRet := .F.
	ElseIf Empty(cCNPJ)
		 Aviso("Aten��o","O Campo (CNPJ do Cliente), n�o pode ficar em branco!!!" + CRLF + "Preencha o campo para Prosseguir.",{"Continuar"},1)	
		 lRet := .F.
	ElseIf Empty(cLocalArq)
		 Aviso("Aten��o","O Campo (Salvar Arquivo Em), n�o pode ficar em branco!!!" + CRLF + "Preencha o campo para Prosseguir.",{"Continuar"},1)		
		 lRet := .F.
	EndIf
Return lRet

/*/{Protheus.doc} NewPag3
Fun��o que cria o conteudo da tela 3.
@type function 
@author Ricardo Tavares Ferreira
@since 15/05/2020
@version 12.1.27
@history 15/05/2020, Ricardo Tavares Ferreira, Constru��o Inicial.
/*/
//==========================================================================================================
	Static Function NewPag3(oPanel)
//==========================================================================================================

	Local oFonte	:= Nil
	Local oSay1		:= Nil
	Local oSay2		:= Nil

	Local cTitulo	:= "ASSISTENTE CONCLUIDO COM SUCESSO..."
	Local cCorpo	:= "VOC� CONCLUIU COM SUCESSO O ASSISTENTE DE GERA��O DO ARQUIVO CRIPTOGRAFADO DE VALIDA��O. CLIQUE EM (CONCLUIR), PARA QUE O ARQUIVO SEJA GERADO COM AS INFORMA��ES DIGITADAS NO DIRETORIO INFORMADO."
				       
	oFonte := TFONT():NEW( " COURIER NEW ",,18,,.T.) // FONTE ARIAL NARROW, TAM. 18, NEGRITO
	
	oSay1:= TSay():New(10,10,{|| Capital(cTitulo)},oPanel,,oFonte,,,,.T.,CLR_BLUE,CLR_WHITE,300,20)
	
	oSay2:= TSay():New(50,10,{|| Capital(cCorpo)},oPanel,,oFonte,,,,.T.,CLR_BLUE,CLR_WHITE,370,70)
Return

/*/{Protheus.doc} FGerArq
Fun��o que cria o arquivo no diretorio informado.
@type function 
@author Ricardo Tavares Ferreira
@since 15/05/2020
@version 12.1.27
@history 15/05/2020, Ricardo Tavares Ferreira, Constru��o Inicial.
/*/
//==========================================================================================================
	Static Function FGerArq()
//==========================================================================================================

	Local lRet 		:= .T.
	Local cArq		:= Upper(cNomeFonte)+"_"+Upper(cCNPJ)+".rtf"
	Local nHandle	:= ""
	Local cCNPJFOR	:= "23545485000102"
	Local cCodFim	:= StrTran(cNomeFonte+cCNPJFOR+cDataAtu+DToc(cDataFim)+cCNPJ+cNomeFonte,"/","")
	Local cCript1	:= Embaralha(cCodFim,0)
	Local cCript2	:= Replicate("$",10)+cCript1+Replicate("*",10)
	Local cCript3	:= Embaralha(cCript2,0)
	Local cCript4	:= Replicate("&",10)+cCript3+Replicate("@",10)
	Local cCript5	:= Embaralha(cCript4,0)
	Local cCript6	:= Encode64(cCript5) // Criptografia em Base64

/*  CHAVE SEQUENCIA PARA DESCRIPITOGRAFAR O ARQUIVO PARA VALIDA��O
	Local cDCript1	:= Decode64(cCript6)
	Local cDCript2	:= Embaralha(cDCript1,1)
	Local cDCript3 	:= StrTran(StrTran(cDCript2,"@",""),"&","")
	Local cDCript4	:= Embaralha(cDCript3,1)
	Local cDCript5	:= StrTran(StrTran(cDCript4,"*",""),"$","")
	Local cDCript6	:= Embaralha(cDCript5,1)
*/
	
	If File(Alltrim(cLocalArq)+cArq)
		FErase(Alltrim(cLocalArq)+cArq)
	EndIf    
	
	nHandle := FCreate(Alltrim(cLocalArq)+cArq,0) 
	
	If nHandle > -1
		FWrite(nHandle,cCript6) 
		FClose(nHandle)
	
		Aviso("Aten��o","Arquivo Gerado com Sucesso no Diretorio: "+ Alltrim(cLocalArq) +" com o nome: "+cArq,{"Continuar"},1)
	Else
		Aviso("Aten��o","N�o foi possivel gerar o arquivo no diret�rio informado: "+Alltrim(cLocalArq) ,{"Continuar"},1)
	EndIf
Return lRet
