string out = "";
list entities = [];

XmlBegin()
{
    out = "<?xml version=\"1.0\" ?>\n";
    out += "<!DOCTYPE object SYSTEM \"object.dtd\">\n";
    
}
integer XmlDepth()
{
    return llGetListLength(entities);
}
XmlOpenEntity(string name)
{
    string tail = llGetSubString(out, -1, -1);
    if(tail == ">")
    {
        out += "\n" + indent(XmlDepth());
    }
    else if(tail == "\n")
    {
        out += indent(XmlDepth());
    }
    out += "<" + name + ">";
    entities += [name];
}
XmlAddVector(vector v)
{
    XmlAddEntityWithFloat("x", v.x);
    XmlAddEntityWithFloat("y", v.y);
    XmlAddEntityWithFloat("z", v.z);
}
XmlAddRotation(rotation r)
{
    XmlAddEntityWithFloat("x", r.x);
    XmlAddEntityWithFloat("y", r.y);
    XmlAddEntityWithFloat("z", r.z);
    XmlAddEntityWithFloat("s", r.s);
}
XmlAddEntityWithFloat(string name, float f)
{
    if(f == (integer)f)
    {
        XmlAddEntityWithInteger(name, (integer)f);
    }
    else
    {
        string t = (string)f;
        while(llGetSubString(t, -1, -1) == "0")
        {
            t = llGetSubString(t, 0, -2);
        }
        XmlAddEntityWithText(name, t);
    }
}
XmlAddEntityWithInteger(string name, integer i)
{
    string t = (string)i;
    XmlAddEntityWithText(name, t);
}
XmlAddEntityWithKey(string name, key k)
{
    string t = (string)k;
    XmlAddEntityWithText(name, t);
}
XmlCloseEntity()
{
    
    string name = llList2String(entities, -1);
    entities = llDeleteSubList(entities, -1, -1);
    string tail = llGetSubString(out, -1, -1);
    if(tail == ">")
    {
        out += "\n" + indent(XmlDepth());
    }
    else if(tail == "\n")
    {
        out += indent(XmlDepth());
    }
    out += "</" + name + ">\n";
}
XmlAddEntityWithText(string name, string text)
{
    XmlOpenEntity(name);
    XmlWriteText(text);
    XmlCloseEntity();
}
XmlAddEntityWithVector(string name, vector v)
{
    XmlOpenEntity(name);
    XmlAddVector(v);
    XmlCloseEntity();
}
XmlAddEntityWithRotation(string name, rotation r)
{
    XmlOpenEntity(name);
    XmlAddRotation(r);
    XmlCloseEntity();
}
XmlAddEntityWithBoolean(string name, integer isTrue)
{
    if(isTrue) XmlAddEntityWithText(name, "true");
    else XmlAddEntityWithText(name, "false");
}
XmlWriteText(string text)
{
    text = XmlEncode(text);
    if(llGetSubString(out, -1, -1) == ">")
    {
        out += text;
    }
    else if(llGetSubString(out, -2, -1) == "\n")
    {
        out += text + "\n";
    }
}
string XmlEncode(string v)
{
    return v;
}
string XmlEntity(string name, string innerXml)
{
    if(innerXml == "")
    {
        return "<" + name + "/>";
    }
    return "<" + name + ">" + innerXml + "</" + name + ">";
}
string indent(integer depth)
{
    string xml = "";
    integer i = 0;
    for(i = 0; i < depth; i++) xml += "\t";
    return xml;
}
XmlOut()
{
    while(out != "")
    {
        if(llStringLength(out) > 1024)
        {
            string part = "";
            integer exit= FALSE;
            do
            {
                integer i = llSubStringIndex(out, "\n");
                if(i == -1)
                {
                    exit = TRUE;
                }
                if(i + llStringLength(part) > 1024)
                {
                    exit = TRUE;
                }
                else
                {
                    part += llGetSubString(out, 0, i);
                    out = llGetSubString(out, i + 1, -1);
                }
            } while(!exit);
            
            if(part == "")
            {
                part = llGetSubString(out, 0, 1023);
                out = llGetSubString(out, 1024, -1);
            }
            
            llOwnerSay(part);
        }
        else
        {
            llOwnerSay(out);
            out = "";
        }
    }
}
XmlAddPrimType()
{
    XmlOpenEntity("type");
    list params = llGetPrimitiveParams([PRIM_TYPE]);
    integer type = llList2Integer(params, 0);
    XmlAddEntityWithText("name", TypeName(type));
    if(type == PRIM_TYPE_BOX
        || type == PRIM_TYPE_CYLINDER
        || type == PRIM_TYPE_PRISM)
    {
        XmlAddEntityWithText("hole_shape", HoleShape(llList2Integer(params, 1)));
        XmlAddEntityWithVector("cut", llList2Vector(params, 2));
        XmlAddEntityWithFloat("hollow", llList2Float(params, 3));
        XmlAddEntityWithVector("twist", llList2Vector(params, 4));
        XmlAddEntityWithVector("top_size", llList2Vector(params, 5));
        XmlAddEntityWithVector("top_shear", llList2Vector(params, 6));    
    }
    else if(type == PRIM_TYPE_SPHERE)
    {
        XmlAddEntityWithText("hole_shape", HoleShape(llList2Integer(params, 1)));
        XmlAddEntityWithVector("cut", llList2Vector(params, 2));
        XmlAddEntityWithFloat("hollow", llList2Float(params, 3));
        XmlAddEntityWithVector("twist", llList2Vector(params, 4));
        XmlAddEntityWithVector("dimple", llList2Vector(params, 5));
    }
    else if(type == PRIM_TYPE_TORUS
        || type == PRIM_TYPE_TUBE
        || type == PRIM_TYPE_RING)
    {
        XmlAddEntityWithText("hole_shape", HoleShape(llList2Integer(params, 1)));
        XmlAddEntityWithVector("cut", llList2Vector(params, 2));
        XmlAddEntityWithFloat("hollow", llList2Float(params, 3));
        XmlAddEntityWithVector("twist", llList2Vector(params, 4));
        XmlAddEntityWithVector("hole_size", llList2Vector(params, 5));
        XmlAddEntityWithVector("top_shear", llList2Vector(params, 6));
        XmlAddEntityWithVector("advanced_cut", llList2Vector(params, 6));
        XmlAddEntityWithVector("taper", llList2Vector(params, 6));
        XmlAddEntityWithFloat("revolutions", llList2Float(params, 6));
        XmlAddEntityWithFloat("radius_offset", llList2Float(params, 6));
        XmlAddEntityWithFloat("skew", llList2Float(params, 6));
    }
    else if(type == PRIM_TYPE_SCULPT)
    {
        integer flags = llList2Integer(params, 2);
        XmlAddEntityWithText("map", llList2String(params, 1));
        XmlAddEntityWithText("sculpt_type", SculptTypeName(flags));
        XmlAddEntityWithBoolean("invert", isSet(flags, PRIM_SCULPT_FLAG_INVERT));
        XmlAddEntityWithBoolean("mirror", isSet(flags, PRIM_SCULPT_FLAG_MIRROR));
    }
    XmlCloseEntity();
}
integer isSet(integer flags, integer flag)
{
    return (flags & flag) == flag;
}
string SculptTypeName(integer type)
{
    if(isSet(type, PRIM_SCULPT_FLAG_INVERT))
    {
        type = type ^ PRIM_SCULPT_FLAG_INVERT;
    }
    if(isSet(type, PRIM_SCULPT_FLAG_MIRROR))
    {
        type = type ^ PRIM_SCULPT_FLAG_MIRROR;
    }
    if(type == PRIM_SCULPT_TYPE_SPHERE) return "Sphere";
    if(type == PRIM_SCULPT_TYPE_TORUS) return "Torus";
    if(type == PRIM_SCULPT_TYPE_PLANE) return "Plane";
    if(type == PRIM_SCULPT_TYPE_CYLINDER) return "Cylinder";
    return "Unrecognized";
}
string TypeName(integer type)
{
    if(type == PRIM_TYPE_BOX) return "Box";
    if(type == PRIM_TYPE_CYLINDER) return "Cylinder";
    if(type == PRIM_TYPE_PRISM) return "Prism";
    if(type == PRIM_TYPE_SPHERE) return "Sphere";
    if(type == PRIM_TYPE_TORUS) return "Torus";
    if(type == PRIM_TYPE_TUBE) return "Tube";
    if(type == PRIM_TYPE_RING) return "Ring";
    if(type == PRIM_TYPE_SCULPT) return "Sculpt";
    return "Unrecognized";
}
string HoleShape(integer shape)
{
    if(shape == PRIM_HOLE_DEFAULT) return "Default";
    if(shape == PRIM_HOLE_CIRCLE) return "Circle";
    if(shape == PRIM_HOLE_SQUARE) return "Square";
    if(shape == PRIM_HOLE_TRIANGLE) return "Triangle";
    return "Unrecognized";
}
default
{
    touch_start(integer num_detected)
    {
        if(llDetectedKey(0) != llGetOwner()) return;
        
        key id = llGetKey();
        
        XmlBegin();
        XmlOpenEntity("object");

        XmlOpenEntity("details");

        XmlAddEntityWithKey("key", id);
        XmlAddEntityWithText("name", llGetObjectName());
        XmlAddEntityWithText("description", llGetObjectDesc());
        XmlAddEntityWithInteger("link_number", llGetLinkNumber());
        
        key creatorId = llGetCreator();
        XmlOpenEntity("creator");
        XmlAddEntityWithKey("key", creatorId);
        XmlOpenEntity("name");
        XmlAddEntityWithText("legacy", llKey2Name(creatorId));
        XmlAddEntityWithText("user", llGetUsername(creatorId));
        XmlAddEntityWithText("display", llGetDisplayName(creatorId));
        XmlCloseEntity();
        XmlCloseEntity();
        
        XmlCloseEntity();
        
        XmlOpenEntity("position");
        XmlAddEntityWithVector("local", llGetLocalPos());
        XmlAddEntityWithVector("regional", llGetPos());
        XmlAddEntityWithVector("root", llGetRootPosition());
        XmlAddEntityWithVector("center_of_mass", llGetCenterOfMass());
        XmlAddEntityWithVector("geometric_center", llGetGeometricCenter());
        XmlCloseEntity();
        
        XmlOpenEntity("rotation");
        XmlAddEntityWithRotation("local", llGetLocalRot());
        XmlAddEntityWithRotation("regional", llGetRot());
        XmlAddEntityWithRotation("root", llGetRootRotation());
        XmlCloseEntity();

        XmlAddEntityWithVector("scale", llGetScale());
        
        XmlOpenEntity("parameters");
        XmlAddPrimType();
        
        XmlCloseEntity();
        XmlCloseEntity();
        
        XmlOut();
     }
}