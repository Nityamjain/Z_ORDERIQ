@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Sales Order Header Projection'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZC_SalesOrder_IQ
  as projection on ZI_SalesOrder_IQ
{
  key OrderUuid,
      OrderId,

      @Consumption.valueHelpDefinition: [
      {
        entity: {
          name    : 'ZVH_CUSTOMER',
          element : 'CustomerId'
        }
      }
      ]
      CustomerId,
      OrderDate,


      @Consumption.valueHelpDefinition: [
      {  entity: {
        name: 'I_Currency',
        element: 'Currency'
      }} ]
      Currency,
      @Semantics.amount.currencyCode: 'Currency'
      NetAmount,
      @Semantics.amount.currencyCode: 'Currency'
      TaxAmount,
      @Semantics.amount.currencyCode: 'Currency'
      TotalAmount,


//      @Consumption.valueHelpDefinition: [{entity:{name: 'ZVH_ORDER_STATUS' , element:'OrderStatus'}}]
      OverallStatus,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt,
      /* Associations */
      _Customers : redirected to ZC_Customer_IQ,
      _Items     : redirected to composition child ZC_SalesOrderItem_IQ
}
