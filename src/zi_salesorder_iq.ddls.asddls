@AccessControl.authorizationCheck: #NOT_REQUIRED    
@EndUserText.label: 'Sales Order Header Interface'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_SalesOrder_IQ
  as select from zso_header_iq
  composition [0..*] of ZI_SalesOrderItem_IQ as _Items
  association [0..1] to ZI_Customer_IQ       as _Customers on $projection.CustomerId = _Customers.CustomerId
{
  key order_uuid            as OrderUuid,
      order_id              as OrderId,
      customer_id           as CustomerId,
      order_date            as OrderDate,
      currency              as Currency,

      @Semantics.amount.currencyCode: 'Currency'
      net_amount            as NetAmount,
      @Semantics.amount.currencyCode: 'Currency'
      tax_amount            as TaxAmount,
      @Semantics.amount.currencyCode: 'Currency'
      total_amount          as TotalAmount,  
      overall_status        as OverallStatus,

      @Semantics.amount.currencyCode: 'Currency'
      credit_limit          as CreditLimit,

      @Semantics.amount.currencyCode: 'USDCurrency'
      credit_limit_usd      as CreditLimitUSD,

      usd_currency          as USDCurrency,
      
      exchange_rate     as ExchangeRate,

      created_by            as CreatedBy,
      created_at            as CreatedAt,
      last_changed_by       as LastChangedBy,
      last_changed_at       as LastChangedAt,
      local_last_changed_at as LocalLastChangedAt,
      _Items,
      _Customers
}
