class ChatIconInteraction extends Interaction;

var bool bUse3rd;
var Texture ChatIconTex;
var PlayerController OwnerPC;
var float fScaleX, fScaleY;
var float fScaleW, fScaleH;

function Initialize()
{
  OwnerPC=ViewportOwner.Actor;
  if(OwnerPC==None) Master.RemoveInteraction(Self);
}

event NotifyLevelChange()
{
  Master.RemoveInteraction(Self);
}

event Initialized()
{
  ChatIconTex=None;
  fScaleX=0;
  fScaleY=0;
  fScaleW=0;
  fScaleH=0;
}

simulated function SetSettings(float ValueX, float ValueY, float ValueW, float ValueH, string ChatIconTexture, bool b3rd, int iFPS)
{
  ChatIconTex=Texture(DynamicLoadObject(ChatIconTexture, Class'Texture', true));
  ChatIconTex.MaxFrameRate = iFPS;
  fScaleX=ValueX;
  fScaleY=ValueY;
  fScaleW=ValueW;
  fScaleH=ValueH;
  bUse3rd=b3rd;
}

simulated function PostRender(Canvas C)
{
  local Rotator CamRot;
  local Vector CamPos, ViewDir, ScreenPos;
  local KFHumanPawn KFHP;
  C.GetCameraLocation(CamPos,CamRot);
  ViewDir=Vector(CamRot);
  ForEach OwnerPC.VisibleCollidingActors(Class'KFHumanPawn', KFHP, 1000.f, CamPos)
  {
    KFHP.bNoTeamBeacon=True;
    if(KFHP.Controller!=OwnerPC && KFHP.PlayerReplicationInfo!=None && KFHP.Health>0 && ((KFHP.Location-CamPos) Dot ViewDir)>0.8)
    {
      ScreenPos=C.WorldToScreen(KFHP.Location+Vect(0,0,1)*KFHP.CollisionHeight);
      if(ScreenPos.X>=0 && ScreenPos.Y>=0 && ScreenPos.X<=C.ClipX && ScreenPos.Y<=C.ClipY)
        DrawChatIcon(C, KFHP, ScreenPos.X, ScreenPos.Y);
    }
  }
  if(bUse3rd)
  {
    if(OwnerPC.Pawn!=None)
    {
      ScreenPos=C.WorldToScreen(OwnerPC.Pawn.Location+Vect(0,0,1)*OwnerPC.Pawn.CollisionHeight);
      DrawChatIcon(C, KFHumanPawn(OwnerPC.Pawn), ScreenPos.X, ScreenPos.Y);
    }
  }
}

simulated function DrawChatIcon(Canvas C, KFHumanPawn KFHP, float ScreenLocX, float ScreenLocY)
{
  local HUDKillingFloor KFHUD;
  local float Dist;
  local byte BeaconAlpha;
  local float TempX, TempY;
  KFHUD=HUDKillingFloor(OwnerPC.myHUD);
  Dist=VSize(KFHP.Location-OwnerPC.CalcViewLocation);
  Dist-=KFHUD.HealthBarFullVisDist;
  Dist=FClamp(Dist, 0, KFHUD.HealthBarCutoffDist-KFHUD.HealthBarFullVisDist);
  Dist=Dist/(KFHUD.HealthBarCutoffDist-KFHUD.HealthBarFullVisDist);
  BeaconAlpha=byte((1.f-Dist)*255.f);
  if(BeaconAlpha==0) Return;
  if(KFHP.bIsTyping)
  {
    if(ChatIconTex!=None)
    {
      TempX=ScreenLocX-ChatIconTex.MaterialUSize()/fScaleW;
      TempY=ScreenLocY-ChatIconTex.MaterialVSize()/fScaleH;
      C.SetPos(TempX, TempY);
      C.Style=KFHUD.ERenderStyle.STY_Alpha;
      C.SetDrawColor(255, 255, 255, BeaconAlpha);
      C.DrawTile(ChatIconTex, ChatIconTex.MaterialUSize()*fScaleX, ChatIconTex.MaterialVSize()*fScaleY, 0, 0, ChatIconTex.MaterialUSize(), ChatIconTex.MaterialVSize());
    }
  }
}

defaultproperties
{
  bVisible=True
}
