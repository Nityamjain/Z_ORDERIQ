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

      
      Currency,
      Country,
      IsActive,
      LastChangedAt,
      LocalLastChangedAt
}
