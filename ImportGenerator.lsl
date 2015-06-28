integer UNKNOWN = 0xFFFFFFFF;

// TODO: llGetLinkMedia


list rules = [
    PRIM_NAME, 
    PRIM_DESC,
    PRIM_TYPE,
    PRIM_SLICE,
    PRIM_PHYSICS_SHAPE_TYPE,
    PRIM_MATERIAL,
    PRIM_PHYSICS,
    PRIM_TEMP_ON_REZ,
    PRIM_PHANTOM,
    PRIM_POSITION,
    PRIM_POS_LOCAL,
    PRIM_ROTATION,
    PRIM_ROT_LOCAL,
    PRIM_SIZE,
    PRIM_TEXT,
    PRIM_FLEXIBLE,
    PRIM_POINT_LIGHT,
    PRIM_OMEGA,
    PRIM_COLOR, ALL_SIDES,
    PRIM_TEXTURE, ALL_SIDES,
    PRIM_BUMP_SHINY, ALL_SIDES,
    PRIM_FULLBRIGHT, ALL_SIDES,
    PRIM_TEXGEN, ALL_SIDES,
    PRIM_GLOW, ALL_SIDES,
    PRIM_NORMAL, ALL_SIDES,
    PRIM_SPECULAR, ALL_SIDES,
    PRIM_ALPHA_MODE, ALL_SIDES
    ];

add(integer indent, string text) {
    while(indent-- > 0) {
        text = "\t" + text;
    }
    llOwnerSay(text);
}

openScript(integer primCount) {
    add(0, "default");
    add(0, "{");
    add(1, "state_entry()");
    add(1, "{");
    
    add(2, "if(llGetNumberOfPrims() != " + (string)primCount + ") {");
    add(3, "llOwnerSay(\"Object must have " + (string)primCount + " prims\");");
    add(3, "return;");
    add(2, "}");
    add(2, "");  
}

closeScript() {
    add(1, "}");
    add(0, "}");
}


integer writeLink(list params, list data, integer sides) {
    
    integer paramCount = llGetListLength(params);
    integer paramIndex = 0;
    integer pos = 0;
    while(paramIndex < paramCount) {
        
        integer paramValue = llList2Integer(params, paramIndex);
        
        if(paramValue != ALL_SIDES) {
            
            integer dataSize = ruleSize(paramValue);
            
            if(ruleIsForSide(paramValue)) {
                
                pos += writeParamSides(paramValue, sides, dataSize, llList2List(data, pos, -1));
                
            }
            else {
                list chunk = llList2List(data, pos, pos + dataSize - 1);
                pos += writeParam(paramValue, dataSize, chunk);
            }
            
        }
        paramIndex++;
    }
    return pos;
}

integer writeParamSides(integer paramValue, integer sides, integer dataSize, list data) {
    list sample = llList2List(data, 0, dataSize - 1);
    integer allSidesMatch = TRUE;
    integer side;
    for(side = 1; side < sides; side++) {
        list sideData = llList2List(data, (side * dataSize), (side * dataSize) + dataSize - 1);
        if(llListFindList(sample, sideData) == -1) {
            allSidesMatch = FALSE;
            side = sides;
        }
    }
    
    if(allSidesMatch) {
        writeSideParam(paramValue, ALL_SIDES, dataSize, sample);
        return sides * dataSize;
    }
        
    integer pos = 0;
    for(side = 0; side < sides; side++) {
        list chunk = llList2List(data, pos, pos + dataSize - 1);
        pos += writeSideParam(paramValue, side, dataSize, chunk);        
    }
    return pos;
}

integer writeParam(integer rule, integer parameterCount, list data) {
    
    string ruleName = ruleName(rule);
    if(rule == PRIM_TYPE) {
        parameterCount = primTypeSize(llList2Integer(data, 0));
        data = llList2List(data, 0, parameterCount);
        parameterCount+=1;
    }
    
    writeParamAs(ruleName, formatList(data, rule));
    return parameterCount;
}

integer writeSideParam(integer rule, integer side, integer parameterCount, list data) {
    string ruleName = ruleName(rule);
    writeParamAs(ruleName, [formatSide(side)] + formatList(data, rule));
    return parameterCount;
}

integer writeParamAs(string name, list data) {
    add(4, name + ", " + llList2CSV(data) + ", ");
    return llGetListLength(data);
}

integer primTypeSize(integer type) {
    if(type == PRIM_TYPE_BOX) return 6;
    if(type == PRIM_TYPE_CYLINDER) return 6;
    if(type == PRIM_TYPE_PRISM) return 6;
    if(type == PRIM_TYPE_SPHERE) return 5;
    if(type == PRIM_TYPE_TORUS) return 11;
    if(type == PRIM_TYPE_TUBE) return 11;
    if(type == PRIM_TYPE_RING) return 11;
    if(type == PRIM_TYPE_SCULPT) return 2;
    return UNKNOWN;
}

list formatList(list raw, integer rule) {
    integer count = llGetListLength(raw);
    integer i;
    list formatted = [];
    for(i = 0; i < count; i++) {
        integer handled = FALSE;
       
        if(rule == PRIM_TYPE) {
            if(rule == PRIM_TYPE && i == 0) {
                formatted += formatPrimType(llList2Integer(raw, i));
                handled = TRUE;
            }
            else {
                integer primType = llList2Integer(raw, 0);
                if(primType != PRIM_TYPE_SCULPT && i == 1) {
                    formatted += formatPrimHole(llList2Integer(raw, i));
                    handled = TRUE;
                }
                if(primType == PRIM_TYPE_SCULPT && i == 2) {
                    formatted += formatPrimSculptType(llList2Integer(raw, i));
                    handled = TRUE;
                }
            }
        }
        else if(rule == PRIM_PHYSICS_SHAPE_TYPE && i == 0) {
            formatted += formatPrimPhysicsShape(llList2Integer(raw, i));
            handled = TRUE;
        }
        else if(rule == PRIM_MATERIAL && i == 0) {
            formatted += formatPrimMaterial(llList2Integer(raw, i));
            handled = TRUE;
        }
        else if(rule == PRIM_BUMP_SHINY && i == 0) {
            formatted += formatPrimShiny(llList2Integer(raw, i));
            handled = TRUE;
        }
        else if(rule == PRIM_BUMP_SHINY && i == 1) {
            formatted += formatPrimBump(llList2Integer(raw, i));
            handled = TRUE;
        }
        else if(rule == PRIM_TEXGEN && i == 0) {
            formatted += formatPrimTexgen(llList2Integer(raw, i));
            handled = TRUE;
        }
        else if(rule == PRIM_ALPHA_MODE && i == 0) {
            formatted += formatPrimAlphaMode(llList2Integer(raw, i));
            handled = TRUE;
        }
         
        if(isBoolean(rule, i)) {
            formatted += formatBoolean(llList2Integer(raw, i));
            handled = TRUE;
        }
        
        if(isRadian(rule, i)) {
            formatted += formatRadian(llList2Float(raw, i));
            handled = TRUE;
        }
        
        if(!handled) {
         integer type = llGetListEntryType(raw, i);
         formatted += formatListEntry(type, i, raw);
        }
    }
   
    return formatted;
}

integer isBoolean(integer rule, integer index) {
    list conditions = [
        PRIM_PHYSICS, 0,
        PRIM_PHANTOM, 0,
        PRIM_TEMP_ON_REZ, 0,
        PRIM_FULLBRIGHT, 0,
        PRIM_FLEXIBLE, 0,
        PRIM_POINT_LIGHT, 0
    ];
    
    return llListFindList(conditions, [rule, index]) != -1;
}

integer isRadian(integer rule, integer index) {
    list conditions = [
        PRIM_TEXTURE, 3,
        PRIM_NORMAL, 3,
        PRIM_SPECULAR, 3
    ];
    
    return llListFindList(conditions, [rule, index]) != -1;
}
string formatPrimAlphaMode(integer value) {
    if(value == PRIM_ALPHA_MODE_NONE) return "PRIM_ALPHA_MODE_NONE";
    if(value == PRIM_ALPHA_MODE_BLEND) return "PRIM_ALPHA_MODE_BLEND";
    if(value == PRIM_ALPHA_MODE_MASK) return "PRIM_ALPHA_MODE_MASK";
    if(value == PRIM_ALPHA_MODE_EMISSIVE) return "PRIM_ALPHA_MODE_EMISSIVE";
    return formatInteger(value);
}

string formatPrimTexgen(integer value) {
    if(value == PRIM_TEXGEN_DEFAULT) return "PRIM_TEXGEN_DEFAULT";
    if(value == PRIM_TEXGEN_PLANAR) return "PRIM_TEXGEN_PLANAR";
    return formatInteger(value);
}

string formatPrimBump(integer value) {
    if(value == PRIM_BUMP_NONE) return "PRIM_BUMP_NONE";
    if(value == PRIM_BUMP_BRIGHT) return "PRIM_BUMP_BRIGHT";
    if(value == PRIM_BUMP_DARK) return "PRIM_BUMP_DARK";
    if(value == PRIM_BUMP_WOOD) return "PRIM_BUMP_WOOD";
    if(value == PRIM_BUMP_BARK) return "PRIM_BUMP_BARK";
    if(value == PRIM_BUMP_BRICKS) return "PRIM_BUMP_BRICKS";
    if(value == PRIM_BUMP_CHECKER) return "PRIM_BUMP_CHECKER";
    if(value == PRIM_BUMP_CONCRETE) return "PRIM_BUMP_CONCRETE";
    if(value == PRIM_BUMP_TILE) return "PRIM_BUMP_TILE";
    if(value == PRIM_BUMP_STONE) return "PRIM_BUMP_STONE";
    if(value == PRIM_BUMP_DISKS) return "PRIM_BUMP_DISKS";
    if(value == PRIM_BUMP_GRAVEL) return "PRIM_BUMP_GRAVEL";
    if(value == PRIM_BUMP_BLOBS) return "PRIM_BUMP_BLOBS";
    if(value == PRIM_BUMP_SIDING) return "PRIM_BUMP_SIDING";
    if(value == PRIM_BUMP_LARGETILE) return "PRIM_BUMP_LARGETILE";
    if(value == PRIM_BUMP_STUCCO) return "PRIM_BUMP_STUCCO";
    if(value == PRIM_BUMP_SUCTION) return "PRIM_BUMP_SUCTION";
    if(value == PRIM_BUMP_WEAVE) return "PRIM_BUMP_WEAVE";
    return formatInteger(value);
}
string formatPrimShiny(integer value) {
    if(value == PRIM_SHINY_NONE) return "PRIM_SHINY_NONE";
    if(value == PRIM_SHINY_LOW) return "PRIM_SHINY_LOW";
    if(value == PRIM_SHINY_MEDIUM) return "PRIM_SHINY_MEDIUM";
    if(value == PRIM_SHINY_HIGH) return "PRIM_SHINY_HIGH";
    return formatInteger(value);
}
string formatRadian(float value) {
    if(value == PI) return "PI";
    if(value == TWO_PI) return "TWO_PI";
    if(value == PI_BY_TWO) return "PI_BY_TWO";
    if(value == -PI) return "-PI";
    if(value == -TWO_PI) return "-TWO_PI";
    if(value == -PI_BY_TWO) return "-PI_BY_TWO";
    if(value == 0) return formatFloat(value);
    return formatFloat(RAD_TO_DEG * value) + " * DEG_TO_RAD";
}

string formatBoolean(integer value) {
    if(value == 0) return "FALSE";
    if(value == 1) return "TRUE";
    return formatInteger(value);
}

string formatPrimMaterial(integer value) {
    if(value == PRIM_MATERIAL_STONE) return "PRIM_MATERIAL_STONE";
    if(value == PRIM_MATERIAL_METAL) return "PRIM_MATERIAL_METAL";
    if(value == PRIM_MATERIAL_GLASS) return "PRIM_MATERIAL_GLASS";
    if(value == PRIM_MATERIAL_WOOD) return "PRIM_MATERIAL_WOOD";
    if(value == PRIM_MATERIAL_FLESH) return "PRIM_MATERIAL_FLESH";
    if(value == PRIM_MATERIAL_PLASTIC) return "PRIM_MATERIAL_PLASTIC";
    if(value == PRIM_MATERIAL_RUBBER) return "PRIM_MATERIAL_RUBBER";
    if(value == PRIM_MATERIAL_LIGHT) return "PRIM_MATERIAL_LIGHT";
    return formatInteger(value);
}
    
string formatPrimPhysicsShape(integer value) {
    if(value == PRIM_PHYSICS_SHAPE_PRIM) return "PRIM_PHYSICS_SHAPE_PRIM";
    if(value == PRIM_PHYSICS_SHAPE_CONVEX) return "PRIM_PHYSICS_SHAPE_CONVEX";
    if(value == PRIM_PHYSICS_SHAPE_NONE) return "PRIM_PHYSICS_SHAPE_NONE";
    return formatInteger(value);
}
string formatPrimSculptType(integer value) {
    string flags = "";

    if((value & PRIM_SCULPT_FLAG_MIRROR) == PRIM_SCULPT_FLAG_MIRROR) {
        flags += " | PRIM_SCULPT_FLAG_MIRROR";
        value -= PRIM_SCULPT_FLAG_MIRROR;
    }
    
    if((value & PRIM_SCULPT_FLAG_INVERT) == PRIM_SCULPT_FLAG_INVERT) {
        flags += " | PRIM_SCULPT_FLAG_INVERT";
        value -= PRIM_SCULPT_FLAG_INVERT;
    }
    
    if(value == PRIM_SCULPT_TYPE_SPHERE) return "PRIM_SCULPT_TYPE_SPHERE" + flags;
    if(value == PRIM_SCULPT_TYPE_TORUS) return "PRIM_SCULPT_TYPE_TORUS" + flags;
    if(value == PRIM_SCULPT_TYPE_PLANE) return "PRIM_SCULPT_TYPE_PLANE" + flags;
    if(value == PRIM_SCULPT_TYPE_CYLINDER) return "PRIM_SCULPT_TYPE_CLININDER" + flags;
    return formatInteger(value) + flags;
}
string formatPrimHole(integer value) {
    if(value == PRIM_HOLE_DEFAULT) return "PRIM_HOLE_DEFAULT";
    if(value == PRIM_HOLE_CIRCLE) return "PRIM_HOLE_CIRCLE";
    if(value == PRIM_HOLE_SQUARE) return "PRIM_HOLE_SQUARE";
    if(value == PRIM_HOLE_TRIANGLE) return "PRIM_HOLE_TRIANGLE";
    return formatInteger(value);
}
string formatPrimType(integer value) {
    if(value == PRIM_TYPE_BOX) return "PRIM_TYPE_BOX";
    if(value == PRIM_TYPE_CYLINDER) return "PRIM_TYPE_CYLINDER";
    if(value == PRIM_TYPE_PRISM) return "PRIM_TYPE_PRISM";
    if(value == PRIM_TYPE_SPHERE) return "PRIM_TYPE_SPHERE";
    if(value == PRIM_TYPE_TORUS) return "PRIM_TYPE_TORUS";
    if(value == PRIM_TYPE_TUBE) return "PRIM_TYPE_TUBE";
    if(value == PRIM_TYPE_RING) return "PRIM_TYPE_RING";
    if(value == PRIM_TYPE_SCULPT) return "PRIM_TYPE_SCULPT";
    return formatInteger(value);
}
string formatListEntry(integer type, integer index, list data) {
    if(type == TYPE_KEY) return formatKey(llList2Key(data, index));
    if(type == TYPE_INTEGER) return formatInteger(llList2Integer(data, index));
    if(type == TYPE_STRING) return formatString(llList2String(data, index));
    if(type == TYPE_VECTOR) return formatVector(llList2Vector(data, index));
    if(type == TYPE_FLOAT) return formatFloat(llList2Float(data, index));
    if(type == TYPE_ROTATION) return formatRotation(llList2Rot(data, index));
    return llList2String(data, index);
}

string formatVector(vector value) {
    if(value == ZERO_VECTOR) return "ZERO_VECTOR";
    return "<" + formatFloat(value.x) + ", " + formatFloat(value.y) + ", " + formatFloat(value.z) + ">";
}

string formatRotation(rotation value) {
    if(value == ZERO_ROTATION) return "ZERO_ROTATION";
    if(value == -ZERO_ROTATION) return "-ZERO_ROTATION";
    vector e = llRot2Euler(value) * RAD_TO_DEG;
    return "llEuler2Rot(" + formatVector(e) + " * DEG_TO_RAD)";
}

string formatFloat(float value) {
    if(value == (integer)value) {
        return (string)((integer)value) + ".0";
    }
    if(value == PI) return "PI";
    if(value == TWO_PI) return "TWO_PI";
    if(value == PI_BY_TWO) return "PI_BY_TWO";
    if(value == -PI) return "-PI";
    if(value == -TWO_PI) return "-TWO_PI";
    if(value == -PI_BY_TWO) return "-PI_BY_TWO";
    
    return (string)value;
}
string formatString(string value) {
    if(value == "\n\n\n") return "EOF";
    return "\"" + value + "\"";
}

string formatInteger(integer value) {
    //if(value == TRUE) return "TRUE";
    //if(value == FALSE) return "FALSE";
    return (string)value;
}
string formatKey(key value) {
    if(value == NULL_KEY) return "NULL_KEY";
    if(value == TEXTURE_BLANK) return "TEXTURE_BLANK";
    if(value == TEXTURE_TRANSPARENT) return "TEXTURE_TRANSPARENT";
    if(value == TEXTURE_MEDIA) return "TEXTURE_MEDIA";
    if(value == TEXTURE_PLYWOOD) return "TEXTURE_PLYWOOD";
    if(value == TEXTURE_DEFAULT) return "TEXTURE_DEFAULT";
    return "\"" + (string)value + "\"";
}

string formatLink(integer link) {
    if(link == LINK_ROOT) return "LINK_ROOT";
    if(link == LINK_SET) return "LINK_SET";
    if(link == LINK_THIS) return "LINK_THIS";
    if(link == LINK_ALL_OTHERS) return "LINK_ALL_OTHERS";
    if(link == LINK_ALL_CHILDREN) return "LINK_ALL_CHILDREN";
    return (string)link;
}

string formatSide(integer side) {
    if(side == ALL_SIDES) return "ALL_SIDES";
    return (string)side;
}

integer ruleIsForSide(integer rule) {
    return rule == PRIM_COLOR ||
        rule == PRIM_TEXTURE ||
        rule == PRIM_BUMP_SHINY ||
        rule == PRIM_FULLBRIGHT ||
        rule == PRIM_TEXGEN ||
        rule == PRIM_GLOW ||
        rule == PRIM_NORMAL ||
        rule == PRIM_SPECULAR ||
        rule == PRIM_ALPHA_MODE;
}
integer ruleSize(integer r) {
    integer i = llListFindList(rules, [r]);
    if(i == -1) return UNKNOWN;
    return llList2Integer([
    1,// name
    1,// desc
    11,    // type
    1,// slice
    1,// physics shape type
    1,// material
    1,// physics
    1,// temp on rez
    1,// phantom
    1,// position
    1,// pos local
    1,// rotation
    1,// rot local
    1,// size
    3,// text
    7,// flexible
    5,// point light
    3,// omega
    2, UNKNOWN, // face * 2 color
    4, UNKNOWN, // face * 4 texture
    2, UNKNOWN, // face * 2 bump shiny
    1, UNKNOWN, // face * 1 full bright
    1, UNKNOWN, // face * 1 texgen
    1, UNKNOWN, // face * 1 glow
    4, UNKNOWN, // face * 4 normal
    7, UNKNOWN, // face * 7 specular
    2, UNKNOWN  // face * 2 alpha mode
    ], i);
    
}
string ruleName(integer r) {
    integer i = llListFindList(rules, [r]);
    if(i == -1) return (string)r;
    
    return "PRIM_" + llList2String([
    "NAME", 
    "DESC",
    "TYPE",
    "SLICE",
    "PHYSICS_SHAPE_TYPE",
    "MATERIAL",
    "PHYSICS",
    "TEMP_ON_REZ",
    "PHANTOM",
    "POSITION",
    "POS_LOCAL",
    "ROTATION",
    "ROT_LOCAL",
    "SIZE",
    "TEXT",
    "FLEXIBLE",
    "POINT_LIGHT",
    "OMEGA",
    "COLOR", "INVALID HERE!!!",
    "TEXTURE", "",
    "BUMP_SHINY", "",
    "FULLBRIGHT", "",
    "TEXGEN", "",
    "GLOW", "",
    "NORMAL", "",
    "SPECULAR", "",
    "ALPHA_MODE", ""
    ], i);
}

writeScript(list params, list data, integer sides) {
    
    add(2, "llSetLinkPrimitiveParamsFast(LINK_ROOT, [");
    
    integer link = LINK_ROOT;
    integer dataLength = llGetListLength(data);
    integer dataPosition = 0;
    while(dataPosition < dataLength) {
        add(3, "PRIM_LINK_TARGET, " + (string)link + ",");
        dataPosition += writeLink(params, llList2List(data, dataPosition, -1), sides); 
        link++;
    }
    
    add(3, "PRIM_LINK_TARGET, LINK_ROOT");
    add(2, "]);");
}

default
{
    state_entry()
    {
        integer link;
        list linkSides = [];
        integer primCount = llGetNumberOfPrims();
        list allParams = [];
        
        openScript(primCount);
        
        for(link = LINK_ROOT; link <= primCount; link++) {
            //linkSides += [llGetLinkNumberOfSides(link)];
            //allParams = allParams + [PRIM_LINK_TARGET, link] + rules;
            list data = llGetLinkPrimitiveParams(link,rules);
            integer linkSides = llGetLinkNumberOfSides(link);
            add(2, "llSetLinkPrimitiveParamsFast(" + (string)link + ", [");
            
            writeLink(rules, data, linkSides);
            
            add(3, "PRIM_LINK_TARGET, " + (string)link);
            add(2, "]);");
            
            llSleep(1.0);
        }
       
        //list data = llGetLinkPrimitiveParams(LINK_ROOT,allParams);
        
        //writeScript(rules, data, linkSides, primCount);
        
        closeScript();
    }
}
