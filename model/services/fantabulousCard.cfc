//model/services/fantabulousCard
component accessors=true {
  /*

  this services generates designs for credit cards, 
  it spits out the appropriate CSS
  it can also generate a true image (JPG, PNG) to be downloaded
  it has the capacity to decode a SHA-244 or SHA-256 hash to generate the image, but in general,
  you want to do the hashing elsewhere, and pass in the values yourself.

  */

  /* init */
  remote function fantabulousCard( string cardName="FantabulousCard", 
    cardClass="", numeric width=120, height=70, struct data = {}, string hash="", size="all", id="" ) {

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

    variables.id = arguments.id;

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

  /*****************
      PRIVATE
  *****************/

  private boolean function isHexShaHash( string hash ) {

    if ( !ReFindNoCase( "^[0-9A-F]{56,64}$", arguments.hash, 1, false ) ) {
      return false;
    }

    return true;

  }

  private function decodeProperties( string c ) {

    /*
    TECH SPEC v1

    (SHA-256 = 64 characters, which is 32 bytes in Hex (2 chars / byte)

    SHA-256: 3FC9B689459D738F8C88A3A48AA9E33542016B7A4052E001AAA536FCA74813CB
    SHA-224: 3EA5E0D9D5DC6D8ABF5C41BD312ADBAA73EE36423BF85E503A9BFD52

    1      7      13 15 17     23     29 31 33 35 37 39 41 43 45 47 49     55 57     63
    3FC9B6 89459D 73 8F 8C88A3 A48AA9 E3 35 42 01 6B 7A 40 52 E0 01 AAA536 FC A74813 CB

    [Character Position: What it is used for]
     1: Primary color; Final stop color for gradients
     7: Border color;
    13: Border style
    15: GIRTH (WIDTH or HEIGHT) (n%, 100% limit) of either radial gradients or repeating line gradients (each modified differently/via static const)
    17: Secondary Color; Starting color for gradients
    23: Tertiary Color; Initial stop color for gradients
    29: Type of background pattern to deploy
    31: ANGLE (0-360) of linear gradients; Shape of radial gradient
    33: POSITION offset (n%, no limit) for linear gradients; Destination position (ie. "Shape" at "Position") for radial gradients; always displays as a percentage (but can go over 100%)
    35: Display security chip (yes/no)
    37: Security chip color (silver/gold)
    39: Security chip position (middle-right/upper-left)
    41: Display vendor name (yes/no)
    43: Vendor name text color (white/gray/black) // TO-DO: scan primary color, determine if it is light; set text dark (or vice-versa)
    45: Vendor position (upper-left/upper-right/lower-left/lower-right)
    47: Vendor text display details (ie. name, transform, line-height, width, text-shadow, etc. )
    49: UNUSED COLOR (Quaternary color, if needed)
    55: UNUSED BYTE
    --- SHA-244 / SHA-256 bridge ---
    57: UNUSED COLOR (Quintentary color, if needed)
    63: UNUSED BYTE
    */

    variables.fc_data = {
      'primary_color': Left( arguments.c, 6 ),
      'border_color': Mid( arguments.c, 7, 6 ),
      'border_style': hex2dec( Mid( arguments.c, 13, 2 ) ),
      'girth': hex2dec( Mid( arguments.c, 15, 2 ) ),
      'secondary_color': Mid( arguments.c, 17, 6 ),
      'tertiary_color': Mid( arguments.c, 23, 6 ),
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

  private function initProperties( struct fc_data ) {

    variables.properties = {
      'border-color': arguments.fc_data['border_color'],
      'border-style': getBorderStyle( arguments.fc_data['border_style'] ),
      'background': buildBackground( arguments.fc_data['background'] ),
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

  private string function buildBackground( numeric value ) {

    var choice = arguments.value MOD 13;

    switch(choice) {
      case 0:
      case 1:
      case 2:
      case 3:
        return 'background: ' & getGradient( arguments.value );
        break;
      case 4:
        return buildMarrakesh();
        break;
      case 5:
        return buildZigZag();
        break;
      case 6:
        return buildStairs();
        break;
      case 7:
        return buildRainbowBokeh();
        break;
      case 8:
        return buildMicrobialMat();
        break;
      case 9:
        return buildSegaiha();
        break;
      case 10:
        return buildTartan();
        break;
      case 11:
        return buildCarbon();
        break;
      case 12:
        return buildWaves();
        break;

    }

  }

  private string function getGradient( numeric value ) {

    var choice = arguments.value MOD 4;

    switch(choice) {
      case 0:
        return 'linear-gradient(' & buildLinearGradient() & ')';
        break;
      case 1:
        return buildRepeatingLinearGradient();
        break;
      case 2:
        return 'radial-gradient(' & buildRadialGradient() & ')';
        break;
      case 3:
        return 'repeating-radial-gradient(' & buildRadialGradient() & ')';
        break;

    }

  }

  private string function buildRadialGradient() {

    var shape = getShape(variables.fc_data['shape']);
    var start = variables.fc_data['secondary_color'];
    var stop = variables.fc_data['tertiary_color'];
    var full_stop = variables.fc_data['primary_color'];
    var position = getPercentage(variables.fc_data['position']);
    var girth = getPercentage(variables.fc_data['girth']);

    return shape & ' at ' & position & '%, ##' & start & ', ##' & stop & ' ' & Evaluate(25+girth) & '%, ##' & full_stop & ' ' & Evaluate(50+girth) & '%';

  }

  private string function buildRepeatingLinearGradient() {

    var angle = getAngle(variables.fc_data['angle']);
    var start = variables.fc_data['secondary_color'];
    var stop = variables.fc_data['tertiary_color'];
    var full_stop = variables.fc_data['primary_color'];
    var position = getPercentage(variables.fc_data['position']);
    var girth = getPercentage(variables.fc_data['girth']);

    var repeat = ((girth*.33) MOD 8) + 1;

    var ordered = [position,(girth*.33),(girth*.66)];
    ordered.sort("numeric","asc");

    var txt = '';
    cfloop(from=1, to=repeat, index="i") {
      txt = txt & 'repeating-linear-gradient(' & angle+(i*8) & 'deg, ' & RepeatString('transparent ' & i*2 & 'px,', i) & ' ##' & start & ' ' & ordered[1]*i & '%, ##' & stop & ' ' & ordered[2]*i & '%, ##' & full_stop & ' ' & ordered[3]*i & '%)';
      if (i < repeat-1) {
        txt = txt & ',' & Chr(13) & Chr(10);
      }
    }

    return txt;
  }

  private string function buildLinearGradient() {

    var angle = getAngle(variables.fc_data['angle']);
    var start = variables.fc_data['secondary_color'];
    var stop = variables.fc_data['tertiary_color'];
    var full_stop = variables.fc_data['primary_color'];
    var position = getPercentage(variables.fc_data['position'], 5, 40);

    return angle & 'deg, ##' & start & ' ' & position & '%, ##' & stop & ', ##' & full_stop;

  }

  private string function buildMarrakesh() {

    var nl = chr(13) & chr(10);
    var position = getPercentage(variables.fc_data['position']);
    var girth = getPercentage(variables.fc_data['girth']);

    var size = {
      "x1":position & "%",
      "y1":Round(position+(position*.65)) & "%",
      "x2":girth & "%",
      "y2":Round(girth+(girth*.638)) & "%"
    };
    
    var data = {
      'background-color': '##' & variables.fc_data['secondary_color'],
      'background-image': {
        'radial-gradient': '##' & variables.fc_data['tertiary_color'] & ' 40%, transparent 30%',
        'repeating-radial-gradient': '##' & variables.fc_data['tertiary_color'] &' 0%, ' & '##' & variables.fc_data['tertiary_color'] & ' 13%, transparent 13%, transparent 31%, ' & '##' & variables.fc_data['tertiary_color'] & ' 26%, ' & '##' & variables.fc_data['tertiary_color'] & ' 39%, transparent 40%, transparent 75%',
      },
      'background-size': size.x1 & ' ' & size.y1 & ', ' & size.x2 & ' ' & size.y2,
      'background-position':'0 0'
    }

    return 'background-color: ' & data['background-color'] & ';' & nl & 
        '  background-image: radial-gradient(' & data['background-image']['radial-gradient'] & '),' & nl & '  repeating-radial-gradient(' & data['background-image']['repeating-radial-gradient'] & ');' & nl &
        '  background-size: ' & data['background-size'] & ';' & nl &
        '  background-position: ' & data['background-position'];

  }

  private string function buildZigZag() {

    var nl = chr(13) & chr(10);
    var start = variables.fc_data['secondary_color'];
    var full_stop = variables.fc_data['primary_color'];
    var perc1 = getPercentage(variables.fc_data['position']);
    var perc2 = getPercentage(variables.fc_data['girth']);

    var txt = 'background: linear-gradient(135deg, ##' & start & ' 25%, transparent 25%) -50% 0,' & nl &
        '  linear-gradient(225deg, ##' & start & ' 25%, transparent 25%) -50% 0,' & nl &
        '  linear-gradient(315deg, ##' & start & ' 25%, transparent 25%), ' & nl &
        '  linear-gradient(45deg, ##' & start & ' 25%, transparent 25%); ' & nl &
        '  background-size: ' & perc1 & '% ' & perc2 & '%; ' & nl &
        '  background-color: ##' & full_stop;

    return txt;

  }

  private string function buildStairs() {

    var nl = chr(13) & chr(10);
    var start = variables.fc_data['secondary_color'];
    var full_stop = variables.fc_data['primary_color'];
    var angle = getPercentage(variables.fc_data['angle'], 5, 8);
    var step = getPercentage(variables.fc_data['girth'], 10, 50);

    var txt = 'background: linear-gradient(63deg, ##' & full_stop & ' 25%, transparent 23%) 7px 0, ' & nl &
        '  linear-gradient(63deg, transparent 74%, ##' & full_stop & ' 78%),' & nl &
        '  linear-gradient(63deg, transparent 34%, ##' & full_stop & ' 38%, ##' & full_stop & ' 58%, transparent 62%),' & nl &
        '  ##' & start & ';' & nl & 
        '  background-size: ' & angle & '% ' & step & '%';

    return txt;

  }

  private string function buildRainbowBokeh() {

    var perc1 = getPercentage(variables.fc_data['position']);
    var perc2 = getPercentage(variables.fc_data['girth']);
    var perc3 = getPercentage(variables.fc_data['angle']);
    var full_stop = variables.fc_data['primary_color'];
    var girth = getAngle(variables.fc_data['girth']);

    var txt = '
    background: 
    radial-gradient(rgba(255,255,255,0) 0, rgba(255,255,255,.15) 30%, rgba(255,255,255,.3) 32%, rgba(255,255,255,0) 33%) 0 0,
    radial-gradient(rgba(255,255,255,0) 0, rgba(255,255,255,.2) 17%, rgba(255,255,255,.43) 19%, rgba(255,255,255,0) 20%) 0 ' & perc1 & '%,
    radial-gradient(rgba(255,255,255,0) 0, rgba(255,255,255,.2) 11%, rgba(255,255,255,.4) 13%, rgba(255,255,255,0) 14%) ' & perc2 & '% ' & perc3 & '%,
    linear-gradient(' & buildLinearGradient() & ');
    background-size: ' & perc1 & '% ' & (perc1*2) & '%, ' & perc2 & '% ' & (perc2*2) & '%, ' & perc3 & '% ' & (perc3*2) & '%, 100% ' & girth & '%;
    background-color: ##' & full_stop & ';';

    return txt;

  }

  private string function buildMicrobialMat() {

    var size1 = getPercentage(variables.fc_data['position'], 4, 25);
    var size2 = getPercentage(variables.fc_data['girth'], 10, 50);
    var size3 = getPercentage(variables.fc_data['angle'], 1, 15);
    var size4 = getPercentage(variables.fc_data['position'], 18, 100)
    var color1 = variables.fc_data['primary_color'];
    var color2 = variables.fc_data['secondary_color'];

    var txt = 'background:
  radial-gradient(circle at 0% 50%, rgba(96, 16, 48, 0) ' & size3 & '%, ##' & color2 & ' ' & size4 & '%, rgba(96, 16, 48, 0) ' & size4 & '%) 0% 10%,
  radial-gradient(at 100% 100%, rgba(96, 16, 48, 0) 1%, ##' & color2 & ' ' & size3 & '%, rgba(96, 16, 48, 0) ' & size4 & '%),
  ##' & color1 & ';
  background-size: ' & size1 & '% ' & size2 & '%';

    return txt;
  }

  private string function buildSegaiha() {

    var color1 = variables.fc_data['primary_color'];
    var color2 = variables.fc_data['secondary_color'];

    var size = getPercentage(variables.fc_data['girth'], 12, 100);

    var txt = 'background-color:##' & color1 & ';
  background-image: 
  radial-gradient(circle at 100% 150%, ##' & color1 & ' 24%, ##' & color2 & ' 25%, ##' & color2 & ' 28%, ##' & color1 & ' 29%, ##' & color1 & ' 36%, ##' & color2 & ' 36%, ##' & color2 & ' 40%, transparent 40%, transparent),
  radial-gradient(circle at 0 150%, ##' & color1 & ' 24%, ##' & color2 & ' 25%, ##' & color2 & ' 28%, ##' & color1 & ' 29%, ##' & color1 & ' 36%, ##' & color2 & ' 36%, ##' & color2 & ' 40%, transparent 40%, transparent),
  radial-gradient(circle at 50% 100%, ##' & color2 & ' 10%, ##' & color1 & ' 11%, ##' & color1 & ' 23%, ##' & color2 & ' 24%, ##' & color2 & ' 30%, ##' & color1 & ' 31%, ##' & color1 & ' 43%, ##' & color2 & ' 44%, ##' & color2 & ' 50%, ##' & color1 & ' 51%, ##' & color1 & ' 63%, ##' & color2 & ' 64%, ##' & color2 & ' 71%, transparent 71%, transparent),
  radial-gradient(circle at 100% 50%, ##' & color2 & ' 5%, ##' & color1 & ' 6%, ##' & color1 & ' 15%, ##' & color2 & ' 16%, ##' & color2 & ' 20%, ##' & color1 & ' 21%, ##' & color1 & ' 30%, ##' & color2 & ' 31%, ##' & color2 & ' 35%, ##' & color1 & ' 36%, ##' & color1 & ' 45%, ##' & color2 & ' 46%, ##' & color2 & ' 49%, transparent 50%, transparent),
  radial-gradient(circle at 0 50%, ##' & color2 & ' 5%, ##' & color1 & ' 6%, ##' & color1 & ' 15%, ##' & color2 & ' 16%, ##' & color2 & ' 20%, ##' & color1 & ' 21%, ##' & color1 & ' 30%, ##' & color2 & ' 31%, ##' & color2 & ' 35%, ##' & color1 & ' 36%, ##' & color1 & ' 45%, ##' & color2 & ' 46%, ##' & color2 & ' 49%, transparent 50%, transparent);
  background-size:' & size & '% ' & size & '%';

    return txt;

  }

  private string function buildTartan() {

    var color = variables.fc_data['primary_color'];
    var width1 = getPercentage(variables.fc_data['girth'], 50, 182);

    var txt = 'background-color: ##' & color & ';
  background-image: repeating-linear-gradient(transparent, transparent ' & width1 & '%, rgba(0,0,0,.4) ' & width1 & '%, 
    rgba(0,0,0,.4) ' & Round(width1+(width1*.06)) & '%, 
    transparent ' & Round(width1+(width1*.06)) & '%, 
    transparent ' & Round(width1+(width1*.18)) & '%, rgba(0,0,0,.4) ' & Round(width1+(width1*.18)) & '%, 
    rgba(0,0,0,.4) ' & Round(width1+(width1*.22)) & '%, 
    transparent ' & Round(width1+(width1*.22)) & '%, 
    transparent ' & Round(width1+(width1*.57)) & '%, rgba(0,0,0,.5) ' & Round(width1+(width1*.55)) & '%, 
    rgba(0,0,0,.5) ' & Round(width1+(width1*.57)) & '%, 
    rgba(255,255,255,.2) ' & Round(width1+(width1*.57)) & '%, 
    rgba(255,255,255,.2) ' & Round(width1+(width1*.71)) & '%, 
    rgba(0,0,0,.5) ' & Round(width1+(width1*.71)) & '%, 
    rgba(0,0,0,.5) ' & Round(width1+(width1*.73)) & '%, 
    rgba(255,255,255,.2) ' & Round(width1+(width1*.73)) & '%, 
    rgba(255,255,255,.2) ' & Round(width1+(width1*.73)) & '%, 
    rgba(0,0,0,.5) ' & Round(width1+(width1*.73)) & '%, 
    rgba(0,0,0,.5) ' & Round(width1+(width1*.80)) & '%, 
    transparent ' & Round(width1+(width1*.80)) & '%),
  repeating-linear-gradient(270deg, transparent, transparent ' & width1 & '%, rgba(0,0,0,.4) ' & width1 & '%, 
    rgba(0,0,0,.4) ' & Round(width1+(width1*.06)) & '%, 
    transparent ' & Round(width1+(width1*.06)) & '%, 
    transparent ' & Round(width1+(width1*.18)) & '%, 
    rgba(0,0,0,.4) ' & Round(width1+(width1*.18)) & '%, 
    rgba(0,0,0,.4) ' & Round(width1+(width1*.18)) & '%, 
    transparent ' & Round(width1+(width1*.18)) & '%, 
    transparent ' & Round(width1+(width1*.22)) & '%, 
    rgba(0,0,0,.5) ' & Round(width1+(width1*.22)) & '%, 
    rgba(0,0,0,.5) ' & Round(width1+(width1*.57)) & '%, 
    rgba(255,255,255,.2) ' & Round(width1+(width1*.57)) & '%, 
    rgba(255,255,255,.2) ' & Round(width1+(width1*.71)) & '%, 
    rgba(0,0,0,.5) ' & Round(width1+(width1*.71)) & '%, 
    rgba(0,0,0,.5) ' & Round(width1+(width1*.73)) & '%, 
    rgba(255,255,255,.2) ' & Round(width1+(width1*.73)) & '%, 
    rgba(255,255,255,.2) ' & Round(width1+(width1*.79)) & '%, 
    rgba(0,0,0,.5) ' & Round(width1+(width1*.79)) & '%, 
    rgba(0,0,0,.5) ' & Round(width1+(width1*.80)) & '%, 
    transparent ' & Round(width1+(width1*.80)) & '%),
  repeating-linear-gradient(125deg, transparent, transparent 1%, 
    rgba(0,0,0,.2) 1%, 
    rgba(0,0,0,.2) 2%, 
    transparent 3%, 
    transparent 5%, 
    rgba(0,0,0,.2) 5%);';

   return txt;

  }

  private string function buildCarbon() {

    var color = variables.fc_data['primary_color'];
    var hsl_color = color2hsl( hex2color( color ) );

    var bg = lightenHSL( hsl_color, -6 );
    var bar1 = lightenHSL( hsl_color, -5 );
    var bar3 = lightenHSL( hsl_color, -3 );
    var bar2 = lightenHSL( hsl_color, -2 );
    var bar4 = lightenHSL( hsl_color, 1 );

    var txt = 'background:
linear-gradient(27deg, ' & formatHSL(bar1) & ' 20%, transparent 20%) 0 4%,
linear-gradient(207deg, ' & formatHSL(bar1) & ' 20%, transparent 20%) 48% 0,
linear-gradient(27deg, ' & formatHSL(hsl_color) & ' 20%, transparent 20%) 0 45%,
linear-gradient(207deg, ' & formatHSL(hsl_color) & ' 20%, transparent 20%) 48% 4%,
linear-gradient(90deg, ' & formatHSL(bar2) & ' 55%, transparent 55%),
linear-gradient(' & formatHSL(bar2) & ' 25%, ' & formatHSL(bar3) & ' 25%, ' & formatHSL(bar3) & ' 50%, transparent 50%, transparent 75%, ' & formatHSL(bar4) & ' 75%, ' & formatHSL(bar4) & ');
background-color: ' & formatHSL(bg) & ';
background-size: 8% 11%;';

    return txt;

  }

  private string function buildWaves() {

    var color = variables.fc_data['primary_color'];
    var pos = getFrequency(variables.fc_data['position'], 4);

    var txt = 'background: 
  radial-gradient(circle at 100% 50%, transparent 20%, rgba(255,255,255,.3) 21%, rgba(255,255,255,.3) 34%, transparent 35%, transparent),
  radial-gradient(circle at 0% 50%, transparent 20%, rgba(255,255,255,.3) 21%, rgba(255,255,255,.3) 34%, transparent 35%, transparent) 0 ' & pos.z & '%;
  background-color: ##' & color &';
  background-size:' & pos.x & '% ' & pos.y & '%;';
    return txt;

  }

  private numeric function hex2dec( string hex ) {
    return InputBaseN( arguments.hex, 16 );
  }

  private string function dec2hex( numeric value ) {

    var tmp = FormatBaseN( arguments.value, 16 );

    if ( Len(tmp) == 1) {
      tmp = '0' & tmp;
    }

    return tmp;
  }

  private string function formatHSL( struct in_hsl ) {

    return 'hsl(' & Round(arguments.in_hsl.h) & ', ' & Round(arguments.in_hsl.s * 100) & '%, ' & Round(arguments.in_hsl.l * 100) & '%)';

  }

  private struct function lightenHSL( struct in_hsl, numeric factor ) {

    var old_l = in_hsl.l;
    var fac = arguments.factor / 100;

    // pass in negative values to darken
    old_l += fac;

    if (old_l < 0)
      old_l = 0;

    if (old_l > 1)
      old_l = 1;

    return {
      h: arguments.in_hsl.h,
      s: arguments.in_hsl.s,
      l: old_l
    };

  }

  private struct function color2hsl( struct in_color ) {

    var rgb = ArrayNew(1);
    var r = in_color.r;
    var g = in_color.g;
    var b = in_color.b;

    rgb[1] = r / 255;
    rgb[2] = g / 255;
    rgb[3] = b / 255;

    var min = rgb[1];
    var max = rgb[1];
    var maxcolor = 1;
    var h = '';
    var l = 0;
    var s = 0;

    for (var i = 1; i <= ArrayLen(rgb); i++) {

      if (rgb[i] <= min) {
        min = rgb[i];
      }

      if (rgb[i] >= max) {
        max = rgb[i];
        maxcolor = i;
      }

    }

    if (maxcolor == 1) {
      h = (rgb[2] - rgb[3]) / (max - min);
    }

    if (maxcolor == 2) {
      h = 2 + (rgb[3] - rgb[1]) / (max - min);
    }

    if (maxcolor == 3) {
      h = 4 + (rgb[1] - rgb[2]) / (max - min);
    }

    if (!IsNumeric(h)) {
      h = 0;
    }

    h = h * 60;

    if (h < 0) {
      h = h + 360; 
    }

    l = (min + max) / 2;

    if (min == max) {
      s = 0;
    } else {
      if (l < 0.5) {
        s = (max - min) / (max + min);
      } else {
        s = (max - min) / (2 - max - min);
      }
    }

    return {
      h : h, s : s, l : l
    };

  }

  private string function color2hex( struct in_color ) {
    return dec2hex(arguments.in_color.r) & dec2hex(arguments.in_color.g) & dec2hex(arguments.in_color.b);
  }

  private struct function hex2color( string hex ) {
    var data = {};

    var R = Left(arguments.hex, 2);
    var G = Mid(arguments.hex, 3, 2);
    var B = Right(arguments.hex, 2);

    data['r'] = hex2dec(R);
    data['g'] = hex2dec(G);
    data['b'] = hex2dec(B);

    return data;
  }

  /* https://stackoverflow.com/questions/1855884/determine-font-color-based-on-background-color */
  private string function contrastColor( string hex ) {
    var in_color = hex2color(arguments.hex);
    var d=0;

    // Counting the perceptive luminance - human eye favors green color... 
    var luminance = ( (0.299 * in_color.r) + (0.587 * in_color.g) + (0.114 * in_color.b) ) / 255;

    if (luminance > 0.5)
       d = 0; // bright colors - black font
    else
       d = 255; // dark colors - white font

    return color2hex({"r":d,"g":d,"b":d});

  }

  private struct function getVendor( numeric value ) {

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

  private struct function getVendorPosition( numeric value ) {

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

  private string function getVendorColor( numeric value ) {

    var textColor = contrastColor(variables.fc_data['primary_color']);

    return '##' & textColor;

  }

  private boolean function hasVendor( numeric value ) {

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

  private string function getShape( numeric value ) {

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

  private struct function getChipPosition( numeric value ) {

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

  private function getChipColor( numeric value ) {

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

  private boolean function hasChip( numeric value ) {

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

  private numeric function getPercentage( numeric value, numeric min=0, numeric max=0 ) {

    var choice = Round( 100 / 256 * arguments.value );

    if ( arguments.min > 0 && choice < arguments.min )
      choice = arguments.min;
    else if ( max > 0 && choice > max )
      choice = arguments.max;

    return choice;

  }

  private numeric function getAngle( numeric value ) {

    var choice = Round( arguments.value / 256 * 360 );

    return choice;

  }

  private struct function getFrequency( numeric value, numeric stages ) {

    var choice = arguments.value MOD arguments.stages;

    switch (choice) {
      case 0:
        return {
          x: 30,
          y: 69,
          z: -111
        }
        break;
      case 1:
        return {
          x: 27,
          y: 62,
          z: -80
        }
        break;
      case 2:
        return {
          x: 14,
          y: 32,
          z: -70
        }
        break;
      case 3:
        return {
          x: 9,
          y: 14,
          z: -43
        }
      default:
        return {
          x: 31,
          y: 71,
          z: -122
        }
        break;
    }

  }

  private string function getBorderStyle( numeric value ) {

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

  private string function getVendorCSS( string size="all" ) {

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
      vendorCSS &='  top: ' & variables.properties['vendor'].position.top & '%;
';
    }

    if ( variables.properties['vendor'].position.left > 0 ) {
      vendorCSS &= '  left: ' & variables.properties['vendor'].position.left & '%;
';
    }

    if ( variables.properties['vendor'].position.bottom > 0 ) {
      vendorCSS &= '  bottom: ' & variables.properties['vendor'].position.bottom & '%;
';
    }

    if ( variables.properties['vendor'].position.right > 0 ) {
      vendorCSS &= '  right: ' & variables.properties['vendor'].position.right & '%;
';
    }

    cfloop( list=StructKeyList(variables.properties['vendor']), index="item" ) {

      if ( !ReFindNoCase( "(name|transform|position|color)", item ) ) {
        vendorCSS &= '
  ' & LCase(item) & ':' & variables.properties['vendor'][item] & ';
        ';
      }

    }

    vendorCSS &= '  z-index: 2;
}
';

    if ( arguments.size == "all" || arguments.size == "small" ) {

      vendorCSS &= '
.' & variables.cardClass & '.small:after {
  font-size: 6px;
}
      ';
    }

    if ( arguments.size == "all" || arguments.size == "large" ) {

      vendorCSS &= '
.' & variables.cardClass & '.large:after {
  font-size: 28px;
}
      ';
    }

    return vendorCSS;

  }

  private string function getChipCSS( string size="all" ) {

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
    ';

    if ( arguments.size == "all" || arguments.size == "small" ) {

      chipCSS &= '
.' & variables.cardClass & '.small:before {
  height: 6px;
  width: 9px;
  border-radius: 1px;
}
      ';
    }

    if ( arguments.size == "all" || arguments.size == "large" ) {

      chipCSS &= '
.' & variables.cardClass & '.large:before {
  height: 24px;
  width: 36px;
  border-radius: 4px;
}
      ';
    }

    return chipCSS;

  }

  private string function getHolderCSS( string size="all" ) {

    var holderCSS = '
.holder {
  position: relative;
  width: ' & variables.width & 'px;
  height: ' & variables.height & 'px;
}
    ';

    if ( arguments.size == "all" || arguments.size == "small" ) {

      holderCSS &= '
.holder.small {
  width: ' & variables.width_small & 'px;
  height: ' & variables.height_small & 'px;
}
      ';

    }

    if ( arguments.size == "all" || arguments.size == "large" ) {

      holderCSS &= '
.holder.large {
  width: ' & variables.width_large & 'px;
  height: ' & variables.height_large & 'px;
}
      ';

    }

    return holderCSS;

  }

  private string function getCardCSS( string size="all" ) {

    var cssString = '
.' & variables.cardClass & ' {
  height: ' & variables.height & 'px;
  width: ' & variables.width & 'px;
  border-radius: 8px;
  border-width: 3px;
  border-color: ##' & variables.properties['border-color'] & ';
  border-style: ' & variables.properties['border-style'] & ';
  ' & variables.properties['background'] & ';
}
    ';

    if ( arguments.size == "all" || arguments.size == "small" ) {

      cssString &= '
.' & variables.cardClass & '.small {
  height: ' & variables.height_small & 'px;
  width: ' & variables.width_small & 'px;
  border-radius: 6px;
}
      ';

    }

    if ( arguments.size == "all" || arguments.size == "large" ) {

      cssString &= '
.' & variables.cardClass & '.large {
  height: ' & variables.height_large & 'px;
  width: ' & variables.width_large & 'px;
  border-radius: 12px;
}
      ';

    }

    if ( hasChip( variables.properties['hasChip'] ) ) {
      cssString &= '
' & getChipCSS( arguments.size );

    }

    if ( hasVendor( variables.properties['hasVendor'] ) ) {
      cssString &= '
' & getVendorCSS( arguments.size );

    }

    return cssString;

  }

  /*******************
      REMOTE
  *******************/

  /*
  - you should be able to call these all from a browser.
  - these will all require the params to be passed in, so nothing here should behave as if properties are stateful
  */

  /* render() is the odd one out, as it actually pushes output to the browser -- the rest are string returns */
  remote string function render( string cardName="FantabulousCard", 
    cardClass="", numeric width=120, height=70, struct data = {}, string hash="", size="all", id="" ) {

    var html = getCompleteHTML( argumentCollection=arguments );

    cfcontent( type="text/html" );
    writeOutput( html );

  }

  remote string function getCompleteHTML( string cardName="FantabulousCard", 
    cardClass="", numeric width=120, height=70, struct data = {}, string hash="", size="all", id="" ) {

    var css = getCSS( argumentCollection=arguments );

    var html='<html>
  <head>
    <style>' & css & '</style>
  </head>
  <body>' & getHTML( argumentCollection=arguments ) & '</body>
  </html>
';

    return html;

  }

  // this method is only intended for remote testing
  remote string function getCSS( string cardName="FantabulousCard", 
    cardClass="", numeric width=120, height=70, struct data = {}, string hash="", size="all", id="" ) {

    // init
    fantabulousCard( argumentCollection=arguments );

    return getHolderCSS( arguments.size ) & getCardCSS( arguments.size );

  }

  /* just returns the HTML fragment (div) that's needed */
  remote string function getHTML( string cardName="FantabulousCard", 
    cardClass="", numeric width=120, height=70, struct data = {}, string hash="", size="all", id="" ) {

    var html = '';

    // init
    fantabulousCard( argumentCollection=arguments );

    if ( arguments.size == "all" || arguments.size == "small" ) {
      html &= '<div class="container">
      <div class="row">
        <div class="col">
          <div class="holder small">
            <div';
            if ( Len(variables.id) ) {
              html &= ' id="#variables.id#_small"';
            }
            html &= ' class="#variables.cardClass# small"></div>
          </div>
        </div>
      </div>
      <br/>
';
    }

    if ( arguments.size == "all" || arguments.size == "regular" ) {
      html &= '<div class="row">
        <div class="col">
          <div class="holder">
            <div';
            if ( Len(variables.id) ) {
              html &= ' id="#variables.id#"';
            }
            html &= ' class="#variables.cardClass#"></div>
          </div>
        </div>
      </div>
      <br/>
';
    }

    if ( arguments.size == "all" || arguments.size == "large" ) {
      html &= '<div class="row">
        <div class="col">
          <div class="holder large">
            <div';
            if ( Len(variables.id) ) {
              html &= ' id="#variables.id#_large"';
            }
            html &= ' class="#variables.cardClass# large"></div>
          </div>
        </div>
      </div>
    </div>
';
    }

    return html;

  }


}