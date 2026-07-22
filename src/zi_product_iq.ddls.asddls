@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Product Interface'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_Product_IQ as select from zproduct_mstr
{
    key product_id as ProductId,
    product_name as ProductName,
    @Semantics.amount.currencyCode: 'Currency'
    net_price as NetPrice,
    currency as Currency,
    tax_code as TaxCode,
    @Semantics.quantity.unitOfMeasure: 'QuantityUnit'
    stock_quantity as StockQuantity,
    quantity_unit as QuantityUnit,
    is_active as IsActive,
    last_changed_at as LastChangedAt,
    local_last_changed_at as LocalLastChangedAt
}
