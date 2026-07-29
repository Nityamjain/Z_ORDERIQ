@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Exchange Rate Interface'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_Exchange_iq as select from zso_exchange_r
{
    key currency_code as CurrencyCode,
    key valid_from as ValidFrom,
    exchange_rate as ExchangeRate,
    valid_to as ValidTo,
    is_active as IsActive,
    created_by as CreatedBy,
    created_at as CreatedAt,
    changed_by as ChangedBy,
    changed_at as ChangedAt
}
