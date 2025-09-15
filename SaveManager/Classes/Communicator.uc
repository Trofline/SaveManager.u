class Communicator extends TCPLink;

var private IpAddr Server;
var private float RetryTime;

function initialize(String IP, int Port){
    LinkMode =Mode_Line;
    InLineMode =LMode_Auto;
    OutLineMode =LMode_Auto;
    ReceiveMode =RMode_Event;

    StringToIpAddr(IP, Server);
    Server.Port =port;
    TryConnect();
}

private function TryConnect(){
    if (!IsConnected() && RetryTime <=8.0){
        BindPort();
        Open(Server);
        SetTimer(RetryTime, false, 'TryConnect');
        RetryTime *=2;
    }
}

function SendPing(){
    SendText("Ping");
}

event Opened(){
    ClearTimer('TryConnect');
    SetTimer(5, true, 'SendPing');
    SendPing();
}

event Closed(){
}

function LogAndCopyState(){
    local String Message;

    Message ="LinkState:"@string(LinkState)$"\nIPStruct:"@IpAddrToString(Server)$"\nLastFailedReason"@string(GetLastError());
    `Log(Message);
    GetALocalPlayerController().CopyToClipboard(Message);
}

defaultproperties
{
    RetryTime =1.0
    bAlwaysTick =true;
}