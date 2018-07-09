// model/services/card_paid
component accessors=true {

  public any function init( beanFactory ) {

    variables.beanFactory = arguments.beanFactory;

    variables.defaultOptions = {
      datasource = application.datasource
    };

    return this;

  }

  /******
    CRUD
  ******/
  /*
  save() = save the contents of a single card
  */

  public any function save( any card_paid ) {
    param name="arguments.card_paid.actually_paid_on" default=Now();

    var sql = '
      INSERT INTO "pUserCardsPaid" (
        user_id,
        card_id,
        actual_payment,
        actually_paid_on,
        payment_for_month,
        payment_for_year
      ) VALUES (
        #arguments.card_paid.user_id#,
        #arguments.card_paid.card_id#,
        #arguments.card_paid.actual_payment#,
        #CreateODBCDate(arguments.card_paid.actually_paid_on)#,
        #arguments.card_paid.payment_for_month#,
        #arguments.card_paid.payment_for_year#
      );
    ';

    var params = {};

    var result = QueryExecute( sql, params, variables.defaultOptions );

    return 0; // -1 if error

  }

  /* the intent here is show all the payments made for a given event - should be 1 payment per card, for a user */
  public any function list( string user_id, numeric month, numeric year ) {

    var sql = '
      SELECT 
        ucp.*
      FROM 
        "pUserCardsPaid" ucp
      WHERE (
          ucp.user_id = :uid
        AND 
          ucp.payment_for_month = :mid
        AND
          ucp.payment_for_year = :yid
      );
    ';

    var card_payments = [];

    var params = {
      uid = {
        value = arguments.user_id, sqltype = 'integer'
      },
      mid = {
        value = arguments.month, sqltype = 'integer'
      },
      yid = {
        value = arguments.year, sqltype = 'integer'
      }
    };

    var result = QueryExecute( sql, params, variables.defaultOptions );

    cfloop( query=result ) {
      var card_payment = variables.beanFactory.getBean('card_paidBean');

      card_payment.setUser_Id( result.user_id[result.currentRow] );
      card_payment.setCard_Id( result.card_id[result.currentRow] );
      card_payment.setActual_Payment( result.actual_payment[result.currentRow] );
      card_payment.setActually_Paid_On( result.actually_paid_on[result.currentRow] );
      card_payment.setPayment_For_Month( result.payment_for_month[result.currentRow] );
      card_payment.setPayment_For_Year( result.payment_for_year[result.currentRow] );

      ArrayAppend( card_payments, card_payment );

    }

    return card_payments;

  }

  /* the intent here is : get a specific payment paid for a specific card, for a specific event */
  public any function get( string card_id, numeric month, numeric year ) {

    var sql = '
      SELECT 
        ucp.*
      FROM 
        "pUserCardsPaid" ucp
      WHERE (
          ucp.card_id = :cid
        AND 
          ucp.payment_for_month = :mid
        AND
          ucp.payment_for_year = :yid
      );
    ';

    var params = {
      cid = {
        value = arguments.card_id, sqltype = 'integer'
      },
      mid = {
        value = arguments.month, sqltype = 'integer'
      },
      yid = {
        value = arguments.year, sqltype = 'integer'
      }
    };

    var result = QueryExecute( sql, params, variables.defaultOptions );

    var card_payment = variables.beanFactory.getBean('card_paidBean');

    if ( result.recordCount ) {

      card_payment.setUser_Id( result.user_id[1] );
      card_payment.setCard_Id( result.card_id[1] );
      card_payment.setActual_Payment( result.actual_payment[1] );
      card_payment.setActually_Paid_On( result.actually_paid_on[1] );
      card_payment.setPayment_For_Month( result.payment_for_month[1] );
      card_payment.setPayment_For_Year( result.payment_for_year[1] );

    }

    return card_payment;

  }

}