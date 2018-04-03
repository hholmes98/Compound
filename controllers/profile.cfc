// controllers/profile.cfc
component accessors = true {

  property framework;
  property cardservice;
  property userservice;

  function init( fw ) {

    variables.fw = fw;

  }

}