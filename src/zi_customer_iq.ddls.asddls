@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Customer Interface'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_Customer_IQ as select from zcustomer_mstr
{
    key customer_id as CustomerId,
    customer_name as CustomerName,
    @Semantics.amount.currencyCode: 'Currency'
    credit_limit as CreditLimit,
    currency as Currency,
    country as Country,
    is_active as IsActive,
    last_changed_at as LastChangedAt,
    local_last_changed_at as LocalLastChangedAt
  
}
