//model/services/generatedCard
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
  get() = get a specific card by its primary key
  */

  public any function get( string id ) {

    var sql = '
      SELECT gc.*
      FROM "pGeneratedCards" gc
      WHERE generated_card_id = :gcid;
    ';

    var params = {
      gcid = {
        value = arguments.id, sqltype = 'integer'
      }
    };

    var result = QueryExecute(sql, params, variables.defaultOptions);
    var card = variables.beanFactory.getBean('generatedCardBean');

    if ( result.RecordCount ) {

      card.setGenerated_Card_Id( result.generated_card_id[1] );
      card.setCode( result.code[1] );

    }

    return card;

  }

  public any function save() {

    var sql = '
      INSERT INTO
        "pGeneratedCards"
      DEFAULT VALUES
      RETURNING
        generated_card_id AS card_id_out;
    ';

    var result = QueryExecute( sql, params, variables.defaultOptions );

    return result.card_id_out;

  }

  public any function create() {

    var new_id = save();

    return get( new_id );

  }

}