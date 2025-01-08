#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FUN_PROD  �Autor  �Leonardo/Sangelles  � Data �  20/10/16   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function RFATA001
	
	Private cCadastro := "Cadastro de T�tulos de Provis�o."
	
	Private aRotina := { {"Pesquisar","AxPesqui",0,1} ,;
	             {"Visualizar","u_RFATA002('V')",0,2} ,;
	             {"Incluir"   ,"u_RFATA002('I')",0,3} ,;
	             {"Legenda"	  ,"u_RFATA002('L')" ,0,4} ,; 
	             {"Excluir"	  ,"u_RFATA002('C')" ,0,5} ,;
	             {"Estornar"  ,"u_RFATA002('E')",0,6} }
	 
	Private cDelFunc := ".T." // Validacao para a exclusao. Pode-se utilizar ExecBlock
	
	Private cString := "SZ1"
	
	dbSelectArea("SZ1")
	dbSetOrder(1)
	                         
	aCores :=  {{"Z1_STATUS == '1'","BR_VERDE"},;   
				{"Z1_STATUS == '2'","BR_VERMELHO"},;
				{"Z1_STATUS == '3'","BR_VERMELHO"}}   
	
	dbSelectArea(cString)
	mBrowse( 6,1,22,75,cString,,,,,,aCores)
	
Return
                        
      
