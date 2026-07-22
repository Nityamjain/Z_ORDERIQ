@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Product Projection'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZC_Product_IQ
  as projection on ZI_Product_IQ
{
  key ProductId,
      ProductName,
      @Semantics.amount.currencyCode: 'Currency'
      NetPrice,

      @Consumption.valueHelpDefinition: [
      {  entity: {
      name: 'I_Currency',
      element: 'Currency'
      }} ]
      Currency,

      @Consumption.valueHelpDefinition: [
      {  entity: {
      name: 'ZVH_TAXCODE_IQ',
      element: 'TaxCode'
      }} ]
      TaxCode,
      @Semantics.quantity.unitOfMeasure: 'QuantityUnit'
      StockQuantity,

      @Consumption.valueHelpDefinition: [ {
      entity: {
      name: 'I_UnitOfMeasure',
      element: 'UnitOfMeasure' } } ]
      QuantityUnit,
      IsActive,
      LastChangedAt,
      LocalLastChangedAt
}
