@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Customer Projection view'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZC_Customer_IQ
  as projection on ZI_Customer_IQ
{
  key CustomerId,
      CustomerName,
      @Semantics.amount.currencyCode: 'Currency'
      CreditLimit,

      @Consumption.valueHelpDefinition: [
      {  entity: {
      name: 'I_Currency',
      element: 'Currency'
      }} ]
      Currency,

      @Consumption.valueHelpDefinition: [
      {
      entity : {
      name    : 'ZVH_Country',
      element : 'Country'
      }
      }
      ]

      Country,
      IsActive,
      LastChangedAt,
      LocalLastChangedAt
}
