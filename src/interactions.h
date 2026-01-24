#pragma once

#define W 600
#define H 600

void keyboard( unsigned char key, int x, int y )
{
	if( key == 27 ) exit( 0 );

	glutPostRedisplay();
}

void handleSpecialKeypress( int key, int x, int y )
{
	if( key == GLUT_KEY_LEFT ) return;

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


