class SMController extends OLPlayerController config(SMConfig);

struct Position //struct = datenstruktur
{
    var vector Pos;
    var Vector2D Rot;
};

Enum ECollision_Type
{
	CT_Normal,
	CT_Vault,
	CT_Door,
	CT_Shimmy
};

Var config array<Position> SavedPositions;
Var bool damage;
var ECollision_Type Collision_Type_Override;

// eigentlich unnötig...
exec function exit() //exec = command für defaultinput
{
    ConsoleCommand("exit");
}

exec function dummy(){
    local OLCheatManager cm;

    cm =new (self) class'OLCheatManager';
    cm.bCheatsEnabled =true;
    cm.ResetWorldState();
}

exec function SavePos(int Index = 0)
{
    Local Position PosToAdd;

    PosToAdd.Pos = OLHero(Pawn).Location;
    PosToAdd.Rot = vect2D(Pawn.Rotation.Yaw,OLHero(Pawn).Camera.ViewCS.Pitch);
    
    SavedPositions[Index] = PosToAdd;
    SaveConfig();
}

exec function LoadPos(int Index = 0,bool setRotation = true) //in manager true/false machen 
{
    OLHero(Pawn).SetLocation(SavedPositions[Index].Pos);
    //DebugCamRot = SavedPositions[Index].Rot;

    if(SetRotation)
    {
     Pawn.SetRotation(MakeRotator(Pawn.Rotation.Pitch,SavedPositions[index].Rot.X,Pawn.Rotation.Roll));
    OLHero(Pawn).Camera.ViewCS.Pitch=SavedPositions[Index].Rot.Y;
    }
}

exec function FreezeEnemy(bool freeze = true)
{
    local OLEnemyPawn p;

    foreach WorldInfo.AllPawns(Class 'OLEnemyPawn',p)
    {
        if(freeze && p.Modifiers.bShouldAttack)
        {
        p.Tag = 'Enemy';
        class'EnemyUtils'.static.Init(p)
        .SetEnemySpeed(0,0,0)
        .EnemyAnimRate(0)
        .getEnemy()
        .Modifiers.bShouldAttack = false;
        }
        else if (p.Tag == 'Enemy')
        {
        p.Tag = 'MadEnemy';
        p.UpdateDifficultyBasedValues();
        class'EnemyUtils'.static.Init(p)
        .EnemyAnimRate(1)
        .getEnemy()
        .Modifiers.bShouldAttack = true;
        }
    }
}

exec function NoDamage() //TODO
{
    Damage = !Damage;
    SMHero(Pawn).PreciseHealth = 100;
}

Exec Function SetPlayerCollisionType(ECollision_Type Type)
{
	local float Radius;
	
	Switch(Type)
	{
		case CT_Normal:
		Radius=30;
		Break;

		Case CT_Vault:
		Radius=15;
		Break;

		Case CT_Door:
		Radius=5;
		Break;

		Case CT_Shimmy:
		Radius=2;
		Break;
	}
	Collision_Type_Override=type;
	SetPlayerCollisionRadius(Radius);
	OLHero(Pawn).CrouchRadius=Radius;
}

Exec Function SetPlayerCollisionRadius(Float Radius)
{
	OLHero(Pawn).SetCollisionSize(Radius, OLHero(Pawn).CylinderComponent.CollisionHeight);    
}

exec function DebugMarkers(bool isOn = true)
{
    local Actor a;
    local Drawer d;

    d =class'Drawer'.static.init();

    if(isOn)
    {
        foreach AllActors(Class'Actor', a){
            if (a.ISA('OLLedgeMarker'))
                d.DrawLedge(OLLedgeMarker(a));
        if (a.ISA('OLCheckPoint'))
            d.DrawCheckPoint(OLCheckpoint(a));
        if (a.ISA('Trigger'))
            d.DrawTrigger(Trigger(a));
        if (a.ISA('OLGameplayMarker'))
            d.DrawGamePlayMarker(OLGameplayMarker(a));
        if (a.ISA('OLSqueezeVolume'))
            d.DrawSqueezeVolume(OLSqueezeVolume (a));
        if (a.ISA('OLLadderMarker'))
            d.DrawLadderMarker(OLLadderMarker(a));
        }
    }
    else
    {
        FlushPersistentDebugLines();
    }
}
