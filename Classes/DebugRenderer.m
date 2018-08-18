//
// DebugRenderer.m
// kerchink
//
// Created by orta on 3/16/10.
// Copyright 2010 Apple Inc. All rights reserved.
//

#import "CCDrawingPrimitives.h"
#import "chipmunk.h"
#import "cocos2d.h"
#import "OpenGL_Internal.h"
#include <stdlib.h>
#include <stdio.h>
#include <math.h>

void debugDrawCircleShape(cpShape *shape) {
	cpBody *body = shape->body;
	cpCircleShape *circle = (cpCircleShape *)shape;
	cpVect c = cpvadd(body->p, cpvrotate(circle->c, body->rot));
	ccDrawCircle( cpv(c.x, c.y), circle->r, body->a, 25, true);
    // !important this number changes the quality of circles
}

void drawSegmentShape(cpShape *shape) {
	cpBody *body = shape->body;
	cpSegmentShape *seg = (cpSegmentShape *)shape;
	cpVect a = cpvadd(body->p, cpvrotate(seg->a, body->rot));
	cpVect b = cpvadd(body->p, cpvrotate(seg->b, body->rot));
	ccDrawLine( cpv(a.x, a.y), cpv(b.x, b.y) );
}

void drawPolyShape(cpShape *shape) {
	cpBody *body = shape->body;
	cpPolyShape *poly = (cpPolyShape *)shape;
	
	int num = poly->numVerts;
	cpVect *verts = poly->verts;
	
	float *vertices = malloc( sizeof(float)*2*poly->numVerts);
	if(!vertices)
		return;
	
	for(int i=0; i<num; i++){
		cpVect v = cpvadd(body->p, cpvrotate(verts[i], body->rot));
		vertices[i*2] = v.x;
		vertices[i*2+1] = v.y;
	}
	ccDrawPoly( vertices, poly->numVerts, true );
	free(vertices);
}

void drawObject(void *ptr, void *unused) {
	
	cpShape *shape = (cpShape *)ptr;
	glColor4f(1.0, 1.0, 1.0, 0.7);
    
	switch(shape->klass->type){
		case CP_CIRCLE_SHAPE:
			debugDrawCircleShape(shape);
			break;
		case CP_SEGMENT_SHAPE:
			drawSegmentShape(shape);
			break;
		case CP_POLY_SHAPE:
			drawPolyShape(shape);
			break;
		default:
			printf("Bad enumeration in drawObject().\n");
	}
}