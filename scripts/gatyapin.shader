//================
// SIMPLE
//================

models/players/gatyapin/gatyapin_body_simple
{
	nopicmip
	cull front

	if GLSL
	{
		cellshade models/players/gatyapin/gatyapin_body.tga env/celldouble - - models/players/gatyapin/gatyapin_body_colorpass.tga - env/celllight
	}
	endif

	if ! GLSL

	//tint pass
	{
		map models/players/gatyapin/gatyapin_body.tga
		rgbgen identity		
	}
	{
		map models/players/gatyapin/gatyapin_body_colorpass.tga
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

//================
// Rider Glass
//================

models/players/gatyapinR/gatyapin_glass
{
	nopicmip
	cull front
	{
		map models/players/gatyapinR/gatyapin_glass.tga
		blendFunc GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA
		alphaFunc GE128
		rgbGen identity
		depthWrite
	}

	// shadow

	//for 3d cards supporting cubemaps
	if textureCubeMap
	{
		shadecubemap env/cell
		rgbGen identity
		blendFunc filter
		//rgbgen entity
	}
	endif
	if ! textureCubeMap //for 3d cards not supporting cubemaps
	{
		map gfx/colors/celshade.tga
		blendfunc filter
		rgbGen identity
		tcGen environment
	}
	endif

}

//================
// FULLBRIGHT
//================

models/players/gatyapin/gatyapin_body_fb
{
	nopicmip
	cull front

	if GLSL
	{
		// <base> <cellshade> [diffuse] [decal] [entitydecal] [stripes] [celllight]
		cellshade $whiteImage env/cellbright models/players/gatyapin/gatyapin_body_colorpass_fb.tga - - - env/celllight
		rgbGen entity
	}
	endif

	if ! GLSL

	//tint pass
	{
		map models/players/gatyapin/gatyapin_body_colorpass_fb.tga
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

models/players/gatyapin/gatyapin_body
{
	nopicmip
	cull front

	if GLSL
	{
		material models/players/gatyapin/gatyapin_body.tga models/players/gatyapin/gatyapin_body_normal.tga - - models/players/gatyapin/gatyapin_body_colorpass.tga
	}
	endif

	if ! GLSL

	template models/players/gatyapin/gatyapin_body_simple
	
	endif
}
