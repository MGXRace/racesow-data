/*
Copyright (C) 2011 Cervesato Andrea ("koochi")

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

*/

/*
	This class provides to manage some cvars into the 
	Graphics section.
 */

class VideoSetup
{
	// use to recognize changes and inhibit vid_restart cmd
	bool allowVidRestart;
	
	// video profile
	Cvar ui_video_profile( "ui_video_profile", "medium", CVAR_ARCHIVE );
	
	// video mode
	Cvar vid_mode( "vid_mode", "-2", 0 );
	
	// quality of textures
	Cvar r_picmip( "r_picmip", "0", 0 );
	
	// filtering
	Cvar r_texturefilter( "r_texturefilter", "4", 0 ); // 0==1, 2, 4, .. values
	Cvar gl_ext_texture_filter_anisotropic_max( "gl_ext_texture_filter_anisotropic_max", "8", 0 );		
	
	// lighting
	Cvar r_lighting_vertexlight( "r_lighting_vertexlight", "0", 0 );
	Cvar r_lighting_deluxemapping( "r_lighting_deluxemapping", "1", 0 );
	Cvar ui_lighting( "ui_lighting", "2", 0 ); // used to store index of selector
	
	// shadows
	Cvar cg_shadows( "cg_shadows", "1", CVAR_ARCHIVE );
	
	// ids
	String idProfile;
	String idPicmip;
	String idFiltering;
	String idLighting;
	String idShadows;

	VideoSetup( Element @elem, 
				const String &idProfile, const String &idPicmip, 
				const String &idFiltering, const String &idLighting, 
				const String &idShadows )
	{
		this.idProfile = idProfile;
		this.idPicmip = idPicmip;
		this.idFiltering = idFiltering;
		this.idLighting = idLighting;
		this.idShadows = idShadows;

		// We only have 3 choices in lightning listbox:
		// vertex lighting: lighting_vertexlight = 1, lighting_deluxemapping = 0
		// lightmaps: lighting_vertexlight = 0, lighting_deluxemapping = 0
		// per-pixel lighting: lighting_vertexlight = 0, lighting_deluxemapping = 1
		// since the variant lighting_vertexlight = 1, lighting_deluxemapping = 1 is
		// equivalent to vertex lighting.
		if( r_lighting_vertexlight.value == 1 )
			ui_lighting.set( 0 );
		else if( r_lighting_deluxemapping.value == 1 )
			ui_lighting.set( 2 );
		else
			ui_lighting.set( 1 );

		Initialize( @elem );
	}
	
	~VideoSetup()
	{
	}
	
	void Initialize( Element @elem )
	{
		PopulateFilteringSelector( @elem );
		
		// reset elements
		SelectGraphicsProfile( @elem, true );
		Reset( @elem );
	}
	
	void PopulateFilteringSelector( Element @elem )
	{
		Element @selector = elem.getElementById( idFiltering );
		
		if( @selector == null )
			return;
			
		int max = gl_ext_texture_filter_anisotropic_max.integer;

		String rml = '';	
		for( int i = 1; i <= max; i*=2 )
			rml += '<option value="'+i+'">x'+i+'</option>';
			
		selector.setInnerRML( rml );
	}
	
	void SelectGraphicsProfile( Element @elem, bool reset )
	{
		ElementFormControl @profile = elem.getElementById( idProfile );
		
		if( @profile == null )
			return;
		
		String gfx;
		
		if( reset )
		{
			gfx = ui_video_profile.string;
			profile.value = gfx;
		}
		else
		{
			gfx = profile.value;
			game.execAppend( "exec profiles/" + gfx + "\n" );
			ui_video_profile.set( gfx );

			allowVidRestart = false;
		}
	}	
	
	void SetPicmip( Element @elem, bool reset )
	{
		Element @picmip_el = elem.getElementById( idPicmip );	
		ElementFormControl @picmip = @picmip_el;

		if( @picmip == null )
			return;

		int maxvalue = picmip_el.getAttr( "max", "0" ).toInt();

		if( reset )
		{
			picmip.value = String( maxvalue - r_picmip.integer );
		}
		else
		{
			r_picmip.set( maxvalue - picmip.value.toInt() );
			Changed();		
		}
	}
	
	void SetFiltering( Element @elem, bool reset )
	{
		ElementFormControl @filter = elem.getElementById( idFiltering );
		
		if( @filter == null )
			return;
	
		if( reset )
		{
			filter.value = String( r_texturefilter.integer );
		}
		else
		{
			r_texturefilter.set( filter.value.toInt() );
			Changed();		
		}		
	}

	void SetLighting( Element @elem, bool reset )
	{
		ElementFormControl @slideLighting = elem.getElementById( idLighting );

		if( @slideLighting == null )
			return;

		if( reset )
		{
			slideLighting.value = ui_lighting.string;
		}
		else
		{
			int value = slideLighting.value.toInt();
			
			switch( value )
			{
				case 0:
					r_lighting_vertexlight.set("1");
					r_lighting_deluxemapping.set("0");
					break;
				case 1:
					r_lighting_vertexlight.set("0");
					r_lighting_deluxemapping.set("0");
					break;
				default: // 2
					r_lighting_vertexlight.set("0");
					r_lighting_deluxemapping.set("1");
					break;
			}
			
			ui_lighting.set( value );
			Changed();
		}
	}

	void SetShadows( Element @elem, bool reset )
	{
		ElementFormControl @slideShadows = elem.getElementById( idShadows );

		if( @slideShadows == null )
			return;

		if( reset )
		{
			slideShadows.value = cg_shadows.string;
		}
		else
		{
			cg_shadows.set( slideShadows.value );
			Changed();
		}
	}

	void Changed( void )
	{
		allowVidRestart = true;
	}
	
	void Reset( Element @elem )
	{
		SetPicmip( @elem, true );
		SetFiltering( @elem, true );
		SetLighting( @elem, true );
		SetShadows( @elem, true );
		
		// cvars are not changed
		allowVidRestart = false;
	}
	
	void Apply( Element @elem )
	{
		// apply changes if something changed
		if( allowVidRestart )
		{
			SetPicmip( @elem, false );
			SetFiltering( @elem, false );
			SetLighting( @elem, false );
			SetShadows( @elem, false );
			
			game.execAppend ( "vid_restart\n" );
		}
	}
}
