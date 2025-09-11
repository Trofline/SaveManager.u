class SMHUD extends OLHUD;

struct RGBA 
{
    var Byte Red;
    var Byte Green;
    var Byte Blue;
    var Byte Alpha;

    structdefaultproperties
    {
        Red=255
        Green=255
        Blue=255
        Alpha=255
    }
};

Function PostRender()
{
    super.PostRender();
    Canvas.Font = class'Engine'.Static.GetLargeFont();

    // DrawString("Test", Vect2D(5, 5),MakeRGBA(154,0,255,255),Vect2D(1.8, 1.8)); //TODO
}

Function DrawString(String String, Vector2D Loc, optional RGBA Color=MakeRGBA(200, 200, 200, 200), optional Vector2D Scale=Vect2D(1.5, 1.5), optional Bool ScaleLoc=true, optional Bool center) {
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
    Canvas.SetDrawColor(Color.Red, Color.Blue, Color.Green, Color.Alpha);
    Canvas.DrawText(String, false, MisScale.X, MisScale.Y);
}

Function RGBA MakeRGBA(Byte R, Byte G, Byte B, Byte A=255) {
    local RGBA Color;
    
    Color.Red=R;
    Color.Green=G;
    Color.Blue=B;
    Color.Alpha=A;
    return Color;
}


event OnLostFocusPause(bool bEnable)
{
    super.OnLostFocusPause(bEnable);
}


