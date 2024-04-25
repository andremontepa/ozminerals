#ifdef SPANISH
	#define STR0001 "Emite una lista con los items en stock que alcanzaron el Punto de Pedido, "
	#define STR0002 "sugiriendo la cant. por comprar."
	#define STR0003 "A Rayas"
	#define STR0004 "Administracion"
	#define STR0005 "Itemes en Punto de Pedido"
	#define STR0006 "PRODUCTO(S)"
	#define STR0007 "CODIGO          DESCRIPCION                    TP GRP  UM SALDO ACTUAL     PUNTO DE     STOCK DE         LOTE ___TOLERANCIA___     CANTIDAD   CANTIDAD A   VALOR ESTIMADO BASE FECHA DE   VALOR UNITARIO     PLAZO DE"
	#define STR0008 "                                                                             PEDIDO    SEGUIRDAD    ECONOMICO   %     CANTIDAD   POR EMBAL.      COMPRAR     DE LA COMPRA      REFERENCIA   DE LA COMPRA      ENTREGA"
	#define STR0009 "ANULADO POR EL OPERADOR"
	#define STR0010 "TOTAL GENERAL A COMPRAR"
	#define STR0011 "Dia(s)"
	#define STR0012 "CODIGO                                  TP GRP  UN  SALDO ACTUAL       ENTRADA     PUNTO DE   ESTOQUE DE         LOTE ___TOLERANCIA___    CANTIDAD   CANTIDAD  A   VALOR ESTIMADO BASE  FECH  DE   VALOR UNITARIO     PLAZO DE"
	#define STR0013 "DESCRIPCION                                                           PREVISTA       PEDIDO    SEGURIDAD    ECONOMICO   %   CANTIDAD   POR EMBAL.      COMPRAR        DE  COMPRA      REFERENCIA      DE  COMPRA      ENTREGA"
	#define STR0014 "Atenc. "
	#define STR0015 "Actualizar patch del programa SIGACUS.PRW !"
	#define STR0016 "Actualizar patch del programa SIGACUSA.PRX !"
	#define STR0017 "Actualizar patch del programa SIGACUSB.PRX !"
	#define STR0018 "Ok"
	#define STR0019 "Saldo Actual"
	#define STR0020 "Entrada "
	#define STR0021 "Stock de"
	#define STR0022 "%"
	#define STR0023 "Cantidad"
	#define STR0024 " p Comprar"
	#define STR0025 "Base"
	#define STR0026 "Fch. de "
	#define STR0027 "Val.Unitario"
	#define STR0028 " de Compra"
	#define STR0029 "Imprimiendo"
	#define STR0030 "Prod. "
	#define STR0031 "Seguridad"
	#define STR0032 "Val.Estimado"
	#define STR0033 " de Compra"
	#define STR0034 "Plazo de"
	#define STR0035 "Entrega(Dias)"
	#define STR0036 "Referencia"
	#define STR0037 "Prevista"
	#define STR0040 "Ctd. por"
	#define STR0041 "Embalaje"
	#define STR0042 "TP"
	#define STR0043 "UM"
	#define STR0044 "Entrega"
	#define STR0045 "(Dias)"
#else
	#ifdef ENGLISH
		#define STR0001 "Lists the items in stock that reached the Point of Order and               "
		#define STR0002 "suggests quantity to be bought.  "
		#define STR0003 "Z.Form "
		#define STR0004 "Management   "
		#define STR0005 "Items in Point of Order"
		#define STR0006 "PRODUCT(S)"
		#define STR0007 "CODE            DESCRIPT.                      TP GRP  UM  CURR.BALANCE   POINT OF      SECURITY      ECONOMIC___TOLERANCE ___   QUANTITY    QUANTITY TO   VALUE  ESTIMAT BASE  DATE OF   UNIT VALUE OF      DELIVERY"
		#define STR0008 "                                                                             ORDER         STOCK          LOT  %      QUANTITY   PER PACK.      PURCHASE      OF PURCHASE       REFERENC       PURCHASE          TERM"
		#define STR0009 "CANCELLED BY OPERATOR  "
		#define STR0010 "TOTAL TO PURCHASE"
		#define STR0011 "Day(s)"
		#define STR0012 "CODE                                    TP GRP  UM  CURRENTBLNC       INFLOW      STOCK POINT        OF         LOT  ___TOLERANCE ___   QUANTITY   QUANTITY   A   ESTIMATE VALUE BASE  DATE      UNIT VALUE         TERM    "
		#define STR0013 "DESCRIPT.                                                            ESTIMATE       ORDER     SECURITY     ECONOMIC    %   QUANTITY     BY PACKAGE      BUY            OF PURCH.      REFERENCE       OF PURCH.      DELIV. "
		#define STR0014 "Warning"
		#define STR0015 "Update patch for program SIGACUS.PRW!"
		#define STR0016 "Update patch for program SIGACUSA.PRX!"
		#define STR0017 "Update patch for program SIGACUSB.PRX!"
		#define STR0018 "OK"
		#define STR0019 "Curr.Balan."
		#define STR0020 "Inflow  "
		#define STR0021 "Stock of  "
		#define STR0022 "%"
		#define STR0023 "Quantity  "
		#define STR0024 " to buy   "
		#define STR0025 "Base"
		#define STR0026 "Date of "
		#define STR0027 "Unit value  "
		#define STR0028 " of purchase"
		#define STR0029 "Printing  "
		#define STR0030 "Products"
		#define STR0031 "Safety   "
		#define STR0032 "Estimated Vl"
		#define STR0033 " of purchase"
		#define STR0034 "Delivery"
		#define STR0035 "Term (Days)  "
		#define STR0036 "Reference "
		#define STR0037 "Estimated"
		#define STR0040 "Qty. by  "
		#define STR0041 "Package  "
		#define STR0042 "TP"
		#define STR0043 "UM"
		#define STR0044 "Delivery"
		#define STR0045 "(Days)"
	#else
		#define STR0001 If( cPaisLoc $ "ANG|PTG", "Emite uma relação com os itens existentes que atingiram o ponto de pedido, ", "Emite uma relação com os itens em estoque que atingiram o Ponto de Pedido, " )
		#define STR0002 If( cPaisLoc $ "ANG|PTG", "A sugerir a quantidade a comprar.", "sugerindo a quantidade a comprar." )
		#define STR0003 If( cPaisLoc $ "ANG|PTG", "Código de barras", "Zebrado" )
		#define STR0004 If( cPaisLoc $ "ANG|PTG", "Administração", "Administracao" )
		#define STR0005 If( cPaisLoc $ "ANG|PTG", "Itens Em Ponto De Pedido", "Itens em Ponto de Pedido" )
		#define STR0006 If( cPaisLoc $ "ANG|PTG", "Artigo(s)", "PRODUTO(S)" )
		#define STR0007 If( cPaisLoc $ "ANG|PTG", "Código          Descrição               Tp Grp  Um  Saldo Actual       Entrada     Ponto De   Stock De         Lote ___tolerância___   Quantidade Quantidade A   Valor Estimado Base  Data De   Valor Unitário     Prazo De", "CODIGO          DESCRICAO               TP GRP  UM  SALDO ATUAL       ENTRADA     PONTO DE   ESTOQUE DE         LOTE ___TOLERANCIA___   QUANTIDADE QUANTIDADE A   VALOR ESTIMADO BASE  DATA DE   VALOR UNITARIO     PRAZO DE" )
		#define STR0008 If( cPaisLoc $ "ANG|PTG", "                                                                     Prevista       Pedido    Segurança    Económico   %   Quantidade   Por Embal.      Comprar        Da Compra      Referência      Da Compra      Entrega", "                                                                     PREVISTA       PEDIDO    SEGURANCA    ECONOMICO   %   QUANTIDADE   POR EMBAL.      COMPRAR        DA COMPRA      REFERENCIA      DA COMPRA      ENTREGA" )
		#define STR0009 If( cPaisLoc $ "ANG|PTG", "Cancelado Pelo Operador", "CANCELADO PELO OPERADOR" )
		#define STR0010 If( cPaisLoc $ "ANG|PTG", "Total Crial A Comprar", "TOTAL GERAL A COMPRAR" )
		#define STR0011 "Dia(s)"
		#define STR0012 If( cPaisLoc $ "ANG|PTG", "Código                                  Tp Tipo  Um  Saldo Actual       Entrada     Ponto De   Stock De         Lote ___tolerância___   Quantidade Quantidade A   Valor Estimado Base  Data De   Valor Unitário     Prazo De", "CODIGO                                  TP GRP  UM  SALDO ATUAL       ENTRADA     PONTO DE   ESTOQUE DE         LOTE ___TOLERANCIA___   QUANTIDADE QUANTIDADE A   VALOR ESTIMADO BASE  DATA DE   VALOR UNITARIO     PRAZO DE" )
		#define STR0013 If( cPaisLoc $ "ANG|PTG", "Descrição                                                            Prevista       Pedido    Segurança    Económico   %   Quantidade   Por Embal.      Comprar        Da Compra      Referência      Da Compra      Entrega", "DESCRICAO                                                            PREVISTA       PEDIDO    SEGURANCA    ECONOMICO   %   QUANTIDADE   POR EMBAL.      COMPRAR        DA COMPRA      REFERENCIA      DA COMPRA      ENTREGA" )
		#define STR0014 If( cPaisLoc $ "ANG|PTG", "Atenção", "Atencao" )
		#define STR0015 If( cPaisLoc $ "ANG|PTG", "Actualizar patch do programa sigacus.prw !!!", "Atualizar patch do programa SIGACUS.PRW !!!" )
		#define STR0016 If( cPaisLoc $ "ANG|PTG", "Actualizar patch do programa sigacusa.prx !!!", "Atualizar patch do programa SIGACUSA.PRX !!!" )
		#define STR0017 If( cPaisLoc $ "ANG|PTG", "Actualizar patch do programa sigacusb.prx !!!", "Atualizar patch do programa SIGACUSB.PRX !!!" )
		#define STR0018 "Ok"
		#define STR0019 If( cPaisLoc $ "ANG|PTG", "Saldo Actual", "Saldo Atual" )
		#define STR0020 "Entrada "
		#define STR0021 If( cPaisLoc $ "ANG|PTG", "Stock de", "Estoque de" )
		#define STR0022 "%"
		#define STR0023 "Quantidade"
		#define STR0024 If( cPaisLoc $ "ANG|PTG", " A Comprar", " a Comprar" )
		#define STR0025 "Base"
		#define STR0026 "Data de "
		#define STR0027 If( cPaisLoc $ "ANG|PTG", "Vlr.unitário", "Vlr.Unitario" )
		#define STR0028 If( cPaisLoc $ "ANG|PTG", " Da Compra", " da Compra" )
		#define STR0029 If( cPaisLoc $ "ANG|PTG", "A imprimir", "Imprimindo" )
		#define STR0030 If( cPaisLoc $ "ANG|PTG", "Artigos", "Produtos" )
		#define STR0031 If( cPaisLoc $ "ANG|PTG", "Segurança", "Seguranca" )
		#define STR0032 If( cPaisLoc $ "ANG|PTG", "Val.estimado", "Vlr.Estimado" )
		#define STR0033 If( cPaisLoc $ "ANG|PTG", " Da Compra", " da Compra" )
		#define STR0034 "Prazo de"
		#define STR0035 If( cPaisLoc $ "ANG|PTG", "Entrega(dias)", "Entrega(Dias)" )
		#define STR0036 If( cPaisLoc $ "ANG|PTG", "Referência", "Referencia" )
		#define STR0037 "Prevista"
		#define STR0040 If( cPaisLoc $ "ANG|PTG", "Qtd. por", "Qtde. por" )
		#define STR0041 "Embalagem"
		#define STR0042 "TP"
		#define STR0043 "UM"
		#define STR0044 "Entrega"
		#define STR0045 "(Dias)"
	#endif
#endif
