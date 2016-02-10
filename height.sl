// Michael Rose
// January 13th 2016
// As of January 13th, 2016, this file compiles using 
// shader.exe from the non-commercial version of
// Renderman found in RenderManProServer-20.6
displacement
height(
	float
		Ad = 0.025,				// width of each stripe
		Bd = 0.10,				// height of each stripe
		Amp = 0,
		Height = .1;
)
{
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
	delta = delta * newrad / oldrad;

	float deltau = xcomp(delta);
	float deltav = ycomp(delta);
	float TheHeight = 0.;
	float newnuminu = floor( deltau / (2*Ad) );
	float newnuminv = floor( deltav / (2*Bd) );
	float u = newnuminu * 2 * Ad + Ad;
	float v = newnuminv * 2 * Bd + Bd;
	float d = ((deltau-u)/Ad)*((deltau-u)/Ad)+((deltav-v)/Bd)*((deltav-v)/Bd);
	if(d <= 1.)
		TheHeight = (1.-d)*Height;			   // apply the blending
#define DISPLACEMENT_MAPPING

	
	if( TheHeight != 0. )
	{
#ifdef DISPLACEMENT_MAPPING
		P = P + normalize(N) * TheHeight;
		N = calculatenormal(P);
#else
		N = calculatenormal( P + normalize(N) * TheHeight );
#endif
	}
}
