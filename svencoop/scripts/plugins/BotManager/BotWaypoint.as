
#include "FileBuffer"
#include "UtilFuncs"
#include "CBotBits"
#include "BotWaypointScript"

CWaypoints g_Waypoints;
CWaypointTypes g_WaypointTypes;

const int W_FL_WATER = (1<<0);			// can go here in water only
const int W_FL_WAIT_NO_PLAYER = (1<<1); // bots wait until space is clear to avoid over crowding
const int W_FL_SCIENTIST = (1<<2); //	bot waits a while for allies to come by
//const int W_FL_TEAM_SPECIFIC = (1<<2);  /* waypoint only for specified team */
const int W_FL_CROUCH	= 	(1<<3);  /* must crouch to reach this waypoint */
const int W_FL_LADDER	= 	(1<<4);  /* waypoint on a ladder */
const int W_FL_LIFT		= 	(1<<5);  // lift button
const int W_FL_PLATFORM	= 	(1<<6);  /* wait for a platform to move to waypoint */
const int W_FL_HEALTH	= 	(1<<7);  /* health kit (or wall mounted) location */
const int W_FL_ARMOR	= 	(1<<8);  /* armor (or HEV) location */
const int W_FL_AMMO		=	(1<<9);  /* ammo location */
const int W_FL_CHECK_GROUND	= (1<<10); /* checks for platform at this point */
const int W_FL_IMPORTANT	= (1<<11);/* flag position (or hostage or president) */
const int W_FL_BARNEY  = (1<<12);
const int W_FL_DEFEND_ZONE  =  (1<<13);
const int W_FL_AIMING	= (1<<14); /* aiming waypoint */
const int W_FL_VEHICLE = (1<<15); /* Experimental */
const int W_FL_CROUCHJUMP = 	(1<<16); // }	
const int W_FL_WAIT = (1<<17);/* wait for lift to be down before approaching this waypoint */
const int W_FL_PAIN	= (1<<18);
const int W_FL_JUMP    = (1<<19);
const int W_FL_WEAPON	= (1<<20); // Crouch and jump
const int W_FL_TELEPORT  = (1<<21);
const int W_FL_TANK	= (1<<22); // func_tank near waypoint
const int W_FL_GRAPPLE = (1<<23);
const int W_FL_STAY_NEAR = (1<<24);
const int W_FL_ENDLEVEL  = (1<<25); // end of level, in svencoop etc
const int W_FL_OPENS_LATER  =(1<<26);
const int W_FL_HUMAN_TOWER = (1<<27);// bot will crouch & wait for a player to jump on them
const int W_FL_UNREACHABLE = (1<<28); // not reachable by bot, used as a reference point for visibility only
const int W_FL_PUSHABLE  = (1<<29);
const int W_FL_GREN_THROW  = (1<<30);
const int W_FL_DELETED = (1<<31); /* used by waypoint allocation code */

const int MAX_WAYPOINTS = 1024;

void drawBeam (CBasePlayer@ pPlayer, Vector start, Vector end, WptColor@ col, int life = 10 )
{
	//BotMessage("Beam from " + formatFloat(start.x) + "," + formatFloat(start.y) + "," + formatFloat(start.z)+ "," + " to " + formatFloat(end.x)+ "," +formatFloat(end.y)+ "," + formatFloat(end.z) + "\n" );
		// PM - Use MSG_ONE_UNRELIABLE
		//    - no overflows!
	NetworkMessage message(MSG_ONE_UNRELIABLE, NetworkMessages::SVC_TEMPENTITY, pPlayer.edict());

	message.WriteByte(TE_BEAMPOINTS);
	message.WriteCoord(start.x);
	message.WriteCoord(start.y);
	message.WriteCoord(start.z);
	message.WriteCoord(end.x);
	message.WriteCoord(end.y);
	message.WriteCoord(end.z);
	message.WriteShort( g_EngineFuncs.ModelIndex("sprites/laserbeam.spr") );
	message.WriteByte( 1 ); // framestart
	message.WriteByte( 10 ); // framerate
	message.WriteByte( life ); // life in 0.1's
	message.WriteByte( 32 ); // width
	message.WriteByte( 2 );  // noise

	message.WriteByte( col.r );   // r, g, b
	message.WriteByte( col.g );   // r, g, b
	message.WriteByte( col.b );   // r, g, b

	message.WriteByte( col.a );   // brightness
	message.WriteByte( 1 );    // speed
	message.End();
}

class CWaypointHeader
{
	// 8 characters
   string filetype;  // should be "RC_bot\0"
   int  waypoint_file_version;
   int  waypoint_file_flags;  // used for visualisation
   int  number_of_waypoints;
   // 32 characters
   string mapname;  // name of map for these waypoints
	
	bool Read ( FileBuffer@ file )
	{
		filetype = file.ReadString(8);
		BotMessage("FILETYPE = " + filetype);
		waypoint_file_version = file.ReadInt32();
		BotMessage("VERSION = " + formatInt(waypoint_file_version));
		waypoint_file_flags = file.ReadInt32();
		BotMessage("FLAGS = " + formatInt(waypoint_file_flags));
		number_of_waypoints = file.ReadInt32();
		BotMessage("NUM WPTS = " + formatInt(number_of_waypoints));

		mapname = file.ReadString(32);		
		BotMessage("MAPNAME = " + mapname);

		return number_of_waypoints < MAX_WAYPOINTS;
	}

	CWaypointHeader ( )
	{
		filetype = "RCBot";
		waypoint_file_version = 10;
		waypoint_file_flags = 0;
		number_of_waypoints = g_Waypoints.m_iNumWaypoints;
	}


	void Save ( FileBuffer@ file )
	{
		file.Write(filetype,8);
		file.Write(waypoint_file_version);
		file.Write(waypoint_file_flags);
		file.Write(number_of_waypoints);
		file.Write(mapname,32);
	}
}

class CWaypointType
{
	string m_szName;
	int m_iFlag;
	WptColor@ color;

	CWaypointType ( string name, int flag, WptColor@ col )
	{
		m_iFlag = flag;
		m_szName = name;
		@color = col;
	}

	bool isBitsInFlags ( int flags )
	{
		return (flags & m_iFlag) == m_iFlag;
	}

	void getColour (WptColor@ other)
	{

		other.r = color.r;
		other.g =  color.g;
		other.b =  color.b;
		other.a =  color.a;

	}

}


class WptColor
{
	WptColor ()
	{
		r=0;g=0;b=0;a=0;
	}

	WptColor ( int _r, int _g, int _b, int _a )
	{
		r=_r;
		g=_g;
		b=_b;
		a=_a;
	}

	WptColor ( int _r, int _g, int _b )
	{
		r=_r;
		g=_g;
		b=_b;
		a=200;
	}


	void mixColor ( WptColor@ other )
	{
		r = int( (0.5*r) + (0.5*other.r));
		g = int( (0.5*g) + (0.5*other.g));
		b = int( (0.5*b) + (0.5*other.b));
	}	
	int r;
	int g;
	int b;
	int a;
	
};

class CWaypointTypes
{
	array<CWaypointType@> m_Types;

	CWaypointTypes ()
	{
		int flag = 1;

		for ( int r = 250; r >= 50; r -= 50 )
		{
			for ( int g = 250; g >= 50; g -= 50 )
			{
				for ( int b = 250; b >= 50; b -= 50 )
				{
					WptColor color = WptColor(r,g,b);
					string name = "";

					switch ( flag )
					{
						case W_FL_WATER:
							name = "water";
							break;
						case W_FL_WAIT_NO_PLAYER :
							name = "wait_noplayer";
							break;
						case W_FL_SCIENTIST :
							name = "scientist";
							break;
						case W_FL_CROUCH :
							name = "crouch";
							break;
						case W_FL_LADDER :
						name = "ladder";
						break;
						case W_FL_LIFT :
						name = "lift";
						break;
						case W_FL_PLATFORM :
						name = "platform";
						break;
						case W_FL_HEALTH :
						name = "health";
						break;
						case W_FL_ARMOR :
						name = "armor";
						break;
						case W_FL_AMMO :
						name = "ammo";
						break;
						case W_FL_CHECK_GROUND :
						name = "checkground";
						break;
						case W_FL_IMPORTANT :
						name = "important";
						break;
						case W_FL_BARNEY :
						name = "barney";
						break;
						case W_FL_DEFEND_ZONE :
						name = "defend";
						break;
						case W_FL_AIMING :
						name = "aiming";
						break;
						case W_FL_CROUCHJUMP :
						name = "crouchjump";
						break;
						case W_FL_WAIT :
						name = "wait";
						break;
						case W_FL_PAIN :
						name = "pain";
						break;
						case W_FL_JUMP :
						name = "jump";
						break;
						case W_FL_WEAPON :
						name = "weapon";
						break;
						case W_FL_TELEPORT :
						name = "teleport";
						break;
						case W_FL_TANK :
						name = "tank";
						break;
						case W_FL_GRAPPLE :
						name = "grapple";
						break;
						case W_FL_STAY_NEAR :
						name = "staynear";
						break;
						case W_FL_ENDLEVEL :
						name = "end";
						break;
						case W_FL_OPENS_LATER :
						name = "openslater";
						break;
						case W_FL_HUMAN_TOWER :
						name = "humantower";
						break;
						case W_FL_UNREACHABLE :
						name = "unreachable";
						break;
						case W_FL_PUSHABLE :
						name = "pushable";
						break;
						case W_FL_GREN_THROW :
						name = "grenthrow";
						break;
						case W_FL_DELETED :
						name = "deleted";
						break;
						default:
						break;
					}

					if ( name != "" )
					{
						m_Types.insertLast(CWaypointType(name,flag,color));
						BotMessage("Added waypoint type ("+name+","+flag+")");
					}
					// finished
					if ( flag == W_FL_DELETED )
					{
						return;
					}
					else 
						flag *= 2;
				}
			}
		}

		//m_Types.insertLast(CWaypointType("button",W_FL_BUTTON,WptColor(200,200,255)));
	}

	string getInfo ( CBasePlayer@ player, int flags )
	{
		string szflags = "";

		for ( uint i = 0; i < m_Types.length(); i ++ )
		{
			//BotMessage("Searching Types in flags " + flags + "... against " + m_Types[i].m_iFlag );

			if ( (flags & m_Types[i].m_iFlag) == m_Types[i].m_iFlag )
			{
				szflags += "," + m_Types[i].m_szName;
			}
		}

		if ( szflags == "" )
			szflags = "NO FLAGS";

		return szflags;
	}

	WptColor getColour ( int flags )
	{
		WptColor colour = WptColor(0,0,255); // normal waypoint

		bool bNoColour = true;

		for ( uint i = 0; i < m_Types.length(); i ++ )
		{
			if ( m_Types[i].isBitsInFlags(flags) )
			{
				if ( bNoColour )
				{
					m_Types[i].getColour(colour);
					bNoColour = false;
				}
				else
				{
					WptColor col;
					m_Types[i].getColour(col);
					colour.mixColor(col);
				}
			}
		}

		return colour;
	}

	int findTypeFlag ( string type )
	{
		for ( uint i = 0; i < m_Types.length(); i ++ )
		{
			//BotMessage("FindTypeFlag('"+type+") against '"+m_Types[i].m_szName+"'" );
			if ( m_Types[i].m_szName == type  )
			{
				//BotMessage("FOUND returning "+ m_Types[i].m_iFlag);
				return m_Types[i].m_iFlag;
			}
		}

		return 0;
	}

	int parseTypes ( array<string> types )
	{
		int flags = 0;

		for ( uint i = 0; i < types.length(); i ++  )
		{
			int flag = findTypeFlag(types[i]);

			if ( flag != 0 )
			{
				flags |= findTypeFlag(types[i]);
				
			}
			else
				BotMessage("Waypoint type " + types[i]+" not found");
			
		}
		//BotMessage("parseTypes returning " + flags);
		return flags;
	}
}

WptColor@ PathColor = WptColor(255,255,255,200);

// apparently "Waypoint" is a reserved class name
class CWaypoint
{
	// link to waypoint id
	array<int> m_PathsFrom;
	array<int> m_PathsTo;

	int iIndex;

	Vector m_vOrigin;
	// flags such as Jump, crouch etc
	int m_iFlags;

	EHandle m_pAttachment; // attachment such as a vehicle - experimental
	
	CWaypoint ()
	{
		m_iFlags = 0;
		m_pAttachment = null;
	}

	bool isDeleted ()
	{
		return hasFlags(W_FL_DELETED);
	}

	void removePaths ()
	{
		m_PathsFrom = {};
		m_PathsTo = {};
	}

	bool hasFlags ( int flags )
	{
		return m_iFlags & flags == flags;
	}

	bool Read ( FileBuffer@ file, int index )
	{
		m_iFlags = file.ReadInt32();
		//BotMessage("m_iFlags = " + m_iFlags + "\n");
		m_vOrigin.x = file.ReadFloat();		
		m_vOrigin.y = file.ReadFloat();
		m_vOrigin.z = file.ReadFloat();

		//BotMessage("m_vOrigin.x = " + m_vOrigin.x + "\n");
		////BotMessage("m_vOrigin.y = " + m_vOrigin.y + "\n");
		//BotMessage("m_vOrigin.z = " + m_vOrigin.z + "\n");

		int numPaths = file.ReadInt32();

		m_PathsTo = {};
		iIndex = index;

		if ( numPaths < 32 )
		{
			//BotMessage("numPaths = " + numPaths + "\n");			

			for (int i = 0; i < numPaths; i ++ )
				m_PathsTo.insertLast(file.ReadInt32());

			return true;
		}
		else
			return false;
		
	}

	void Save ( FileBuffer@ file )
	{
		file.Write(m_iFlags);
		file.Write(m_vOrigin.x);
		file.Write(m_vOrigin.y);
		file.Write(m_vOrigin.z);
		file.Write(m_PathsTo.length());

		for ( uint i = 0; i < m_PathsTo.length(); i ++ )
		{
			file.Write(m_PathsTo[i]);
		}
	}

	void draw ( CBasePlayer@ pPlayer, bool drawPaths )
	{
		drawBeam(pPlayer,m_vOrigin-Vector(0,0,32),m_vOrigin+Vector(0,0,32),g_WaypointTypes.getColour(m_iFlags));

		if ( drawPaths )
		{
			for ( uint i = 0; i < m_PathsTo.length(); i ++ )
			{
				CWaypoint@ wpt = g_Waypoints.getWaypointAtIndex(m_PathsTo[i]);
				
				drawBeam(pPlayer,m_vOrigin,wpt.m_vOrigin,PathColor);
			}
		}
	}

	float distanceFrom ( Vector vecLocation )
	{
		return (m_vOrigin - vecLocation).Length();
	}

	int numPaths ( )
	{
		return m_PathsTo.length();
	}

	void removePath ( int wpt )
	{
		int idx = m_PathsTo.find(wpt);

		if ( idx >= 0 )
			m_PathsTo.removeAt(idx);
	}

	void addPath ( int wpt )
	{
		// can't add paths to unreachables -- for visibles only
		if ( hasFlags(W_FL_UNREACHABLE) )
			return;

		if ( wpt == iIndex )
			return;
		if ( m_PathsTo.find(wpt) < 0 )
		{
			CWaypoint@ pwpt = g_Waypoints.getWaypointAtIndex(wpt);
			
			if ( pwpt.hasFlags(W_FL_DELETED) )
				return;
			// can't add paths to unreachables
			if ( pwpt.hasFlags(W_FL_UNREACHABLE) )
				return;

			if ( m_PathsTo.length() < 32 )
				m_PathsTo.insertLast(wpt);
		}
	}

	int getPath ( int i )
	{
		return m_PathsTo[i];
	}

	void addWaypointType ( int type )
	{
		 m_iFlags |= type;
	}

	void removeWaypointType ( int type )
	{
		m_iFlags &= ~type;
	}

	string getSerialized ()
	{
		return formatFloat(m_vOrigin.x) + "," + formatFloat(m_vOrigin.y) + "," + formatFloat(m_vOrigin.z) + "," + formatFloat(m_vOrigin.x) + "," + formatUInt(m_iFlags);
	}

	void Delete ()
	{
		Clear();

		m_iFlags = W_FL_DELETED;
	}

	void Place ( int index, Vector loc )
	{
		m_vOrigin = loc;
		m_iFlags = 0;
		iIndex = index;
	}

	void Clear ()
	{
		m_PathsFrom = {};
		m_PathsTo = {};
		
		m_iFlags = 0;
	}


}


const int W_VIS_RUNNING = 0;
const int W_VIS_COMPLETE = 1;

final class CWaypointVisibility
{
	int state;
	int iWptFrom;
	int iWptTo;	
	int iMaxLoops = 200;
	int m_iNumWaypoints;

	CBits@ bits;

	CWaypointVisibility ( int iNumWaypoints )
	{
		//BotMessage("SET STATE");
		state = W_VIS_RUNNING;
		iWptFrom = 0;
		iWptTo = 0;
		@bits = CBits(MAX_WAYPOINTS*MAX_WAYPOINTS);		
		m_iNumWaypoints = iNumWaypoints;
	}

	bool VisibleFromTo ( int iFrom, int iTo )
	{
		int bit_num = (iFrom * MAX_WAYPOINTS) + iTo;
		
		return bits.getBit(bit_num);
	}

	int run ( )
	{

		if ( state == W_VIS_RUNNING  )
		{
			int iLoops = 0;

			if ( m_iNumWaypoints == 0  )
			{
				state = W_VIS_COMPLETE;
				return state;
			}

			int Percent = (100 * ((iWptFrom * m_iNumWaypoints) + iWptTo)) / (m_iNumWaypoints * m_iNumWaypoints);

			//BotMessage("Visibility Calculating Percent = " + Percent + " complete" );

			while ( (iLoops < iMaxLoops) && (state == W_VIS_RUNNING) )
			{				
					//@set_bits = null;
					//BotMessage(" " + iWptFrom + " / " + m_iNumWaypoints);

				if ( iWptFrom < m_iNumWaypoints )
				{					
					//BotMessage("iWptFrom < m_iNumWaypoints");

					if ( iWptTo >= m_iNumWaypoints )	
					{
						//BotMessage("iWptTo >= m_iNumWaypoints");
							iWptFrom++;
							iWptTo = 0;
					}
					else
					{
						//BotMessage("else");
						CWaypoint@ pFrom = g_Waypoints.getWaypointAtIndex(iWptFrom);
						CWaypoint@ pTo = g_Waypoints.getWaypointAtIndex(iWptTo);

						if ( !pFrom.hasFlags(W_FL_DELETED) && !pTo.hasFlags(W_FL_DELETED) )
						{
							int bit_num = (iWptFrom * MAX_WAYPOINTS) + iWptTo;
							
							bool bVisible =  UTIL_IsVisible ( pFrom.m_vOrigin, pTo.m_vOrigin, null );

							bits.setBit(bit_num,bVisible);																			
						}

						iWptTo ++;
					}
				}
				else
				{
					state = W_VIS_COMPLETE;
					//@set_bits = null;

				}

				iLoops++;
			}
		}

		return state;
	}
}

// to do for finding waypoint types nearest a goal
class CWaypointDistance
{
	int iWpt;
	float fDistance;

	CWaypointDistance ( int wptIndex, float fDist )
	{
		iWpt = wptIndex;
		fDistance = fDist;
	}
}

class CWaypoints
{
	// Max waypoint is 1024 
	private array<CWaypoint> m_Waypoints(MAX_WAYPOINTS);
	//private array<float> m_fDanger(MAX_WAYPOINTS);

	// look up for flagged waypoints (speed up)
	private array<array<int>> m_FlaggedLookup;

	bool g_WaypointsOn = false;
	int m_iNumWaypoints = 0;
	int m_PathFrom;

	int m_iPasteWaypointFlags = 0;
	uint m_iMoveWaypointIndex = 0;
	bool m_bMoveWaypointValid = false;
	AutoWaypointer@ autoWaypointer = null;
	CWaypointVisibility@ m_VisibilityTable = null;

	CWaypoint@ getWaypointAtIndex ( uint idx )
	{
		return m_Waypoints[idx];
	}

	void copyWaypoint ( CBaseEntity@ player )
	{
		int wpt = getNearestWaypointIndex(player.pev.origin,player,-1,128.0f,false);

		if ( wpt != -1 )
		{
			m_iPasteWaypointFlags = m_Waypoints[wpt].m_iFlags;		
		}

		playsound(player,wpt != -1);
	}
	
	void cutWaypoint ( CBaseEntity@ player )
	{
		int wpt = getNearestWaypointIndex(player.pev.origin,player,-1,128.0f,false);

		if ( wpt != -1 )
		{
			m_iPasteWaypointFlags = m_Waypoints[wpt].m_iFlags;	
			deleteWaypoint(wpt);
		}

		playsound(player,wpt != -1);

	}

	void pasteWaypoint ( CBaseEntity@ player )
	{
		addWaypoint ( player.pev.origin, m_iPasteWaypointFlags, player );
		
	}

	void moveWaypoint1 ( CBaseEntity@ player )
	{
		int wpt = getNearestWaypointIndex(player.pev.origin,player,-1,128.0f,false);

		if ( wpt != -1 )
		{
			m_bMoveWaypointValid = true;
			m_iMoveWaypointIndex = wpt;
		}
		playsound(player,wpt != -1);

	}

	void moveWaypoint2 ( CBaseEntity@ player )
	{
		
		if ( m_bMoveWaypointValid )
		{
			m_Waypoints[m_iMoveWaypointIndex].m_vOrigin = player.pev.origin;
			
		}

		playsound(player,m_bMoveWaypointValid);
	}


	void WaypointsOn ( bool on )
	{
		g_WaypointsOn = on;

		if ( on )
		{
			// Kill beams (w00tguy123)
			array<CBaseEntity@> toRemove;

			CBaseEntity@ ent = null;
			do {
				@ent = g_EntityFuncs.FindEntityByClassname(ent, "*"); 
				if (ent !is null)
				{
					string cname = ent.pev.classname;
					if (cname == "env_beam" or cname == "env_laser" or cname == "cbeam")
					{
						toRemove.insertLast(ent);						
					}
				}
			} while (ent !is null);

			for ( uint i = 0; i < toRemove.length(); i ++ )
			{
				@ent = toRemove[i];

				g_EntityFuncs.Remove(ent);
			}

			BotMessage("removed " + toRemove.length() + " beams");

			BotMessage("Waypoints On");
		}
		else 
			BotMessage("Waypoints OFf");
	}

	bool m_bPrecachedsounds = false;

	void precacheSounds ()
	{
		g_SoundSystem.PrecacheSound("weapons/mine_activate.wav");
		g_SoundSystem.PrecacheSound("common/wpn_denyselect.wav");
			
		m_bPrecachedsounds = true;
	}

	void playsound ( CBaseEntity@ player, bool ok )
	{
		if ( player is null )
			return;
		if ( m_bPrecachedsounds == false )
			return;

		if ( ok )
			g_SoundSystem.PlaySound(player.edict(),CHAN_AUTO,"weapons/mine_activate.wav",1,0);
		else
			g_SoundSystem.PlaySound(player.edict(),CHAN_AUTO,"common/wpn_denyselect.wav",1,0);		
	}

	void PathWaypoint_Create1 ( CBasePlayer@ player )
	{
		int wpt = getNearestWaypointIndex(player.pev.origin,player,-1,128.0f,false);

		BotMessage("Nearest waypoint is " + wpt + "\n");

		m_PathFrom = wpt;

		playsound(player,wpt!=-1);
	}

	void PathWaypoint_Create2 ( CBasePlayer@ player )
	{
		int wpt = getNearestWaypointIndex(player.pev.origin,player,-1,128.0f,false);

		BotMessage("Nearest waypoint is " + wpt + "\n");

		if ( wpt != -1 && m_PathFrom != -1 )
		{
			CWaypoint@ pWpt = getWaypointAtIndex(m_PathFrom);

			pWpt.addPath(wpt);
		}

		playsound(player,wpt!=-1&& m_PathFrom != -1);
	}


	void PathWaypoint_Remove1 ( CBasePlayer@ player )
	{
		int wpt = getNearestWaypointIndex(player.pev.origin,player,-1,128.0f,false);

		BotMessage("Nearest waypoint is " + wpt + "\n");

		m_PathFrom = wpt;

		playsound(player,wpt!=-1); 
	}

	void PathWaypoint_Remove2 ( CBasePlayer@ player )
	{
		int wpt = getNearestWaypointIndex(player.pev.origin,player,-1,128.0f,false);

		BotMessage("Nearest waypoint is " + wpt + "\n");

		if ( wpt != -1 && m_PathFrom != -1 )
		{
			CWaypoint@ pWpt = getWaypointAtIndex(m_PathFrom);

			pWpt.removePath(wpt);
		}

		playsound(player,wpt!=-1&& m_PathFrom != -1);
	}


	void DrawWaypoints ( CBasePlayer@ player )
	{
		if ( g_WaypointsOn )
		{
			CWaypoint@ pNearestWpt = null;
			float m_fNearest = 96;

			for ( int i = 0; i < m_iNumWaypoints; i ++ )
			{
				CWaypoint@ wpt = m_Waypoints[i];

				if ( wpt.m_iFlags & W_FL_DELETED == W_FL_DELETED )
					continue;					

				float dist = wpt.distanceFrom(player.pev.origin);

				if ( dist < m_fNearest )
				{
					@pNearestWpt = wpt;
					m_fNearest = dist;					
				}
				
				if ( dist < 512 )
					wpt.draw(player,false);
			}

			if ( pNearestWpt !is null )
				pNearestWpt.draw(player,true);
		}
	}	

	int getWaypointIndex ( CWaypoint@ pWpt )
	{
		return pWpt.iIndex;
	}
	
	int addWaypoint ( Vector vecLocation, int flags = 0, CBaseEntity@ ignore = null, bool autoPath = true, bool autoType = true )
	{
		int index = freeWaypointIndex();

		BotMessage("Adding waypoint...");

		if ( index != -1 )
		{	
			m_Waypoints[index].Place(index,vecLocation);

			BotMessage("OK! index " + formatInt(index));
		
			if ( index == m_iNumWaypoints )
				m_iNumWaypoints++;	

				BotMessage("Num waypoints = "+m_iNumWaypoints);

				CWaypoint@ added = getWaypointAtIndex(index);

				if ( flags & W_FL_UNREACHABLE  != W_FL_UNREACHABLE )
				{
					if ( autoPath )
					{
						// auto path waypoint
						for ( int i = 0; i < m_iNumWaypoints; i ++ )
						{
							CWaypoint@ other = getWaypointAtIndex(i);

							if ( other.hasFlags(W_FL_DELETED))
								continue;

							if ( other.hasFlags(W_FL_UNREACHABLE) )
								continue;

							if ( i == index )
								continue;					

							if ( added.distanceFrom(other.m_vOrigin) > m_pWPAutoPathDist.GetInt() )
								continue;

							if ( UTIL_IsReachable ( added.m_vOrigin, other.m_vOrigin, ignore ) )
							{
								added.addPath(i);
							}

							if ( UTIL_IsReachable ( other.m_vOrigin, added.m_vOrigin, ignore ) )
							{
								other.addPath(index);
							}						

							
						}
					}

					if ( autoType )
					{
						CBaseEntity@ pent = null;
						
						while ( (@pent =  g_EntityFuncs.FindEntityByClassname(pent, "*")) !is null )
						{					
							string classname = pent.GetClassname();

							float dist = (added.m_vOrigin - UTIL_EntityOrigin(pent)).Length();

							if ( dist > 96 )
								continue;

							if ( !UTIL_IsVisible(added.m_vOrigin,pent,ignore) )
								continue;

							if ( pent.pev.owner is null )
							{				
								// must be a respawnable item
								if ( pent.pev.spawnflags & SF_NORESPAWN == 0 )
								{
									if ( classname.SubString(0,7) == "weapon_")
										flags |= W_FL_WEAPON;
									else if ( classname.SubString(0,5) == "ammo_")
										flags |= W_FL_AMMO;
									else if ( classname.SubString(0,11) == "item_health")
										flags |= W_FL_HEALTH;
									else if ( classname.SubString(0,12) == "item_battery")
										flags |= W_FL_ARMOR;
								}
							}

							if ( classname.SubString(0,11) == "func_button")
								flags |= W_FL_IMPORTANT;
							else if ( classname.SubString(0,15) == "func_rot_button")
								flags |= W_FL_IMPORTANT;						
							else if ( classname.SubString(0,11) == "func_health" )
								flags |= W_FL_HEALTH;
							else if ( classname.SubString(0,13) == "func_recharge" )
								flags |= W_FL_ARMOR;
							else if ( classname.SubString(0,12) == "trigger_hurt" )
								flags |= W_FL_PAIN;			
							else if ( classname == "trigger_changelevel" )
								flags |= W_FL_ENDLEVEL;

							BotMessage(classname);
						}

						if ( g_EngineFuncs.PointContents(vecLocation) == CONTENTS_WATER )
							flags |= W_FL_WATER;
					}
				}


			m_Waypoints[index].m_iFlags = flags;

			return index;
		}

		return -1;
	}

	int getIncompleteObjective (CBaseEntity@ pBot)
	{
		array<int> objectives = {};

		for( int i = 0; i < m_iNumWaypoints; i ++ )
		{
			if ( (m_Waypoints[i].m_iFlags & W_FL_DELETED) == W_FL_DELETED )
				continue;

			if ( (m_Waypoints[i].m_iFlags & W_FL_IMPORTANT) == W_FL_IMPORTANT )
			{

				switch ( g_WaypointScripts.canDoObjective(pBot,i) )				
				{
					case BotWaypointScriptResult_Incomplete:
					objectives.insertLast(i);
					BotMessage("SCRIPT Waypoint " + i + " AVAILABLE");
					break;
					case BotWaypointScriptResult_Complete:
					BotMessage("SCRIPT Waypoint " + i + " COMPLETE (NOT AVAILABLE)");
					break;
					case BotWaypointScriptResult_Previous_Incomplete:
					BotMessage("SCRIPT Waypoint " + i + " INCOMPLETE (NOT AVAILABLE)");
					break;
					case BotWaypointScriptResult_Error:
					BotMessage("SCRIPT Waypoint " + i + " ERROR (NOT IN SCRIPT)");
					break;
				}
			}
		}

		if ( objectives.length() > 0 )
		{
			return objectives[Math.RandomLong(0,objectives.length()-1)];
		}

		return -1;
	}

	int freeWaypointIndex ()
	{
		for( int i = 0; i < MAX_WAYPOINTS; i ++ )
		{
			if ( (m_Waypoints[i].m_iFlags & W_FL_DELETED) == W_FL_DELETED )
				return int(i);
		}

		if ( m_iNumWaypoints < MAX_WAYPOINTS )
			return m_iNumWaypoints;

		return -1;
	}

	void WaypointInfo ( CBasePlayer@ player )
	{
		int index = getNearestWaypointIndex(player.pev.origin,player,-1,128);

		if ( index != -1 ) 
		{
			CWaypoint@ wpt = m_Waypoints[index];

			string info = g_WaypointTypes.getInfo(player,wpt.m_iFlags);

			SayMessage(player,"ID = " + index + " FLAGS = " + info);
		}
	}

	int getNearestFlaggedWaypoint ( Vector vOrigin, int iFlags, CFailedWaypointsList@ failed = null, CBeliefWaypointsList@ belief = null )
	{
		int iIndex = -1;
		float min_distance = 0;

		if ( m_FlaggedLookup.length() == 0 )
			return -1;

		//BotMessage("Length = " + m_FlaggedLookup.length() + "\n");

		for( uint x = 0; x < 32; x ++ )
		{
			if ( iFlags & (1<<x) == (1<<x) )
			{
				//BotMessage("Length = " + m_FlaggedLookup[x].length() + "\n");

				for ( uint j = 0; j < m_FlaggedLookup[x].length(); j ++ )
				{
					int i = m_FlaggedLookup[x][j];

					//UTIL_DebugMsg(null,"Got Wpt",0);

					if ( m_Waypoints[i].m_iFlags & W_FL_DELETED == W_FL_DELETED )
						continue;	

					if ( m_Waypoints[i].m_iFlags & iFlags == iFlags )
					{
						if ( failed !is null && failed.contains(i) )
							continue;

						float distance = m_Waypoints[i].distanceFrom(vOrigin);

						if ( belief !is null )
						{
							distance += belief.getBeliefCost(i);
						}

						if ( iIndex == -1 || distance < min_distance )
						{
							min_distance = distance;
							iIndex = i;
						}
					}				
				}
			}
		}

		/*for( int i = 0; i < m_iNumWaypoints; i ++ )
		{
			if ( m_Waypoints[i].m_iFlags & W_FL_DELETED == W_FL_DELETED )
				continue;	

			if ( m_Waypoints[i].m_iFlags & iFlags == iFlags )
			{
				if ( failed !is null && failed.contains(i) )
					continue;

				float distance = m_Waypoints[i].distanceFrom(vOrigin);

				if ( belief !is null )
				{
					distance += belief.getBeliefCost(i);
				}

				if ( iIndex == -1 || distance < min_distance )
				{
					min_distance = distance;
					iIndex = i;
				}
			}
		}*/
		
		return iIndex;
	}
/*
	int getRandomFlaggedWaypointNearestGoal ( int iFlags, CFailedWaypointsList@ failed = null, Vector vGoal )
	{
		array<int> wpts;
		
		for( int i = 0; i < m_iNumWaypoints; i ++ )
		{
			if ( m_Waypoints[i].m_iFlags & W_FL_DELETED == W_FL_DELETED )
				continue;	

			if ( failed.contains(i) )
				continue;

			if ( m_Waypoints[i].m_iFlags & iFlags == iFlags )
			{
				wpts.insertLast(i);
			}
		}
		
		if ( wpts.length() == 0 )
			return -1;

		return wpts[Math.RandomLong( 0, wpts.length()-1 )];
	}	
	*/
	int getRandomFlaggedWaypoint ( int iFlags, CFailedWaypointsList@ failed = null, CBeliefWaypointsList@ fBelief = null )
	{
		RCBotWaypointBeliefSorter@ wpts = RCBotWaypointBeliefSorter();

		// not initialised yet or waypoints not yet loaded
		if ( m_FlaggedLookup.length() == 0 )
			return -1;

		for( uint x = 0; x < 32; x ++ )
		{
			if ( iFlags & (1<<x) == (1<<x) )
			{
				for ( uint j = 0; j < m_FlaggedLookup[x].length(); j ++ )
				{
					int i = m_FlaggedLookup[x][j];

					CWaypoint@ pWpt;
					
					@pWpt = m_Waypoints[i];

					if ( pWpt.m_iFlags & W_FL_DELETED == W_FL_DELETED )
						continue;	

					if ( pWpt.m_iFlags & iFlags == iFlags )
					{
						if ( failed !is null && failed.contains(i) )
							continue;

						wpts.add(i,fBelief.getBelief(i));
						//wpts.insertLast(i);
					}					
				}
			}

		}

		/*		
		
		for( int i = 0; i < m_iNumWaypoints; i ++ )
		{
			CWaypoint@ pWpt = m_Waypoints[i];

			if ( pWpt.m_iFlags & W_FL_DELETED == W_FL_DELETED )
				continue;	

			if ( pWpt.m_iFlags & iFlags == iFlags )
			{
				if ( failed !is null && failed.contains(i) )
					continue;

				wpts.add(i,fBelief.getBelief(i));
				//wpts.insertLast(i);
			}
		}*/
		
//		if ( wpts.m_pWaypoints.length() == 0 )
///			return -1;

		return wpts.getRandomWptIndex();
	///	return wpts[Math.RandomLong( 0, wpts.length()-1 )];
	}

	void PathWaypoint_RemovePathsFrom ( int wpt )
	{
		CWaypoint@ pWpt = m_Waypoints[wpt];

		pWpt.removePaths();	
	}

	void PathWaypoint_RemovePathsTo ( int wpt )
	{
		for ( int i = 0; i < m_iNumWaypoints; i ++ )
		{
			CWaypoint@ pWpt = m_Waypoints[i];

			pWpt.removePath(wpt);
		}
	}

	int getNearestWaypointIndex ( Vector vecLocation, CBaseEntity@ player = null, int iIgnore = -1, float minDistance = 512.0f, bool bCheckVisible = true, bool bIgnoreUnreachable = true )
	{
		int nearestWptIdx = -1;
		float distance = 0;

		for( int i = 0; i < m_iNumWaypoints; i ++ )
		{
			if ( i == iIgnore )
				continue;

			if ( m_Waypoints[i].hasFlags(W_FL_DELETED) )
				continue;					

			if ( !bIgnoreUnreachable )
			{
				if ( m_Waypoints[i].hasFlags(W_FL_UNREACHABLE) )
					continue;
				if ( m_Waypoints[i].hasFlags(W_FL_LADDER) )
					continue;
				if ( m_Waypoints[i].hasFlags(W_FL_JUMP) )
					continue;
				if ( m_Waypoints[i].hasFlags(W_FL_HUMAN_TOWER) )
					continue;
				if ( m_Waypoints[i].hasFlags(W_FL_TELEPORT) )
					continue;					
			}

			distance = m_Waypoints[i].distanceFrom(vecLocation);
			
			if ( distance < minDistance )
			{
				if ( !bCheckVisible || UTIL_IsVisible(vecLocation,m_Waypoints[i].m_vOrigin,player) )
				{
					minDistance = distance;
					nearestWptIdx = i;
				}
			}
		}
		
		return nearestWptIdx;
	}

	void deleteWaypoint ( int idx )
	{		
		for ( int i = 0; i < m_iNumWaypoints; i ++ )
		{
			CWaypoint@ pWpt = m_Waypoints[i];

			for ( uint j = 0; j < pWpt.m_PathsFrom.length(); j ++ )
			{
				if ( pWpt.m_PathsFrom[j] == idx )
				{
					pWpt.m_PathsFrom.removeAt(j);
					break;
				}
			}

			for ( uint j = 0; j < pWpt.m_PathsTo.length(); j ++ )
			{
				if ( pWpt.m_PathsTo[j] == idx )
				{
					pWpt.m_PathsTo.removeAt(j);
					break;
				}
			}
		}

		if ( m_iNumWaypoints > 0 )
		{
			CWaypoint@ pDelete = g_Waypoints.getWaypointAtIndex(idx);

			pDelete.Delete();

			if ( idx == m_iNumWaypoints )
				m_iNumWaypoints--;
		}
	}

	void ClearWaypoints ()
	{
		for( uint i = 0; i < MAX_WAYPOINTS; i ++ )
		{
			m_Waypoints[i].Clear();
		}
		m_iNumWaypoints = 0 ;
		m_PathFrom = -1;
		@m_VisibilityTable = null;
	}

	bool Load ()
	{
		bool ret = false;
		string filename = g_Engine.mapname;
		
		File@ f;

		// clear the auto waypointer
		@autoWaypointer = null;

		filename += ".rcwa";		

		ClearWaypoints();

		// read waypoint objective script
		g_WaypointScripts.Read();

		// try to open custom waypoint first		
		@f  = g_FileSystem.OpenFile( "scripts/plugins/store/" + filename , OpenFile::READ);

		// no custom waypoint exists
		if ( @f is null )
		{
			// open default waypoint 
			@f = g_FileSystem.OpenFile( "scripts/plugins/BotManager/rcw/" + filename , OpenFile::READ);
		}

		// Open the file in 'read' mode
		if( f !is null ) 
		{
			FileBuffer buf(f);
			// Read the whole file into the string buffer

			ClearWaypoints();

			int index = 0;

			CWaypointHeader@ hdr = CWaypointHeader();

			if ( !hdr.Read(buf) )
			{
				f.Close();
				BotMessage("WAYPOINT FILE CORRUPT");
				return false;
			}

			// reinitialise lookup
			m_FlaggedLookup = array<array<int>>();
			// lookup up to 32 waypoint types
			m_FlaggedLookup.resize(32);
			// initialise all to empty array
			for ( int i = 0; i < 32; i ++ )
			{
				m_FlaggedLookup[i] = array<int>();
			}

			BotMessage("Waypoint Header : " + hdr.number_of_waypoints + "\n");

			//if ( hdr !is null )
			//	return false;

			for ( int i = 0; i < hdr.number_of_waypoints ; i ++ )
			{
				if ( !m_Waypoints[i].Read(buf,i) )
				{
				//	BotMessage("WAYPOINT " + i + " CORRUPT!");
					return false;
				}
				// check any waypoint types this waypoint has
				// and add to lookup
				for ( int j = 0; j < 32; j ++ )
				{
					if ( m_Waypoints[i].m_iFlags & (1<<j) == (1<<j) )
					{
						//BotMessage("ADDING ONE TO " + j + "\n");
						m_FlaggedLookup[j].push_back(i);
					}
				}
			}

			BotMessage("Num Waypoints = " + hdr.number_of_waypoints);
			m_iNumWaypoints = hdr.number_of_waypoints;

			@m_VisibilityTable = CWaypointVisibility(m_iNumWaypoints);

			f.Close();
		}
		else
			BotMessage("Waypoint " + filename + " not found \n");

		return ret;
	}

	void ConvertFlagsToOther ( int iFlagsFrom, int iFlagsTo )
	{
		for ( int i = 0; i < m_iNumWaypoints; i ++ )
		{
			CWaypoint@ wpt = m_Waypoints[i];

			if ( wpt.isDeleted() )
				continue;

			if ( wpt.hasFlags(iFlagsFrom) )
			{
				wpt.m_iFlags &= ~iFlagsFrom;
				wpt.m_iFlags |= iFlagsTo;
			}
		}
	}

	bool Save ()
	{
		bool ret = false;
		string filename = "scripts/plugins/store/" + g_Engine.mapname + ".rcwa";
		File@ f = g_FileSystem.OpenFile( filename, OpenFile::WRITE);
		// Open the file in 'read' mode
		if( f !is null ) 
		{
			CWaypointHeader@ hdr = CWaypointHeader();

			FileBuffer buf;

			hdr.Save(buf);			

			for ( int i = 0; i < m_iNumWaypoints; i ++ )
			{
				m_Waypoints[i].Save(buf);
			}

			f.Write(buf.getData());

			f.Close();
		}
		else
			BotMessage("F is null!\n");

		return ret;
	}

	void AutoWaypoint ( CBasePlayer@ player )
	{
		if ( player !is null )
			@autoWaypointer = AutoWaypointer(player);
		else 
			@autoWaypointer = null;
	}

	void Think ( )
	{
		if ( m_VisibilityTable !is null )
		{
			m_VisibilityTable.run();
		}

		if ( autoWaypointer !is null )
		{
			autoWaypointer.Think();
		}
	}

	
}

class RCBotWaypointBeliefSorter
{
	void add ( int index, uint8 belief )
	{
		int iInsertInto = m_pWaypoints.length();
		CWaypoint@ other = g_Waypoints.getWaypointAtIndex(index);

		for ( uint i = 0; i < m_pWaypoints.length(); i ++ )
		{
			if ( belief < m_belief[i] )
			{
				iInsertInto = i;
				break;
			}
		}

		m_pWaypoints.insertAt(iInsertInto,other);
		m_belief.insertAt(iInsertInto,belief);
	}

	int length ()
	{
		return m_pWaypoints.length();
	}

	CWaypoint@ getRandomWpt ()
	{
		int index = getRandomWptIndex();
		CWaypoint@ ret = null;

		if ( index >= 0 )
		{
			@ret = m_pWaypoints[index];
		}

		return ret;
	}

	int ceil(float &in x)  
	{ 
		int y = int(x); 
		return (y==x?y:y+1); 
	}

	int getRandomWptIndex ()
	{
		int index = -1;

		if ( m_pWaypoints.length() > 0 )
		{		
			if ( m_pUseBelief.GetBool() )
			{
				// roulette method
				uint sum = 0;
				uint rnd = 0;
				
				for ( uint i = 0; i < m_belief.length(); i ++ )
				{
					sum += m_belief[i];
				}

				rnd = Math.RandomLong(0,sum);

				sum = 0;

				for ( uint i = 0; i < m_belief.length(); i ++ )
				{					
					sum += m_belief[i];

					if ( rnd <= sum )
					{
						index = m_pWaypoints[i].iIndex;

						UTIL_DebugMsg(null,"RCBotWaypointBeliefSorter Chose Waypoint " + index + " ("+i+")",DEBUG_NAV);

						break;
					}
				}
			}
			else
			{
				index = m_pWaypoints[Math.RandomLong(0,m_pWaypoints.length()-1)].iIndex;
			}			
		}

		return index;		
	}

	array<CWaypoint@> m_pWaypoints;
	array<uint8> m_belief;
}

class RCBotWaypointSorter
{
	void add ( int index, Vector vHideFrom )
	{
		int iInsertInto = m_pWaypoints.length();
		CWaypoint@ other = g_Waypoints.getWaypointAtIndex(index);

		for ( uint i = 0; i < m_pWaypoints.length(); i ++ )
		{
			CWaypoint@ inList = m_pWaypoints[i];

			if ( other.distanceFrom(vHideFrom) > inList.distanceFrom(vHideFrom) )
			{
				iInsertInto = i;
				break;
			}
		}

		m_pWaypoints.insertAt(iInsertInto,other);
	}

	array<CWaypoint@> m_pWaypoints;

}

final class RCBotCoverWaypointFinder
{
	/** Starting waypoint */
	int iStart;
	/** Maximum search depth */
	int iDepth = 0;
	/** vector to hide from */
	Vector vHideFrom;
	/** Maximum search depth */
	int iMaxDepth = 12;
	/** waypoint index to hide from */
	int iHideFrom;
	/** waypoints already searched */
	CBits@ closedWaypoints;
	CWaypointVisibility@ m_visibility;
	RCBot@ m_pBot;
	int state;
	int m_iGoalWaypoint;

	RCBotCoverWaypointFinder ( CWaypointVisibility@ visibility, RCBot@ bot, Vector vHideFrom ) 
	{
		if ( visibility is null )
		{
			state = NavigatorState_Fail;
			return;
		}

		@m_pBot = bot;
		
		iStart = g_Waypoints.getNearestWaypointIndex(bot.origin(),bot.m_pPlayer,bot.m_iLastFailedWaypoint,400.0f);

		iHideFrom = g_Waypoints.getNearestWaypointIndex(vHideFrom,null,-1,128.0f);

		if ( iHideFrom != -1 || iStart == -1 )
		{
			state = NavigatorState_InProgress;

			@m_visibility = visibility;

			@closedWaypoints = CBits(MAX_WAYPOINTS);
		}
		else
			state = NavigatorState_Fail;
	}

	/**
	 * FindCover
	 *
	 * Recursive function
	 */
	int FindCover ( int iWaypoint )
	{
		// failed before we started
		if ( state == NavigatorState_Fail )
			return -1;

		iDepth++;

		if ( iDepth > iMaxDepth )
			return -1;

		if (m_visibility.VisibleFromTo(iHideFrom,iWaypoint) == false )
			return iWaypoint;
		else
		{
			CWaypoint@ wpt = g_Waypoints.getWaypointAtIndex(iWaypoint);
			closedWaypoints.setBit(iWaypoint,true);

			RCBotWaypointSorter@ paths = RCBotWaypointSorter();

			for ( int i = 0; i < wpt.numPaths(); i ++ )
			{			
				int iWptIndex = wpt.getPath(i);

				if ( closedWaypoints.getBit(iWptIndex) == false )
				{
					paths.add(iWptIndex,vHideFrom);		
				}
			}

			for ( uint i = 0; i < paths.m_pWaypoints.length(); i ++ )
			{
				CWaypoint@ pWpt = paths.m_pWaypoints[i];

				int iWptIndex = pWpt.iIndex;

				if ( m_pBot.canGotoWaypoint(wpt,pWpt) )
				{

					if ( FindCover(iWptIndex) == iWptIndex )
					{
						return iWptIndex;
					}

				}			
			}
		}
	
		return -1;
	}

	bool execute ( )
	{
		//UTIL_DebugMsg(m_pBot.m_pPlayer,"FINDING COVER!!!!",DEBUG_NAV);
		//BotMessage("FINDING COVER");
		m_iGoalWaypoint = FindCover(iStart);

		return m_iGoalWaypoint != -1;
	}

}

class CBeliefWaypointsList
{
	void danger (int index, Vector location, uint8 amount = 10 )
	{
		//BotMessage("danger index = " + index + " , amount = " + amount);

		if ( isValid(index) )
		{
			if ( location != Vector(0,0,0) )
			{
				if ( amount > m_fBelief[index] ) // update danger location
					m_vDangerVector[index] = location;
			}

			if ( m_fBelief[index] < (255 - amount) )
				m_fBelief[index] += amount;
			else
				m_fBelief[index] = 255; // cap at 255
		}		
	}

	bool isValid ( int index )
	{
		return  ( index >= 0 && index < MAX_WAYPOINTS );
	}

	bool isDangerLocationValid (int index)
	{
			return m_vDangerVector[index] != Vector(0,0,0);
	}

	bool isDangerous ( int index )
	{
		return m_fBelief[index] > 5;
	}

	Vector DangerLocation ( int index )
	{
		return m_vDangerVector[index];
	}

	void safety( int index, uint8 amount = 10 )
	{
		if ( isValid(index) )
		{
			if ( m_fBelief[index] > amount )
				m_fBelief[index] -= amount;
			else // cap to zero
				m_fBelief[index]  = 0;
		}
	}

	float getBeliefPercent (int index )
	{
		return float(getBelief(index))/255;
	}

	uint8 getBelief ( int index )
	{
		return m_fBelief[index];
	}

	float getBeliefCost ( int index )
	{
		return getBeliefPercent(index) * m_pBeliefMultiplier.GetFloat();
	}

	array<uint8> m_fBelief = array<uint8>(MAX_WAYPOINTS);
	array<Vector> m_vDangerVector = array<Vector>(MAX_WAYPOINTS);
	
}

class CFailedWaypointsList
{
    void add ( int iwpt )
    {
        if ( !contains(iwpt) )
            list.insertLast(iwpt);
    }

    bool contains ( int iwpt )
    {
        return list.find(iwpt) >= 0;
    }

	void remove ( int iwpt )
	{
		int idx = list.find(iwpt);

		if ( idx >= 0 )
			list.removeAt(idx);
	}

    void clear ()
    {
        list = {};
    }
	
    array<int> list;
}

const int NavigatorState_Complete = 0;
const int NavigatorState_InProgress = 1;
const int NavigatorState_Fail = 2;
const int NavigatorState_ReachedGoal = 3;
const int NavigatorState_FoundGoal = 4;
const int NavigatorState_Following = 5;

// ------------------------------------
// NAVIGATOR - 	START (WIP)
// ------------------------------------
final class RCBotNavigator 
{
	int state;

	int iStart;
	int iGoal;

	EHandle m_pTarget;

	int iMaxLoops = 200;
	int iLastNode;

	float m_fNextTimeout;

	int m_iCurrentWaypoint = -1;
	int m_iPreviousWaypoint = -1;

	array<AStarNode> paths(MAX_WAYPOINTS);
	AStarNode@ curr;

	CWaypoint@ pStartWpt;
	CWaypoint@ pGoalWpt;

	float m_fNextCheckVisible = 0.0;
	float m_fLastSeeWaypoint = 0.0;
	float m_fPreviousDistance = 9999;

	AStarOpenList m_theOpenList;

	void open ( AStarNode@ pNode )
	{
		if ( pNode.isOpen() == false )
		{
			pNode.open();
			//m_theOpenList.push_back(pNode);
			m_theOpenList.add(pNode);
		}
	}

	// AStar Algorithm : get the waypoint with lowest cost
	AStarNode@ nextNode ()
	{
		AStarNode@ pNode = null;

		@pNode = m_theOpenList.top();
		m_theOpenList.pop();
			
		return pNode;
	}

	RCBotNavigator ( RCBot@ bot , int iGoalWpt, CBaseEntity@ pTarget = null )
	{
		m_pTarget = pTarget;
		bot.m_iPreviousWaypoint = m_iPreviousWaypoint = bot.m_iCurrentWaypoint = m_iCurrentWaypoint = iStart = g_Waypoints.getNearestWaypointIndex(bot.m_pPlayer.pev.origin, bot.m_pPlayer,bot.m_iLastFailedWaypoint,512.0f,true,false);

		UTIL_DebugMsg(bot.m_pPlayer,"m_iCurrentWaypoint == " + m_iCurrentWaypoint,DEBUG_NAV);
		m_fNextTimeout = 0;

		if ( iStart == -1 || iGoalWpt == -1 )
		{
			UTIL_DebugMsg(bot.m_pPlayer,"iStart == -1 OR iGOAL == -1 (FAIL)",DEBUG_NAV);
			state = NavigatorState_Fail;
		}
		else
		{
			state = NavigatorState_InProgress;
			@curr = paths[iStart];
			curr.setWaypoint(iStart);
			@pStartWpt = g_Waypoints.getWaypointAtIndex(iStart);
			iGoal = iGoalWpt;
			@pGoalWpt = g_Waypoints.getWaypointAtIndex(iGoal);

			curr.setHeuristic(0);
			open(curr);
			iLastNode = iStart;
		}
	}	

	float m_fExecutionTime = 0.0f;

	void execute ( RCBot@ bot )
	{		
		// whenever we touch a waypoint or execution is paused
		// the timeout is reset
		if ( m_fExecutionTime < g_Engine.time )
		{
			UTIL_DebugMsg(bot.m_pPlayer,"m_fExecutionTime < g_Engine.time",DEBUG_NAV);
			m_fNextTimeout = g_Engine.time + 10.0f;
		}

		if ( m_fNextTimeout < g_Engine.time )
		{
			UTIL_DebugMsg(bot.m_pPlayer,"m_fNextTimeout < g_Engine.time",DEBUG_NAV);
			bot.m_iLastFailedWaypoint = m_iCurrentWaypoint;
			state = NavigatorState_Fail;
			return;
		}
	
		if ( m_currentRoute.length () == 0 )
		{			
			UTIL_DebugMsg(bot.m_pPlayer,"m_currentRoute.length () == 0",DEBUG_NAV);
			state = NavigatorState_Fail;
			return;
		}

		if ( m_iCurrentWaypoint != m_currentRoute[0] )
		{
			bot.m_iPreviousWaypoint  = m_iPreviousWaypoint = m_iCurrentWaypoint;
			
		}

		bot.m_iCurrentWaypoint = m_iCurrentWaypoint = m_currentRoute[0];

		CWaypoint@ wpt = g_Waypoints.getWaypointAtIndex(m_iCurrentWaypoint);

		float distance = (wpt.m_vOrigin - bot.origin()).Length();

		if ( m_pTarget.GetEntity() !is null )
		{
			CBaseEntity@ pTarget = m_pTarget.GetEntity();

			Vector vTarget = UTIL_EntityOrigin(pTarget);

			if ( bot.distanceFrom(vTarget) < bot.distanceFrom(wpt.m_vOrigin) )	
			{
				// Bot is closer to moving target than waypoint
				// and moving target is visible (i.e. not through a wall)
				// Goal reached!!
				if ( UTIL_IsVisible(vTarget,bot.m_pPlayer.EyePosition(),bot.m_pPlayer) )
				{
					state = NavigatorState_ReachedGoal;			
					UTIL_DebugMsg(bot.m_pPlayer,"bot reached target entity",DEBUG_NAV);			
					return;
				}
			}
		}

		float touch_distance = 64;

		bool bTouchedWpt = false;

		if ( bot.m_flJumpPlatformTime > g_Engine.time )
		{
			if ( wpt.hasFlags(W_FL_PLATFORM) )
			{
				if ( bot.m_pPlayer.pev.groundentity !is null )
				{
					if ( g_EntityFuncs.Instance(bot.m_pPlayer.pev.groundentity) is bot.m_pExpectedPlatform )
					{
						bot.m_flJumpPlatformTime = 0;
						// we're on a platform
						bTouchedWpt = true;
					}
				}
			}
		}
		else if ( wpt.hasFlags(W_FL_CROUCH) )
			touch_distance = 32;
		else if ( wpt.hasFlags(W_FL_JUMP))
			touch_distance = 32;
		else if ( wpt.hasFlags(W_FL_STAY_NEAR)  )
			touch_distance = 32;
		else if ( wpt.hasFlags(W_FL_LADDER) || bot.m_pPlayer.pev.movetype == MOVETYPE_FLY )
		{
			float length2d = (wpt.m_vOrigin - bot.m_pPlayer.pev.origin).Length2D();
			float zdiff = abs(wpt.m_vOrigin.z - bot.m_pPlayer.pev.origin.z);
			UTIL_DebugMsg(bot.m_pPlayer,"Length2d is " + length2d + " zdiff is " + zdiff,DEBUG_NAV);
			bTouchedWpt = (length2d < 16) && (zdiff < 16);
		}

		//BotMessage("Current = " + m_iCurrentWaypoint + " , Dist = " + distance);

		if ( bTouchedWpt || (distance < touch_distance) || (distance > (m_fPreviousDistance+(touch_distance*2))) )
		{
			CWaypoint@ pNextWpt = null;
			CWaypoint@ pThirdWpt = null;

			int iTimesToPop = 0;

			// touched waypoint
			if ( bot.m_pEnemy.GetEntity() !is null ) // enemy, slow increase belief	
			{		
				Vector enemyOrigin = UTIL_EntityOrigin(bot.m_pEnemy.GetEntity());

				bot.m_fBelief.danger(m_iCurrentWaypoint,enemyOrigin,3.0f);			
				//UTIL_DebugMsg(bot.m_pPlayer,"Danger added to current waypoint",DEBUG_BELIEF);
			}
			else // no enemy, slow decrease belief
			{
				bot.m_fBelief.safety(m_iCurrentWaypoint,1.0f);
				//UTIL_DebugMsg(bot.m_pPlayer,"Safety added to current waypoint",DEBUG_BELIEF);
			}

			if ( m_currentRoute.length() > 1 )
			{
				//BotMessage("m_currentRoute.length() > 1");
				@pNextWpt = g_Waypoints.getWaypointAtIndex(m_currentRoute[1]);
			}
			if ( m_currentRoute.length() > 2 )
				@pThirdWpt = g_Waypoints.getWaypointAtIndex(m_currentRoute[2]);

			iTimesToPop = bot.touchedWpt(wpt,pNextWpt,pThirdWpt);

			m_fNextTimeout = g_Engine.time + 10.0f;

			while ( (m_currentRoute.length()) > 0 && (iTimesToPop > 0) )
			{
				m_currentRoute.removeAt(0);
				iTimesToPop--;
			}

			m_fPreviousDistance = 9999.0;

			m_fLastSeeWaypoint = g_Engine.time;

			if ( m_currentRoute.length () == 0 )
			{
				state = NavigatorState_ReachedGoal;			
				UTIL_DebugMsg(bot.m_pPlayer,"m_currentRoute.length () == 0 ",DEBUG_NAV);			
				return;
			}
		}
		else
		{
			//BotMessage("FOLLOWING");
			bot.followingWpt(wpt.m_vOrigin,wpt.m_iFlags);
			m_fPreviousDistance = distance;

			if ( m_fNextCheckVisible < g_Engine.time )
			{
				float fSeeWaypointFailTime = 3.0f;

				if ( wpt.hasFlags(W_FL_LADDER) )
					fSeeWaypointFailTime += 7.0f;

				m_fNextCheckVisible = g_Engine.time + 1.0;

        		TraceResult tr;

		        g_Utility.TraceLine( bot.m_pPlayer.pev.origin + bot.m_pPlayer.pev.view_ofs, wpt.m_vOrigin, ignore_monsters,dont_ignore_glass, bot.m_pPlayer.edict(), tr );

				if ( tr.flFraction >= 1.0 )				
					m_fLastSeeWaypoint = g_Engine.time;
				else if ( m_fLastSeeWaypoint > 0 && ((g_Engine.time - m_fLastSeeWaypoint) > fSeeWaypointFailTime) )
				{
					UTIL_DebugMsg(bot.m_pPlayer,"BotNavigator FAIL",DEBUG_NAV);
					m_fLastSeeWaypoint = 0;
					// Fail
					state = NavigatorState_Fail;
					return;
				}
				else
				{
					// an entity is blocking the way
					if ( tr.pHit !is null )
					{						
						CBaseEntity@ pent = g_EntityFuncs.Instance(tr.pHit);
						CBaseToggle@ pDoor = null;

						bot.setBlockingEntity(pent);

						if ( pent !is null )
						{
							@pDoor = cast<CBaseToggle@>(pent);
						}

						if ( pDoor !is null )
						{
							UTIL_DebugMsg(bot.m_pPlayer,"pDoor !is null ",DEBUG_NAV);

							bool bUse = true;

							if ( pDoor.pev.targetname != "" )
							{
								//UTIL_DebugMsg(bot.m_pPlayer,"pDoor !is null ",DEBUG_NAV);
								//BotMessage("pDoor.pev.targetname != \"\" ");
								// It has a button ?
								CBaseEntity@ pButton = UTIL_FindButton(pDoor,bot.m_pPlayer);

								UTIL_DebugMsg(bot.m_pPlayer,"UTIL_FindButton()",DEBUG_NAV);

								if ( pButton !is null )
								{								
									UTIL_DebugMsg(bot.m_pPlayer,"pButton !is null",DEBUG_NAV);

									bot.pressButton(pButton,m_iCurrentWaypoint,true);
									bUse = false;
								}
						
							}
							
							
							if ( bUse )
							{					
								if ( Math.RandomLong(0,100) < 90 )
									bot.PressButton(IN_USE);
							}
						}
					}
					else
						bot.setBlockingEntity(null);
				}
			}
		}	

		m_fExecutionTime = g_Engine.time + 0.5f;

		return;
	}

	int iCurrentNode = -1;

	array<int> m_currentRoute = {};

	// run navigator tasks
	int run (RCBot@ bot)
	{		
		switch ( state )
		{
			case NavigatorState_InProgress:
			{
				int iLoops = 0;
				int iPath;

				iMaxLoops = m_pNavRevs.GetInt();

//BotMessage("Navigator State IN_PROGRESS...\n");

				while ( state == NavigatorState_InProgress )
				{
					iLoops++;


					if ( m_theOpenList.empty() )
					{
						//BotMessage("EMPTY OPEN LIST");
						state = NavigatorState_Fail;
						break;
					}							

					@curr = nextNode();


					if ( @curr is null )
					{
						//BotMessage("CURR NULL");
						state = NavigatorState_Fail;
						break;
					}

					if ( iLoops > iMaxLoops )
						break;


					if ( curr.getWaypoint() == iGoal )
					{
						state = NavigatorState_FoundGoal;
						break;
					}

					CWaypoint@ currWpt = g_Waypoints.getWaypointAtIndex(curr.getWaypoint());
					CWaypoint@ succWpt;
					AStarNode@ succ;

					iCurrentNode = curr.getWaypoint();
					int iMaxPaths = currWpt.numPaths();

					float fEnemyCost = 0;
					
					if ( m_pExperimental.GetBool() )
						fEnemyCost = bot.getEnemyDanger(currWpt.m_vOrigin);

					for ( iPath = 0; iPath < iMaxPaths; iPath ++ )
					{
						int iSucc = currWpt.getPath(iPath);

					//	BotMessage("PATH FROM " + iCurrentNode + " TO " + iSucc);
						
						if ( iSucc == iLastNode ) // argh?
							continue;
						if ( iSucc == iCurrentNode ) // argh?
							continue;										

						/*(if ( m_lastFailedPath.bValid )
						{
							if ( m_lastFailedPath.iFrom == iCurrentNode ) 
							{
								// failed this path last time
								if ( m_lastFailedPath.iTo == iSucc )
								{
									m_lastFailedPath.bSkipped = true;
									continue;
								}
							}
						}*/

						@succ = @paths[iSucc];
						@succWpt = g_Waypoints.getWaypointAtIndex(iSucc);

						if ( !bot.canGotoWaypoint(currWpt,succWpt) )
							continue;

						float fCost = curr.getCost();

						if ( m_pUseBelief.GetBool() )
						{
							fCost += bot.m_fBelief.getBeliefCost(iCurrentNode);		

							fCost += fEnemyCost;
						}	
						if ( currWpt.m_iFlags != 0 ) // add cost to any flagged waypoint
							fCost += 48.0f;					

						if ( !currWpt.hasFlags(W_FL_TELEPORT) && !succWpt.hasFlags(W_FL_TELEPORT) )								
							fCost += (succWpt.distanceFrom(currWpt.m_vOrigin));
						// add extra cost to human tower waypoints
						if ( currWpt.hasFlags(W_FL_HUMAN_TOWER) )
							fCost += 512.0f;
						
						if ( succWpt.m_vOrigin.z < currWpt.m_vOrigin.z )
						{
							if ( bot.HealthPercent() > 0 )
							{
								// add extra cost to high heights
								fCost += (succWpt.m_vOrigin.z - currWpt.m_vOrigin.z) / bot.HealthPercent();
							}
						}

						if ( succ.isOpen() || succ.isClosed() )
						{
							if ( succ.getParent() != -1 )
							{
								if ( fCost >= succ.getCost() )
									continue; // ignore route
							}
							else
								continue;
						}

						succ.unClose();

						succ.setParent(iCurrentNode);
						//BotMessage("Succ " + iSucc + " parent = " + iCurrentNode);

						succ.setCost(fCost);	

						succ.setWaypoint(iSucc);

						if ( succ.heuristicSet() == false )		
						{
							float h = pStartWpt.distanceFrom(succWpt.m_vOrigin) + pGoalWpt.distanceFrom(succWpt.m_vOrigin);

							succ.setHeuristic(h);
						}

						// Fix: do this AFTER setting heuristic and cost!!!!
						if ( succ.isOpen() == false )
						{
							open(succ);
						}

					}

					curr.close(); // close chosen node

					iLastNode = iCurrentNode;				
				}	
			}		
			break;
			case NavigatorState_FoundGoal:
			{
					int iLoops = 0;

					float fDistance = 0.0;
					int iParent;

					m_fNextTimeout = g_Engine.time + 5.0;

					iCurrentNode = iGoal;

					while ( (iCurrentNode != -1) && (iCurrentNode != m_iCurrentWaypoint ) && (iLoops <= g_Waypoints.m_iNumWaypoints) )
					{
						iLoops++;

						m_currentRoute.insertAt(0,iCurrentNode);

						iParent = paths[iCurrentNode].getParent();

						iCurrentNode = iParent;
					}

					if ( iLoops < g_Waypoints.m_iNumWaypoints )
					{

						m_currentRoute.insertAt(0,m_iCurrentWaypoint);

						if ( m_currentRoute.length () > 0 )
						{
							bot.m_iCurrentWaypoint = m_iCurrentWaypoint = m_currentRoute[0];

							state = NavigatorState_Following;

							UTIL_DebugMsg(bot.m_pPlayer,"Navigator State FOUND_GOAL...\n",DEBUG_NAV);
						}
						else
						{
							state = NavigatorState_Fail;
							break;
						}

					}
					else
					{
						state = NavigatorState_Fail;
					}

			}
			break;
			default:

				//BotMessage("Current Waypoint =	 " +  m_iCurrentWaypoint + " - goal =  " + iGoal+"");
			break;
		}

		return state;
	}
}
// ------------------------------------
// NAVIGATOR - 	END
// ------------------------------------
const int FL_ASTAR_CLOSED 	= 1;
const int FL_ASTAR_PARENT 	= 2;
const int FL_ASTAR_OPEN	 	= 4;
const int FL_HEURISTIC_SET 	= 8;

class AStarNode
{
	AStarNode() { m_fCost = 0; m_fHeuristic = 0; m_iFlags = 0; m_iParent = -1; m_iWaypoint = -1; }
	///////////////////////////////////////////////////////
	void close () { setFlag(FL_ASTAR_CLOSED); }
	void unClose () { removeFlag(FL_ASTAR_CLOSED); }
	bool isOpen () { return hasFlag(FL_ASTAR_OPEN); }
	void unOpen () { removeFlag(FL_ASTAR_OPEN); }
	bool isClosed () { return hasFlag(FL_ASTAR_CLOSED); }
	void open () { setFlag(FL_ASTAR_OPEN); }
	//////////////////////////////////////////////////////	
	void setHeuristic ( float fHeuristic ) { m_fHeuristic = fHeuristic; setFlag(FL_HEURISTIC_SET); }
	bool heuristicSet () { return hasFlag(FL_HEURISTIC_SET); }
	float getHeuristic () { return m_fHeuristic; } 

	////////////////////////////////////////////////////////
	void setFlag ( int iFlag ) { m_iFlags |= iFlag; }
	bool hasFlag ( int iFlag ) { return ((m_iFlags & iFlag) == iFlag); }
	void removeFlag ( int iFlag ) { m_iFlags &= ~iFlag; }
	/////////////////////////////////////////////////////////
	int getParent () { if ( hasFlag(FL_ASTAR_PARENT) ) return m_iParent; else return -1; }
	void setParent ( int iParent ) 
	{ 
		m_iParent = iParent; 

		if ( m_iParent == -1 )
			removeFlag(FL_ASTAR_PARENT); // no parent
		else
			setFlag(FL_ASTAR_PARENT);
	}
	////////////////////////////////////////////////////////
	float getCost () { return m_fCost; }
	void setCost ( float fCost ) { m_fCost = fCost; }
	////////////////////////////////////////////////////////
	// for comparison
	bool precedes ( AStarNode@ other ) const
	{
		return (m_fCost+m_fHeuristic) < (other.getCost() + other.getHeuristic());
	}
	void setWaypoint ( int iWpt ) { m_iWaypoint = iWpt; }
	int getWaypoint () { return m_iWaypoint; }

	private float m_fCost;
	private float m_fHeuristic;
	private int  m_iFlags;
	private int m_iParent;
	private int m_iWaypoint;
};

// Insertion sorted list
final class AStarListNode
{
	AStarListNode ( AStarNode@ data )
	{
		@m_Data = data;
		@m_Next = null;
	}
	AStarNode@ m_Data;
	AStarListNode@ m_Next;
};

final class AStarOpenList
{
	AStarOpenList()
	{
		@m_Head = null;
	}

	bool empty ()
	{
		return (m_Head is null);
	}

	AStarNode@ top ()
	{
		if ( m_Head is null )
			return null;
		
		return m_Head.m_Data;
	}

	void pop ()
	{
		if ( m_Head !is null )
		{
			AStarListNode@ t = m_Head;

			@m_Head = m_Head.m_Next;
		}
	}

	void add ( AStarNode@ data )
	{
		AStarListNode@ newNode = AStarListNode(data);
		AStarListNode@ t;
		AStarListNode@ p;

		if ( m_Head is null )
			@m_Head = newNode;
		else
		{
			if ( data.precedes(m_Head.m_Data) )
			{
				@newNode.m_Next = m_Head;
				@m_Head = newNode;
			}
			else
			{
				@p = m_Head;
				@t = m_Head.m_Next;

				while ( t !is null )
				{
					if ( data.precedes(t.m_Data) )
					{
						@p.m_Next = newNode;
						@newNode.m_Next = t;
						break;
					}

					@p = t;
					@t = t.m_Next;
				}

				if ( t is null )
					@p.m_Next = newNode;

			}
		}
	}

	void destroy ()
	{
		AStarListNode@ t;

		while ( m_Head !is null )
		{
			@t = m_Head;
			@m_Head = m_Head.m_Next;
			//delete t;
			@t = null;
		}

		@m_Head = null;
	}
	
	private AStarListNode@ m_Head;
};

const int Run = 0;
const int Jumping = 1;
const int OnLadder = 2;
const int Standing = 3;
const int Swimming = 4;
const int Falling = 5;
const float AutoWaypointTypeDistance = 64.0f;
const float AutoWaypointPathDistance = 200.0f;
const int iLastPositionsMax = 10;
const float RunWaypointCheckTime = 0.33f;

class AutoWaypointer 
{
	float m_fRunCheckTime;
	CBasePlayer@ m_pPlayer;
	CWaypoint@ previousWaypoint;
	array<Vector> vLastPositions;
	int State;
	Vector vJumpWaypointLocation;
	Vector vFallLocation;

	AutoWaypointer ( CBasePlayer@ pPlayer )
	{
		@m_pPlayer = pPlayer;
		@previousWaypoint = null;
		m_fRunCheckTime = 0;
		vLastPositions = array<Vector>();
		State = Standing;
	}

	void CreateWaypoint ( Vector vPosition, float fDistance, int flags, bool singlePath = false )
	{	
		// check for existing waypoint
		int wpt = g_Waypoints.getNearestWaypointIndex(vPosition,m_pPlayer,-1,fDistance,true);

		if ( wpt == -1 )
		{
			// no exisitng waypoint - create one
			if ( m_pPlayer.pev.flags & FL_DUCKING == FL_DUCKING )
				flags |= W_FL_CROUCH; // make sure its a crouch waypoint if crouching

			// add a waypoint - automatic paths at the moment
			wpt = g_Waypoints.addWaypoint(vPosition,flags,m_pPlayer);
			
			// play sound if displaying
			if ( g_Waypoints.g_WaypointsOn )
				g_Waypoints.playsound(m_pPlayer,wpt!=-1);
		}
		
		if ( wpt != -1 )
		{
			// we've got a new current waypoint
			CWaypoint@ currentWaypoint = g_Waypoints.getWaypointAtIndex(wpt);

			// add path from previous waypoint to current waypoint
			if ( previousWaypoint !is null )
			{
				if ( singlePath ) // keep a single path (remove existing) for this waypoint
					currentWaypoint.removePaths();

				previousWaypoint.addPath(wpt);
			}

			@previousWaypoint = currentWaypoint;
			currentWaypoint.addWaypointType(flags);
		}
		else 
			@previousWaypoint = null;
	}

	// if at any point the previous waypoint becomes invisible
	// check intermediate points until both previous and current waypoint position becomes visible.
	void CheckPreviousPoints ()
	{
		TraceResult tr;

		vLastPositions.push_back(m_pPlayer.pev.origin);

		if ( vLastPositions.size() > iLastPositionsMax )
			vLastPositions.removeAt(0);

		if ( previousWaypoint !is null )
		{
			g_Utility.TraceLine( m_pPlayer.pev.origin, previousWaypoint.m_vOrigin, ignore_monsters,dont_ignore_glass, m_pPlayer.edict(), tr );

			if ( tr.flFraction < 1.0 )	
			{
				// find which last point is visible to previous waypoint and current waypoint
				for ( uint i = 0; i < vLastPositions.size(); i ++ )
				{
					TraceResult tr1;
					TraceResult tr2;

					g_Utility.TraceLine( m_pPlayer.pev.origin, vLastPositions[i], ignore_monsters,dont_ignore_glass, m_pPlayer.edict(), tr1 );
					g_Utility.TraceLine( vLastPositions[i], previousWaypoint.m_vOrigin, ignore_monsters,dont_ignore_glass, m_pPlayer.edict(), tr2 );	

					if ( tr1.flFraction >= 1.0 && tr2.flFraction >= 1.0 )
					{
						// Add Waypoint Here
						CreateWaypoint(vLastPositions[i],32.0,0);
						return;
					}
					
				}

				
				// Add Waypoint Here
				CreateWaypoint(m_pPlayer.pev.origin,AutoWaypointTypeDistance,0);

				return;
			}
		}

		m_fRunCheckTime = g_Engine.time + RunWaypointCheckTime;

		if ( @previousWaypoint !is null )
		{
			if ( previousWaypoint.distanceFrom(m_pPlayer.pev.origin) > AutoWaypointPathDistance )
				CreateWaypoint(m_pPlayer.pev.origin,AutoWaypointPathDistance,0);
		}
		// normal shiz
		else 
			CreateWaypoint(m_pPlayer.pev.origin,AutoWaypointPathDistance,0);
	}

	void Think ()
	{
		if ( !m_pPlayer.IsAlive() )
		{
			@previousWaypoint = null;
			m_fRunCheckTime = 0;
			State = Standing;
			vLastPositions = {};
			return;
		}

		if ( previousWaypoint !is null )
		{
			// check previous waypoint is still used
			if ( previousWaypoint.isDeleted() )
				@previousWaypoint = null;
		}

		switch ( State )
		{
		case Swimming:
			if ( m_pPlayer.pev.waterlevel < 3 )
				State = Run;
			else 
			{
				CheckPreviousPoints();
			}
			break;
		case Run:
		
			if ( m_pPlayer.pev.waterlevel >= 3 )
			{
				State = Swimming;
			}
			else if ( m_pPlayer.pev.button & IN_JUMP == IN_JUMP )
			{
				State = Jumping;
				vJumpWaypointLocation = m_pPlayer.pev.origin;
				vLastPositions = {};
			}
			else if ( m_pPlayer.IsOnLadder() )
			{
				State = OnLadder;
				// Add waypoint
				CreateWaypoint(m_pPlayer.pev.origin,AutoWaypointTypeDistance,W_FL_LADDER);
				vLastPositions = {};
			}
			else if ( m_pPlayer.pev.flags & FL_ONGROUND != FL_ONGROUND )
			{
				State = Falling;
				vFallLocation = m_pPlayer.pev.origin;
			}
			else if ( m_fRunCheckTime < g_Engine.time ) 
			{
				CheckPreviousPoints();
			}
			else if ( m_pPlayer.pev.velocity.Length() < 1 )
			{
				State = Standing;
			}

		break;
		case Standing:
			// don't do anything if standing still , even if jumping cos we won't go anywhere
			if ( m_pPlayer.pev.velocity.Length() > 1 )
			{
				State = Run;
			}
		break;
		case Falling:
			if ( m_pPlayer.pev.flags & FL_ONGROUND == FL_ONGROUND )
			{
				State = Run;
				CreateWaypoint(vFallLocation,AutoWaypointTypeDistance,0,true);
				// Add Waypoint
				CreateWaypoint(m_pPlayer.pev.origin,200.0f,0);
			}
			else if ( m_pPlayer.IsOnLadder())
			{
				State = OnLadder;
				// Add waypoint
				CreateWaypoint(m_pPlayer.pev.origin,AutoWaypointTypeDistance,W_FL_LADDER);
			}
			break;
		case Jumping:
			if ( m_pPlayer.pev.flags & FL_ONGROUND == FL_ONGROUND )
			{
				State = Run;
				CreateWaypoint(vJumpWaypointLocation,AutoWaypointTypeDistance,W_FL_JUMP,true);
				// Add Waypoint
				CreateWaypoint(m_pPlayer.pev.origin,AutoWaypointTypeDistance,0);
			}
			else if ( m_pPlayer.IsOnLadder())
			{
				State = OnLadder;
				// Add waypoint
				CreateWaypoint(m_pPlayer.pev.origin,AutoWaypointTypeDistance,W_FL_LADDER);
			}
		break;
		case OnLadder:
			if ( m_pPlayer.pev.button & IN_JUMP == IN_JUMP )
			{
				State = Jumping;
				// Add Jump waypoint
				vJumpWaypointLocation = m_pPlayer.pev.origin;
			}
			else if ( !m_pPlayer.IsOnLadder())
			{
				Vector vForward;

				g_EngineFuncs.MakeVectors(m_pPlayer.pev.v_angle);

				vForward = g_Engine.v_forward;
				// make 2D
				vForward.z = 0;
				vForward = vForward.Normalize();

				State = Run;
				// Add waypoint
				CreateWaypoint(m_pPlayer.pev.origin+(vForward*16.0f),48.0f,W_FL_LADDER);
			}
		break;

		}
	}
}
