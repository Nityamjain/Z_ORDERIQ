@EndUserText.label: 'Product Value Help'
@ObjectModel.dataCategory: #VALUE_HELP
define view entity ZVH_PRODUCT
  as select from zproduct_mstr
{
  key product_id   as ProductId,
      product_name as ProductName
}
