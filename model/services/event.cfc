// model/services/event
component accessors = true {

  variables.qPayPeriods = 0;

  public any function init( beanFactory ) {

    variables.beanFactory = beanFactory;

    variables.defaultOptions = {
      datasource = application.datasource
    };

    variables.qPayPeriods = QueryNew("pay_date");

    initPayPeriods( Year( Now() ) );

    return this;

  }

  private any function initPayPeriods( numeric for_year ) {

    // 1. find out how many Fridays there are in January of the specified date's year
    var targetYear = arguments.for_year; // eg. 2016.
    var janFirst = CreateDate(targetYear, 1, 1); // eg. Jan 1st, 2016.
    var janFirstDay = DayOfWeek( janFirst ); // eg. 6 (Friday)
    var janFirstFridayDate = 0;

    if (janFirstDay == 6 || janFirstDay == 5 || janFirstDay == 4) {  // if the 1st of Jan. is a Friday, Thursday, or Wednesday.

      var fridayOffset = 1;

      if (janFirstDay == 6)
        janFirstFridayDate = janFirst;

    } else {

      var fridayOffset = 0;

    }

    // get the first friday of the jan date above, offset by the aforementioned offset (iter: a week)
    var nextDate = janFirst;
    while (janFirstDay != 6) {

      nextDate = DateAdd( "d", 1, nextDate ); // keep adding days to the 1st of Jan.

      janFirstDay = DayOfWeek( nextDate ); // update janFirstDay

    }

    // if it wasn't before (line #35), janFirstFridayDate is now *definitely* a Friday.
    janFirstFridayDate = nextDate;

    QueryAddRow( variables.qPayPeriods )

    var firstPayPeriodOfYear = DateAdd( "ww", fridayOffset, janFirstFridayDate );

    QuerySetCell( variables.qPayPeriods, "pay_date", firstPayPeriodOfYear );

    // now, make the remaining 25 of 'em
    var currentPayPeriod = firstPayPeriodOfYear;

    for ( var a=1; a <= 25; a++ ) {
      var nextPayPeriod = DateAdd( "ww", 2, currentPayPeriod );

      QueryAddRow( variables.qPayPeriods );
      QuerySetCell( variables.qPayPeriods, "pay_date", nextPayPeriod );

      currentPayPeriod = nextPayPeriod;
    }

  }

  public any function get( string id ) {

    // an event doesn't have a single key - events only come by way of a user_id
    return getByUser( arguments.id );

  }

  public any function delete( string id ) {

    // an event doesn't have a single key - events only come by way of a user_id
    return deleteByUser( arguments.id )

  }

  public array function getByUser( string user_id ) {

    var sql = '
      SELECT c.card_id, c.user_id, c.card_label, c.min_payment, c.is_emergency, c.interest_rate, p.is_hot, p.calculated_payment, e.calculated_for_month, e.calculated_for_year, e.pay_date, e.balance
      FROM "pCards" c
      INNER JOIN "pPlans" p ON
        c.card_id = p.card_id
      INNER JOIN (
        SELECT last_updated
        FROM "pPlans"
        WHERE user_id = :uid
        GROUP BY last_updated
        ORDER BY last_updated DESC
        LIMIT 1
      ) AS PP ON 
        pp.last_updated = p.last_updated
      INNER JOIN "pEvents" e ON
        c.card_id = e.card_id
      INNER JOIN (
        SELECT last_updated
          FROM "pEvents"
          WHERE user_id = :uid
          GROUP BY last_updated
          ORDER BY last_updated DESC
        LIMIT 1
      ) AS EE ON
        ee.last_updated = e.last_updated
      WHERE c.user_id = :uid
      ORDER BY e.calculated_for_year, e.calculated_for_month, e.pay_date, c.card_id
    ';

    var params = {
      uid = {
        value = arguments.user_id, sqltype = 'integer'
      }
    };

    var result = QueryExecute( sql, params, variables.defaultOptions );
    var schedule = ArrayNew(1);
    var plan = StructNew();

    cfloop( query = result, group="calculated_for_month" ) {

      var plan = StructNew();

      cfloop() {

        var card = variables.beanFactory.getBean('cardBean');

        card.setCard_Id(result.card_id);
        card.setUser_Id(result.user_id);
        card.setLabel(result.card_label);
        card.setMin_Payment(result.min_payment);
        card.setIs_Emergency(result.is_emergency);
        card.setBalance(result.balance);
        card.setInterest_Rate(result.interest_rate);
        card.setIs_Hot(result.is_hot);
        card.setCalculated_Payment(result.calculated_payment);
        card.setPay_Date(result.pay_date);
        card.setCalculated_For_Month(result.calculated_for_month);
        card.setCalculated_For_Year(result.calculated_for_year);

        plan[card.getCard_Id()] = card;

      }

      ArrayAppend( schedule, plan );

    }

    return schedule;

  }

  public any function save( array events ) {

    var i=0;
    var sql=0;
    var result=0;
    var params={};

    sql = '
      INSERT INTO "pEvents" (
        calculated_for_month,
        calculated_for_year,
        card_id,
        pay_date,
        balance,
        user_id
      ) VALUES
    ';

    for ( var event in arguments.events ) {

      for ( var card in event ) {

        if ( event[card].getPay_Date() != '1900-1-1' ) {

          sql = sql & '(
            #event[card].getCalculated_For_Month()#,
            #event[card].getCalculated_For_Year()#,
            #event[card].getCard_Id()#,
            #CreateODBCDateTime(event[card].getPay_Date())#,
            #event[card].getBalance()#,
            #event[card].getUser_Id()#
          )';

          sql = sql & ',';

        }

      }

    }

    sql = Left( sql, Len(sql)-1 ); // trim trailing comma off
    sql = sql & ';';      // add a semi-colon to the end

    //trace( category="SQL", type="Information", text=sql );  

    result = QueryExecute( sql, params, variables.defaultOptions );

    return 0;

  }

  public any function deleteByUser( string user_id ) {

    var sql = '
      DELETE FROM "pEvents"
      WHERE user_id = :uid
    ';

    var params = {
      uid = {
        value = arguments.user_id, sqltype = 'integer'
      }
    };

    var result = QueryExecute( sql, params, variables.defaultOptions );

    return 0;

  }

  public query function qGetPayPeriods( numeric y ) {

    var the_start = CreateDate( arguments.y, 1, 1 );
    var the_end = CreateDate( arguments.y, 12, 31 );

    var sql = '
      SELECT pay_date
      FROM variables.qPayPeriods
      WHERE pay_date >= :start_d
      AND pay_date <= :end_d
      ORDER BY pay_date ASC;
    ';

    var params = {
      start_d = {
        value = the_start, sqltype = 'date'
      },
      end_d = {
        value = the_end, sqltype = 'date'
      }
    };

    var queryOptions = {
      dbtype = 'query'
    };

    var result = QueryExecute( sql, params, queryOptions );

    if (result.recordcount == 0) {
      // hack for now
      initPayPeriods(arguments.y);
      result = qGetPayPeriods(arguments.y);
    }

    return result;

  }

  public query function qGetPayPeriodsInMonthOfDate( date d ) {

    var result = 0;
    var year = Year(arguments.d);
    var month = Month(arguments.d);
    var the_start = CreateDate( year, month, 1 );
    var the_end = CreateDate( year, month, DaysInMonth(arguments.d) );

    var sql = '
      SELECT pay_date
      FROM variables.qPayPeriods
      WHERE pay_date >= :start_d
      AND pay_date <= :end_d
      ORDER BY pay_date ASC;
    ';

    var params = {
      start_d = {
        value = the_start, sqltype = 'date'
      },
      end_d = {
        value = the_end, sqltype = 'date'
      }
    };

    var queryOptions = {
      dbtype = 'query'
    };

    result = QueryExecute( sql, params, queryOptions );

    if (result.recordcount == 0) {
      // hack for now
      initPayPeriods(Year(arguments.d));
      result = qGetPayPeriodsInMonthOfDate(arguments.d);
    }

    return result;

  }

}