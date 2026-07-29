CLASS lhc_ZI_Customer_IQ DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR ZI_Customer_IQ RESULT result.
    METHODS setcurrency FOR DETERMINE ON MODIFY
      IMPORTING keys FOR zi_customer_iq~setcurrency.


    METHODS earlynumbering_create FOR NUMBERING
      IMPORTING entities FOR CREATE ZI_Customer_IQ.

ENDCLASS.

CLASS lhc_ZI_Customer_IQ IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

METHOD earlynumbering_create.

  SELECT MAX( customer_id ) FROM zcustomer_mstr INTO @DATA(lv_max_active).
  SELECT MAX( customerid )  FROM zcustomer_d_mstr INTO @DATA(lv_max_draft).

  DATA(lv_max_customer) = COND #(
    WHEN lv_max_active > lv_max_draft THEN lv_max_active
    ELSE lv_max_draft ).

  DATA lv_number TYPE i.

  IF lv_max_customer IS INITIAL.
    lv_number = 1.
  ELSE.
    lv_number = CONV i( lv_max_customer+2(8) ) + 1.
  ENDIF.

  LOOP AT entities INTO DATA(ls_entity).
    APPEND VALUE #(
      %cid       = ls_entity-%cid
      %is_draft  = ls_entity-%is_draft
      customerid = |CU{ lv_number WIDTH = 8 PAD = '0' }|
    ) TO mapped-zi_customer_iq.
    lv_number += 1.
  ENDLOOP.

ENDMETHOD.


METHOD setcurrency.

    READ ENTITIES OF ZI_Customer_IQ IN LOCAL MODE
      ENTITY ZI_Customer_IQ
        FIELDS ( Country Currency ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_customers).

    DATA lt_update TYPE TABLE FOR UPDATE ZI_Customer_IQ.

    LOOP AT lt_customers INTO DATA(ls_customer) WHERE Country IS NOT INITIAL.

      SELECT SINGLE currency_code
        FROM zso_country
        WHERE country_code = @ls_customer-Country
        INTO @DATA(lv_currency).

      IF sy-subrc = 0 AND lv_currency <> ls_customer-Currency.
        APPEND VALUE #(
          %tky     = ls_customer-%tky
          Currency = lv_currency
          %control-Currency = if_abap_behv=>mk-on
        ) TO lt_update.
      ENDIF.

    ENDLOOP.

    IF lt_update IS NOT INITIAL.
      MODIFY ENTITIES OF ZI_Customer_IQ IN LOCAL MODE
        ENTITY ZI_Customer_IQ
          UPDATE FIELDS ( Currency ) WITH lt_update
        REPORTED DATA(lt_reported).
    ENDIF.

  ENDMETHOD.

ENDCLASS.
