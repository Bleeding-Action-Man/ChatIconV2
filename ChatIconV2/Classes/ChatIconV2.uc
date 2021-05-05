///////////////////////////////////////////////////////////////
// Modifed version of Essence's Chat Icon Mutator
// TexPackage is now a config var
// Change mut name
// Removed russian comments
// Added a new texture package with animated icons
// Formatted Code
// Option to show random chat icon for every player
// TODO: Option to show specific icon for selected player (?)
// Will not be released on the Steam Workshop, but only on
// @Killingfloor.ru
///////////////////////////////////////////////////////////////

class ChatIconV2 extends Mutator
  Config(ChatIconV2_Config);

// Textures Count | Default 10, can be increased if needed
const T_COUNT = 10;

// Config Variables
struct TextureNames
{
  var config string Name; // Name of the texture e.g. PackageName.Group.TexName
  var config string Description; // Only for reference, not used in anything
};
var config TextureNames aIcon[T_COUNT]; // Config List to hold all textures you have in your package
var TextureNames Icon[T_COUNT]; // Local list

var config string sChatIconPackage;
var config int iSelectTexture;
var config bool bRandomIcon, bDisplayFrom3rdP;
var config float fScaleX, fScaleY;
var config float fScaleW, fScaleH;

// Player Var Replication
replication
{
  reliable if(bNetDirty && Role==Role_Authority)
    iSelectTexture,
    fScaleX, fScaleY, fScaleW, fScaleH,
    bRandomIcon, bDisplayFrom3rdP,
    Icon, aIcon;
}

// Force Clients to download the texture Package
function PostBeginPlay()
{
  // Make sure Clients also download the Texture Package
  AddToPackageMap(sChatIconPackage);
}

// Tick, Injects Interaction
simulated function Tick(float DeltaTime)
{
  local ChatIconInteraction CII;
  local PlayerController PC;
  local int Count;

  PC=Level.GetLocalPlayerController();

  // Get Count + Vars to Client
  Count = GetServerVars();
  if(PC!=None)
  {
    CII=ChatIconInteraction(PC.Player.InteractionMaster.AddInteraction("ChatIconV2.ChatIconInteraction", PC.Player));
    if(CII!=None)
    {
      if(!bRandomIcon)
        CII.SetSettings(fScaleX, fScaleY, fScaleW, fScaleH, Icon[iSelectTexture].Name, bDisplayFrom3rdP);
      else
        CII.SetSettings(fScaleX, fScaleY, fScaleW, fScaleH, Icon[Rand(Count)].Name, bDisplayFrom3rdP);
    }
    Disable('Tick');
  }
  if(Role==Role_Authority) Disable('Tick');
}

simulated function int GetServerVars()
{
  local int i;
  local int count; // To avoid running loops over T_COUNT, just get the count of actual array entry

  count = 0;
  for(i=0; i<T_COUNT; i++)
  {
    if (aIcon[i].Name != "")
    {
      Icon[i] = aIcon[i];
      count++;
    }
  }

  return count;
}

defaultproperties
{
  GroupName="KF-ChatIconV2"
  FriendlyName="Chat Icon - v2.0"
  Description="Shows an icon on top of a player when he is using chat"
  bAlwaysRelevant=True
  RemoteRole=ROLE_SimulatedProxy
  bNetNotify=True
  bAddToServerPackages=True
}
