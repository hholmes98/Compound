component accessors = true {

  property cardservice;
  property mailservice;

  function init( fw ) {

    variables.fw = fw;

  }

  public void function list( struct rc ) {

    var cards = cardservice.list( arguments.rc.id );

    variables.fw.renderdata( 'JSON', cards );

  }

  public void function get( struct rc ) {

    var cardbean = cardservice.get( arguments.rc.id );

    /* consider:

    https://docs.angularjs.org/api/ng/service/$http#jsonp

    A JSON vulnerability allows third party website to turn your JSON resource URL into JSONP request under some conditions. To counter this your server can prefix all JSON requests with following string ")]}',\n". AngularJS will automatically strip the prefix before processing it as JSON.

    For example if your server needs to return:

    ['one','two']
    which is vulnerable to attack, your server can return:

    )]}',
    ['one','two']
    AngularJS will strip the prefix, before processing the JSON.
    */

    variables.fw.renderdata( 'JSON', cardbean );

  }

  public void function delete( struct rc ) {

    var ret = cardservice.delete( arguments.rc.card_id );

    variables.fw.renderdata( 'JSON', ret );

  }


  public void function save( struct rc ) {

    var ret = cardservice.save( arguments.rc );

    variables.fw.renderdata( 'JSON', ret );

  }

  public void function setAsEmergency( struct rc ) {

    var ret = cardservice.setAsEmergency( arguments.rc.eid, arguments.rc.uid );

    variables.fw.renderdata( 'JSON', ret );

  }

  public void function oops( struct rc ) {

    var the_url = 'Unknown';

    if (StructKeyExists(request,'_fw1') && 
        StructKeyExists(request._fw1, 'CGIPATHINFO') &&
        StructKeyExists(request._fw1, 'CGISCRIPTNAME') &&
        StructKeyExists(request._fw1, 'HEADERS') &&
        StructKeyExists(request._fw1.HEADERS, 'origin') ) {

      the_url = request._fw1.HEADERS.origin & request._fw1.CGISCRIPTNAME & request._fw1.CGIPATHINFO;

    }

    // email the admins before displaying anything nice to the user.
    mailservice.sendError( application.admin_email, request.exception, the_url );

  }

}