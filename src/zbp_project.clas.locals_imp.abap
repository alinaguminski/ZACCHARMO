*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations
CLASS lhc_project DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS uploadOrgList  FOR MODIFY IMPORTING it_keys
                                                  FOR ACTION Project~uploadOrgList  RESULT rt_result.
    METHODS uploadAccounts FOR MODIFY IMPORTING it_keys
                                                  FOR ACTION Project~uploadAccounts RESULT rt_result.
ENDCLASS.

CLASS lhc_project IMPLEMENTATION.
  METHOD uploadOrgList.
*   to be implemented
  ENDMETHOD.

  METHOD uploadAccounts.
    TYPES: BEGIN OF t_fieldlist,
             fieldname(30) TYPE c,
             offset(6)     TYPE n,
             length(6)     TYPE n,
             type(1)       TYPE c,
             fieldtext(60) TYPE c,
           END   OF t_fieldlist.
    TYPES: BEGIN OF t_options,
             text(72) TYPE c,
           END OF   t_options.
    TYPES: BEGIN OF t_data,
             wa(512) TYPE c,
           END OF   t_data.
    DATA: l_rfcdest  TYPE rfcdest,
          l_srctab   TYPE tabname,
          l_dbtab    TYPE tabname,
          ls_source  TYPE zacc_project,
          ls_ccode   TYPE zacc_prorglist,
          lt_ccodes  TYPE TABLE OF zacc_prorglist,
          ls_flist   TYPE t_fieldlist,
          lt_flist   TYPE TABLE OF t_fieldlist,
          ls_option  TYPE t_options,
          lt_options TYPE TABLE OF t_options,
          lt_data    TYPE TABLE OF t_data.
    DATA: db_skb1  TYPE zacc_4ccode,
          dbt_skb1 TYPE TABLE OF zacc_4ccode,
          db_ska1  TYPE zacc_header,
          dbt_ska1 TYPE TABLE OF zacc_header,
          db_skat  TYPE zacc_text,
          dbt_skat TYPE TABLE OF zacc_text,
          db_cskb  TYPE zacc_costcat,
          dbt_cskb TYPE TABLE OF zacc_costcat.
    FIELD-SYMBOLS: <keys>    TYPE any,
                   <value>   TYPE any,
                   <srcdata> TYPE any,
                   <dbdata>  TYPE any,
                   <dbtab>   TYPE STANDARD TABLE.
       DELETE FROM zacc_4ccode WHERE project = @db_skb1-project
                               AND   source  = @db_skb1-source.
*   READ TABLE it_keys REFERENCE INTO DATA(lr_key) INDEX 1.
*   ls_source-project = lr_keys->project.
    LOOP AT it_keys ASSIGNING <keys>.
      MOVE-CORRESPONDING <keys> TO ls_source.
      CHECK ls_source-source IS NOT INITIAL.
      CLEAR l_rfcdest.
      SELECT SINGLE destination FROM  zacc_project
                                WHERE project = @ls_source-project
                                AND   source  = @ls_source-source
                                INTO  ( @l_rfcdest ).
      CHECK l_rfcdest IS NOT INITIAL.

      zcl_acc_uploader=>resolve_destination( CHANGING c_rfcdest = l_rfcdest ).
      CHECK l_rfcdest IS NOT INITIAL.

      CLEAR lt_ccodes.
      SELECT * FROM  zacc_prorglist
               WHERE project = @ls_source-project
               AND   source  = @ls_source-source
               INTO TABLE @lt_ccodes.

      LOOP AT lt_ccodes INTO ls_ccode WHERE bukrs IS NOT INITIAL.

        DO 4 TIMES.
          CLEAR: lt_options, lt_data, lt_flist.
          CASE sy-index.
            WHEN 1.
              l_srctab = 'SKB1'. l_dbtab = 'ZACC_4CCODE'.
              ASSIGN db_skb1  TO <dbdata>.
              ASSIGN dbt_skb1 TO <dbtab>.
              CONCATENATE '''' ls_ccode-bukrs '''' INTO ls_option-text.
              CONCATENATE 'BUKRS =' ls_option-text INTO ls_option-text SEPARATED BY space.
              APPEND ls_option TO lt_options.
            WHEN 2.
              l_srctab = 'SKA1'. l_dbtab = 'ZACC_HEADER'.
              ASSIGN db_ska1  TO <dbdata>.
              ASSIGN dbt_ska1 TO <dbtab>.
              CONCATENATE '''' ls_ccode-ktopl '''' INTO ls_option-text.
              CONCATENATE 'KTOPL =' ls_option-text INTO ls_option-text SEPARATED BY space.
              "APPEND ls_option TO lt_options.
            WHEN 3.
              l_srctab = 'SKAT'. l_dbtab = 'ZACC_TEXT'.
              ASSIGN db_skat  TO <dbdata>.
              ASSIGN dbt_skat TO <dbtab>.
              CONCATENATE '''' 'EN' '''' INTO ls_option-text.
              CONCATENATE 'SPRAS =' ls_option-text INTO ls_option-text SEPARATED BY space.
              APPEND ls_option TO lt_options.
            WHEN 4.
              l_srctab = 'CSKB'. l_dbtab = 'ZACC_COSTCAT'.
              ASSIGN db_cskb  TO <dbdata>.
              ASSIGN dbt_cskb TO <dbtab>.
              CONCATENATE '''' ls_ccode-kokrs '''' INTO ls_option-text.
              CONCATENATE 'KOKRS =' ls_option-text INTO ls_option-text SEPARATED BY space.
              "APPEND ls_option TO lt_options.
          ENDCASE.

          MOVE-CORRESPONDING ls_source TO <dbdata>.
          CALL FUNCTION 'RFC_READ_TABLE' DESTINATION l_rfcdest
            EXPORTING
              query_table          = l_srctab
            TABLES
              options              = lt_options
              fields               = lt_flist
              data                 = lt_data
            EXCEPTIONS
              table_not_available  = 1
              table_without_data   = 2
              option_not_valid     = 3
              field_not_valid      = 4
              not_authorized       = 5
              data_buffer_exceeded = 6.
          IF lines( lt_data ) > 0.
            "DELETE FROM (l_dbtab) WHERE project = @db_skb1-project
            "                       AND   source  = @db_skb1-source.
          ENDIF.
          LOOP AT lt_data ASSIGNING <srcdata>.
            LOOP AT lt_flist INTO ls_flist.
              ASSIGN COMPONENT ls_flist-fieldname OF STRUCTURE <dbdata> TO <value>.
              CHECK sy-subrc = 0.
              <value> = <srcdata>+ls_flist-offset(ls_flist-length).
            ENDLOOP.
            APPEND <dbdata> TO <dbtab>.
          ENDLOOP.
          INSERT (l_dbtab) FROM TABLE @<dbtab> ACCEPTING DUPLICATE KEYS.
        ENDDO.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
