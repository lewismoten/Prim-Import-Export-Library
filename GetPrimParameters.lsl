string WriteAllShiny()
{
    string s;
    list params = llGetPrimitiveParams([PRIM_BUMP_SHINY, ALL_SIDES]);
    if(AllFacesSame(params, 2))
    {
        if(isSameList(llList2List(params, 1, 2), [0, 0])) return "";
        
        return WriteShiny(0, params, "ALL_SIDES");
    }
    else
    {
        integer n = llGetListLength(params);
        integer i;
        integer j = 0;
        for(i = 0; i < n; i+= 2)
            s += WriteShiny(i, params, (string)(j++)) + ", ";
        return s;
    }
}
string WriteShiny(integer i, list params, string face)
{
    string s = "PRIM_BUMP_SHINY, " + face + ", ";
    integer shinyType = llList2Integer(params, i);
    list shinies = ["NONE", "LOW", "MEDIUM", "HIGH"];
    if(shinyType < llGetListLength(shinies))
        s += "PRIM_SHINY_" + llList2String(shinies, shinyType) + ", ";
    else
        s += (string)shinyType + ", ";
    integer bumpType = llList2Integer(params, i + 1);
    list bumps = ["NONE", "BRIGHT", "DARK", "WOOD", "BARK", "BRICKS", "CHECKER",
        "CONCRETE", "TILE", "STONE", "DISKS", "GRAVEL", "BLOBS", "SIDING",
        "LARGETILE", "STUCCO", "SUCTION", "WEAVE"];
    if(bumpType < llGetListLength(bumps))
        s += "PRIM_BUMP_" + llList2String(bumps, bumpType);
    else
        s += (string)bumpType;
    return s;
}
integer AllFacesSame(list params, integer size)
{
    integer i;
    integer j;
    integer n = llGetListLength(params);
    for(i = size; i < n; i += size)
        for(j = 0; j < size; j++)
            if(llList2String(params, i + j) != llList2String(params, j))
                return FALSE;
    return TRUE;
}
string WriteAllColors()
{
    string s;
    list params = llGetPrimitiveParams([PRIM_COLOR, ALL_SIDES]);
    if(AllFacesSame(params, 2))
    {
        if(isSameList(llList2List(params, 1, 2), [1.0, <1, 1, 1>])) return ""; 
        s += WriteColor(0, params, "ALL_SIDES") + ", ";
    }
    else
    {
        integer n = llGetListLength(params);
        integer i;
        integer j = 0;
        for(i = 0; i < n; i+= 2)
            s += WriteColor(i, params, (string)(j++)) + ", ";
    }
    return s;
}
string WriteColor(integer i, list params, string face)
{
    string s = "PRIM_COLOR, " + (string)face + ", ";
    s += WriteVector(llList2Vector(params, i)) + ", ";
    s += WriteFloat(llList2Float(params, i + 1), FALSE);
    return s;
}
string WriteFlexible()
{
    list params = llGetPrimitiveParams([PRIM_FLEXIBLE]);
    if(isSameList(params, [FALSE, 0, 0.0, 0.0, 0.0, 0.0, ZERO_VECTOR])) return "";
    
    string s = "PRIM_FLEXIBLE, ";
    s += WriteBoolean(llList2Integer(params, 0)) + ", ";
    s += llList2String(params, 1) + ", ";
    s += WriteFloat(llList2Float(params, 2), FALSE) + ", ";
    s += WriteFloat(llList2Float(params, 3), FALSE) + ", ";
    s += WriteFloat(llList2Float(params, 4), FALSE) + ", ";
    s += WriteFloat(llList2Float(params, 5), FALSE) + ", ";
    s += WriteVector(llList2Vector(params, 6)) + ", ";
    return s;
}
integer isSameList(list list1, list list2) {
    return llList2CSV(list1) == llList2CSV(list2);
}
string WriteFullBrights()
{
    list params = llGetPrimitiveParams([PRIM_FULLBRIGHT, ALL_SIDES]);
    
    if(AllFacesSame(params, 1))
    {
        if(llList2Integer(params, 0) == FALSE) return "";
        return "PRIM_FULLBRIGHT, ALL_SIDES, " + WriteBoolean(llList2Integer(params, 0)) + ", ";
    }
    else
    {
        integer n = llGetListLength(params);
        integer i;
        string s;
        integer j = 0;
        for(i = 0; i < n; i++)
            s += "PRIM_FULLBRIGHT, " + (string)i + ", " + WriteBoolean(llList2Integer(params, i)) + ", ";
        return s;
    }
}
string WriteMaterial()
{
    list m = ["STONE", "METAL", "GLASS", "WOOD", "FLESH", "PLASTIC", "RUBBER", "LIGHT"];
    list params = llGetPrimitiveParams([PRIM_MATERIAL]);
    string type = llList2String(m, llList2Integer(params, 0));
    if(type == "WOOD") return "";
    string s = "PRIM_MATERIAL, PRIM_MATERIAL_" + type + ", ";
    return s;
}
string WritePhantom()
{
    list params = llGetPrimitiveParams([PRIM_PHANTOM]);
    if(llList2Integer(params, 0) == FALSE) return "";
    
    string s = "PRIM_PHANTOM, " + WriteBoolean(llList2Integer(params, 0)) + ", ";
    return s;
}
string WritePhysics()
{
    list params = llGetPrimitiveParams([PRIM_PHYSICS]);
    if(llList2Integer(params, 0) == FALSE) return "";
    return "PRIM_PHYSICS, " + WriteBoolean(llList2Integer(params, 0)) + ", ";
}
string WritePointLight()
{
    list params = llGetPrimitiveParams([PRIM_POINT_LIGHT]);
    if(isSameList(params, [FALSE, ZERO_VECTOR, 0.0, 0.0, 0.0])) return "";
    
    string s = "PRIM_POINT_LIGHT, " + WriteBoolean(llList2Integer(params, 0)) + ", ";
    s += WriteVector(llList2Vector(params, 1)) + ", ";
    s += WriteFloat(llList2Float(params, 2), FALSE) + ", ";
    s += WriteFloat(llList2Float(params, 3), FALSE) + ", ";
    s += WriteFloat(llList2Float(params, 4), FALSE) + ", ";
    return s;
}
string WritePosition()
{
    list params = llGetPrimitiveParams([PRIM_POSITION]);
    return "PRIM_POSITION, " + WriteVector(llList2Vector(params, 0)) + ", ";
}
string WritePrimRotation()
{
    list params = llGetPrimitiveParams([PRIM_ROTATION]);
    rotation rot = llList2Rot(params, 0);
    if(rot == ZERO_ROTATION) return "";
    return "PRIM_ROTATION, " + WriteRotation(rot) + ", ";
}
string WriteSize()
{
    list params = llGetPrimitiveParams([PRIM_SIZE]);
    vector v = llList2Vector(params, 0);
    if(v == <0.5, 0.5, 0.5>) return "";
    return "PRIM_SIZE, " + WriteVector(v) + ", ";
}
string WriteTempOnRez()
{
    list params = llGetPrimitiveParams([PRIM_TEMP_ON_REZ]);
    if(llList2Integer(params, 0) == FALSE) return "";
    return "PRIM_TEMP_ON_REZ, " + WriteBoolean(llList2Integer(params, 0)) + ", ";
}
string WriteType()
{
    list params = llGetPrimitiveParams([PRIM_TYPE]);
    if(isSameList(params, [PRIM_TYPE_BOX, PRIM_HOLE_DEFAULT, <0, 1, 0>, 0.0, ZERO_VECTOR, <1, 1, 0>, ZERO_VECTOR])) return "";
    integer t = llList2Integer(params, 0);
    if(t == PRIM_TYPE_BOX) return "PRIM_TYPE, PRIM_TYPE_BOX, " + WriteType1(params);
    if(t == PRIM_TYPE_CYLINDER) return "PRIM_TYPE, PRIM_TYPE_CYLINDER, " + WriteType1(params);
    if(t == PRIM_TYPE_PRISM) return "PRIM_TYPE, PRIM_TYPE_PRISM, " + WriteType1(params);
    if(t == PRIM_TYPE_SPHERE) return "PRIM_TYPE, PRIM_TYPE_SPHERE, " + WriteType2(params);
    if(t == PRIM_TYPE_TORUS) return "PRIM_TYPE, PRIM_TYPE_TORUS, " + WriteType3(params);
    if(t == PRIM_TYPE_TUBE) return "PRIM_TYPE, PRIM_TYPE_TUBE, " + WriteType3(params);
    if(t == PRIM_TYPE_RING) return "PRIM_TYPE, PRIM_TYPE_RING, " + WriteType3(params);
    if(t == PRIM_TYPE_SCULPT) return "PRIM_TYPE, PRIM_TYPE_SCULPT, " + WriteType4(params);
    return "";
}
string WriteType1(list params)
{
    string s = WriteHole(llList2Integer(params, 1)) + ", ";
    s += WriteVector(llList2Vector(params, 2)) + ", ";
    s += WriteFloat(llList2Float(params, 3), FALSE) + ", ";
    s += WriteVector(llList2Vector(params, 4)) + ", ";
    s += WriteVector(llList2Vector(params, 5)) + ", ";
    s += WriteVector(llList2Vector(params, 6)) + ", ";
    return s;
}
string WriteType2(list params)
{
    string s = WriteHole(llList2Integer(params, 1)) + ", ";
    s += WriteVector(llList2Vector(params, 2)) + ", ";
    s += WriteFloat(llList2Float(params, 3), FALSE) + ", ";
    s += WriteVector(llList2Vector(params, 4)) + ", ";
    s += WriteVector(llList2Vector(params, 5)) + ", ";
    return s;
}
string WriteType3(list params)
{
    string s = WriteHole(llList2Integer(params, 1)) + ", ";
    s += WriteVector(llList2Vector(params, 2)) + ", ";
    s += WriteFloat(llList2Float(params, 3), FALSE) + ", ";
    s += WriteVector(llList2Vector(params, 4)) + ", ";
    s += WriteVector(llList2Vector(params, 5)) + ", ";
    s += WriteVector(llList2Vector(params, 6)) + ", ";
    s += WriteVector(llList2Vector(params, 7)) + ", ";
    s += WriteVector(llList2Vector(params, 8)) + ", ";
    s += WriteFloat(llList2Float(params, 9), FALSE) + ", ";
    s += WriteFloat(llList2Float(params, 10), FALSE) + ", ";
    s += WriteFloat(llList2Float(params, 11), FALSE) + ", ";
    return s;
}
string WriteType4(list params)
{
    string s = "\"" + llList2String(params, 1) + "\", ";
 
    integer type = llList2Integer(params, 2);
    list types = ["SPHERE", "TORUS", "PLANE", "CYLINDER"];
    integer n = llGetListLength(types);
    if(type < n)
        s += "PRIM_SCULPT_TYPE_" + llList2String(types, type) + ", ";
    else
        s += (string)type + ", ";
    return s;
}
string WriteTextureMaps()
{
    string s;
    list params = llGetPrimitiveParams([PRIM_TEXGEN, ALL_SIDES]);
    if(AllFacesSame(params, 1))
    {
        integer type = llList2Integer(params, 0);
        if(type == 0) return "";
        return WriteTextureMap(type, "ALL_SIDES");
    }
    else
    {
        integer n = llGetListLength(params);
        integer i;
        integer j = 0;
        for(i = 0; i < n; i++)
            s += WriteTextureMap(llList2Integer(params, i), (string)(j++));
        return s;
    }
}
string WriteTextureMap(integer type, string face)
{
    string s = "PRIM_TEXGEN, " + face + ", PRIM_TEXGEN_";
    list types = ["DEFAULT", "PLANAR"];
    integer n = llGetListLength(types);
    if(type < n)
        s += llList2String(types, type) + ", ";
    else
        s += (string)type + ", ";
    return s;
}
string WriteTextures()
{
    string s;
    list params = llGetPrimitiveParams([PRIM_TEXTURE, ALL_SIDES]);
    if(AllFacesSame(params, 4))
    {
        list l = llList2List(params, 0, 3);
         if(isSameList(l, [TEXTURE_PLYWOOD, <1, 1, 0>, ZERO_VECTOR, 0.0])) return "";
         
        return WriteTexture(0, params, "ALL_SIDES");
    }
    else
    {
        integer n = llGetListLength(params);
        integer i;
        integer j = 0;
        for(i = 0; i < n; i += 4)
            s += WriteTexture(i, params, (string)(j++));
        return s;
    }
}
string WriteKey(string text) {
    if(text == TEXTURE_BLANK) return "TEXTURE_BLANK";
    if(text == TEXTURE_TRANSPARENT) return "TEXTURE_TRANSPARENT";
    if(text == TEXTURE_MEDIA) return "TEXTURE_MEDIA";
    if(text == TEXTURE_PLYWOOD) return "TEXTURE_PLYWOOD";
    if(text == TEXTURE_DEFAULT) return "TEXTURE_DEFAULT";
    
    return "\"" + text + "\"";
}
string WriteTexture(integer i, list params, string face)
{
    
    string s = "PRIM_TEXTURE, " + face + ", ";
    s += WriteKey(llList2String(params, i)) + ", ";
    s += WriteVector(llList2Vector(params, i + 1)) + ", ";
    s += WriteVector(llList2Vector(params, i + 2)) + ", ";
    s += WriteFloat(llList2Float(params, i + 3), FALSE) + ", ";
    return s;
}
string WriteHole(integer hole)
{
    list iHoles = [0, 32, 16, 48];
    list holes = ["DEFAULT", "SQUARE", "CIRCLE", "TRIANGLE"];
    integer i = llListFindList(iHoles, [hole]);
    if(i == -1) return (string)hole;
    return "PRIM_HOLE_" + llList2String(holes, i);
}
string WriteRotation(rotation r)
{
    if(r == ZERO_ROTATION) return "ZERO_ROTATION";
    if(r == -ZERO_ROTATION) return "-ZERO_ROTATION";
    
    vector e = llRot2Euler(r) * RAD_TO_DEG;
    return "llEuler2Rot(" + WriteVector(e) + " * DEG_TO_RAD)";
}
string WriteVector(vector v)
{
    if(v == ZERO_VECTOR) return "ZERO_VECTOR";
    return "<" + WriteFloat(v.x, TRUE) + ", "
    + WriteFloat(v.y, TRUE) + ", " +
    WriteFloat(v.z, TRUE) + ">";
}
string WriteFloat(float f, integer integerOk)
{
    if(f == PI) return "PI";
    if(f == TWO_PI) return "TWO_PI";
    if(f == PI_BY_TWO) return "PI_BY_TWO";
    if(f == -PI) return "-PI";
    if(f == -TWO_PI) return "-TWO_PI";
    if(f == -PI_BY_TWO) return "-PI_BY_TWO";
    
    string s = (string)f;
    while(llGetSubString(s, -1, -1) == "0")
        s = llGetSubString(s, 0, -2);
    if(llGetSubString(s, -1, -1) == ".")
    {
        if(integerOk)
            s = llGetSubString(s, 0, -2);
        else
            s+= "0";
    }
    return (string)s;
}
string WriteBoolean(integer i)
{
    if(i == TRUE) return "TRUE"; else return "FALSE";
}
string trimComma(string s)
{
    if(llGetSubString(s, -2, -1) == ", ")
        return llGetSubString(s, 0, -3);
    else
        return s;
}
addParams(string text) {
    if(text == "") return;
    llOwnerSay("\t\t\tllSetPrimitiveParams([" + trimComma(text) + "]);");
}
default
{
    state_entry()
    {
        string name = llGetObjectName();
        string desc = llGetObjectDesc();
        
        llSetObjectName("");
        llOwnerSay("default\n{\n\tstate_entry()\n\t{");
        
        llOwnerSay("\t\t\t// Link " + (string)llGetLinkNumber() + " of " +(string) llGetNumberOfPrims() + " prims");

        if(name != "") llOwnerSay("\t\t\tllSetObjectName(\"" + name + "\");");
        
        if(desc != "") llOwnerSay("llSetObjectDesc(\"" + desc + "\");");
        
        addParams(WriteType());
        addParams(WriteAllShiny());
        addParams(WriteFlexible());
        addParams(WriteMaterial());
        addParams(WritePhantom());
        addParams(WritePhysics());
        addParams(WritePointLight());
        addParams(WritePrimRotation());
        addParams(WriteSize());
        addParams(WriteTempOnRez());
        addParams(WriteFullBrights());
        addParams(WriteAllColors());
        addParams(WriteTextureMaps());
        addParams(WriteTextures());
        
        llOwnerSay("\t\t\tllSetPrimitiveParams([" + trimComma(WritePosition()) + "]);");
 
        llOwnerSay("\t\t\twhile(llGetPos() != " + WriteVector(llGetPos()) + ") llSetPos(" + WriteVector(llGetPos()) + ");");
        
        llOwnerSay("\t}\n}");
 
        llSetObjectName(name);
    }
}