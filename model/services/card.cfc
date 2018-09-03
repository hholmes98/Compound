//model/services/card
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
  list() = get all cards for a user
  */

  public any function list( string user_id ) {

    var sql = '
      SELECT c.*
      FROM "pCards" c
      WHERE c.user_id = :uid
      ORDER BY c.card_id
    ';

    var params = {
      uid = {
        value = arguments.user_id, sqltype = 'integer' 
      }
    };

    var cards = {}

    var result = QueryExecute(sql, params, variables.defaultOptions);

    for ( var i = 1; i <= result.recordcount; i++ ) {
      var card = variables.beanFactory.getBean('cardBean');

      card.setCard_Id( result.card_id[i] );
      card.setCredit_Limit( result.credit_limit[i] );
      card.setDue_On_Day( result.due_on_day[i] );
      card.setUser_Id( result.user_id[i] );
      card.setLabel( result.card_label[i] );
      card.setMin_Payment( result.min_payment[i] );
      card.setIs_Emergency( result.is_emergency[i] );
      card.setBalance( result.balance[i] );
      card.setInterest_Rate( result.interest_rate[i] );
      card.setZero_APR_End_Date( result.zero_apr_end_date[i] );
      card.setCode( result.code[i] );
      card.setPriority( result.priority[i] );

      cards[card.getCard_Id()] = card;

    }

    return cards;

  }

  /*
  get() = get a specific card by its primary key
  */

  public any function get( string id ) {

    var sql = '
      SELECT c.*
      FROM "pCards" c
      WHERE c.card_id = :cid
    ';

    var params = {
      cid = {
        value = arguments.id, sqltype = 'integer'
      }
    };

    var result = QueryExecute(sql, params, variables.defaultOptions);
    var card = variables.beanFactory.getBean('cardBean');

    if ( result.RecordCount ) {

      card.setCard_Id( result.card_id[1] );
      card.setCredit_Limit( result.credit_limit[1] );
      card.setDue_On_Day( result.due_on_day[1] );
      card.setUser_Id( result.user_id[1] );
      card.setLabel( result.card_label[1] );
      card.setMin_Payment( result.min_payment[1] );
      card.setIs_Emergency( result.is_emergency[1] );
      card.setBalance( result.balance[1] );
      card.setInterest_Rate( result.interest_rate[1] );
      card.setZero_APR_End_Date( result.zero_apr_end_date[1] );
      card.setCode( result.code[1] );
      card.setPriority( result.priority[1] );

    }

    return card;

  }

  /*
  save() = save the contents of a single card
  */

  public any function save( any card ) {
    param name="card.credit_limit" default=-1;
    param name="card.due_on_day" default=0;
    param name="card.zero_apr_end_date" default="";
    param name="card.code" default="#Hash(RandRange(1,9999),'SHA-256','UTF-8')#";

    if ( IsDate( arguments.card.zero_apr_end_date ) && arguments.card.zero_apr_end_date != '1900-01-01' ) {
      var in_date = CreateODBCDate( arguments.card.zero_apr_end_date );
    } else {
      var in_date = 'NULL';
    }

    if ( arguments.card.card_id <= 0 ) {

      var sql = '
        INSERT INTO "pCards" (
          credit_limit,
          due_on_day,
          user_id,
          card_label,
          min_payment,
          is_emergency,
          balance,
          interest_rate,
          zero_apr_end_date,
          code,
          priority
        ) VALUES (
          #arguments.card.credit_limit#,
          #arguments.card.due_on_day#,
          #arguments.card.user_id#,
          :label,
          #arguments.card.min_payment#,
          #arguments.card.is_emergency#,
          #arguments.card.balance#,
          #arguments.card.interest_rate#,
          #in_date#,
          :code,
          #arguments.card.priority#
        ) RETURNING card_id AS card_id_out;
      ';

      var params = {
        label = {
          value = arguments.card.label, sqltype = 'varchar'
        },
        code = {
          value = arguments.card.code, sqltype = 'varchar'
        },
        psq = true
      };

      var result = QueryExecute( sql, params, variables.defaultOptions );

      return result.card_id_out;

    } else {

      // we'll skip user_id because a card will NEVER change to a diff owner. Ever.
      var sql = '
        UPDATE "pCards"
        SET
          credit_limit = #arguments.card.credit_limit#,
          due_on_day = #arguments.card.due_on_day#,
          card_label = :label,
          min_payment = #arguments.card.min_payment#,
          is_emergency = #arguments.card.is_emergency#,
          balance = #arguments.card.balance#,
          interest_rate = #arguments.card.interest_rate#,
          zero_apr_end_date = #in_date#,
          code = :code,
          priority = #arguments.card.priority#
        WHERE
          card_id = :cid;
      ';

      var params = {
        label = {
          value = arguments.card.label, sqltype = 'varchar'
        },
        code = {
          value = arguments.card.code, sqltype = 'varchar'
        },
        cid = {
          value = card.card_id, sqltype = 'integer'
        },
        psq = true
      };

      var result = QueryExecute( sql, params, variables.defaultOptions );

      return card.card_id;

    }

  }

  /*
  delete() = delete a specfic card
  */

  public any function delete( string id ) {

    var sql = '
      DELETE FROM "pCards" c
      WHERE c.card_id = :cid
    ';

    var params = {
      cid = {
        value = arguments.id, sqltype = 'integer'
      }
    };

    var result = QueryExecute( sql, params, variables.defaultOptions );

    return 0; // -1 if it is an error

  }

  /*
  purge() = delete all cards for a user
  */

  public any function purge( string user_id ) {

    var sql = '
      DELETE FROM "pCards" c
      WHERE c.user_id = :uid
    ';

    var params = {
      uid = {
        value = arguments.user_id, sqltype = 'integer'
      }
    };

    var result = QueryExecute( sql, params, variables.defaultOptions );

    return 0; // -1 if it is an error

  }

  /*
  create() = create a new user
  */

  /*************
  Card Functions
  *************/

  /* return a user's deck as a true deck object, rather than an arbitrary list of cards */
  public any function deck( string user_id ) {

    var deck = variables.beanFactory.getBean('deckBean'); // do not change to an array! json populates gaps in the ids, which dumps a bunch of routines!!

    var cards = list( arguments.user_id );

    for ( var card_id in cards ) {
      deck.addCard( cards[card_id] );
    }

    return deck;
  }

  public any function getEmergencyCard( string user_id ) {  // was getEmergencyCardByUser

    var sql = '
      SELECT c.card_id
      FROM "pCards" c
      WHERE c.user_id = :uid
      AND c.is_emergency = 1
    ';

    var params = {
      uid = {
        value = arguments.user_id, sqltype = 'integer'
      }
    };

    var result = QueryExecute( sql, params, variables.defaultOptions );

    var card = variables.beanFactory.getBean('cardBean');

    if ( result.RecordCount ) {

      card = get( result.card_id );

    }

    return card;

  }

  public any function setEmergencyCard( string e_card_id ) {  // was: setAsEmergency()

    // get the card itself
    var e_card = get( arguments.e_card_id );

    // get the user_id
    var user_id = e_card.getUser_Id();

    // blank out all the cards' emergency
    // then set the new one
    var sql = '
      UPDATE "pCards"
      SET
        is_emergency = 0
      WHERE
        user_id = :uid;
      UPDATE "pCards"
      SET
        is_emergency = 1
      WHERE 
        card_id = :cid;
    ';

    var params = {
      uid = {
        value = user_id, sqltype = 'integer'
      },
      cid = {
        value = arguments.e_card_id, sqltype = 'integer'
      }
    };

    var result = QueryExecute( sql, params, variables.defaultOptions );

    return 0; // -1 if error

  }

  public query function getCardCodes( numeric limit=0 ) {

    var sql = '
      SELECT 
        c.code, COUNT(DISTINCT c.code) AS total
      FROM 
        "pCards" c
      WHERE
        c.code <> ''''
      GROUP BY
        c.code
      ORDER BY
        total DESC';

    if ( arguments.limit > 0 ) {
      sql = sql & '
  LIMIT ' & arguments.limit;
    }

    sql = sql & ';';

    var params = {};

    var result = QueryExecute( sql, params, variables.defaultOptions );

    return result;

  }

}