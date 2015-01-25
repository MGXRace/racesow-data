//================
// SIMPLE
//================

models/players/padporkold/padpork_torso_simple
{
	nopicmip
	cull front

	if GLSL
	{
		cellshade models/players/padporkold/padpork_torso.tga env/celldouble - - models/players/padporkold/padpork_torso_colorpass.tga - env/celllight
	}
	endif

	if ! GLSL

	//tint pass
	{
		map models/players/padporkold/padpork_torso.tga
		rgbgen identity		
	}
	{
		map models/players/padporkold/padpork_torso_colorpass.tga
		rgbGen entity
		blendFunc blend
	}

	// shadow

	//for 3d cards supporting cubemaps
	if textureCubeMap
	{
		shadecubemap env/celldouble
		rgbGen identityLighting
		blendFunc filter
		//rgbgen entity
	}
	endif
	if ! textureCubeMap //for 3d cards not supporting cubemaps
	{
		map gfx/colors/celshade.tga
		blendfunc filter
		rgbGen identityLighting
		tcGen environment
	}
	endif

	// light
	
	if textureCubeMap
	{
		shadecubemap env/celllight
		rgbGen identityLighting
		blendFunc add
	}
	endif
	
	endif
}

models/players/padporkold/padpork_legs_simple
{
	nopicmip
	cull front

	if GLSL
	{
		cellshade models/players/padporkold/padpork_legs.tga env/celldouble - - models/players/padporkold/padpork_legs_colorpass.tga - env/celllight
	}
	endif

	if ! GLSL

	//tint pass
	{
		map models/players/padporkold/padpork_legs.tga
		rgbgen identity		
	}
	{
		map models/players/padporkold/padpork_legs_colorpass.tga
		rgbgen entity
		blendFunc blend
	}

	// shadow

	//for 3d cards supporting cubemaps
	if textureCubeMap
	{
		shadecubemap env/celldouble
		rgbGen identityLighting
		blendFunc filter
		//rgbgen entity
	}
	endif

	if ! textureCubeMap //for 3d cards not supporting cubemaps
	{
		map gfx/colors/celshade.tga
		blendfunc filter
		rgbGen identityLighting
		tcGen environment
	}
	endif

	// light
	
	if textureCubeMap
	{
		shadecubemap env/celllight
		rgbGen identityLighting
		blendFunc add
	}
	endif

	endif
}

models/players/padporkold/padpork_head_simple
{
	nopicmip
	cull front

	if GLSL
	{
		cellshade models/players/padporkold/padpork_head.tga env/celldouble - - - - env/celllight
	}	
	endif

	if ! GLSL

	//tint pass
	{
		map models/players/padporkold/padpork_head.tga
		rgbgen identity
	}

	// shadow

	//for 3d cards supporting cubemaps
	if textureCubeMap
	{
		shadecubemap env/celldouble
		rgbGen identityLighting
		blendFunc filter
		//rgbgen entity
	}
	endif
	if ! textureCubeMap //for 3d cards not supporting cubemaps
	{
		map gfx/colors/celshade.tga
		blendfunc filter
		rgbGen identityLighting
		tcGen environment
	}
	endif

	// light
	
	if textureCubeMap
	{
		shadecubemap env/celllight
		rgbGen identityLighting
		blendFunc add
	}
	endif
	
	endif
}

//================
// FULLBRIGHT
//================

models/players/padporkold/padpork_torso_fb
{
	nopicmip
	cull front

	if GLSL
	{
		// <base> <cellshade> [diffuse] [decal] [entitydecal] [stripes] [celllight]
		cellshade $whiteImage env/cellbright models/players/padporkold/padpork_torso_colorpass_fb.tga - - - env/celllight
		rgbGen entity
	}
	endif

	if ! GLSL

	//tint pass
	{
		map models/players/padporkold/padpork_torso_colorpass_fb.tga
		rgbgen entity
	}

	// shadow

	//for 3d cards supporting cubemaps
	if textureCubeMap
	{
		shadecubemap env/cellbright
		rgbGen identityLighting
		blendFunc filter
		//rgbgen entity
	}
	endif
	if ! textureCubeMap //for 3d cards not supporting cubemaps
	{
		map gfx/colors/celshade.tga
		blendfunc filter
		rgbGen identityLighting
		tcGen environment
	}
	endif
	
	endif
}

models/players/padporkold/padpork_legs_fb
{
	nopicmip
	cull front

	if GLSL
	{
		// <base> <cellshade> [diffuse] [decal] [entitydecal] [stripes] [celllight]
		cellshade $whiteImage env/cellbright models/players/padporkold/padpork_legs_colorpass_fb.tga - - - env/celllight
		rgbGen entity
	}
	endif

	if ! GLSL

	//tint pass
	{
		map models/players/padporkold/padpork_legs_colorpass_fb.tga
		rgbgen entity
	}

	// shadow

	//for 3d cards supporting cubemaps
	if textureCubeMap
	{
		shadecubemap env/cellbright
		rgbGen identityLighting
		blendFunc filter
		//rgbgen entity
	}
	endif
	if ! textureCubeMap //for 3d cards not supporting cubemaps
	{
		map gfx/colors/celshade.tga
		blendfunc filter
		rgbGen identityLighting
		tcGen environment
	}
	endif
	
	endif
}

models/players/padporkold/padpork_head_fb
{
	nopicmip
	cull front

	if GLSL
	{
		// <base> <cellshade> [diffuse] [decal] [entitydecal] [stripes] [celllight]
		cellshade $whiteImage env/cellbright models/players/padporkold/padpork_head_colorpass_fb.tga - - - env/celllight
		rgbGen entity
	}
	endif

	if ! GLSL
	
	//tint pass
	{
		map models/players/padporkold/padpork_head_colorpass_fb.tga
		rgbgen entity
	}

	// shadow

	//for 3d cards supporting cubemaps
	if textureCubeMap
	{
		shadecubemap env/cellbright
		rgbGen identityLighting
		blendFunc filter
		//rgbgen entity
	}
	endif
	if ! textureCubeMap //for 3d cards not supporting cubemaps
	{
		map gfx/colors/celshade.tga
		blendfunc filter
		rgbGen identityLighting
		tcGen environment
	}
	endif
	
	endif
}

//================
// DEFAULT
//================

models/players/padporkold/padpork_torso
{
	nopicmip
	cull front

	if GLSL
	{
		material models/players/padporkold/padpork_torso.tga models/players/padporkold/padpork_torso_norm.tga - - models/players/padporkold/padpork_torso_colorpass.tga
	}
	endif

	if ! GLSL

	template models/players/padporkold/padpork_torso_simple
	
	endif
}

models/players/padporkold/padpork_legs
{
	nopicmip
	cull front

	if GLSL
	{
		material models/players/padporkold/padpork_legs.tga models/players/padporkold/padpork_legs_norm.tga - - models/players/padporkold/padpork_legs_colorpass.tga
	}
	endif

	if ! GLSL

	template models/players/padporkold/padpork_legs_simple
	
	endif
}

models/players/padporkold/padpork_head
{
	nopicmip
	cull front

	if GLSL
	{
		material models/players/padporkold/padpork_head.tga models/players/padporkold/padpork_head_norm.tga
	}
	endif

	if ! GLSL

	template models/players/padporkold/padpork_head_simple

	endif
}
