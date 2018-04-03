// controllers/mail
component accessors = true {

  property mailService;

  function init( fw ) {

    variables.fw = fw;

  }

  public void function reminders( struct rc ) {

    var i_date = Now();

    if ( StructKeyExists( arguments.rc, 'reminder_date' ) ) {
      i_date = arguments.rc.reminder_date;
    }

    if ( StructKeyExists( arguments.rc, 'today') ) {
      var results = mailService.processReminders( i_date, arguments.rc.today );
    } else {
      var results = mailService.processReminders( i_date );
    }

    variables.fw.renderdata( 'JSON', results );

  }

}
