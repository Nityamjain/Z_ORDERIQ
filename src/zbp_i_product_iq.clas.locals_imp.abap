CLASS lhc_ZI_Product_IQ DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR ZI_Product_IQ RESULT result.

    METHODS earlynumbering_create FOR NUMBERING
      IMPORTING entities FOR CREATE ZI_Product_IQ.

ENDCLASS.

CLASS lhc_ZI_Product_IQ IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

METHOD earlynumbering_create.

  SELECT MAX( product_id )
    FROM zproduct_mstr
    INTO @DATA(lv_max_product).

  DATA lv_number TYPE i.

  IF lv_max_product IS INITIAL.

    lv_number = 1.

  ELSE.

    lv_number = CONV i( lv_max_product+2(8) ).
    lv_number = lv_number + 1.

  ENDIF.

  LOOP AT entities INTO DATA(ls_entity).

    APPEND VALUE #(
      %cid       = ls_entity-%cid
      %is_draft  = ls_entity-%is_draft
      ProductId  = |PR{ lv_number WIDTH = 8 PAD = '0' }|
    ) TO mapped-zi_product_iq.

    lv_number += 1.

  ENDLOOP.

ENDMETHOD.

ENDCLASS.
