Class SMGame extends OLGame;

static event class<GameInfo> SetGameType(string MapnName,string Options, string Portal)
{
    return Default.class;
    
}


DefaultProperties
{
    DefaultPawnClass=class'SaveManager.SMHero'
    PlayerControllerClass=Class'SaveManager.SMController'
}