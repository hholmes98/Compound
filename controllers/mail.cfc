// controllers/mail
component accessors=true {

  property mailService;

  function init( fw ) {

    variables.fw = fw;

  }

  public void function reminders( struct rc ) {
    param name="rc.reminder_date" default=Now();
    param name="rc.dry_run" default="true";

    if ( StructKeyExists( arguments.rc, 'today' ) ) {
      var results = mailService.processReminders( arguments.rc.reminder_date, arguments.rc.today, rc.dry_run );
    } else {
      var results = mailService.processReminders( for_date = arguments.rc.reminder_date, dryRun = rc.dry_run );
    }

    variables.fw.renderdata( 'JSON', results );

  }

}
