#pragma once

#define W 800
#define H 800

extern double Xadd, Yadd, Zoom;

void keyboard( unsigned char key, int x, int y )
{
	if( key == 27 ) exit( 0 );

	glutPostRedisplay();
}

void handleSpecialKeypress( int key, int x, int y )
{
	if( key == GLUT_KEY_RIGHT ) Xadd += ( 2.0 * Zoom );
	if( key == GLUT_KEY_LEFT ) Xadd -= ( 2.0 * Zoom );
	if( key == GLUT_KEY_UP ) Yadd += ( 2.0 * Zoom );
	if( key == GLUT_KEY_DOWN ) Yadd -= ( 2.0 * Zoom );
	if( key == GLUT_KEY_PAGE_DOWN ) Zoom *= 1.2;
	if( key == GLUT_KEY_PAGE_UP ) Zoom /= 1.2;

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


