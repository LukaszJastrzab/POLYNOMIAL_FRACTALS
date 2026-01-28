#pragma once

#define W 800
#define H 800

extern double DiffX, DiffY, MidX, MidY;

void keyboard( unsigned char key, int x, int y )
{
	if( key == 27 ) exit( 0 );

	glutPostRedisplay();
}

void handleSpecialKeypress( int key, int x, int y )
{
	const double shift{ 0.1 }, zoom{ 0.9 };

	if( key == GLUT_KEY_RIGHT ) MidX += shift * DiffX;
	if( key == GLUT_KEY_LEFT ) MidX -= shift * DiffX;
	if( key == GLUT_KEY_UP ) MidY -= shift * DiffY;
	if( key == GLUT_KEY_DOWN ) MidY += shift * DiffY;
	if( key == GLUT_KEY_PAGE_DOWN )
	{
		DiffX *= zoom;
		DiffY *= zoom;
	}
	if( key == GLUT_KEY_PAGE_UP )
	{
		DiffX /= zoom;
		DiffY /= zoom;
	}

	glutPostRedisplay();
}

void mouseMove( int x, int y )
{
	//assign x and y to some global
	glutPostRedisplay();
}

void mouseDrag( int x, int y )
{
	//assign x and y to some global
	glutPostRedisplay();
}

void printInstructions()
{

}


