integer pin = 1234;

init()
{
    llSay(0, "I'm doing something!");
    //llSetRemoteScriptAccessPin(pin);
    string script = llGetScriptName();
//    llRemoveInventory();

    if(llGetLinkNumber() == 1)
    {
        llSay(PUBLIC_CHANNEL, "I am in the root prim");
        integer linkNum;
        integer primCount = llGetNumberOfPrims();
        // give scripts to children
        for(linkNum = 2; linkNum < primCount; linkNum++)
        {
            key destination = llGetLinkKey(linkNum);
            llGiveInventory(destination, script);
        }
        // set scripts to running
        //for(linkNum = 2; linkNum < primCount; linkNum++)
        //{
            //key destination = llGetLinkKey(linkNum);
            //llRemoteLoadScriptPin(destination, script, pin, TRUE, 0);
        //}
    }
    else
        llSay(PUBLIC_CHANNEL, "I am in link " + (string)llGetLinkNumber());
}
default
{
    state_entry()
    {
        init();
    }
    on_rez(integer start_param)
    {
        init();
    }
}