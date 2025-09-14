class SMHud extends OLHUD;

var color PushColor;
var String Command, StrPushMessage;

Function PostRender()
{
    local SMController c;
    local SMHero Hero;

    c =SMController(PlayerOwner);

    super.PostRender();
    if (c.bShowInfo){
        hero =SMHero(c.Pawn);
        Canvas.font =class'Engine'.static.GetSmallFont();    
        //DrawString("CheckPoint:"@string(SMGame(WorldInfo.Game).CurrentCheckpointName), vect2D(5, 5), MakeColor(255, 255, 200), vect2D(2, 2));
        DrawString("Location:"@VectorToString(Hero.location), vect2D(5, 5), MakeColor(0,0,255,200), vect2D(2, 2));
        DrawString("Velocity:"@FloatToString(VSize(Hero.RealVelocity)),vect2D(5,25), MakeColor(0,0,255,200), vect2D(2, 2));
    }
}

/************************OTHER FUNCTIONS************************/

Exec Function PushMessage(String Msg) {
    StrPushMessage = Msg;
    PushColor = MakeColor(255, 255, 255, 255);
    WorldInfo.Game.ClearTimer('PushMessageHide', Self);
    WorldInfo.Game.SetTimer(0.005, true, 'PushMessageHide', Self);
}

Function PushMessageHide() {
    if(PushColor.A == 0) {
        StrPushMessage = "";
        PushColor = MakeColor(0,0,0,0);
        WorldInfo.Game.ClearTimer('PushMessageHide', Self);
        return;
    }
    PushColor.A = PushColor.A - 1;
}

Function AddConsoleMessage(string M, class<LocalMessage> InMessageClass, PlayerReplicationInfo PRI, optional float LifeTime) {
	local Int Idx, MsgIdx;

	MsgIdx = -1;
	if( bMessageBeep && InMessageClass.default.bBeep )
	{
		PlayerOwner.PlayBeepSound();
	}
	if (ConsoleMessages.Length < ConsoleMessageCount)
	{
		MsgIdx = ConsoleMessages.Length;
	}
	else
	{
		for (Idx = 0; Idx < ConsoleMessages.Length && MsgIdx == -1; Idx++)
		{
			if (ConsoleMessages[Idx].Text == "")
			{
				MsgIdx = Idx;
			}
		}
	}
    if( MsgIdx == ConsoleMessageCount || MsgIdx == -1)
    {
		// push up the array
		for(Idx = 0; Idx < ConsoleMessageCount-1; Idx++ )
		{
			ConsoleMessages[Idx] = ConsoleMessages[Idx+1];
		}
		MsgIdx = ConsoleMessageCount - 1;
    }
	// fill in the message entry
	if (MsgIdx >= ConsoleMessages.Length)
	{
		ConsoleMessages.Length = MsgIdx + 1;
	}

    ConsoleMessages[MsgIdx].Text = M;
	if (LifeTime != 0.f)
	{
		ConsoleMessages[MsgIdx].MessageLife = WorldInfo.TimeSeconds + LifeTime;
	}
	else
	{
		ConsoleMessages[MsgIdx].MessageLife = WorldInfo.TimeSeconds + InMessageClass.default.LifeTime;
	}

    ConsoleMessages[MsgIdx].TextColor = InMessageClass.static.GetConsoleColor(PRI);
    ConsoleMessages[MsgIdx].PRI = PRI;
}

Function DrawString(String String, Vector2D Loc, optional Color Color=MakeColor(200, 200, 200, 200), optional Vector2D Scale=Vect2D(1.5, 1.5), optional Bool ScaleLoc=true, optional Bool center) {
    local Vector2D MisScale, StringScale;

    MisScale = Vect2D((0.7 * Scale.X) / 1920 * Canvas.SizeX, (0.7 * Scale.Y) / 1080 * Canvas.SizeY);
    Canvas.TextSize(String, StringScale.X, StringScale.Y, MisScale.X, MisScale.Y);

    if(Center) {
        Loc=Vect2D(Loc.X - (StringScale.X / 2), Loc.Y - (StringScale.Y / 2));
    }
    if(ScaleLoc) {
        Loc=Vect2D(Loc.X / 1920 * Canvas.SizeX, Loc.Y / 1080 * Canvas.SizeY);
    }

    Canvas.SetDrawColor(0, 0, 0, 255);
    Canvas.SetPos(Loc.X+1, Loc.Y+1.3);
    Canvas.DrawText(String, false, MisScale.X, MisScale.Y);

    Canvas.SetPos(Loc.X, Loc.Y);
    Canvas.SetDrawColor(Color.R, Color.B, Color.G, Color.A);
    Canvas.DrawText(String, false, MisScale.X, MisScale.Y);
}

Function Bool ContainsName(Array<Name> Array, Name find) {
    return Array.Find(Find) >=0;
}

Function Bool ContainsString(Array<String> Array, String find) {
    return Array.Find(Find) >=0;
}

Function bool InRange(float Target, Float RangeMin, Float RangeMax) {
    return Target > RangeMin && Target < RangeMax;
}

Function DrawTextInWorld(String Text, Vector location, Float Max_View_Distance, Float scale, optional Vector offset) {
    local Vector DrawLocation, CameraLocation; //Location to Draw Text & Location of Player Camera
    local Rotator CameraDir; //Direction the camera is facing
    local Float Distance; //Distance between Camera and text

    PlayerOwner.GetPlayerViewPoint(CameraLocation, CameraDir);
    Distance =  ScaleByCam(VSize(CameraLocation - Location)); //Get the distance between the camera and the location of the text being placed, then scale it by the camera's FOV. 
    DrawLocation = Canvas.Project(Location); //Project the 3D location into 2D space. 
    if(Vector(CameraDir) dot (Location - CameraLocation) > 0.0 && Distance < Max_View_Distance) {
        Scale = Scale / Distance; //Scale By distance. 
        Canvas.SetPos(DrawLocation.X + (Offset.X * Scale), DrawLocation.Y + (Offset.Y * Scale), DrawLocation.Z + (Offset.Z * Scale)); //Set the Position of text using the Draw Location and an optional Offset. 
        Canvas.SetDrawColor(255,40,40,255);
        Canvas.DrawText(Text, false, Scale, Scale);
    }
}

Function DrawBox(Vector2D Begin_Point, Vector2D End_Point, Color Color=MakeColor(255,255,255,255), optional out Vector2D Begin_Point_Calculated, optional out Vector2D End_Point_Calculated) {
    Begin_Point_Calculated = Scale2DVector(Begin_Point);
    End_Point_Calculated = Scale2DVector(End_Point);
    Canvas.SetPos(Begin_Point_Calculated.X, Begin_Point_Calculated.Y);
    Canvas.SetDrawColor(Color.R,Color.G,Color.B,Color.A);
    Canvas.DrawRect(End_Point_Calculated.X, End_Point_Calculated.Y);
}

Function Float ScaleByCam(Float Float) {
    return Float * (PlayerOwner.GetFOVAngle() / 100);
}

Function Vector2D Scale2DVector(Vector2D Vector) {
    Vector.X=Vector.X / 1280.0f * Canvas.SizeX;
    Vector.Y=Vector.Y / 720.0f * Canvas.SizeY;
    return Vector;
}

Function Bool Vector2DInRange(Vector2D Target, Vector2D Vector1, Vector2D Vector2) {
    return InRange(Target.X, Vector1.X, Vector2.X) && InRange(Target.Y, Vector1.Y, Vector2.Y);
}

Function String VectorToString(Vector Target) {
    return FloatToString(Target.X)@ "|" @ FloatToString(Target.Y) @ "|" @ FloatToString(Target.Z);
}

function String FloatToString(float f){
    local int fp, pp;

    fp =int(f);
    pp =int(abs(f -fp)*1000000+0.5);
    return fp$"."$pp;
}