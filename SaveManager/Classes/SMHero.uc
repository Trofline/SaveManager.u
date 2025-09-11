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
