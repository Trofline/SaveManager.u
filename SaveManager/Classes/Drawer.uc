class Drawer extends Object;

var private WorldInfo wi;

public static function Drawer init(){
    local Drawer d;

    d =new (class'WorldInfo'.static.GetWorldInfo()) class'Drawer';
    d.wi =WorldInfo(d.Outer);

    return d;
}

 function DrawLedge(OLLedgeMarker lm){
    if (lm.next !=none)
        wi.DrawDebugCylinder(lm.location, lm.next.location, 2, 6, 222,227,209, true);
    if (lm.prev !=none)
        wi.DrawDebugCylinder(lm.location, lm.Prev.location, 2, 6, 222,227,209, true);
}

 function DrawCheckPoint(OLCheckpoint cp){
    wi.DrawDebugCylinder(cp.Location,cp.Location+vect(0,0,25),25,16,238,107,103,true);
}

 function DrawTrigger(Trigger t)
{
    wi.DrawDebugCylinder(t.Location,t.Location+vect(0,0,25),t.CylinderComponent.CollisionRadius,16,238,107,103,true);
}

 function DrawGamePlayMarker(OLGameplayMarker gm)
{
    wi.DrawDebugSphere(gm.Location,5,10,222,227,209,true);
}

 function DrawSqueezeVolume(OLSqueezeVolume sv)
{
    wi.DrawDebugCylinder(sv.Node1.Location,sv.Node2.Location,2,7,48,50,56,true);
}

 function DrawLadderMarker(OLLadderMarker lm)
{
    if(lm.OtherMarker != none)
        wi.DrawDebugCylinder(lm.Location,lm.OtherMarker.Location,3,7,107,189,132,true);
}
