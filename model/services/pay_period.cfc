//model/services/pay_periods
component accessors=true {

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