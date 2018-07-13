//model/services/fantabulousCard
component accessors=true {
  /*

  this services generates designs for credit cards, 
  it spits out the appropriate CSS
  it can also generate a true image (JPG, PNG) to be downloaded
  it has the capacity to decode a SHA-244 or SHA-256 hash to generate the image, but in general,
  you want to do the hashing elsewhere, and pass in the values yourself.

  */

  remote function fantabulousCard( string cardName="FantabulousCard", cardClass="", numeric width=120, height=70, struct data = {}, string hash="" ) {

    variables.cardName = arguments.cardName;

    // if cardClass isn't specified, strip the spaces from the cardName, hash the card name, and append the 1st four chars.
    if ( !Len(arguments.cardClass) ) {
      var tmp = ReReplaceNoCase( arguments.cardName, "[^A-Z0-9]", "", "ALL" );
      var tmp2 = Hash(tmp,"SHA-256","UTF-8");
      variables.cardClass = tmp & Left(tmp2, 4);
    } else {
      variables.cardClass = arguments.cardClass;
    }

    variables.width = arguments.width;
    variables.width_small = Round(arguments.width / 2);
    variables.width_large = arguments.width * 2;
    variables.height = arguments.height;
    variables.height_small = Round(arguments.height / 2);
    variables.height_large = arguments.height * 2;

    variables.fc_data = StructNew();
    variables.properties = StructNew();

    if ( !StructIsEmpty( arguments.data ) && Len( arguments.hash ) ) {
      Throw(
        message="Both data and hash are specified.",
        detail="You have attempted to initialize fantabulousCard with both a data argument and a hash argument. You may only specify one or the other, but not both."
      );
    }

    // data takes precedence
    if ( !StructIsEmpty( arguments.data ) ) {
      variables.fc_data = arguments.data;
    } else {

      // if you're passing a hash in, set the data first
      if ( isHexShaHash( arguments.hash ) && Len( arguments.hash ) >= 56 ) {
        decodeProperties( arguments.hash );
      } else {
        decodeProperties( Hash( variables.cardName, "SHA-256", "UTF-8") );
      }

    }

    initProperties( variables.fc_data );

    return this;

  }

  remote boolean function isHexShaHash( string hash ) {

    if ( !reFindNoCase( "^[0-9A-F]{56,64}$", arguments.hash, 1, false ) ) {
      return false;
    }

    return true;

  }

  remote function decodeProperties( string c ) {

    /*
    TECH SPEC v1

    (SHA-256 = 64 characters, which is 32 bytes in Hex (2 chars / byte)

    SHA-256: 3FC9B689459D738F8C88A3A48AA9E33542016B7A4052E001AAA536FCA74813CB
    SHA-224: 3EA5E0D9D5DC6D8ABF5C41BD312ADBAA73EE36423BF85E503A9BFD52

    1      7      13 15 17     23     29 31 33 35 37 39 41 43 45 47 49     55 57     63
    3FC9B6 89459D 73 8F 8C88A3 A48AA9 E3 35 42 01 6B 7A 40 52 E0 01 AAA536 FC A74813 CB

    [Character Position: What it is used for]
     1: Primary color; Final stop color for gradients
     7: Secondary color
    13: Border style
    15: Thickness of either radial gradients or repeating line gradients (each modified differently/via static const)
    17: Starting color for gradients
    23: Initial stop color for gradients
    29: Type of gradient to deploy
    31: Angle of linear gradients; Shape of radial gradient
    33: Offset position for linear gradients; Destination position (ie. "Shape" at "Position") for radial gradients; always displays as a percentage (but can go over 100%)
    35: Display security chip (yes/no)
    37: Security chip color (silver/gold)
    39: Security chip position (middle-right/upper-left)
    41: Display vendor name (yes/no)
    43: Vendor name text color (white/gray/black) // TO-DO: scan primary color, determine if it is light; set text dark (or vice-versa)
    45: Vendor position (upper-left/upper-right/lower-left/lower-right)
    47: Vendor text display details (ie. name, transform, line-height, width, text-shadow, etc. )
    49: UNUSED COLOR
    55: UNUSED BYTE
    --- SHA-244 / SHA-256 bridge ---
    57: UNUSED COLOR
    63: UNUSED BYTE
    */

    variables.fc_data = {
      'full_stop': Left( arguments.c, 6 ),
      'border-color': Mid( arguments.c, 7, 6 ),
      'border-style': hex2dec( Mid( arguments.c, 13, 2 ) ),
      'girth': hex2dec( Mid( arguments.c, 15, 2 ) ),
      'start': Mid( arguments.c, 17, 6 ),
      'stop': Mid( arguments.c, 23, 6 ),
      'background': hex2dec( Mid( arguments.c, 29, 2 ) ),
      'shape': hex2dec( Mid( arguments.c, 31, 2 ) ), // TODO: fix this dupe
      'angle': hex2dec( Mid( arguments.c, 31, 2 ) ),
      'position': hex2dec( Mid( arguments.c, 33, 2 ) ),
      'hasChip': hex2dec( Mid( arguments.c, 35, 2 ) ),
      'chipColor': hex2dec( Mid( arguments.c, 37, 2 ) ),
      'chipPosition': hex2dec( Mid( arguments.c, 39, 2 ) ),
      'hasVendor': hex2dec( Mid( arguments.c, 41, 2 ) ),
      'vendorColor': hex2dec( Mid( arguments.c, 43, 2 ) ),
      'vendorPosition': hex2dec( Mid( arguments.c, 45, 2 ) ),
      'vendor': hex2dec( Mid( arguments.c, 47, 2 ) )
    };

  }

  remote function initProperties( struct fc_data ) {

    variables.properties = {
      'border-color': arguments.fc_data['border-color'],
      'border-style': getBorderStyle( arguments.fc_data['border-style'] ),
      'background': getGradient( arguments.fc_data['background'] ),
      'hasChip': hasChip( arguments.fc_data['hasChip'] ),
      'chipColor': getChipColor( arguments.fc_data['chipColor'] ),
      'chipPosition': {
        'top': getChipPosition( arguments.fc_data['chipPosition'] ).top,
        'left': getChipPosition( arguments.fc_data['chipPosition'] ).left
      },
      'hasVendor': hasVendor( arguments.fc_data['hasVendor'] ),
      'vendor': {
        'name': getVendor( arguments.fc_data['vendor'] ).name,
        'color': getVendorColor( arguments.fc_data['vendorColor'] ),
        'transform': getVendor( arguments.fc_data['vendor'] ).transform,
        'position': {
          'top': getVendorPosition( arguments.fc_data['vendor'] ).top,
          'left': getVendorPosition( arguments.fc_data['vendor'] ).left,
          'bottom': getVendorPosition( arguments.fc_data['vendor'] ).bottom,
          'right': getVendorPosition( arguments.fc_data['vendor'] ).right
        }
      }
    };

    cfloop( list=StructKeyList( getVendor( arguments.fc_data['vendor'] ) ), index="item" ) {
      if ( !ReFindNoCase("name|color|transform|position", item ) ) {
        variables.properties['vendor'][item] = getVendor( arguments.fc_data['vendor'])[item];
      }
    }

  }

  remote string function buildRadialGradient() {

    var shape = getShape(variables.fc_data['shape']);
    var start = variables.fc_data['start'];
    var stop = variables.fc_data['stop'];
    var full_stop = variables.fc_data['full_stop'];
    var position = getPercentage(variables.fc_data['position']);
    var girth = getPercentage(variables.fc_data['girth']);

    return shape & ' at ' & position & '%, ##' & start & ', ##' & stop & ' ' & Evaluate(25+girth) & '%, ##' & full_stop & ' ' & Evaluate(50+girth) & '%';

  }

  remote string function buildRepeatingLinearGradient() {

    var angle = getAngle(variables.fc_data['angle']);
    var start = variables.fc_data['start'];
    var stop = variables.fc_data['stop'];
    var full_stop = variables.fc_data['full_stop'];
    var position = getPercentage(variables.fc_data['position']);
    var girth = getPercentage(variables.fc_data['girth']);
    
    return angle & 'deg, ##' & start & ' ' & position & '%, ##' & stop & ' ' & Round(girth*.33) & '%, ##' & full_stop & ' ' & Round(girth*.66) & '%';

  }

  remote string function buildLinearGradient() {

    var angle = getAngle(variables.fc_data['angle']);
    var start = variables.fc_data['start'];
    var stop = variables.fc_data['stop'];
    var full_stop = variables.fc_data['full_stop'];
    var position = getPercentage(variables.fc_data['position']);

    return angle & 'deg, ##' & start & ' ' & position & '%, ##' & stop & ', ##' & full_stop;
  }

  remote numeric function hex2dec( string hex ) {
    return InputBaseN( arguments.hex, 16 );
  }

  remote struct function getVendor( numeric value ) {

    var data = {
      name: '',
      transform: ''
    }

    var choice = arguments.value MOD 4;

    switch(choice) {

      case 0: // this is the base rectangle - 
        data.name = 'EXPL' & chr(9788) & 'RE'; 
        data.transform = '1.0, 0, 0, 1.0, 0, 0';
        break;

      case 1: // angled, bit shorter
         data.name = 'FLISA'; 
         data.transform = '1, 0, -0.404026, 1, 0, 0';
         break;

      case 2: // narrow but tall -- misc. properties are necessary
        data.name = 'BLAM EX';
        data.transform = '1.0, 0, 0, 0.7, 0.5, 0.5';
        data['line-height'] = 0.7;
        data.width = '35%';
        data['text-shadow'] = '0 0 10px ##fff, 0 0 10px ##fff';
        break;

      case 3:
        data.name = 'fastercard'; // longer
        data.transform = '1.0, 0, 0, 1.0, 0, 0';
        break;

    }

    return data;

  }

  remote struct function getVendorPosition( numeric value ) {

    var pos = {
      top: 0,
      right: 0,
      bottom: 0,
      left: 0
    };

    var choice = arguments.value MOD 4;

    switch(choice) {

      case 0:
        // top-left
        pos.top = 5;
        pos.left = 5;
        break;

      case 1:
        // top-right
        pos.top = 5
        pos.right = 5;
        break;

      case 2:
        // bottom-right
        pos.bottom = 5;
        pos.right = 5;
        break;

      case 3:
        // bottom-left
        pos.bottom = 5
        pos.left = 5;
        break;

    }

    return pos;

  }

  remote string function getVendorColor( numeric value ) {

    var choice = arguments.value MOD 3;

    // TODO: this really needs to be decided, based on the bg color (if light, choose dark, and vice-versa)

    switch(choice) {
      case 0:
        return 'silver';
        break;
      case 1:
        return '##fff';
        break;
      case 2:
        return '##000';
        break;
    }

  }

  remote boolean function hasVendor( numeric value ) {

    //var vendByte = Mid( c, 41, 2 );
    //var value = InputBaseN( vendByte, 16 );
    var choice = arguments.value MOD 2;

    switch(choice) {
      case 0:
        return false;
        break;
      case 1:
        return true;
        break;
    }

  }

  remote string function getShape( numeric value ) {

    var choice = arguments.value MOD 6;

    switch(choice) {
      case 0:
        return 'circle';
        break;
      case 1:
        return 'ellipse';
        break;
      case 2:
        return 'closest-corner';
        break;
      case 3:
        return 'closest-side';
        break;
      case 4:
        return 'farthest-corner';
        break;
      case 5:
        return 'farthest-side';
        break;
    }

  }

  remote struct function getChipPosition( numeric value ) {

    var pos = {
      top: 0,
      left: 0
    };

    var choice = arguments.value MOD 2;

    switch(choice) {
      case 0:
        pos.top = 50;
        pos.left = 66;
        break;
      case 1:
        pos.top = 32;
        pos.left = 15;
        break;
    }

    return pos;

  }

  remote function getChipColor( numeric value ) {

    var choice = arguments.value MOD 2;

    switch(choice) {
      case 0:
        return 'silver';
        break;
      case 1:
        return '##9a8259';
        break;
    }

  }

  remote boolean function hasChip( numeric value ) {

    //var chipByte = Mid( c, 35, 2 );
    //var value = InputBaseN( chipByte, 16 );
    var choice = arguments.value MOD 2;

    switch(choice) {
      case 0:
        return false;
        break;
      case 1:
        return true;
        break;
    }

  }

  remote numeric function getPercentage( numeric value ) {

    var choice = Round( 100 / 256 * arguments.value );

    return choice;

  }

  remote numeric function getAngle( numeric value ) {

    var choice = Round( arguments.value / 256 * 360 );

    return choice;

  }

  remote string function getGradient( numeric value ) {

    var choice = arguments.value MOD 4;

    switch(choice) {
      case 0:
        return 'linear-gradient(' & buildLinearGradient() & ')';
        break;
      case 1:
        return 'repeating-linear-gradient(' & buildRepeatingLinearGradient() & ')';
        break;
      case 2:
        return 'radial-gradient(' & buildRadialGradient() & ')';
        break;
      case 3:
        return 'repeating-radial-gradient(' & buildRadialGradient() & ')';
        break;
    }

  }

  remote string function getBorderStyle( numeric value ) {

    var choice = arguments.value MOD 9;

    switch(choice) {
      case 0:
        return 'none';
        break;
      case 1:
        return 'dotted';
        break;
      case 2:
        return 'dashed';
        break;
      case 3:
        return 'solid';
        break;
      case 4:
        return 'double';
        break;
      case 5:
        return 'groove';
        break;
      case 6:
        return 'ridge';
        break;
      case 7:
        return 'inset';
        break;
      case 8:
        return 'outset';
        break;
    }
  }

  private string function getVendorCSS() {

    var vendorCSS = '.' & variables.cardClass & ':after {
  content: "' & variables.properties['vendor'].name & '";
  font-family: ''Arial'', sans-serif;
  font-weight: 600;
  font-size: 14px;
  color: ' & variables.properties['vendor'].color & ';
  transform: matrix(' & variables.properties['vendor'].transform & ');
  position: absolute;
    ';

    if ( variables.properties['vendor'].position.top > 0 ) {
      vendorCSS = vendorCSS & '
  top: ' & variables.properties['vendor'].position.top & '%;
      ';
    }

    if ( variables.properties['vendor'].position.left > 0 ) {
      vendorCSS = vendorCSS & '
  left: ' & variables.properties['vendor'].position.left & '%;
      ';
    }

    if ( variables.properties['vendor'].position.bottom > 0 ) {
      vendorCSS = vendorCSS & '
  bottom: ' & variables.properties['vendor'].position.bottom & '%;
      ';
    }

    if ( variables.properties['vendor'].position.right > 0 ) {
      vendorCSS = vendorCSS & '
  right: ' & variables.properties['vendor'].position.right & '%;
      ';
    }

    cfloop( list=StructKeyList(variables.properties['vendor']), index="item" ) {

      if ( !ReFindNoCase( "(name|transform|position|color)", item ) ) {
        vendorCSS = vendorCSS & '
  ' & LCase(item) & ':' & variables.properties['vendor'][item] & ';
        ';
      }

    }

    vendorCSS = vendorCSS & '
  z-index: 2;
}

.' & variables.cardClass & '.small:after {
  font-size: 6px;
}

.' & variables.cardClass & '.large:after {
  font-size: 28px;
}
    ';

    return vendorCSS;

  }

  private string function getChipCSS() {

    var chipCSS = '.' & variables.cardClass & ':before {
  content: '''';
  height: 12px;
  width: 18px;
  border-radius: 2px;
  position: absolute;
  background: ' & variables.properties['chipColor'] & ';
  top: ' & variables.properties['chipPosition'].top & '%;
  left: ' & variables.properties['chipPosition'].left & '%;
  z-index: 1;
}

.' & variables.cardClass & '.small:before {
  height: 6px;
  width: 9px;
  border-radius: 1px;
}

.' & variables.cardClass & '.large:before {
  height: 24px;
  width: 36px;
  border-radius: 4px;
}
    ';

    return chipCSS;

  }

  remote string function getHolderCSS() {

    var holderCSS = '
.holder {
  position: relative;
  width: ' & variables.width & 'px;
  height: ' & variables.height & 'px;
}

.holder.small {
  width: ' & variables.width_small & 'px;
  height: ' & variables.height_small & 'px;
}

.holder.large {
  width: ' & variables.width_large & 'px;
  height: ' & variables.height_large & 'px;
}
    ';

    return holderCSS;

  }

  remote string function getCSS() {

    var cssString = '
.' & variables.cardClass & ' {
  height: ' & variables.height & 'px;
  width: ' & variables.width & 'px;
  border-radius: 8px;
  border-width: 3px;
  border-color: ##' & variables.properties['border-color'] & ';
  border-style: ' & variables.properties['border-style'] & ';
  background: ' & variables.properties['background'] & ';
}

.' & variables.cardClass & '.small {
  height: ' & variables.height_small & 'px;
  width: ' & variables.width_small & 'px;
  border-radius: 6px;
}

.' & variables.cardClass & '.large {
  height: ' & variables.height_large & 'px;
  width: ' & variables.width_large & 'px;
  border-radius: 12px;
}
    ';

    if ( hasChip( variables.properties['hasChip'] ) ) {
      cssString = cssString & '
' & getChipCSS() & '

      ';

    }

    if ( hasVendor( variables.properties['hasVendor'] ) ) {
      cssString = cssString & '
' & getVendorCSS() & '

      ';
    }

    return cssString;

  }

  // this method is only intended for remote testing
  remote string function getCompleteCSS( string cardName="FantabulousCard", cardClass="", numeric width=120, height=70, struct data = {}, string hash="" ) {

    // init
    fantabulousCard( argumentCollection=arguments );

    // return getHolderCss & getCSS() method
    return getHolderCSS() & getCSS();

  }

  remote string function getHTML( string cardName="FantabulousCard", cardClass="", numeric width=120, height=70, struct data = {}, string hash="" ) {

    var css = getCompleteCSS( argumentCollection=arguments );

    var html='
    <html>
    <head>
      <style>' & css & '</style>
    </head>
    <body>
      <div class="container">
        <div class="row">
          <div class="col">
            <div class="holder small">
              <div class="#variables.cardClass# small"></div>
            </div>
          </div>
        </div>
        <br/>
        <div class="row">
          <div class="col">
            <div class="holder">
              <div class="#variables.cardClass#"></div>
            </div>
          </div>
        </div>
        <br/>
        <div class="row">
          <div class="col">
            <div class="holder large">
              <div class="#variables.cardClass# large"></div>
            </div>
          </div>
        </div>
      </div>
    </body>
    </html>
';

    return html;

  }

  remote string function render( string cardName="FantabulousCard", cardClass="", numeric width=120, height=70, struct data = {}, string hash="" ) {

    var html = getHTML( argumentCollection=arguments );

    cfcontent( type="text/html" );
    writeOutput( html );

  }

}