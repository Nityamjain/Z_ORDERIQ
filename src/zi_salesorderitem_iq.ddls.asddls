@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Sales Order Item Interface'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_SalesOrderItem_IQ
  as select from zso_item_iq
  association        to parent ZI_SalesOrder_IQ as _SalesOrder on $projection.OrderUuid = _SalesOrder.OrderUuid
  association [0..1] to ZI_Product_IQ           as _Product    on $projection.ProductId = _Product.ProductId


{
  key order_uuid              as OrderUuid,
  key item_uuid               as ItemUuid,
      item_number             as ItemNumber,
      product_id              as ProductId,
      @Semantics.quantity.unitOfMeasure: 'QuantityUnit'
      order_quantity          as OrderQuantity,
      quantity_unit           as QuantityUnit,
      @Semantics.amount.currencyCode : 'Currency'
      net_price               as NetPrice,
      @Semantics.amount.currencyCode : 'Currency'
      net_amount              as NetAmount,
      tax_code                as TaxCode,
      @Semantics.amount.currencyCode : 'Currency'
      tax_amount              as TaxAmount,
      currency                as Currency,
      requested_delivery_date as RequestedDeliveryDate,
      item_status             as ItemStatus,
      @Semantics.amount.currencyCode: 'USDCurrency'
      net_amount_usd          as NetAmountUSD,
      @Semantics.amount.currencyCode: 'USDCurrency'
      tax_amount_usd          as TaxAmountUSD,
      usd_currency            as USDCurrency,
      local_last_changed_at   as LocalLastChangedAt,
      _SalesOrder,
      _Product
}
