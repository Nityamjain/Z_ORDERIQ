@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Exchange Rate Projection'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZC_Exchange_iq as projection on ZI_Exchange_iq
{
    key CurrencyCode,
    key ValidFrom,
    ExchangeRate,
    ValidTo,
    IsActive,
    CreatedBy,
    CreatedAt,
    ChangedBy,
    ChangedAt
}
