// model/services/mail
component accessors = true {

  property eventservice;
  property planservice;

  public any function init( beanFactory ) {

    variables.nl = chr(13) & chr(10);
    variables.beanFactory = beanFactory;

    variables.defaultOptions = {
      datasource = application.datasource
    };

    variables.qoqOptions = {
      dbtype = 'query'
    };

    return this;

  }

  public string function sendReminderEmail( string dest_email, struct reminder_cards ) {

    var mailBody = 'It''s time to pay some bills!

Yep. It''s that time again. So, here is a friendly reminder from the folks at ' & application.locale[session.auth.locale]['name'] & ' on your upcoming card due dates.

Here is the next batch of cards you''ll want to pay, and when:' & nl & nl;

    for ( var this_card in arguments.reminder_cards ) {

      mailBody = mailBody & '- Pay $' & arguments.reminder_cards[this_card].getCalculated_Payment() & ' to ' & arguments.reminder_cards[this_card].getLabel() & ' on ' & DateFormat(arguments.reminder_cards[this_card].getPay_Date(),"long") & variables.nl;

    }

    mailBody = mailBody & nl & 'Be sure to head on back to the calculator to update the balances & minimum payments as you go!' & nl & nl;
    mailBody = mailBody & ' - Pay bills now: ' & application.base_url & '/index.cfm/pay/cards' & nl;
    mailBody = mailBody & ' - Update Email Preferences/Unsubscribe: ' & application.base_url & '/index.cfm/profile/basic' & nl & nl;
    mailBody = mailBody & 'Sincerely,

Your friends at ' & application.locale[session.auth.locale]['name'];

    // send the email
    cfmail(
        to = arguments.dest_email,
        from = application.locale[session.auth.locale]['name'] & " <" & application.admin_email & ">",
        subject = "[" & application.locale[session.auth.locale]['name'] & "] Time to Pay Some Bills!" ) {
      WriteOutput(mailBody);
    }

    // return the body of the email
    return mailBody;

  }


  function sendPasswordResetEmail( dest_email, key, dest_url ) {

    var mailBody = 'Greetings!

Someone (possibly you) requested a password reset. If you requested this reset, please click the link below to confirm the reset.

' & application.base_url & dest_url & '/q/' & key & '

If it was not you, please disregard this email completely.

Sincerely, 
Your friends at ' & application.locale[session.auth.locale]['name'];

    // send the email
    cfmail(
        to = dest_email,
        from = application.locale[session.auth.locale]['name'] & " <" & application.admin_email & ">",
        subject = "[" & application.locale[session.auth.locale]['name'] & "] Password Reset Request" ) {
      WriteOutput(mailBody);
    }

    // log the change request, for audit purposes.

  }

  function verifyUser( dest_email, plain_password ) {

    var mailBody = 'Welcome to ' & application.locale[session.auth.locale]['name'] & '!

Someone (possibly you) has created an account. If this is, in fact, you, here is your starting password:

' & plain_password & '

Use this as a temporary password to log in to your new account. We look forward to helping you become financially secure!

Be sure to update your password in profile > basic settings.

Sincerely,
Your friends at ' & application.locale[session.auth.locale]['name'];

    // send the email
    cfmail( 
        to = dest_email,
        from = application.locale[session.auth.locale]['name'] & " <" & application.admin_email & ">",
        subject = "[" & application.locale[session.auth.locale]['name'] & "] New Account" ) {
      WriteOutput(mailBody);
    }

  }

  function sendError( dest_email, e, requested_url ) {

    var errorBody = '';
    var tagBody = '';
    var msg = "Unknown";
    var tagCount = 1;
    var offender = StructNew();

    errorBody &= 'URL: ' & requested_url & nl & nl;

    if ( StructKeyExists(e,'message') ) {
      msg = e.message;
      errorBody &= 'Message: ' & msg & nl & nl;
    }

    if ( StructKeyExists(e, 'stacktrace') ) {
      errorBody &= 'Stack Trace: ' & nl & e.stacktrace & nl & nl;
    }

    if ( StructKeyExists(e, 'tagcontext') ) {

      for (tag in e.tagcontext) {

        savecontent variable="tagBody" append=true {
          WriteDump( var=tag, format="text" );
        }

        if (tagCount == 1) {
          offender = tag;
        }

        tagCount++;
      }

      errorBody &= 'Start at:' & nl;
      errorBody &= '- Line: ' & offender.line & nl;
      errorBody &= '- Template: ' & offender.template & nl;
      errorBody &= '- Code: ' & nl & offender.codePrintPlain & nl & nl;

      errorBody &= 'Tag Context: ' & tagBody & nl & nl;

    }

    cfmail(
        to = dest_email,
        from = application.admin_email,
        subject = "[" & application.locale[session.auth.locale]['name'] & "] ERROR: " & msg ) {
      WriteOutput(errorBody);
    }

  }

  /********

   main scheduled task

  *********/
  remote function processReminders( date for_date, date today=Now() ) {

    var email_list = StructNew();

    // 0. load all users into memory that allow email reminders
    var qUsersToRemind = qryGetUsersWithEmailReminders();

    // 1. if (today = Last Day of Month)
    if ( !DateCompare( arguments.for_date, GetEndDateOfMonth( arguments.today ), "d" ) ) {

      var qLastDayUsers = qryGetLastDayUsers( qUsersToRemind, arguments.for_date, arguments.today );

      cfloop( query=qLastDayUsers ) {
        email_list[qLastDayUsers.user_id[qLastDayUsers.currentRow]] = qLastDayUsers.email[qLastDayUsers.currentRow];
      }

      //writeDump(qLastDayUsers);

    }

    // 2. if (today = 15th of Month)
    if ( !DateCompare( arguments.for_date, CreateDate( Year( arguments.today ), Month( arguments.today ), 15), "d" ) ) {

      var qFifteenthDayUsers = qryGetFifteenthDayUsers( qUsersToRemind, arguments.for_date, arguments.today );

      cfloop( query=qFifteenthDayUsers ) {
        email_list[qFifteenthDayUsers.user_id[qFifteenthDayUsers.currentRow]] = qFifteenthDayUsers.email[qFifteenthDayUsers.currentRow];
      }

      //writeDump(qFifteenthDayUsers);

    }

    // 3. if (today = one of the calculated pay dates)
    var qryPayDatesInThisMonth = eventservice.qGetPayPeriodsInMonthOfDate( arguments.today );

    cfloop( query=qryPayDatesInThisMonth ) {

      if ( !DateCompare( arguments.for_date, qryPayDatesInThisMonth.pay_date[qryPayDatesInThisMonth.currentRow], "d" ) ) {

        var qEveryTwoWeekUsers = qryGetEveryTwoWeekUsers( qUsersToRemind, arguments.for_date, arguments.today );

        cfloop( query=qEveryTwoWeekUsers ) {

          email_list[qEveryTwoWeekUsers.user_id[qEveryTwoWeekUsers.currentRow]] = qEveryTwoWeekUsers.email[qEveryTwoWeekUsers.currentRow];

        }

        //writeDump(qEveryTwoWeekUsers);

        break;

      }

    }

    // 4. TODO: if (today = any card's due date)
    // return all users whose email_frequency == 3.

    // 5. TODO: return all users whose email_frequency == 1 and have had email sent this month already (pEmails)
    // remove all those user_ids from email_list

    // 6. Batch out all the emails in email_list, logging each email into pEmails (email_id, user_id, email, date_sent, body)
    emailReminders( email_list );

    // return struct of of emails (key:user_id) that were emailed a reminder.
    return email_list;

  }

  public numeric function logReminderEmail( numeric user_id, string email_address, string email_body ) {

    var sql = '
      INSERT INTO "pEmails" (
        user_id,
        email,
        body
      ) VALUES (
        #arguments.user_id#,
        ''#arguments.email_address#'',
        :body
      ) 
      RETURNING
        email_id AS email_id_out;
    ';

    var params = {
      body = {
        value = arguments.email_body, sqltype = 'varchar'
      }
    };

    var result = QueryExecute( sql, params, variables.defaultOptions );

    return result.email_id_out;

  }

  public void function emailReminders( struct users ) {

    for ( var thisUser in arguments.users ) {

      var id = thisUser;
      var email = arguments.users[thisUser];
      var events = planservice.dbCalculateSchedule( id );

      // email it
      var bodyCopy = sendReminderEmail( email, events[1] );

      // log it
      var email_id = logReminderEmail( id, email, bodyCopy );

    }

  }

  function qryGetUsersWithEmailReminders() {

    // only return users that have
    // 1. email_reminders on
    // 2. an email_frequency > 0, and
    // 3. that have at least 1 card.
    var sql = '
      SELECT u.user_id, u.email, up.pay_frequency, up.email_frequency
      FROM "pUsers" u 
      INNER JOIN "pUserPreferences" up ON
        u.user_id = up.user_id
      INNER JOIN "pCards" c ON
        u.user_id = c.user_id
      WHERE up.email_reminders = 1
      AND up.email_frequency > 0
      GROUP BY u.user_id, up.pay_frequency, up.email_frequency
      ORDER BY u.user_id
    ';

    var params = {};

    var result = QueryExecute( sql, params, variables.defaultOptions );

    return result;

  }

  /* should target users who are paid:
  - once a month (lastDay), 
  - twice a month (15th, last day),
  - every two weeks (qGetPayPeriods), and
  - unknown (lastDay)
  */
  function qryGetLastDayUsers( query qUserSet, date for_date, date today=Now() ) {

    var matchedPayDates = eventservice.qGetPayPeriodsInMonthOfDate( arguments.for_date );
    var date_list = '';

    cfloop( query=matchedPayDates ) {
      date_list = ListAppend( date_list, matchedPayDates.pay_date[matchedPayDates.currentRow] );
    }

    var sql = '
      SELECT user_id, email, pay_frequency, email_frequency
      FROM arguments.qUserSet
      WHERE pay_frequency > -1
      ORDER BY user_id
    ';

    var params = {};

    var result = QueryExecute( sql, params, variables.qoqOptions );

    var proper_result = QueryNew(result.columnList);

    cfloop( query=result ) {

      //if paid every 2 weeks
      if ( result.pay_frequency[result.currentRow] == 3 ) {

        if ( DateInList(date_list, arguments.today) ) {

          queryCopyRow( result, proper_result, result.currentRow );

        }

      // other styles of pay
      } else {

        queryCopyRow( result, proper_result, result.currentRow );

      }

    }

    return proper_result;

  }

  /* should target users who are paid:
  - twice a month (15th, last day), and
  - every two weeks (qGetPayPeriods)
  */
  function qryGetFifteenthDayUsers( query qUserSet, date for_date, date today=Now() ) {

    var matchedPayDates = eventservice.qGetPayPeriodsInMonthOfDate( arguments.for_date );
    var date_list = '';

    cfloop( query=matchedPayDates ) {
      date_list = ListAppend( date_list, matchedPayDates.pay_date[matchedPayDates.currentRow] );
    }

    // paid twice a month
    // paid every two weeks
    var sql = '
      SELECT user_id, email, pay_frequency, email_frequency
      FROM arguments.qUserSet
      WHERE ( 
        pay_frequency = 2
        OR 
        pay_frequency = 3
      )
      ORDER BY user_id
    ';

    var params = {};

    var result = QueryExecute( sql, params, variables.qoqOptions );

    var proper_result = QueryNew(result.columnList);

    cfloop( query=result ) {

      if (result.pay_frequency[result.currentRow] == 2 || 
          (result.pay_frequency[result.currentRow] == 3 && dateInList(date_list, arguments.today))) {

        queryCopyRow( result, proper_result, result.currentRow );

      }

    }

    return proper_result;

  }

  /* should target users who are paid:
  - every two weeks (qGetPayPeriods)
  */
  function qryGetEveryTwoWeekUsers( query qUserSet, date for_date, date today=Now() ) {

    var matchedPayDates = eventservice.qGetPayPeriodsInMonthOfDate( arguments.for_date );
    var date_list = '';

    cfloop( query=matchedPayDates ) {
      date_list = ListAppend( date_list, matchedPayDates.pay_date[matchedPayDates.currentRow] );
    }

    // paid every two weeks
    var sql = '
      SELECT user_id, email, pay_frequency, email_frequency
      FROM arguments.qUserSet
      WHERE pay_frequency = 3
      ORDER BY user_id
    ';

    var params = {};

    var result = QueryExecute( sql, params, variables.qoqOptions );

    var proper_result = QueryNew(result.columnList);

    cfloop( query=result ) {

      if ( dateInList( date_list, arguments.today ) ) {

        queryCopyRow( result, proper_result, result.currentRow );

      }

    }

    return proper_result;

  }

  function queryCopyRow(query source, query destination, numeric row) {

    var thisCol = '';

    QueryAddRow( arguments.destination );

    cfloop( list=arguments.source.columnList, index="thisCol" ) {

      QuerySetCell(arguments.destination, thisCol, arguments.source[thisCol][arguments.row] );

    }

  }

  remote function dateInList( string list_of_dates, date target_date, string date_part="d" ) {

    var thisDate = '';

    cfloop( list=arguments.list_of_dates, index="thisDate" ) {

      if ( !DateCompare( thisDate, arguments.target_date, arguments.date_part ) ) {
        return true;
      }

    }

    return false;

  }

  remote date function getEndDateOfMonth( date in_date ) {

    var num_days = DaysInMonth( arguments.in_date );
    var the_first = CreateDate( Year(arguments.in_date), Month(arguments.in_date), 1 );

    return DateAdd( "d", num_days-1, the_first );

  }

  /* in the footsteps of CF's FirstDayOfMonth() */
  remote numeric function lastDayOfMonth( date in_date ) {

    return DayOfYear( getEndDateOfMonth( arguments.in_date ) );

  }

}