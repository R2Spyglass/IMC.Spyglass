global function spyglassChatUtilsInit

const array<string> MaintainerUIDPlaceholder = []

table<string, void functionref(entity, array<string>)> CommandRegister ={}

void function spyglassChatUtilsInit(){
    AddCallback_OnReceivedSayTextMessage(SpyglassCommand)
    CommandRegister["checkreport"] <- CheckReportFunc
    CommandRegister["getuid"] <- GetUIDFunc
    CommandRegister["getname"] <- GetNameFunc

}
void function GetUIDFunc(entity player, array<string> args) 
{
    if(args.len()==0)
        return
    if(args[0].tolower() in Spyglass_PlayerNameUIDMap)
        Chat_ServerPrivateMessage(player,"UID of: "+ args[0]+ ": "+Spyglass_PlayerNameUIDMap[args[0].tolower()],true)
    else
        Chat_ServerPrivateMessage(player,"Name not found in database",true)
}

void function GetNameFunc(entity player, array<string> args) {
    if(args.len()==0)
        return
    if(args[0] in Spyglass_Infractions)
        Chat_ServerPrivateMessage(player,"Name of: "+ args[0]+ ": "+Spyglass_Infractions[args[0]][0].PlayerUsername,true)
    else
        Chat_ServerPrivateMessage(player,"UID not found in database",true)
}

ClServer_MessageStruct function SpyglassCommand(ClServer_MessageStruct message)
{
    if( Spyglass_MutedPlayers.find(message.player.GetUID())!=-1){
        message.shouldBlock = true
        return message
    }
    /*
    if( GetConVarBool("spyglass_commands_admin_only")&&!(GetConVarStringArray("spyglass_admin_uids").find(message.player.GetUID() )!=-1)
        || (GetConVarBool("spyglass_commands_maintainers_allowed") && MaintainerUIDPlaceholder.find(message.player.GetUID())!= -1)){
        return message
    }
    */
    string msg = lstrip(message.message)
    var prefixIndex = msg.find(GetConVarString("spyglass_command_prefix"));

    if (prefixIndex == null || expect int(prefixIndex) != 0)
    {
        return message
    }
    string prefixless = msg.slice(expect int(prefixIndex) + GetConVarString("spyglass_command_prefix").len(), msg.len());
    array<string> args = split(prefixless, " ");
    string commandName = args[0].tolower();
    if(!(commandName in CommandRegister))
        return message
    args.remove(0)
    CommandRegister[commandName](message.player, args)
    message.shouldBlock = true
    return message   
}

void function CheckReportFunc(entity player, array<string> args)
{
    if(args.len()== 0 )
        return
    string searchedPlayerName = args[0].tolower()
    if( !(searchedPlayerName in Spyglass_PlayerNameUIDMap)){
        Chat_ServerPrivateMessage(player, "Player not found",true)
        return
    }
    Chat_ServerBroadcast("Printing reports:")
    foreach(PlayerInfraction p in Spyglass_Infractions[Spyglass_PlayerNameUIDMap[searchedPlayerName]])
        Chat_ServerBroadcast(Spyglass_GetInfractionAsString(p))
}

string function RemovePrefix(string s) {
    return split(s, GetConVarString("spyglass_command_prefix"))[1]
}

array<string> function GetConVarStringArray(string convar){
    return split(GetConVarString(convar), ",")
}