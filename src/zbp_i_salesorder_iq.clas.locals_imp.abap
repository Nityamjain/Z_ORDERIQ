CLASS lhc_zi_salesorderitem_iq DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS calculateItemAmount FOR DETERMINE ON MODIFY
      IMPORTING keys FOR ZI_SalesOrderItem_IQ~calculateItemAmount.

    METHODS calculateItemTax FOR DETERMINE ON MODIFY
      IMPORTING keys FOR ZI_SalesOrderItem_IQ~calculateItemTax.

    METHODS calculateHeaderTotals FOR DETERMINE ON MODIFY
      IMPORTING keys FOR ZI_SalesOrderItem_IQ~calculateHeaderTotals.

    METHODS deriveProductData FOR DETERMINE ON MODIFY
      IMPORTING keys FOR ZI_SalesOrderItem_IQ~deriveProductData.

    METHODS deriveDeliveryDate FOR DETERMINE ON MODIFY
      IMPORTING keys FOR ZI_SalesOrderItem_IQ~deriveDeliveryDate.

    METHODS setInitialItemStatus FOR DETERMINE ON MODIFY
      IMPORTING keys FOR ZI_SalesOrderItem_IQ~setInitialItemStatus.

    METHODS determineItemNumber FOR DETERMINE ON MODIFY
      IMPORTING keys FOR ZI_SalesOrderItem_IQ~determineItemNumber.

    METHODS validateProduct FOR VALIDATE ON SAVE
      IMPORTING keys FOR ZI_SalesOrderItem_IQ~validateProduct.

    METHODS validateStock FOR VALIDATE ON SAVE
      IMPORTING keys FOR ZI_SalesOrderItem_IQ~validateStock.
    METHODS validateQuantity FOR VALIDATE ON SAVE
      IMPORTING keys FOR ZI_SalesOrderItem_IQ~validateQuantity.

    METHODS validate_delivery_date FOR VALIDATE ON SAVE
      IMPORTING keys FOR ZI_SalesOrderItem_IQ~validate_delivery_date.
    METHODS ConfirmItem FOR MODIFY
      IMPORTING keys FOR ACTION ZI_SalesOrderItem_IQ~ConfirmItem RESULT result.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR ZI_SalesOrderItem_IQ RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR ZI_SalesOrderItem_IQ RESULT result.

    METHODS CancelItem FOR MODIFY
      IMPORTING keys FOR ACTION ZI_SalesOrderItem_IQ~CancelItem RESULT result.

    METHODS DeliverItem FOR MODIFY
      IMPORTING keys FOR ACTION ZI_SalesOrderItem_IQ~DeliverItem RESULT result.
    METHODS convertItemAmountToUSD FOR DETERMINE ON MODIFY
      IMPORTING keys FOR ZI_SalesOrderItem_IQ~convertItemAmountToUSD.
    METHODS determineExchangeRateItem FOR DETERMINE ON MODIFY
      IMPORTING keys FOR ZI_SalesOrderItem_IQ~determineExchangeRateItem.




ENDCLASS.

CLASS lhc_zi_salesorderitem_iq IMPLEMENTATION.

  METHOD calculateItemAmount.
    READ ENTITIES OF ZI_SalesOrder_IQ IN LOCAL MODE
    ENTITY ZI_SalesOrderItem_IQ
    FIELDS
    (
     ProductId
     OrderQuantity
     NetPrice
     NetAmount
    )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_items).

    DATA lt_update TYPE TABLE FOR UPDATE ZI_SalesOrderItem_IQ.

    LOOP AT lt_items  INTO DATA(ls_item).

      DATA(lv_price) = ls_item-NetPrice.
      DATA(lv_amount) = ls_item-NetAmount.

      IF lv_price IS INITIAL  AND ls_item-ProductId IS NOT INITIAL.

        SELECT SINGLE net_price
         FROM zproduct_mstr
         WHERE product_id = @ls_item-ProductId
         INTO @lv_price.

      ENDIF.


      lv_amount = ls_item-OrderQuantity * lv_price.

      APPEND VALUE #(
       %tky = ls_item-%tky
       NetPrice = lv_price
       NetAmount = lv_amount
       ) TO lt_update.

    ENDLOOP.

    MODIFY ENTITIES OF ZI_SalesOrder_IQ IN LOCAL MODE
    ENTITY ZI_SalesOrderItem_IQ
    UPDATE FIELDS
    ( NetPrice
      NetAmount
       ) WITH lt_update.


  ENDMETHOD.

  METHOD calculateItemTax.

    READ ENTITIES OF ZI_SalesOrder_IQ IN LOCAL MODE
      ENTITY ZI_SalesOrderItem_IQ
      FIELDS (
        ProductId
        TaxCode
        NetAmount
      )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_items).

    DATA lt_update TYPE TABLE FOR UPDATE ZI_SalesOrderItem_IQ.

    LOOP AT lt_items INTO DATA(ls_item).

      DATA: lv_taxcode TYPE zde_tax_code.
      DATA lv_taxrate TYPE p LENGTH 5 DECIMALS 2.
      DATA lv_taxamt  TYPE p LENGTH 15 DECIMALS 2.

      lv_taxcode = ls_item-TaxCode.

      IF lv_taxcode IS INITIAL
         AND ls_item-ProductId IS NOT INITIAL.

        SELECT SINGLE tax_code
          FROM zproduct_mstr
          WHERE product_id = @ls_item-ProductId
          INTO @lv_taxcode.

      ENDIF.

      CASE lv_taxcode.
        WHEN 'A1'.
          lv_taxrate = 5.
        WHEN 'A2'.
          lv_taxrate = 12.
        WHEN 'A3'.
          lv_taxrate = 18.
        WHEN 'A4'.
          lv_taxrate = 28.
        WHEN OTHERS.
          lv_taxrate = 0.
      ENDCASE.

      lv_taxamt = ls_item-NetAmount * lv_taxrate / 100.
      IF lv_taxcode <> ls_item-TaxCode
            OR lv_taxamt <> ls_item-TaxAmount.
        APPEND VALUE #(
          %tky      = ls_item-%tky
          TaxAmount = lv_taxamt
          TaxCode =  lv_taxcode
        ) TO lt_update.
      ENDIF.

    ENDLOOP.

    MODIFY ENTITIES OF ZI_SalesOrder_IQ IN LOCAL MODE
      ENTITY ZI_SalesOrderItem_IQ
      UPDATE FIELDS (
        TaxAmount
        TaxCode
      )
      WITH lt_update.

  ENDMETHOD.


  METHOD calculateHeaderTotals.

  READ ENTITIES OF ZI_SalesOrder_IQ IN LOCAL MODE
    ENTITY ZI_SalesOrder_IQ
    FIELDS ( OrderId )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_header).

  DATA lt_update TYPE TABLE FOR UPDATE ZI_SalesOrder_IQ.

  LOOP AT lt_header INTO DATA(ls_header).

    DATA lv_netamt TYPE zde_net_amount.
    DATA lv_taxamt TYPE zde_tax_amount.
    DATA lv_totalamt TYPE zde_total_amount_10.

    CLEAR: lv_netamt, lv_taxamt, lv_totalamt.

    READ ENTITIES OF ZI_SalesOrder_IQ IN LOCAL MODE
      ENTITY ZI_SalesOrder_IQ BY \_Items
      FIELDS ( NetAmountUSD TaxAmountUSD )
      WITH VALUE #( ( %tky = ls_header-%tky ) )
      RESULT DATA(lt_items).

    LOOP AT lt_items INTO DATA(ls_item).
      lv_netamt += ls_item-NetAmountUSD.
      lv_taxamt += ls_item-TaxAmountUSD.
    ENDLOOP.

    lv_totalamt = lv_netamt + lv_taxamt.

    APPEND VALUE #(
      %tky        = ls_header-%tky
      NetAmount   = lv_netamt
      TaxAmount   = lv_taxamt
      TotalAmount = lv_totalamt
      USDCurrency = 'USD'
    ) TO lt_update.

  ENDLOOP.

  IF lt_update IS NOT INITIAL.
    MODIFY ENTITIES OF ZI_SalesOrder_IQ IN LOCAL MODE
      ENTITY ZI_SalesOrder_IQ
      UPDATE FIELDS ( NetAmount TaxAmount TotalAmount USDCurrency )
      WITH lt_update.
  ENDIF.

ENDMETHOD.
  METHOD deriveProductData.

    READ ENTITIES OF ZI_SalesOrder_IQ IN LOCAL MODE
      ENTITY ZI_SalesOrderItem_IQ
      FIELDS ( ProductId )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_items).

    DATA lt_update TYPE TABLE FOR UPDATE ZI_SalesOrderItem_IQ.

    LOOP AT lt_items INTO DATA(ls_item).

      SELECT SINGLE
        net_price,
        tax_code,
        quantity_unit,
        currency
        FROM zproduct_mstr
        WHERE product_id = @ls_item-ProductId
        INTO @DATA(ls_product).

      APPEND VALUE #(
        %tky         = ls_item-%tky
        NetPrice     = ls_product-net_price
        TaxCode      = ls_product-tax_code
        QuantityUnit = ls_product-quantity_unit
        Currency = ls_product-currency
      ) TO lt_update.

    ENDLOOP.

    MODIFY ENTITIES OF ZI_SalesOrder_IQ IN LOCAL MODE
      ENTITY ZI_SalesOrderItem_IQ
      UPDATE FIELDS (
        NetPrice
        TaxCode
        QuantityUnit
        Currency
      )
      WITH lt_update.

  ENDMETHOD.

  METHOD deriveDeliveryDate.

    READ ENTITIES OF ZI_SalesOrder_IQ IN LOCAL MODE
      ENTITY ZI_SalesOrderItem_IQ
      FIELDS (
        RequestedDeliveryDate
        OrderUuid
      )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_items).

    DATA lt_update TYPE TABLE FOR UPDATE ZI_SalesOrderItem_IQ.

    LOOP AT lt_items INTO DATA(ls_item).

      "Keep manually entered date
      IF ls_item-RequestedDeliveryDate IS NOT INITIAL.
        CONTINUE.
      ENDIF.

      "Get order date from header
      SELECT SINGLE orderdate
        FROM zso_d_header_iq
        WHERE orderuuid = @ls_item-OrderUuid
        INTO @DATA(lv_order_date).

      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      APPEND VALUE #(
        %tky                  = ls_item-%tky
        RequestedDeliveryDate = lv_order_date + 14
      ) TO lt_update.

    ENDLOOP.

    IF lt_update IS NOT INITIAL.

      MODIFY ENTITIES OF ZI_SalesOrder_IQ IN LOCAL MODE
        ENTITY ZI_SalesOrderItem_IQ
        UPDATE FIELDS (
          RequestedDeliveryDate
        )
        WITH lt_update.

    ENDIF.

  ENDMETHOD.

  METHOD setInitialItemStatus.

    READ ENTITIES OF ZI_SalesOrder_IQ IN LOCAL MODE
      ENTITY ZI_SalesOrderItem_IQ
      FIELDS ( ItemStatus )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_items).

    DATA lt_update TYPE TABLE FOR UPDATE ZI_SalesOrderItem_IQ.

    LOOP AT lt_items INTO DATA(ls_item).

      "Edge case: already has a status
      IF ls_item-ItemStatus IS NOT INITIAL.
        CONTINUE.
      ENDIF.

      APPEND VALUE #(
        %tky       = ls_item-%tky
        ItemStatus = 'OP'
      ) TO lt_update.

    ENDLOOP.

    IF lt_update IS NOT INITIAL.

      MODIFY ENTITIES OF ZI_SalesOrder_IQ IN LOCAL MODE
        ENTITY ZI_SalesOrderItem_IQ
        UPDATE FIELDS ( ItemStatus )
        WITH lt_update.

    ENDIF.

  ENDMETHOD.

  METHOD determineItemNumber.

    READ ENTITIES OF ZI_SalesOrder_IQ IN LOCAL MODE
      ENTITY ZI_SalesOrderItem_IQ
      FIELDS ( ItemNumber )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_items).

    DATA lt_update TYPE TABLE FOR UPDATE ZI_SalesOrderItem_IQ.

    SELECT MAX( itemnumber )
      FROM zso_d_item_iq
      INTO @DATA(lv_max_item).

    DATA lv_next_number TYPE i.

    IF lv_max_item IS INITIAL.
      lv_next_number = 10001.
    ELSE.
      lv_next_number = lv_max_item + 1.
    ENDIF.

    LOOP AT lt_items INTO DATA(ls_item).

      IF ls_item-ItemNumber IS NOT INITIAL.
        CONTINUE.
      ENDIF.

      APPEND VALUE #(
        %tky       = ls_item-%tky
        ItemNumber = lv_next_number
      ) TO lt_update.

      lv_next_number = lv_next_number + 1.

    ENDLOOP.

    IF lt_update IS NOT INITIAL.

      MODIFY ENTITIES OF ZI_SalesOrder_IQ IN LOCAL MODE
        ENTITY ZI_SalesOrderItem_IQ
        UPDATE FIELDS ( ItemNumber )
        WITH lt_update.

    ENDIF.

  ENDMETHOD.


  METHOD validateProduct.

    READ ENTITIES OF ZI_SalesOrder_IQ IN LOCAL MODE
      ENTITY ZI_SalesOrder_IQ BY \_Items
      FIELDS ( ProductId )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_items).

    LOOP AT lt_items INTO DATA(ls_item).

      IF ls_item-ProductId IS INITIAL.

        APPEND VALUE #(
          %tky = ls_item-%tky
        ) TO failed-zi_salesorderitem_iq.

        APPEND VALUE #(
          %tky = ls_item-%tky
          %element-ProductId = if_abap_behv=>mk-on
          %state_area = ''
          %msg = new_message(
            id = 'ZSO_MSG'
            number = '011'
            severity = if_abap_behv_message=>severity-error )
        ) TO reported-zi_salesorderitem_iq.

        CONTINUE.

      ENDIF.

      SELECT SINGLE product_id,
                    is_active
        FROM zproduct_mstr
        WHERE product_id = @ls_item-ProductId
        INTO @DATA(ls_product).

      " Product does not exist
      IF sy-subrc <> 0.

        APPEND VALUE #(
          %tky = ls_item-%tky
        ) TO failed-zi_salesorderitem_iq.

        APPEND VALUE #(
          %tky = ls_item-%tky
          %element-ProductId = if_abap_behv=>mk-on
          %msg = new_message(
                   id       = 'ZSO_MSG'
                   number   = '004'
                   severity = if_abap_behv_message=>severity-error
                   v1       = ls_item-ProductId )
        ) TO reported-zi_salesorderitem_iq.

        CONTINUE.

      ENDIF.

      " Product inactive
      IF ls_product-is_active <> 'X'.

        APPEND VALUE #(
          %tky = ls_item-%tky
        ) TO failed-zi_salesorderitem_iq.

        APPEND VALUE #(
          %tky = ls_item-%tky
          %element-ProductId = if_abap_behv=>mk-on
          %msg = new_message(
                   id       = 'ZSO_MSG'
                   number   = '005'
                   severity = if_abap_behv_message=>severity-error
                   v1       = ls_item-ProductId )
        ) TO reported-zi_salesorderitem_iq.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD validateStock.


    READ ENTITIES OF ZI_SalesOrder_IQ IN LOCAL MODE
      ENTITY ZI_SalesOrderItem_IQ
      FIELDS (
        ProductId
        OrderQuantity
        OrderUuid
      )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_items).


    LOOP AT lt_items INTO DATA(ls_item).


      IF ls_item-ProductId IS INITIAL.
        CONTINUE.
      ENDIF.


      SELECT SINGLE stock_quantity
        FROM zproduct_mstr
        WHERE product_id = @ls_item-ProductId
        INTO @DATA(lv_stock_qty).


      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.


      IF ls_item-OrderQuantity > lv_stock_qty.


        APPEND VALUE #(
          %tky = ls_item-%tky
        ) TO failed-zi_salesorderitem_iq.


        APPEND VALUE #(
          %tky = ls_item-%tky


          %element-OrderQuantity = if_abap_behv=>mk-on


          %msg = new_message(
                   id       = 'ZSO_MSG'
                   number   = '006'
                   severity = if_abap_behv_message=>severity-error
                   v1       = CONV string( ls_item-ProductId )
                   v2       = |{ ls_item-OrderQuantity }|
                   v3       = |{ lv_stock_qty }| )
        ) TO reported-zi_salesorderitem_iq.


      ENDIF.


    ENDLOOP.


  ENDMETHOD.

  METHOD validateQuantity.

    READ ENTITIES OF ZI_SalesOrder_IQ IN LOCAL MODE
      ENTITY ZI_SalesOrderItem_IQ
      FIELDS (
        ProductId
        OrderQuantity
        OrderUuid
      )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_items).

    LOOP AT lt_items INTO DATA(ls_item).

      IF ls_item-OrderQuantity <= 0.

        APPEND VALUE #(
          %tky = ls_item-%tky
        ) TO failed-zi_salesorderitem_iq.

        APPEND VALUE #(
          %tky                    = ls_item-%tky
          %element-OrderQuantity  = if_abap_behv=>mk-on
          %state_area  = 'validation'
          %msg = new_message(
                   id       = 'ZSO_MSG'
                   number   = '007'
                   severity = if_abap_behv_message=>severity-error
                   v1       = CONV string( ls_item-ProductId ) )
        ) TO reported-zi_salesorderitem_iq.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD validate_delivery_date.

    READ ENTITIES OF ZI_SalesOrder_IQ IN LOCAL MODE
      ENTITY ZI_SalesOrderItem_IQ
      FIELDS (
        ProductId
        RequestedDeliveryDate
        OrderUuid
      )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_items).

    READ ENTITIES OF ZI_SalesOrder_IQ IN LOCAL MODE
      ENTITY ZI_SalesOrder_IQ
      FIELDS (
        OrderDate
      )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_header).

    LOOP AT lt_items INTO DATA(ls_item).

      READ TABLE lt_header INTO DATA(ls_header) INDEX 1.

      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      DATA(lv_min_delivery_date) = ls_header-OrderDate + 7.

      IF ls_item-RequestedDeliveryDate < lv_min_delivery_date.

        APPEND VALUE #(
          %tky = ls_item-%tky
        ) TO failed-zi_salesorderitem_iq.

        APPEND VALUE #(
          %tky                           = ls_item-%tky
          %element-RequestedDeliveryDate = if_abap_behv=>mk-on
          %msg = new_message(
                   id       = 'ZSO_MSG'
                   number   = '008'
                   severity = if_abap_behv_message=>severity-error
                   v1       = CONV string( ls_item-ProductId ) )
        ) TO reported-zi_salesorderitem_iq.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.





  METHOD get_instance_features.

  READ ENTITIES OF ZI_SalesOrder_IQ IN LOCAL MODE
    ENTITY ZI_SalesOrderItem_IQ
    FIELDS ( ItemStatus )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_items).

  result = VALUE #(
    FOR ls_item IN lt_items (

      %tky = ls_item-%tky

      %action-ConfirmItem =
        COND #(
          WHEN ls_item-ItemStatus = 'OP'
          THEN if_abap_behv=>fc-o-enabled
          ELSE if_abap_behv=>fc-o-disabled )

      %action-CancelItem =
        COND #(
          WHEN ls_item-ItemStatus = 'OP'
          THEN if_abap_behv=>fc-o-enabled
          ELSE if_abap_behv=>fc-o-disabled )

      %action-DeliverItem =
        COND #(
          WHEN ls_item-ItemStatus = 'CO'
          THEN if_abap_behv=>fc-o-enabled
          ELSE if_abap_behv=>fc-o-disabled )

    )
  ).

ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.


  METHOD ConfirmItem.

  MODIFY ENTITIES OF ZI_SalesOrder_IQ IN LOCAL MODE
    ENTITY ZI_SalesOrderItem_IQ
    UPDATE FIELDS ( ItemStatus )
    WITH VALUE #(
      FOR key IN keys (
        %tky       = key-%tky
        ItemStatus = 'CO'
      )
    ).

  READ ENTITIES OF ZI_SalesOrder_IQ IN LOCAL MODE
    ENTITY ZI_SalesOrderItem_IQ
    ALL FIELDS
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_result).

  result = VALUE #(
    FOR ls IN lt_result (
      %tky   = ls-%tky
      %param = ls
    )
  ).

ENDMETHOD.

  METHOD CancelItem.

  MODIFY ENTITIES OF ZI_SalesOrder_IQ IN LOCAL MODE
    ENTITY ZI_SalesOrderItem_IQ
    UPDATE FIELDS ( ItemStatus )
    WITH VALUE #(
      FOR key IN keys (
        %tky       = key-%tky
        ItemStatus = 'CN'
      )
    ).


  READ ENTITIES OF ZI_SalesOrder_IQ IN LOCAL MODE
    ENTITY ZI_SalesOrderItem_IQ
    ALL FIELDS
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_result).

  result = VALUE #(
    FOR ls IN lt_result (
      %tky   = ls-%tky
      %param = ls
    )
  ).

ENDMETHOD.


METHOD DeliverItem.

  MODIFY ENTITIES OF ZI_SalesOrder_IQ IN LOCAL MODE
    ENTITY ZI_SalesOrderItem_IQ
    UPDATE FIELDS ( ItemStatus )
    WITH VALUE #(
      FOR key IN keys (
        %tky       = key-%tky
        ItemStatus = 'DL'
      )
    ).

  READ ENTITIES OF ZI_SalesOrder_IQ IN LOCAL MODE
    ENTITY ZI_SalesOrderItem_IQ
    ALL FIELDS
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_result).

  result = VALUE #(
    FOR ls IN lt_result (
      %tky   = ls-%tky
      %param = ls
    )
  ).

ENDMETHOD.


  METHOD convertItemAmountToUSD.

  READ ENTITIES OF ZI_SalesOrder_IQ IN LOCAL MODE
    ENTITY ZI_SalesOrderItem_IQ
    FIELDS ( NetAmount TaxAmount Currency OrderUuid )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_items).

  DATA lt_update TYPE TABLE FOR UPDATE ZI_SalesOrderItem_IQ.

  LOOP AT lt_items INTO DATA(ls_item).

    " Get OrderDate AND Currency from the parent header (fallback source)
    READ ENTITIES OF ZI_SalesOrder_IQ IN LOCAL MODE
      ENTITY ZI_SalesOrder_IQ
      FIELDS ( OrderDate Currency )
      WITH VALUE #( ( OrderUuid = ls_item-OrderUuid ) )
      RESULT DATA(lt_header).

    READ TABLE lt_header INTO DATA(ls_header) INDEX 1.

    " Fallback: if header hasn't derived OrderDate yet (create timing), use today
    DATA(lv_order_date) = COND #( WHEN sy-subrc = 0 AND ls_header-OrderDate IS NOT INITIAL
                                   THEN ls_header-OrderDate
                                   ELSE sy-datum ).

    " Fallback: if item's own Currency isn't propagated yet, use header's Currency
    DATA(lv_currency) = COND #( WHEN ls_item-Currency IS NOT INITIAL
                                 THEN ls_item-Currency
                                 ELSE ls_header-Currency ).

    DATA lv_net_usd TYPE zde_net_amount.
    DATA lv_tax_usd TYPE zde_tax_amount.
    CLEAR: lv_net_usd, lv_tax_usd.

    IF lv_currency = 'USD'.

      lv_net_usd = ls_item-NetAmount.
      lv_tax_usd = ls_item-TaxAmount.

    ELSEIF lv_currency IS NOT INITIAL.

      SELECT SINGLE exchange_rate
        FROM zso_exchange_r
        WHERE currency_code = @lv_currency
          AND is_active     = @abap_true
          AND valid_from   <= @lv_order_date
          AND valid_to     >= @lv_order_date
        INTO @DATA(lv_rate).

      IF sy-subrc = 0 AND lv_rate > 0.
        lv_net_usd = ls_item-NetAmount / lv_rate.
        lv_tax_usd = ls_item-TaxAmount / lv_rate.
      ENDIF.

    ENDIF.

    APPEND VALUE #(
      %tky         = ls_item-%tky
      NetAmountUSD = lv_net_usd
      TaxAmountUSD = lv_tax_usd
      USDCurrency  = 'USD'
    ) TO lt_update.

  ENDLOOP.

  IF lt_update IS NOT INITIAL.
    MODIFY ENTITIES OF ZI_SalesOrder_IQ IN LOCAL MODE
      ENTITY ZI_SalesOrderItem_IQ
      UPDATE FIELDS ( NetAmountUSD TaxAmountUSD USDCurrency )
      WITH lt_update.
  ENDIF.

ENDMETHOD.

METHOD determineExchangeRateItem.

  READ ENTITIES OF ZI_SalesOrder_IQ IN LOCAL MODE
    ENTITY ZI_SalesOrderItem_IQ
    FIELDS ( Currency OrderUuid )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_items).

  DATA lt_update TYPE TABLE FOR UPDATE ZI_SalesOrderItem_IQ.

  LOOP AT lt_items INTO DATA(ls_item).

    " Get OrderDate from the parent header
    READ ENTITIES OF ZI_SalesOrder_IQ IN LOCAL MODE
      ENTITY ZI_SalesOrder_IQ
      FIELDS ( OrderDate )
      WITH VALUE #( ( OrderUuid = ls_item-OrderUuid ) )
      RESULT DATA(lt_header).

    READ TABLE lt_header INTO DATA(ls_header) INDEX 1.

    " Fallback: use today if header OrderDate hasn't derived yet (create timing)
    DATA(lv_order_date) = COND #( WHEN sy-subrc = 0 AND ls_header-OrderDate IS NOT INITIAL
                                   THEN ls_header-OrderDate
                                   ELSE sy-datum ).

    " Currency not propagated to item yet - skip, self-corrects on next pass
    IF ls_item-Currency IS INITIAL.
      CONTINUE.
    ENDIF.

    DATA(lv_exchange_rate) = COND zso_exchange_r-exchange_rate( WHEN ls_item-Currency = 'USD' THEN 1 ).

    IF ls_item-Currency <> 'USD'.

      SELECT SINGLE exchange_rate
        FROM zso_exchange_r
        WHERE currency_code = @ls_item-Currency
          AND is_active     = @abap_true
          AND valid_from   <= @lv_order_date
          AND ( valid_to   >= @lv_order_date OR valid_to = @( VALUE #( ) ) )
        INTO @lv_exchange_rate.

      IF sy-subrc <> 0.
        lv_exchange_rate = 0.
      ENDIF.

    ENDIF.

    APPEND VALUE #( %tky         = ls_item-%tky
                     ExchangeRate = lv_exchange_rate ) TO lt_update.

  ENDLOOP.

  IF lt_update IS NOT INITIAL.
    MODIFY ENTITIES OF ZI_SalesOrder_IQ IN LOCAL MODE
      ENTITY ZI_SalesOrderItem_IQ
      UPDATE FIELDS ( ExchangeRate )
      WITH lt_update.
  ENDIF.

ENDMETHOD.

ENDCLASS.


CLASS lhc_ZI_SalesOrder_IQ DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR ZI_SalesOrder_IQ RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR ZI_SalesOrder_IQ RESULT result.

    METHODS determineOrderID FOR DETERMINE ON MODIFY
      IMPORTING keys FOR ZI_SalesOrder_IQ~determineOrderID.
    METHODS setInitialOrderStatus FOR DETERMINE ON MODIFY
      IMPORTING keys FOR ZI_SalesOrder_IQ~setInitialOrderStatus.
    METHODS deriveOrderDate FOR DETERMINE ON MODIFY
      IMPORTING keys FOR ZI_SalesOrder_IQ~deriveOrderDate.
    METHODS deriveCustomerCurrency FOR DETERMINE ON MODIFY
      IMPORTING keys FOR ZI_SalesOrder_IQ~deriveCustomerCurrency.
    METHODS validateCustomer FOR VALIDATE ON SAVE
      IMPORTING keys FOR ZI_SalesOrder_IQ~validateCustomer.
    METHODS validateCreditLimit FOR VALIDATE ON SAVE
      IMPORTING keys FOR ZI_SalesOrder_IQ~validateCreditLimit.

    METHODS validateDuplicateProduct FOR VALIDATE ON SAVE
      IMPORTING keys FOR ZI_SalesOrder_IQ~validateDuplicateProduct.

    METHODS get_instance_features FOR INSTANCE FEATURES
  IMPORTING keys REQUEST requested_features
  FOR ZI_SalesOrder_IQ RESULT result.
    METHODS cancelorder FOR MODIFY
      IMPORTING keys FOR ACTION zi_salesorder_iq~cancelorder RESULT result.

    METHODS completeorder FOR MODIFY
      IMPORTING keys FOR ACTION zi_salesorder_iq~completeorder RESULT result.

    METHODS rejectorder FOR MODIFY
      IMPORTING keys FOR ACTION zi_salesorder_iq~rejectorder RESULT result.

    METHODS releaseorder FOR MODIFY
      IMPORTING keys FOR ACTION zi_salesorder_iq~releaseorder RESULT result.
    METHODS validateexchangerateavailable FOR VALIDATE ON SAVE
      IMPORTING keys FOR zi_salesorder_iq~validateexchangerateavailable.
    METHODS derivecustomercreditlimitusd FOR DETERMINE ON MODIFY
      IMPORTING keys FOR zi_salesorder_iq~derivecustomercreditlimitusd.
    METHODS determineexchangerate FOR DETERMINE ON MODIFY
      IMPORTING keys FOR zi_salesorder_iq~determineexchangerate.





ENDCLASS.

CLASS lhc_ZI_SalesOrder_IQ IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.




  METHOD determineOrderID.

    READ ENTITIES OF ZI_SalesOrder_IQ IN LOCAL MODE
      ENTITY ZI_SalesOrder_IQ
      FIELDS ( OrderId )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_orders).

    DATA lt_update TYPE TABLE FOR UPDATE ZI_SalesOrder_IQ.

    DATA: lv_max_active TYPE zde_so_order_id,
          lv_max_draft  TYPE zde_so_order_id,
          lv_max_order  TYPE zde_so_order_id,
          lv_number     TYPE i.

    " Get highest OrderId from draft table
    SELECT MAX( orderid )
      FROM zso_d_header_iq
      INTO @lv_max_active.

    " Get highest OrderId from active table
    SELECT MAX( order_id )
      FROM zso_header_IQ
      INTO @lv_max_draft.

    " Determine the highest OrderId overall
    IF lv_max_active IS INITIAL.
      lv_max_order = lv_max_draft.
    ELSEIF lv_max_draft IS INITIAL.
      lv_max_order = lv_max_active.
    ELSEIF lv_max_active > lv_max_draft.
      lv_max_order = lv_max_active.
    ELSE.
      lv_max_order = lv_max_draft.
    ENDIF.

    " Calculate next sequence number
    IF lv_max_order IS INITIAL.
      lv_number = 1.
    ELSE.
      lv_number = lv_max_order+2(8).
      lv_number = lv_number + 1.
    ENDIF.

    LOOP AT lt_orders INTO DATA(ls_order).

      " Skip if already assigned
      IF ls_order-OrderId IS NOT INITIAL.
        CONTINUE.
      ENDIF.

      APPEND VALUE #(
        %tky    = ls_order-%tky
        OrderId = |SO{ lv_number WIDTH = 8 PAD = '0' }|
      ) TO lt_update.

      lv_number = lv_number + 1.

    ENDLOOP.

    IF lt_update IS NOT INITIAL.

      MODIFY ENTITIES OF ZI_SalesOrder_IQ IN LOCAL MODE
        ENTITY ZI_SalesOrder_IQ
        UPDATE FIELDS ( OrderId )
        WITH lt_update.

    ENDIF.

  ENDMETHOD.


  METHOD setInitialOrderStatus.

    READ ENTITIES OF ZI_SalesOrder_IQ IN LOCAL MODE
      ENTITY ZI_SalesOrder_IQ
      FIELDS ( OverallStatus )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_orders).

    DATA lt_update TYPE TABLE FOR UPDATE ZI_SalesOrder_IQ.

    LOOP AT lt_orders INTO DATA(ls_order).

      "Edge case: status already supplied
      IF ls_order-OverallStatus IS NOT INITIAL.
        CONTINUE.
      ENDIF.

      APPEND VALUE #(
        %tky          = ls_order-%tky
        OverallStatus = 'NW'
      ) TO lt_update.

    ENDLOOP.

    IF lt_update IS NOT INITIAL.

      MODIFY ENTITIES OF ZI_SalesOrder_IQ IN LOCAL MODE
        ENTITY ZI_SalesOrder_IQ
        UPDATE FIELDS ( OverallStatus )
        WITH lt_update.

    ENDIF.

  ENDMETHOD.

  METHOD deriveOrderDate.

    READ ENTITIES OF ZI_SalesOrder_IQ IN LOCAL MODE
      ENTITY ZI_SalesOrder_IQ
      FIELDS ( OrderDate )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_orders).

    DATA lt_update TYPE TABLE FOR UPDATE ZI_SalesOrder_IQ.

    LOOP AT lt_orders INTO DATA(ls_order).

      "Keep manually entered date
      IF ls_order-OrderDate IS NOT INITIAL.
        CONTINUE.
      ENDIF.

      APPEND VALUE #(
        %tky      = ls_order-%tky
        OrderDate = cl_abap_context_info=>get_system_date( )
      ) TO lt_update.

    ENDLOOP.

    IF lt_update IS NOT INITIAL.

      MODIFY ENTITIES OF ZI_SalesOrder_IQ IN LOCAL MODE
        ENTITY ZI_SalesOrder_IQ
        UPDATE FIELDS ( OrderDate )
        WITH lt_update.

    ENDIF.

  ENDMETHOD.

  METHOD deriveCustomerCurrency.

    READ ENTITIES OF ZI_SalesOrder_IQ IN LOCAL MODE
      ENTITY ZI_SalesOrder_IQ
      FIELDS (
        CustomerId
        Currency
      )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_orders).

    DATA lt_update TYPE TABLE FOR UPDATE ZI_SalesOrder_IQ.

    LOOP AT lt_orders INTO DATA(ls_order).

      IF ls_order-CustomerId IS INITIAL.
        CONTINUE.
      ENDIF.

      SELECT SINGLE currency
        FROM zcustomer_mstr
        WHERE customer_id = @ls_order-CustomerId
        INTO @DATA(lv_currency).

      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      IF lv_currency <> ls_order-Currency.

        APPEND VALUE #(
          %tky     = ls_order-%tky
          Currency = lv_currency
        ) TO lt_update.

      ENDIF.

    ENDLOOP.

    IF lt_update IS NOT INITIAL.

      MODIFY ENTITIES OF ZI_SalesOrder_IQ IN LOCAL MODE
        ENTITY ZI_SalesOrder_IQ
        UPDATE FIELDS ( Currency )
        WITH lt_update.

    ENDIF.

  ENDMETHOD.

  METHOD validateCustomer.

    READ ENTITIES OF ZI_SalesOrder_IQ IN LOCAL MODE
      ENTITY ZI_SalesOrder_IQ
      FIELDS ( CustomerID )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_orders).

    LOOP AT lt_orders INTO DATA(ls_order).

      " Mandatory check
      IF ls_order-CustomerID IS INITIAL.

        APPEND VALUE #(
          %tky = ls_order-%tky
        ) TO failed-zi_salesorder_iq.

        APPEND VALUE #(
          %tky                = ls_order-%tky

          %element-CustomerId = if_abap_behv=>mk-on
          %state_area = 'VALIDATION'
          %msg = new_message(
                   id       = 'ZSO_MSG'
                   number   = '010'
                   severity = if_abap_behv_message=>severity-error )
        ) TO reported-zi_salesorder_iq.

        CONTINUE.

      ENDIF.

      " Check whether customer exists
      SELECT SINGLE customer_id,
                    is_active
        FROM zcustomer_mstr
        WHERE customer_id = @ls_order-CustomerID
        INTO @DATA(ls_customer).

      IF sy-subrc <> 0.

        APPEND VALUE #(
          %tky = ls_order-%tky
        ) TO failed-zi_salesorder_iq.

        APPEND VALUE #(
          %tky                = ls_order-%tky
          %element-CustomerId = if_abap_behv=>mk-on
          %msg = new_message(
                   id       = 'ZSO_MSG'
                   number   = '001'
                   severity = if_abap_behv_message=>severity-error
                   v1       = ls_order-CustomerID )
        ) TO reported-zi_salesorder_iq.

        CONTINUE.

      ENDIF.

      " Check whether customer is active
      IF ls_customer-is_active <> 'X'.

        APPEND VALUE #(
          %tky = ls_order-%tky
        ) TO failed-zi_salesorder_iq.

        APPEND VALUE #(
          %tky                = ls_order-%tky
          %state_area = 'VALIDATION'
          %element-CustomerId = if_abap_behv=>mk-on
          %msg = new_message(
                   id       = 'ZSO_MSG'
                   number   = '002'
                   severity = if_abap_behv_message=>severity-error
                   v1       = ls_order-CustomerID )
        ) TO reported-zi_salesorder_iq.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD validateCreditLimit.

  READ ENTITIES OF ZI_SalesOrder_IQ IN LOCAL MODE
    ENTITY ZI_SalesOrder_IQ
    FIELDS (
      CustomerId
      OrderId
      TotalAmount
      CreditLimitUSD
    )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_orders).

  LOOP AT lt_orders INTO DATA(ls_order).

    DATA: lv_credit_limit_usd  TYPE zde_credit_limit,
          lv_open_orders_total TYPE zde_total_amount_10,
          lv_total_exposure    TYPE zde_total_amount_10,
          lv_excess_amount     TYPE zde_total_amount_10.

    CLEAR:
      lv_credit_limit_usd,
      lv_open_orders_total,
      lv_total_exposure,
      lv_excess_amount.

    " Ignore incomplete drafts
    IF ls_order-CustomerId IS INITIAL
       OR ls_order-TotalAmount IS INITIAL.
      CONTINUE.
    ENDIF.

    " Credit limit already converted and stored on header (set by deriveCustomerCreditLimitUSD)
    lv_credit_limit_usd = ls_order-CreditLimitUSD.

    IF lv_credit_limit_usd IS INITIAL.
      CONTINUE.  " limit not yet derived - avoid false positive
    ENDIF.

    " Sum active orders of same customer (USD totals), exclude current order
    SELECT total_amount
      FROM zso_header_iq
      WHERE customer_id    = @ls_order-CustomerId
        AND overall_status <> 'CN'
        AND order_id       <> @ls_order-OrderId
      INTO TABLE @DATA(lt_amounts).

    LOOP AT lt_amounts INTO DATA(ls_amount).

      lv_open_orders_total =
        lv_open_orders_total +
        ls_amount-total_amount.

    ENDLOOP.

    " Current Draft Order + Existing Orders (all in USD)
    lv_total_exposure =
      lv_open_orders_total +
      ls_order-TotalAmount.

    IF lv_total_exposure > lv_credit_limit_usd.

      lv_excess_amount =
        lv_total_exposure -
        lv_credit_limit_usd.

      APPEND VALUE #(
        %tky = ls_order-%tky
      ) TO failed-zi_salesorder_iq.

      APPEND VALUE #(
        %tky = ls_order-%tky
        %msg = new_message(
                 id       = 'ZSO_MSG'
                 number   = '003'
                 severity = if_abap_behv_message=>severity-error
                 v1       = CONV string( ls_order-CustomerId )
                 v2       = CONV string( lv_credit_limit_usd )
                 v3       = CONV string( lv_excess_amount ) )
      ) TO reported-zi_salesorder_iq.

    ENDIF.

  ENDLOOP.

ENDMETHOD.

  METHOD validateDuplicateProduct.

    READ ENTITIES OF ZI_SalesOrder_IQ IN LOCAL MODE
      ENTITY ZI_SalesOrder_IQ BY \_Items
      ALL FIELDS
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_items).

    TYPES:
      BEGIN OF ty_duplicate,
        order_uuid TYPE sysuuid_x16,
        product_id TYPE zi_salesorderitem_iq-productid,
      END OF ty_duplicate.

    DATA lt_processed TYPE SORTED TABLE OF ty_duplicate
                      WITH UNIQUE KEY order_uuid product_id.

    LOOP AT lt_items INTO DATA(ls_item).

      IF ls_item-ProductId IS INITIAL.
        CONTINUE.
      ENDIF.

      READ TABLE lt_processed
        WITH KEY order_uuid = ls_item-OrderUuid
                 product_id = ls_item-ProductId
        TRANSPORTING NO FIELDS.

      IF sy-subrc = 0.
        CONTINUE.
      ENDIF.

      DATA(lv_count) = 0.

      LOOP AT lt_items INTO DATA(ls_dup)
        WHERE OrderUuid = ls_item-OrderUuid
          AND ProductId = ls_item-ProductId.

        lv_count += 1.

      ENDLOOP.

      IF lv_count > 1.

        APPEND VALUE #(
          %tky = VALUE #( OrderUuid = ls_item-OrderUuid )
        ) TO failed-zi_salesorder_iq.

        APPEND VALUE #(
          %tky = VALUE #( OrderUuid = ls_item-OrderUuid )
          %msg = new_message(
                   id       = 'ZSO_MSG'
                   number   = '012'
                   severity = if_abap_behv_message=>severity-error
                   v1       = CONV string( ls_item-ProductId ) )
        ) TO reported-zi_salesorder_iq.

        INSERT VALUE #(
          order_uuid = ls_item-OrderUuid
          product_id = ls_item-ProductId
        ) INTO TABLE lt_processed.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.




  METHOD get_instance_features.

  READ ENTITIES OF ZI_SalesOrder_IQ IN LOCAL MODE
    ENTITY ZI_SalesOrder_IQ
    FIELDS ( OverallStatus )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_orders).

  LOOP AT lt_orders INTO DATA(ls_order).

    APPEND VALUE #(

      %tky = ls_order-%tky

      %action-ReleaseOrder =
        COND #(
          WHEN ls_order-OverallStatus = 'NW'
          THEN if_abap_behv=>fc-o-enabled
          ELSE if_abap_behv=>fc-o-disabled )

      %action-RejectOrder =
        COND #(
          WHEN ls_order-OverallStatus = 'NW'
          THEN if_abap_behv=>fc-o-enabled
          ELSE if_abap_behv=>fc-o-disabled )

      %action-CancelOrder =
        COND #(
          WHEN ls_order-OverallStatus = 'NW'
            OR ls_order-OverallStatus = 'RL'
          THEN if_abap_behv=>fc-o-enabled
          ELSE if_abap_behv=>fc-o-disabled )

      %action-CompleteOrder =
        COND #(
          WHEN ls_order-OverallStatus = 'RL'
          THEN if_abap_behv=>fc-o-enabled
          ELSE if_abap_behv=>fc-o-disabled )

    ) TO result.

  ENDLOOP.

ENDMETHOD.

  METHOD CancelOrder.

    MODIFY ENTITIES OF ZI_SalesOrder_IQ IN LOCAL MODE
      ENTITY ZI_SalesOrder_IQ
      UPDATE FIELDS ( OverallStatus )
      WITH VALUE #(
        FOR key IN keys (
          %tky          = key-%tky
          OverallStatus = 'CN'
        )
      ).


        READ ENTITIES OF ZI_SalesOrder_IQ IN LOCAL MODE
    ENTITY ZI_SalesOrder_IQ
    ALL FIELDS
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_result).

  result = VALUE #(
    FOR ls IN lt_result (
      %tky   = ls-%tky
      %param = ls
    )
  ).

  ENDMETHOD.


  METHOD CompleteOrder.

    MODIFY ENTITIES OF ZI_SalesOrder_IQ IN LOCAL MODE
      ENTITY ZI_SalesOrder_IQ
      UPDATE FIELDS ( OverallStatus )
      WITH VALUE #(
        FOR key IN keys (
          %tky          = key-%tky
          OverallStatus = 'CM'
        )
      ).


        READ ENTITIES OF ZI_SalesOrder_IQ IN LOCAL MODE
    ENTITY ZI_SalesOrder_IQ
    ALL FIELDS
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_result).

  result = VALUE #(
    FOR ls IN lt_result (
      %tky   = ls-%tky
      %param = ls
    )
  ).

  ENDMETHOD.


METHOD RejectOrder.

  MODIFY ENTITIES OF ZI_SalesOrder_IQ IN LOCAL MODE
    ENTITY ZI_SalesOrder_IQ
    UPDATE FIELDS ( OverallStatus )
    WITH VALUE #(
      FOR key IN keys (
        %tky          = key-%tky
        OverallStatus = 'RJ'
      )
    ).

  READ ENTITIES OF ZI_SalesOrder_IQ IN LOCAL MODE
    ENTITY ZI_SalesOrder_IQ
    ALL FIELDS
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_result).

  result = VALUE #(
    FOR ls IN lt_result (
      %tky   = ls-%tky
      %param = ls
    )
  ).

ENDMETHOD.

METHOD ReleaseOrder.

  MODIFY ENTITIES OF ZI_SalesOrder_IQ IN LOCAL MODE
    ENTITY ZI_SalesOrder_IQ
    UPDATE FIELDS ( OverallStatus )
    WITH VALUE #(
      FOR key IN keys (
        %tky          = key-%tky
        OverallStatus = 'RL'
      )
    ).

  READ ENTITIES OF ZI_SalesOrder_IQ IN LOCAL MODE
    ENTITY ZI_SalesOrder_IQ
    ALL FIELDS
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_result).

  result = VALUE #(
    FOR ls_result IN lt_result (
      %tky   = ls_result-%tky
      %param = ls_result
    )
  ).

ENDMETHOD.

  METHOD validateExchangeRateAvailable.

  READ ENTITIES OF ZI_SalesOrder_IQ IN LOCAL MODE
    ENTITY ZI_SalesOrder_IQ
    FIELDS ( OrderDate CustomerId )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_orders).

  LOOP AT lt_orders INTO DATA(ls_order).

    IF ls_order-OrderDate IS INITIAL.
      CONTINUE.
    ENDIF.

    " 1. Check customer's own currency has a valid rate on OrderDate
    IF ls_order-CustomerId IS NOT INITIAL.

      SELECT SINGLE currency
        FROM zcustomer_mstr
        WHERE customer_id = @ls_order-CustomerId
        INTO @DATA(lv_cust_currency).

      IF sy-subrc = 0 AND lv_cust_currency <> 'USD'.

        SELECT SINGLE @abap_true
          FROM zso_exchange_r
          WHERE currency_code = @lv_cust_currency
            AND is_active     = @abap_true
            AND valid_from   <= @ls_order-OrderDate
            AND valid_to     >= @ls_order-OrderDate
          INTO @DATA(lv_rate_exists).

        IF lv_rate_exists IS INITIAL.

          APPEND VALUE #( %tky = ls_order-%tky ) TO failed-zi_salesorder_iq.

          APPEND VALUE #(
            %tky = ls_order-%tky
            %msg = new_message(
                     id       = 'ZSO_MSG'
                     number   = '016'
                     severity = if_abap_behv_message=>severity-error
                     v1       = lv_cust_currency
                     v2       = |{ ls_order-OrderDate DATE = USER }| )
          ) TO reported-zi_salesorder_iq.

        ENDIF.

      ENDIF.

    ENDIF.

    " 2. Check every item's currency has a valid rate on OrderDate
    READ ENTITIES OF ZI_SalesOrder_IQ IN LOCAL MODE
      ENTITY ZI_SalesOrder_IQ BY \_Items
      FIELDS ( Currency )
      WITH VALUE #( ( %tky = ls_order-%tky ) )
      RESULT DATA(lt_items).

    LOOP AT lt_items INTO DATA(ls_item).

      IF ls_item-Currency IS INITIAL OR ls_item-Currency = 'USD'.
        CONTINUE.
      ENDIF.

      SELECT SINGLE @abap_true
        FROM zso_exchange_r
        WHERE currency_code = @ls_item-Currency
          AND is_active     = @abap_true
          AND valid_from   <= @ls_order-OrderDate
          AND valid_to     >= @ls_order-OrderDate
        INTO @DATA(lv_item_rate_exists).

      IF lv_item_rate_exists IS INITIAL.

        APPEND VALUE #( %tky = ls_order-%tky ) TO failed-zi_salesorder_iq.

        APPEND VALUE #(
          %tky = ls_order-%tky
          %msg = new_message(
                   id       = 'ZSO_MSG'
                   number   = '017'
                   severity = if_abap_behv_message=>severity-error
                   v1       = ls_item-Currency
                   v2       = |{ ls_order-OrderDate DATE = USER }| )
        ) TO reported-zi_salesorder_iq.

      ENDIF.

    ENDLOOP.

  ENDLOOP.

ENDMETHOD.

METHOD deriveCustomerCreditLimitUSD.

  READ ENTITIES OF ZI_SalesOrder_IQ IN LOCAL MODE
    ENTITY ZI_SalesOrder_IQ
    FIELDS ( CustomerId OrderDate CreditLimit CreditLimitUSD )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_orders).

  DATA lt_update TYPE TABLE FOR UPDATE ZI_SalesOrder_IQ.

  LOOP AT lt_orders INTO DATA(ls_order).

    IF ls_order-CustomerId IS INITIAL OR ls_order-OrderDate IS INITIAL.
      CONTINUE.
    ENDIF.

    " Get customer's native credit limit and currency
    SELECT SINGLE credit_limit, currency
      FROM zcustomer_mstr
      WHERE customer_id = @ls_order-CustomerId
      INTO @DATA(ls_customer).

    IF sy-subrc <> 0.
      CONTINUE.
    ENDIF.

    DATA lv_credit_limit_usd TYPE zde_credit_limit.
    CLEAR lv_credit_limit_usd.

    " If customer currency is already USD, no conversion needed
    IF ls_customer-currency = 'USD'.

      lv_credit_limit_usd = ls_customer-credit_limit.

    ELSE.

      " Direct lookup from own exchange rate table - no FM, no cloud API
      SELECT SINGLE exchange_rate
        FROM zso_exchange_r
        WHERE currency_code = @ls_customer-currency
          AND is_active     = @abap_true
          AND valid_from   <= @ls_order-OrderDate
          AND valid_to     >= @ls_order-OrderDate
        INTO @DATA(lv_rate).

      IF sy-subrc = 0 AND lv_rate > 0.
        lv_credit_limit_usd = ls_customer-credit_limit / lv_rate.
      ELSE.
        lv_credit_limit_usd = 0.   " no valid rate found for that date
      ENDIF.

    ENDIF.

    APPEND VALUE #(
      %tky           = ls_order-%tky
      CreditLimit    = ls_customer-credit_limit
      CreditLimitUSD = lv_credit_limit_usd
      USDCurrency    = 'USD'
    ) TO lt_update.

  ENDLOOP.

  IF lt_update IS NOT INITIAL.
    MODIFY ENTITIES OF ZI_SalesOrder_IQ IN LOCAL MODE
      ENTITY ZI_SalesOrder_IQ
      UPDATE FIELDS ( CreditLimit CreditLimitUSD USDCurrency )
      WITH lt_update.
  ENDIF.

ENDMETHOD.

METHOD determineExchangeRate.

  READ ENTITIES OF ZI_SalesOrder_IQ IN LOCAL MODE
    ENTITY ZI_SalesOrder_IQ
    FIELDS ( OrderDate Currency )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_header).

  DATA lt_update TYPE TABLE FOR UPDATE ZI_SalesOrder_IQ.

  LOOP AT lt_header INTO DATA(ls_header).

    " Fallback: use today if OrderDate hasn't been derived yet (create timing)
    DATA(lv_order_date) = COND #( WHEN ls_header-OrderDate IS NOT INITIAL
                                   THEN ls_header-OrderDate
                                   ELSE sy-datum ).

    " Currency not derived yet in this pass - skip for now, will self-correct
    " once deriveCustomerCurrency writes it and re-triggers this determination
    IF ls_header-Currency IS INITIAL.
      CONTINUE.
    ENDIF.

    DATA(lv_exchange_rate) = COND zso_exchange_r-exchange_rate( WHEN ls_header-Currency = 'USD' THEN 1 ).

    IF ls_header-Currency <> 'USD'.

      SELECT SINGLE exchange_rate
        FROM zso_exchange_r
        WHERE currency_code = @ls_header-Currency
          AND is_active     = @abap_true
          AND valid_from   <= @lv_order_date
          AND ( valid_to   >= @lv_order_date OR valid_to = @( VALUE #( ) ) )
        INTO @lv_exchange_rate.

      IF sy-subrc <> 0.
        lv_exchange_rate = 0.   " no valid rate found for that date
      ENDIF.

    ENDIF.

    APPEND VALUE #( %tky         = ls_header-%tky
                     ExchangeRate = lv_exchange_rate ) TO lt_update.

  ENDLOOP.

  IF lt_update IS NOT INITIAL.
    MODIFY ENTITIES OF ZI_SalesOrder_IQ IN LOCAL MODE
      ENTITY ZI_SalesOrder_IQ
      UPDATE FIELDS ( ExchangeRate )
      WITH lt_update.
  ENDIF.

ENDMETHOD.


ENDCLASS.
