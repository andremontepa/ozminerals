#Include 'Protheus.ch'   
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CN120IT7  �Autor  � Toni Aguiar - STARSOFT em 22/03/2019    ���
�������������������������������������������������������������������������͹��
���Desc.     � Ponto de entrada para tratamento de campos espec�ficos     ���
���          � na gera��o do pedido de compras.                           ���
���A��o:     � Grava na Array com a observa��o da medi��o e grava         ���
���          � grava no pedido de compras                                 ���
���          �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � SIGAGCT>Atualiza��es>Movimentos>Medi��es/Entregas>CNTA120  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������    
*/

User Function CN120IT7()
Local _aItem := aClone(PARAMIXB[1])
Local _a := 0
Local _cProdut  := ""
For _a:=1 To Len(_aItem)
    _nPosOBS  := ASCAN(_aItem[_A], {|aVal| Alltrim(aVal[1]) == "C7_XOBS"})
    If _nPosOBS<=0
       AADD(_aItem[_a], {"C7_XOBS", CND->CND_OBS, Nil})  
    Endif
	If (nLin :=aScan(_aItem[_a],{|x|x[1]=="C7_PRODUTO"}))>0
		_cProdut  := _aItem[_a][nLin][2]
	Endif    
	DbSelectArea("SB1")
	SB1->(DbSetOrder(1))
	If (DbSeek(xFilial("SB1")+substr(_cProdut,1,TAMSX3("B1_COD")[1])))   
		AADD(_aItem[_a], {"C7_XTPAPL", SB1->B1_XAPROPR, Nil})
	Endif
Next

Return _aItem
 