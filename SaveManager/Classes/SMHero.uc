class SMHero extends OLHero;


event TakeDamage(int Damage, Controller InstigatedBy, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
    if(!SMController(Controller).Damage)
    {
        super.TakeDamage(Damage,  InstigatedBy,  HitLocation,  Momentum, DamageType,  HitInfo, DamageCauser);
    }
}

function TakeFallingDamage()
{
    if(!SMController(Controller).Damage)
    {
        super.TakeFallingDamage();
    }
}

exec function ReloadCheckpoint()
{
        if (LocomotionMode ==LM_Cinematic){
        SMController(controller).StartNewGameAtCheckpoint(string(OLGame(WorldInfo.game).CurrentCheckPointName),false);
        return;
    }

    if(DeathScreenDuration >7){
        DeathScreenDuration =0;
    }
    if(LocomotionMode ==LM_Locker ||  LocomotionMode ==LM_Bed)
    {
        PreciseHealth =0;
    }
    else
    {
        DMGS(101);
    }
}

private Function DMGS(Float Amount)
{
    TakeDamage(Amount, none, Location, Vect(0,0,0), none);
}

DefaultProperties
{
    begin object name=MyLightEnvironment
		bEnabled=True
		bUseBooleanEnvironmentShadowing=false
		bSynthesizeSHLight=true
		bIsCharacterLightEnvironment=true
		bForceNonCompositeDynamicLights=true
	End Object
	LightEnvironment=MyLightEnvironment
	Components.Add(MyLightEnvironment)

	begin object name=WPawnSkeletalMeshComponent
		LightEnvironment=MyLightEnvironment
	End Object

	//This is what is used for the shadow.
	begin object name=ShadowProxyComponent
		LightEnvironment=DynamicLightEnvironmentComponent'MyLightEnvironment'
	End Object

	// This is the head mesh seen in the shadow. 
	begin object name=HeadMeshComp
		LightEnvironment=DynamicLightEnvironmentComponent'MyLightEnvironment'
	End Object
}