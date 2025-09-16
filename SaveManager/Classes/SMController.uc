class SMController extends OLPlayerController config(SMConfig);

struct Position
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
var config String SavedCheckpointName;
Var bool damage, bShowInfo;
var ECollision_Type Collision_Type_Override;
var Communicator cm;

exec function exit()
{
    ConsoleCommand("exit");
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
            p.NormalSpeedValues.PatrolSpeed =0;
            p.NormalSpeedValues.InvestigateSpeed =0;
            p.NormalSpeedValues.ChaseSpeed=0;
            p.DarknessSpeedValues.PatrolSpeed =0;
            p.DarknessSpeedValues.InvestigateSpeed=0;
            p.DarknessSpeedValues.ChaseSpeed=0;
            p.mesh.GlobalAnimRateScale =0;
            P.Modifiers.bShouldAttack = false;
        }
        else if (p.Tag == 'Enemy')
        {
            p.Tag = 'MadEnemy';
            if (SMGame(WorldInfo.Game).DifficultyMode ==EDM_Normal){
                P.NormalSpeedValues = P.NrmNormalSpeedValues;
		        P.DarknessSpeedValues = P.NrmDarknessSpeedValues;
		        P.ElectricitySpeedValues = P.NrmElectricitySpeedValues;
            } else{
                P.NormalSpeedValues = P.HardNormalSpeedValues;
	    	    P.DarknessSpeedValues = P.HardDarknessSpeedValues;
		        P.ElectricitySpeedValues = P.HardElectricitySpeedValues;
            }
            p.mesh.GlobalAnimRateScale =1;
            P.Modifiers.bShouldAttack = true;
        }
    }
}

exec function NoDamage()
{
    Damage = !Damage;
    if (damage){
        ClearTimer('DisableEnemyDamage');
        ReEnableEnemyDamage();
    } else{
        SMHero(Pawn).PreciseHealth = 100;
        DisableEnemyDamage();
        SetTimer(2.5, true, 'DisableEnemyDamage');
    }
}

private function DisableEnemyDamage(){
    local OLEnemyPawn P;

    foreach WorldInfo.AllPawns(Class'OLEnemyPawn', P){
        if (P.modifiers.bShouldAttack){
            P.AttackNormalDamage = 0.0;
	    	P.AttackThrowDamage = 0.0;
		    P.DoorBashDamage = 0.0;
		    P.VaultDamage = 0.0;
        }
    }
}

private function ReEnableEnemyDamage()
{
    local OLEnemyPawn P;

    foreach WorldInfo.AllPawns(Class'OLEnemyPawn', P){
        if (SMGame(WorldInfo.Game).DifficultyMode ==EDM_Normal){
            P.AttackNormalDamage = P.NrmAttackNormalDamage;
	    	P.AttackThrowDamage = P.NrmAttackThrowDamage;
    		P.DoorBashDamage = P.NrmDoorBashDamage;
	    	P.VaultDamage = P.NrmVaultDamage;
        } else{
    		p.AttackNormalDamage = P.HardAttackNormalDamage;
	    	p.AttackThrowDamage = P.HardAttackThrowDamage;
    		P.DoorBashDamage = P.HardDoorBashDamage;
		    P.VaultDamage = P.HardVaultDamage;
        }
    }
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
	SMHero(Pawn).CrouchRadius=Radius;
    SendMsg("Collision has been modified via Script.");
}

Function SetPlayerCollisionRadius(Float Radius)
{
	SMHero(Pawn).SetCollisionSize(Radius, SMHero(Pawn).CylinderComponent.CollisionHeight);    
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
        if (a.ISA('OLGameplayMarker') && !a.ISA('OLCornerMarker'))
            d.DrawGamePlayMarker(OLGameplayMarker(a));
        if (a.ISA('OLSqueezeVolume'))
            d.DrawSqueezeVolume(OLSqueezeVolume (a));
        if (a.ISA('OLLadderMarker'))
            d.DrawLadderMarker(OLLadderMarker(a));
        if (a.ISA('OLRecordingMarker'))
            d.DrawRecordMarker(OLRecordingMarker(a));
        }
    }
    else
    {
        FlushPersistentDebugLines();
    }
}

exec function rsw()
{
    local OLCheatManager cm;

    cm =new (self) class'OLCheatManager';
    cm.bCheatsEnabled =true;
    cm.ResetWorldState();
}

exec function gamespeed(float value = 1)
{
    WorldInfo.Game.SetGameSpeed(value);
}

exec function removeDocuments(){
    local OLCollectiblePickup cpu;
    Hud.LatestDocumentName ='';
    RemoveAllDocuments();

    foreach AllActors(class'OLCollectiblePickup', cpu){
        cpu.SetHidden(false);
        cpu.bUsed =false;
        cpu.PickupMesh.SetHidden(false);
        cpu.PickupMesh.SetTranslation(vect(0,0,0));
        cpu.PickupMesh.SetRotation(rot(0,0,0));
        cpu.AttachComponent(cpu.PickupMesh);
    }
}

private function RemoveAllDocuments(){
    local Array<name> AllFuckingDocumentNames;
    local name n;

	AllFuckingDocumentNames.AddItem('Admin_Doc_AnonymousEmail');
	AllFuckingDocumentNames.AddItem('Admin_Doc_ProjectWallrider1');
	AllFuckingDocumentNames.AddItem('Admin_Doc_ProjectWallrider2');
	AllFuckingDocumentNames.AddItem('Admin_Doc_Reception');
	AllFuckingDocumentNames.AddItem('Admin_Doc_BossRoom');
	AllFuckingDocumentNames.AddItem('Admin_Doc_Basement');
	AllFuckingDocumentNames.AddItem('Prison_Doc_Wernicke1');
	AllFuckingDocumentNames.AddItem('Prison_Doc_Wernicke2');
	AllFuckingDocumentNames.AddItem('Prison_Doc_Lobby');
	AllFuckingDocumentNames.AddItem('Prison_Doc_SecuritySAS');
	AllFuckingDocumentNames.AddItem('Sewer_Doc_BeginningSewer');
	AllFuckingDocumentNames.AddItem('Sewer_Doc_DeadGuy');
	AllFuckingDocumentNames.AddItem('Male_Doc_Experiment');
	AllFuckingDocumentNames.AddItem('Male_Doc_Bathroom3rdFloor');
	AllFuckingDocumentNames.AddItem('Male_Doc_MainHall');
	AllFuckingDocumentNames.AddItem('Male_Doc_LockerRoom');
	AllFuckingDocumentNames.AddItem('Male_Doc_Office');
	AllFuckingDocumentNames.AddItem('Court_Doc_Pergola');
	AllFuckingDocumentNames.AddItem('Court_Doc_Chapel');
	AllFuckingDocumentNames.AddItem('Female_Doc_UnderStair');
	AllFuckingDocumentNames.AddItem('Female_Doc_Hole');
	AllFuckingDocumentNames.AddItem('Revisit_Doc_Office');
	AllFuckingDocumentNames.AddItem('Revisit_Doc_Backstage');
	AllFuckingDocumentNames.AddItem('Revisit_Doc_Library');
	AllFuckingDocumentNames.AddItem('Revisit_Doc_Room');
	AllFuckingDocumentNames.AddItem('Lab_Doc_LabRoom');
	AllFuckingDocumentNames.AddItem('Lab_Doc_MachineRoom');
	AllFuckingDocumentNames.AddItem('Lab_Doc_MajorRoom');
	AllFuckingDocumentNames.AddItem('Lab_Doc_LifeLiquid');
	AllFuckingDocumentNames.AddItem('Lab_Doc_TallRoom');
	AllFuckingDocumentNames.AddItem('Lab_Doc_CoreRoom');
	
    AllFuckingDocumentNames.AddItem('Hospital_Doc_MainHall');
    AllFuckingDocumentNames.AddItem('Hospital_Doc_Morgue');
    AllFuckingDocumentNames.AddItem('Hospital_Doc_NearCrema');
    AllFuckingDocumentNames.AddItem('Hospital_Doc_OldRoom');
    AllFuckingDocumentNames.AddItem('Hospital_Doc_Lab');
    AllFuckingDocumentNames.AddItem('Courtyard1_Doc_WatchTower');
    AllFuckingDocumentNames.AddItem('PrisonRevisit_Doc_Reception');
    AllFuckingDocumentNames.AddItem('Courtyard2_Doc_Shack');
    AllFuckingDocumentNames.AddItem('Courtyard2_Doc_Helpme');
    AllFuckingDocumentNames.AddItem('Workshop_Doc_Attic');
    AllFuckingDocumentNames.AddItem('Workshop_Doc_Garden');
    AllFuckingDocumentNames.AddItem('MaleRevisit_Doc_OldArchive');
    AllFuckingDocumentNames.AddItem('Admin_Doc_Secret');

    foreach AllFuckingDocumentNames(n){
        InventoryManager.UnreadDocuments.RemoveItem(n);
        InventoryManager.CollectedDocuments.RemoveItem(n);
    }    
}
exec function removeRecordings(){
    local OLRecordingMarker rm;
    
    Hud.LatestRecordingName ='';
    Hud.LatestRecordingTimer =0;
    PendingRecordingMarker =none;
    removeAllRecords();

    foreach AllActors(class'OLRecordingMarker', rm){
        rm.bRecorded =false;
    }
}

private function removeAllRecords(){
    local Array<Name> AllFuckingRecordNames;
    local name n;

    AllFuckingRecordNames.AddItem('Admin_RM_Asylum');
    AllFuckingRecordNames.AddItem('Admin_RM_Stevenson');
    AllFuckingRecordNames.AddItem('Admin_RM_StaticTV');
    AllFuckingRecordNames.AddItem('Admin_RM_Witness');
    AllFuckingRecordNames.AddItem('Admin_RM_Chris');
    AllFuckingRecordNames.AddItem('Prison_RM_PriestCell');
    AllFuckingRecordNames.AddItem('Prison_RM_Necro');
    AllFuckingRecordNames.AddItem('Prison_RM_SoldierRippingHeadOff');
    AllFuckingRecordNames.AddItem('Prison_RM_SwarmShower');
    AllFuckingRecordNames.AddItem('Sewer_RM_GuyOnMattress');
    AllFuckingRecordNames.AddItem('Sewer_RM_EndOfSewer');
    AllFuckingRecordNames.AddItem('Male_RM_IsolationRoom');
    AllFuckingRecordNames.AddItem('Male_RM_SurgeonKilling');
    AllFuckingRecordNames.AddItem('Male_RM_TragersDeath');
    AllFuckingRecordNames.AddItem('Male_RM_Pyro');
    AllFuckingRecordNames.AddItem('Male_RM_Kitchen');
    AllFuckingRecordNames.AddItem('Court_RM_Walrider');
    AllFuckingRecordNames.AddItem('Court_RM_Fountain');
    AllFuckingRecordNames.AddItem('Female_RM_DryMachine');
    AllFuckingRecordNames.AddItem('Female_RM_Elevator');
    AllFuckingRecordNames.AddItem('Female_RM_ChuteHole');
    AllFuckingRecordNames.AddItem('Revisit_RM_RecreationHall');
    AllFuckingRecordNames.AddItem('Revisit_RM_PoolRoom');
    AllFuckingRecordNames.AddItem('Revisit_RM_PriestBurning');
    AllFuckingRecordNames.AddItem('Lab_RM_Reception');
    AllFuckingRecordNames.AddItem('Lab_RM_Morphegenic');
    AllFuckingRecordNames.AddItem('Lab_RM_ChrisDeath');
    AllFuckingRecordNames.AddItem('Lab_RM_Sphere');
    AllFuckingRecordNames.AddItem('Lab_RM_Billy');
    AllFuckingRecordNames.AddItem('Lab_RM_LiquidLife');
    AllFuckingRecordNames.AddItem('Lab_RM_BillysDeath');
    
    AllFuckingRecordNames.AddItem('Hospital_RM_Beginning');
    AllFuckingRecordNames.AddItem('Hospital_RM_Airvent');
    AllFuckingRecordNames.AddItem('Hospital_RM_SAS');
    AllFuckingRecordNames.AddItem('Hospital_RM_Cannibal');
    AllFuckingRecordNames.AddItem('Hospital_RM_DrowningGuy');
    AllFuckingRecordNames.AddItem('Courtyard1_RM_CannibalOutro');
    AllFuckingRecordNames.AddItem('Courtyard1_RM_BasketBall');
    AllFuckingRecordNames.AddItem('PrisonRevisit_RM_Priest');
    AllFuckingRecordNames.AddItem('Courtyard2_RM_Electricity');
    AllFuckingRecordNames.AddItem('Courtyard2_RM_Suicide');
    AllFuckingRecordNames.AddItem('Workshop_RM_Hangman');
    AllFuckingRecordNames.AddItem('Workshop_RM_BirthScene');
    AllFuckingRecordNames.AddItem('Workshop_RM_PostTorture');
    AllFuckingRecordNames.AddItem('Workshop_RM_Gymnase');
    AllFuckingRecordNames.AddItem('Workshop_RM_GroomsDeath');
    AllFuckingRecordNames.AddItem('MaleRevisit_RM_ChapelBurning');
    AllFuckingRecordNames.AddItem('MaleRevisit_RM_Trager');
    AllFuckingRecordNames.AddItem('Admin_RM_Blair');

    foreach AllFuckingRecordNames(n){
        CompletedRecordingMoments.RemoveItem(n);
        UnreadRecordingMoments.RemoveItem(n);
    }
}

exec function PlayerInfo(){
    bShowInfo = !bShowInfo;
}

exec function Dummy(){
    cm =Spawn(Class'Communicator');
    cm.Initialize("127.0.0.1", 34657);
}

Function SendMsg(String Msg, Float LifeTime=3.0) 
{
    SMHud(HUD).AddConsoleMessage(Msg, Class'LocalMessage', PlayerReplicationInfo, LifeTime);
}

exec function SaveCheckpoint(){
    SavedCheckpointName =string(OLGame(WorldInfo.game).CurrentCheckPointName);
    SaveConfig();
}

exec function LoadCheckpoint(){
    CP(SavedCheckpointName);
}

Function CP(String CP) {
    local OLEnemyPawn P;
    
    if(Class'CPList'.static.IsCP(name(CP))) {
        // ConsoleCommand("Streammap All_Checkpoints");
        // Kill all enemies (for safety).
        foreach WorldInfo.AllPawns(Class'OLEnemyPawn', P){
            if (p.Bot !=none)
                P.Bot.Destroy();
            P.Destroy();
        }
        SMHero(Pawn).RespawnHero();
        StartNewGameAtCheckpoint(CP, true);
    }
}

defaultproperties
{
    damage =true
}