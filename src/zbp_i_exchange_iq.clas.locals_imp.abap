CLASS lhc_ZI_Exchange_iq DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR ZI_Exchange_iq RESULT result.

    METHODS SetDefaults FOR DETERMINE ON MODIFY
      IMPORTING keys FOR ZI_Exchange_iq~SetDefaults.

    METHODS ValidateCurrencyExists FOR VALIDATE ON SAVE
      IMPORTING keys FOR ZI_Exchange_iq~ValidateCurrencyExists.

    METHODS ValidateDateRange FOR VALIDATE ON SAVE
      IMPORTING keys FOR ZI_Exchange_iq~ValidateDateRange.

    METHODS ValidateOverlap FOR VALIDATE ON SAVE
      IMPORTING keys FOR ZI_Exchange_iq~ValidateOverlap.

    METHODS ValidatePositiveRate FOR VALIDATE ON SAVE
      IMPORTING keys FOR ZI_Exchange_iq~ValidatePositiveRate.

    METHODS ValidateUSDRate FOR VALIDATE ON SAVE
      IMPORTING keys FOR ZI_Exchange_iq~ValidateUSDRate.
    METHODS CheckOverlap FOR DETERMINE ON MODIFY
      IMPORTING keys FOR ZI_Exchange_iq~CheckOverlap.

ENDCLASS.

CLASS lhc_ZI_Exchange_iq IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD SetDefaults.

  READ ENTITIES OF zi_exchange_iq IN LOCAL MODE
    ENTITY ZI_Exchange_iq
    ALL FIELDS
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_exchange).

  DATA lt_update TYPE TABLE FOR UPDATE zi_exchange_iq.

  LOOP AT lt_exchange INTO DATA(ls_exchange).

    DATA(lv_valid_to) = ls_exchange-ValidTo.

    IF lv_valid_to IS INITIAL.
      lv_valid_to = ls_exchange-ValidFrom + 90.
    ENDIF.

    APPEND VALUE #(

      %tky = ls_exchange-%tky

      ValidTo = lv_valid_to

      IsActive = COND #(
        WHEN ls_exchange-IsActive IS INITIAL
        THEN abap_true
        ELSE ls_exchange-IsActive )

    ) TO lt_update.

  ENDLOOP.

  MODIFY ENTITIES OF zi_exchange_iq IN LOCAL MODE
    ENTITY ZI_Exchange_iq
    UPDATE FIELDS (
      ValidTo
      IsActive
    )
    WITH lt_update.

ENDMETHOD.

 METHOD ValidateCurrencyExists.

  READ ENTITIES OF zi_exchange_iq IN LOCAL MODE
    ENTITY ZI_Exchange_iq
    ALL FIELDS
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_exchange).

  LOOP AT lt_exchange INTO DATA(ls_exchange).

    SELECT SINGLE @abap_true
      FROM zso_country
      WHERE currency_code = @ls_exchange-CurrencyCode
        AND is_active     = @abap_true
      INTO @DATA(lv_exists).

    IF lv_exists IS INITIAL.

      APPEND VALUE #(
        %tky = ls_exchange-%tky
      ) TO failed-zi_exchange_iq.

      APPEND VALUE #(
        %tky = ls_exchange-%tky
        %msg = new_message_with_text(
                 severity = if_abap_behv_message=>severity-error
                 text = |Currency { ls_exchange-CurrencyCode } does not exist in Country Master|
               )
      ) TO reported-zi_exchange_iq.

    ENDIF.

  ENDLOOP.

ENDMETHOD..

 METHOD ValidateDateRange.

  READ ENTITIES OF zi_exchange_iq IN LOCAL MODE
    ENTITY ZI_Exchange_iq
    ALL FIELDS
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_exchange).

  LOOP AT lt_exchange INTO DATA(ls_exchange).

    " Valid To mandatory
    IF ls_exchange-ValidTo IS INITIAL.

      APPEND VALUE #(
        %tky = ls_exchange-%tky
      ) TO failed-zi_exchange_iq.

      APPEND VALUE #(
        %tky = ls_exchange-%tky
        %msg = new_message_with_text(
                 severity = if_abap_behv_message=>severity-error
                 text     = 'Valid To date is mandatory'
               )
      ) TO reported-zi_exchange_iq.

      CONTINUE.

    ENDIF.

    " Valid To must be greater than or equal to Valid From
    IF ls_exchange-ValidTo < ls_exchange-ValidFrom.

      APPEND VALUE #(
        %tky = ls_exchange-%tky
      ) TO failed-zi_exchange_iq.

      APPEND VALUE #(
        %tky = ls_exchange-%tky
        %msg = new_message_with_text(
                 severity = if_abap_behv_message=>severity-error
                 text     = 'To date must be greater than or equal to From date'
               )
      ) TO reported-zi_exchange_iq.

    ENDIF.

  ENDLOOP.

ENDMETHOD.

  METHOD ValidateOverlap.

  READ ENTITIES OF zi_exchange_iq IN LOCAL MODE
    ENTITY zi_exchange_iq
    ALL FIELDS
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_exchange).

  LOOP AT lt_exchange INTO DATA(ls_exchange).

    SELECT SINGLE currency_code
      FROM zso_exchange_r
      WHERE currency_code = @ls_exchange-CurrencyCode
        AND valid_from <= @ls_exchange-ValidTo
        AND valid_to   >= @ls_exchange-ValidFrom
        AND NOT (
              currency_code = @ls_exchange-CurrencyCode
          AND valid_from    = @ls_exchange-ValidFrom
        )
      INTO @DATA(lv_currency).

    IF sy-subrc = 0.

      APPEND VALUE #(
        %tky = ls_exchange-%tky
      ) TO failed-zi_exchange_iq.

      APPEND VALUE #(
        %tky = ls_exchange-%tky
        %msg = new_message(
                 id       = 'ZSO_MSG'
                 number   = '013'
                 severity = if_abap_behv_message=>severity-error
               )
      ) TO reported-zi_exchange_iq.

    ENDIF.

  ENDLOOP.

ENDMETHOD.

  METHOD ValidatePositiveRate.

  READ ENTITIES OF zi_exchange_iq IN LOCAL MODE
    ENTITY zi_exchange_iq
    ALL FIELDS
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_exchange).

  LOOP AT lt_exchange INTO DATA(ls_exchange).

    IF ls_exchange-ExchangeRate <= 0.

      APPEND VALUE #(
        %tky = ls_exchange-%tky
      ) TO failed-zi_exchange_iq.

      APPEND VALUE #(
        %tky = ls_exchange-%tky
        %msg = new_message(
                 id       = 'ZSO_MSG'
                 number   = '014'
                 severity = if_abap_behv_message=>severity-error
               )
      ) TO reported-zi_exchange_iq.

    ENDIF.

  ENDLOOP.

ENDMETHOD.


  METHOD ValidateUSDRate.

  READ ENTITIES OF zi_exchange_iq IN LOCAL MODE
    ENTITY zi_exchange_iq
    ALL FIELDS
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_exchange).

  LOOP AT lt_exchange INTO DATA(ls_exchange).

    IF ls_exchange-CurrencyCode = 'USD'
       AND ls_exchange-ExchangeRate <> '1.00000'.

      APPEND VALUE #(
        %tky = ls_exchange-%tky
      ) TO failed-zi_exchange_iq.

      APPEND VALUE #(
        %tky = ls_exchange-%tky
        %msg = new_message(
                 id       = 'ZSO_MSG'
                 number   = '015'
                 severity = if_abap_behv_message=>severity-error
               )
      ) TO reported-zi_exchange_iq.

    ENDIF.

  ENDLOOP.

ENDMETHOD.



  METHOD CheckOverlap.

  READ ENTITIES OF zi_exchange_iq IN LOCAL MODE
    ENTITY zi_exchange_iq
    ALL FIELDS
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_exchange).

  LOOP AT lt_exchange INTO DATA(ls_exchange).

    IF ls_exchange-ValidFrom IS INITIAL
       OR ls_exchange-ValidTo IS INITIAL.
      CONTINUE.
    ENDIF.

    SELECT SINGLE currency_code
      FROM zso_exchange_r
      WHERE currency_code = @ls_exchange-CurrencyCode
        AND valid_from <= @ls_exchange-ValidTo
        AND valid_to   >= @ls_exchange-ValidFrom
        AND NOT (
            currency_code = @ls_exchange-CurrencyCode
        AND valid_from    = @ls_exchange-ValidFrom
        )
      INTO @DATA(lv_currency).

    IF sy-subrc = 0.

      APPEND VALUE #(
        %tky = ls_exchange-%tky
        %msg = new_message(
                  id       = 'ZSO_MSG'
                 number   = '013'
                 severity = if_abap_behv_message=>severity-error
               )
      ) TO reported-zi_exchange_iq.

    ENDIF.

  ENDLOOP.

ENDMETHOD.



ENDCLASS.
