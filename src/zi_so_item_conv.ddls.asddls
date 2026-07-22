@EndUserText.label: 'Sales Order Currency Conversion'
define view entity ZI_SO_ITEM_CONV
  as select from zso_d_item_iq   as item
    inner join zso_d_header_iq   as hdr
      on item.orderuuid = hdr.orderuuid
{
  key item.itemuuid,
  key item.orderuuid,

      item.itemnumber,
      item.productid,

    
      item.currency as ItemCurrency,

      
      hdr.currency  as OrderCurrency,

      cast( hdr.orderdate as abap.dats ) as ExchangeDate,

      @Semantics.amount.currencyCode: 'ItemCurrency'
      item.netamount,

      @Semantics.amount.currencyCode: 'ItemCurrency'
      item.taxamount,

      @Semantics.amount.currencyCode: 'OrderCurrency'
      currency_conversion(
        amount              => item.netamount,
        source_currency     => item.currency,
        target_currency     => hdr.currency,
        exchange_rate_date  => cast( hdr.orderdate as abap.dats ),
        exchange_rate_type  => 'M',
        error_handling      => 'SET_TO_NULL'
      ) as ConvNetAmount,

      @Semantics.amount.currencyCode: 'OrderCurrency'
      currency_conversion(
        amount              => item.taxamount,
        source_currency     => item.currency,
        target_currency     => hdr.currency,
        exchange_rate_date  => cast( hdr.orderdate as abap.dats ),
        exchange_rate_type  => 'M',
        error_handling      => 'SET_TO_NULL'
      ) as ConvTaxAmount

}
