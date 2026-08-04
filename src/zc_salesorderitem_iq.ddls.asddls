    @AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Sales Order Item Projection'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZC_SalesOrderItem_IQ
  as projection on ZI_SalesOrderItem_IQ
{
  key OrderUuid,
  key ItemUuid,
      ItemNumber,

      @Consumption.valueHelpDefinition: [
      {
      entity : {
      name    : 'ZVH_PRODUCT',
      element : 'ProductId'
      }
      }
      ]
      ProductId,

      @Semantics.quantity.unitOfMeasure: 'QuantityUnit'
      OrderQuantity,

      @Consumption.valueHelpDefinition: [ {
      entity: {
      name: 'I_UnitOfMeasure',
      element: 'UnitOfMeasure' } } ]


      QuantityUnit,
      @Semantics.amount.currencyCode: 'Currency'
      NetPrice,
      @Semantics.amount.currencyCode: 'Currency'
      NetAmount,
      TaxCode,
      @Semantics.amount.currencyCode: 'Currency'
      TaxAmount,

      Currency,
      USDCurrency,
       @Semantics.amount.currencyCode: 'USDCurrency'
      NetAmountUSD,
      @Semantics.amount.currencyCode: 'USDCurrency'
      TaxAmountUSD, 
      
      RequestedDeliveryDate,

      @Consumption.valueHelpDefinition: [{entity:{name: 'ZVH_ITEM_STATUS' , element:'ItemStatus'}}]
      
      ItemStatus,
      ExchangeRate,
      LocalLastChangedAt,
      /* Associations */
      _Product    : redirected to ZC_Product_IQ,
      _SalesOrder : redirected to parent ZC_SalesOrder_IQ
        
      
      
}
