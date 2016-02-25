// Michael Rose
// January 13th 2016
// As of January 13th, 2016, this file compiles using 
// shader.exe from the non-commercial version of
// Renderman found in RenderManProServer-20.6
surface
ovals(
	float
		Ad = 0.025,				// width of each stripe
		Bd = 0.10,				// height of each stripe
		Amp = 0,
		Ks = 0.4,				// specular coefficient
		Kd = 0.5, 				// diffuse  coefficient
		Ka = 0.1, 				// ambient  coefficient
		Roughness = 0.1;			// specular roughness
	color	SpecularColor = color( 1, 1, 1 )	// specular color
)
{
	color PINK = color( 1., 0.0784, 0.577 );
	color PURPLE = color( 0.577, 0.44, 0.86 );
	// be sure the normal points correctly (used for lighting):

	varying vector Nf = faceforward( normalize( N ), I );
	vector V = normalize( -I );

	// determine how many squares over and up we are in right now:

	float up = 2. * u;	// because we are rendering a sphere
	float vp = v;
	float numinu = floor( up / (2*Ad) );
	float numinv = floor( vp / (2*Bd) );
	float uc = numinu * 2 * Ad + Ad;
	float vc = numinv * 2 * Bd + Bd;
	
	// use whatever opacity the rib file gave us)

	Oi = Os;

    // Noise
    point PP = point "shader" P;
	float magnitude = 0.;
	float size = 2.;
	float i;
	for( i = 0.; i < 7.0; i += 1.0 )
	{
		magnitude += ( noise(size * PP ) - 0.50 ) / size;
		size *= 2.;
	}
	
	point upvp =  point( up, vp, 0. );      // the point
	point cntr =  point( 0., 0., 0. );      // the center
	vector delta = upvp-cntr;			// vector from center to u',v'

	float oldrad = length(delta);		// result from the ellipse equation
	float newrad = oldrad+Amp*magnitude;
	delta = delta * newrad / oldrad;	//new delta, vector to diff location
	float deltau = xcomp(delta);
	float deltav = ycomp(delta);
	color TheColor = PURPLE;
	float newnuminu = floor( deltau / (2*Ad) );
	float newnuminv = floor( deltav / (2*Bd) );
	float u = newnuminu * 2 * Ad + Ad;
	float v = newnuminv * 2 * Bd + Bd;
	float d = ((deltau-u)/Ad)*((deltau-u)/Ad)+((deltav-v)/Bd)*((deltav-v)/Bd);
	//uses new delta distance to update color for original point
	if( d <= 1. )
	{
		TheColor = PINK;
	}
	// determine the lighted output color Ci:

	Ci =        TheColor * Ka * ambient();
	Ci = Ci  +  TheColor * Kd * diffuse(Nf);
	Ci = Ci  +  SpecularColor * Ks * specular( Nf, V, Roughness );
	Ci = Ci * Oi;
}
