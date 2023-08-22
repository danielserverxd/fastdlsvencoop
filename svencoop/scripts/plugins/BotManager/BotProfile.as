	const uint MAX_PROFILES = 64;

	BotProfiles g_Profiles;

	final class BotProfile
	{
		string m_Name;
		int m_Skill;
		bool m_bUsed;
		string skin;

		BotProfile ( string name, int skill, string model = "gordon" )
		{
			m_Name = name;
			m_Skill = skill;
			m_bUsed = false;
			skin = model;
		}	
	}

	final class BotProfiles
	{
		array<BotProfile@> m_Profiles;
		
		BotProfiles()
		{
			readProfiles();
		}

		void readProfiles()
		{
			string botName;
			int botSensitivity;
			string botModel;

			for ( uint i = 1; i < MAX_PROFILES; i ++ )
			{
				File@ profileFile = g_FileSystem.OpenFile( "scripts/plugins/BotManager/profiles/" + i + ".ini", OpenFile::READ);
				if ( profileFile is null )
					continue;

				botName = "Unnamed";
				botSensitivity = Math.RandomLong( 1, 4 );
				botModel = "freeman";

				while ( !profileFile.EOFReached() )
				{
					string fileLine; profileFile.ReadLine( fileLine );
					if ( fileLine[0] == "#" )
						continue;

					array<string> args = fileLine.Split( "=" );
					if ( args.length() < 2 )
						continue;
					args[0].Trim(); args[1].Trim();

					if ( args[0] == "name" )
						botName = args[1];
					
					if ( args[0] == "sensitivity" )
					{
						int sensitivity = atoi(args[1]);
						if ( sensitivity != 0 )
							botSensitivity = sensitivity;
					}

					if ( args[0] == "model" )
						botModel = args[1];
				}

				profileFile.Close();

				m_Profiles.insertLast(BotProfile(botName, botSensitivity, botModel));
			}
		}

		void resetProfiles ()
		{
			for ( uint i = 0; i < m_Profiles.length(); i ++ )
			{
				m_Profiles[i].m_bUsed = false;
			}
		}

		BotProfile@ getRandomProfile ()
		{
			array<BotProfile@> UnusedProfiles;

			for ( uint i = 0; i < m_Profiles.length(); i ++ )
			{
				if ( !m_Profiles[i].m_bUsed )
				{
					UnusedProfiles.insertLast(m_Profiles[i]);
				}
			}

			if ( UnusedProfiles.length() > 0 )
			{
				return UnusedProfiles[Math.RandomLong(0, UnusedProfiles.length()-1)];
			}

			return null;
		}
	}