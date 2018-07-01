//controllers/preferences
component accessors=true {

  property preferenceService;
  property eventService;

  function init( fw ) {

    variables.fw = fw;

  }

  public void function get( struct rc ) {

    var prefbean = preferenceService.get( rc.user_id );

    variables.fw.renderdata( "JSON" , prefbean );

  }

  public void function save( struct rc ) {
    param name="rc.user_id" default=0;

    rc.preferences = preferenceService.get( rc.user_id );

    variables.fw.populate( cfc = rc.preferences, trim = true );

    // flatten bean to struct, pass to save service
    ret = preferenceService.save( rc.preferences.flatten() );

    session.auth.user.setPreferences( preferenceService.get( session.auth.user.getUser_Id() ) );

    variables.fw.renderdata( "JSON", ret );

  }

  public void function export( struct rc ) {

    // grab the entire schedule
    var qData = eventService.export( session.auth.user.getUser_Id() );

    // turn the query into a spreadsheet
    var csvData = queryToCSV( qData, qData.ColumnList );

    // TODO: zip it. zip it real good.

    // deliver it
    variables.fw.renderdata().data( csvData ).type( function( csvData ) {
      return {
        contentType = 'application/vnd.ms-excel',
        output = csvData.data,
        writer = function ( output ) {
          cfheader( name="Content-Disposition", value="inline; filename=#session.auth.user.getName()#.csv" );
          cfcontent( type="text/csv" ) {
            WriteOutput(output);
          }
        }
      };
    });

  }

  private function queryToCSV( query dataQry, string fieldNames, string delimiter="," ) {

    var csv = {};
    csv.ColumnNames = [];

    cfloop( list=arguments.fieldNames, index="csv.ColumnName", delimiters="," ) {

      ArrayAppend( csv.ColumnNames, Trim( csv.ColumnName ) );

    };

    csv.ColumnCount = ArrayLen( csv.ColumnNames );
    csv.Buffer = CreateObject( "java", "java.lang.StringBuffer" ).Init();
    csv.NewLine = (Chr( 13 ) & Chr( 10 ));
    csv.RowData = [];

    cfloop( from=1, to=csv.ColumnCount, index="csv.ColumnIndex", step=1 ) {

      csv.RowData[ csv.ColumnIndex ] = """#csv.ColumnNames[ csv.ColumnIndex ]#""";

    };

    csv.Buffer.Append( JavaCast( "string", ( ArrayToList( csv.RowData, arguments.delimiter ) & csv.NewLine ) ) );

    cfloop( query=arguments.dataQry ) {

      csv.RowData = [];

      cfloop( from=1, to=csv.ColumnCount, index="csv.ColumnIndex", step=1 ) {

         csv.RowData[ csv.ColumnIndex ] = """#Replace( arguments.dataQry[ csv.ColumnNames[ csv.ColumnIndex ] ][ arguments.dataQry.CurrentRow ], """", """""", "all" )#""";

      };

      csv.Buffer.Append( JavaCast( "string", ( ArrayToList( csv.RowData, arguments.delimiter ) & csv.NewLine ) ) );

    };

    return csv.Buffer.ToString();

  }

}